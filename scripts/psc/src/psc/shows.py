"""Parses show YAML files into Show / Layer objects."""

from dataclasses import dataclass, field
from pathlib import Path

from .errors import ErrorCollector, PscError
from .hwmap import HardwareMap
from .values import (GRID_MS, Tempo, check_keys, expect_mapping, parse_color, parse_int,
                     parse_name, parse_number, parse_time)
from .yamlio import load_yaml

TIME, INT, NUMBER, TEXT, MAPPING = "time", "int", "number", "text", "mapping"

COMMON = {"target", "each", "pattern", "start", "color", "brightness", "priority"}

# pattern -> {param: (kind, default)}; a default of REQUIRED means required.
REQUIRED = object()
PATTERNS = {
    "solid": {"duration": (TIME, None), "fade": (TIME, 0), "tail": (TIME, 0)},
    "flash": {"count": (INT, 1), "on": (TIME, REQUIRED), "off": (TIME, None), "fade": (TIME, 0)},
    "chase": {"interval": (TIME, REQUIRED), "order": (TEXT, "listed"), "width": (INT, 1),
              "tail": (TIME, 0), "fade": (TIME, 0), "count": (INT, 1)},
    "sweep": {"direction": (TEXT, REQUIRED), "anchor": (TEXT, None), "speed": (NUMBER, REQUIRED),
              "width": (NUMBER, 100), "tail": (TIME, 0), "fade": (TIME, 0), "count": (INT, 1),
              "gap": (TIME, 0)},
    "breathe": {"period": (TIME, REQUIRED), "min": (NUMBER, 0), "max": (NUMBER, None),
                "cycles": (INT, 1)},
    # tracks: {target: "x...x..."}, one character per tempo step
    # plays another PSC show's timeline, inlined at compile time
    "show": {"show": (TEXT, REQUIRED), "count": (INT, 1)},
    "beat": {"tracks": (MAPPING, REQUIRED), "accents": (MAPPING, None), "attack": (TIME, 0),
             "hold": (TIME, 0), "decay": (TIME, 0), "count": (INT, 1)},
}

REST_CHARS = set(".-_")
IGNORE_CHARS = set("| \t")
DEFAULT_ACCENTS = {"x": 100.0, "X": 100.0}


@dataclass
class BeatTrack:
    targets: list[str]
    hits: list[tuple[int, float]]  # (step index, peak brightness)
    steps: int                     # pattern length in steps


def parse_beat_pattern(text: str, accents: dict[str, float], where: str) -> tuple[list[tuple[int, float]], int]:
    """Drum-tab notation: one character per step. '.', '-' and '_' rest;
    '|' and whitespace are visual only; '#' starts a comment; extra lines
    continue the pattern (one bar per line reads well)."""
    steps = []
    for line in text.splitlines():
        steps.extend(ch for ch in line.split("#", 1)[0] if ch not in IGNORE_CHARS)
    hits = []
    for i, ch in enumerate(steps):
        if ch in REST_CHARS:
            continue
        if ch not in accents:
            raise PscError(f"{where}: unknown symbol {ch!r}; rests are . - _ and hits are {', '.join(sorted(accents))}")
        hits.append((i, accents[ch]))
    if not steps:
        raise PscError(f"{where}: pattern is empty")
    return hits, len(steps)


@dataclass
class Layer:
    index: int
    where: str
    pattern: str
    targets: list[str]
    start: float
    color: str | None
    brightness: float
    priority: int
    params: dict = field(default_factory=dict)
    start_after: bool = False  # `start: after` = when the layer above ends
    # `each:` runs the pattern once per (entry name, target list); `target:`
    # is one list. `targets` is the union, in order.
    target_sets: list[tuple[str, list[str]]] = field(default_factory=list)


@dataclass
class Show:
    name: str
    path: Path
    length: float | None
    layers: list[Layer]
    resolution: int = 10
    tempo: Tempo | None = None


def _parse_param(kind, value, where, tempo):
    if kind == TIME:
        return parse_time(value, where, tempo)
    if kind == MAPPING:
        if not isinstance(value, dict) or not value:
            raise PscError(f"{where}: expected a mapping")
        return value
    if kind == INT:
        return parse_int(value, where, minimum=0)
    if kind == NUMBER:
        return parse_number(value, where)
    if not isinstance(value, str):
        raise PscError(f"{where}: expected text, got {value!r}")
    return value.strip()


def parse_layer(raw, index: int, show_where: str, hw: HardwareMap, tempo: Tempo | None = None) -> Layer:
    where = f"{show_where}: layer {index + 1}"
    raw = expect_mapping(raw, where)
    pattern = raw.get("pattern")
    if pattern not in PATTERNS:
        raise PscError(f"{where}: pattern must be one of {', '.join(PATTERNS)}, got {pattern!r}")
    where = f"{where} ({pattern})"
    schema = PATTERNS[pattern]
    check_keys(raw, COMMON | set(schema), where)
    if pattern == "beat":
        extra = [k for k in ("target", "each") if k in raw]
        if extra:
            raise PscError(f"{where}: a beat layer takes tracks: instead of {', '.join(extra)}:")
    elif pattern == "show":
        extra = [k for k in ("target", "each", "color", "brightness") if k in raw]
        if extra:
            raise PscError(f"{where}: a show layer can't take {', '.join(extra)}; it plays the other show as written")
    elif "target" in raw and "each" in raw:
        raise PscError(f"{where}: use target: or each:, not both")
    elif "target" not in raw and "each" not in raw:
        raise PscError(f"{where}: target is required")
    if "each" in raw:
        target_sets = hw.resolve_each(raw["each"], f"{where}: each")
    elif "target" in raw:
        target_sets = [("", hw.resolve_target(raw["target"], where))]
    else:
        target_sets = []
    targets: list[str] = []
    for _, names in target_sets:
        targets += [n for n in names if n not in targets]
    layer = Layer(
        index=index,
        where=where,
        pattern=pattern,
        targets=targets,
        target_sets=target_sets,
        start=parse_time(raw["start"], f"{where}: start", tempo) if raw.get("start", "after") != "after" else 0.0,
        start_after=raw.get("start") == "after",
        color=parse_color(raw["color"], f"{where}: color") if "color" in raw else None,
        brightness=parse_number(raw["brightness"], f"{where}: brightness", 0, 100) if "brightness" in raw else 100.0,
        priority=parse_int(raw["priority"], f"{where}: priority", minimum=0) if "priority" in raw else index,
    )
    for key, (kind, default) in schema.items():
        if key in raw:
            layer.params[key] = _parse_param(kind, raw[key], f"{where}: {key}", tempo)
        elif default is REQUIRED:
            raise PscError(f"{where}: {key} is required")
        else:
            layer.params[key] = default
    if pattern == "beat":
        _finish_beat(layer, hw, tempo)
    return layer


def _finish_beat(layer: Layer, hw: HardwareMap, tempo: Tempo | None):
    where = layer.where
    if tempo is None:
        raise PscError(f"{where}: a beat layer needs a tempo: on the show")
    accents = dict(DEFAULT_ACCENTS)
    if layer.params["accents"] is not None:
        accents = {}
        for symbol, value in layer.params["accents"].items():
            if len(symbol) != 1 or symbol in REST_CHARS | IGNORE_CHARS | {"#"}:
                raise PscError(f"{where}: accent {symbol!r} must be a single non-rest character")
            accents[symbol] = parse_number(value, f"{where}: accents.{symbol}", 0, 100)
    tracks = []
    for target, text in layer.params["tracks"].items():
        tw = f"{where}: tracks.{target}"
        if not isinstance(text, str):
            raise PscError(f"{tw}: expected a pattern string like \"x...x...\"")
        hits, steps = parse_beat_pattern(text, accents, tw)
        targets = hw.resolve_target(target, tw)
        tracks.append(BeatTrack(targets, hits, steps))
        layer.targets += [t for t in targets if t not in layer.targets]
    layer.params["tracks"] = tracks
    layer.params["step_ms"] = tempo.step_ms


def parse_show(path: Path, hw: HardwareMap) -> Show:
    raw = expect_mapping(load_yaml(path), str(path))
    where = path.name
    check_keys(raw, {"show", "tempo", "length", "resolution", "layers"}, where)
    tempo = None
    if "tempo" in raw:
        tw = f"{where}: tempo"
        spec = expect_mapping(raw["tempo"], tw)
        check_keys(spec, {"bpm", "steps_per_beat", "beats_per_bar"}, tw)
        if "bpm" not in spec:
            raise PscError(f"{tw}: bpm is required")
        tempo = Tempo(
            bpm=parse_number(spec["bpm"], f"{tw}.bpm", minimum=1),
            steps_per_beat=parse_int(spec.get("steps_per_beat", "4"), f"{tw}.steps_per_beat", minimum=1),
            beats_per_bar=parse_int(spec.get("beats_per_bar", "4"), f"{tw}.beats_per_bar", minimum=1),
        )
    name = parse_name(raw.get("show"), f"{where}: show")
    if name != path.stem:
        raise PscError(f"{where}: show name {name!r} must match the file name {path.stem!r}")
    length = parse_time(raw["length"], f"{where}: length", tempo) if "length" in raw else None
    resolution = GRID_MS
    if "resolution" in raw:
        resolution = int(parse_time(raw["resolution"], f"{where}: resolution"))
        if resolution < GRID_MS or resolution % GRID_MS:
            raise PscError(f"{where}: resolution must be a multiple of {GRID_MS}ms")
    layers_raw = raw.get("layers")
    if not isinstance(layers_raw, list) or not layers_raw:
        raise PscError(f"{where}: layers must be a non-empty list")
    errors = ErrorCollector()
    layers = []
    for i, layer_raw in enumerate(layers_raw):
        try:
            layers.append(parse_layer(layer_raw, i, where, hw, tempo))
        except PscError as e:
            errors.extend(e)
    errors.raise_if_any()
    if layers[0].start_after:
        raise PscError(f"{where}: layer 1 can't start after a previous layer")
    return Show(name=name, path=path, length=length, layers=layers, resolution=resolution, tempo=tempo)
