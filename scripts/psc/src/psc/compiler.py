"""Ties it together: hardware map + show files -> psc_shows.vbs."""

import dataclasses
import math
import os
import re
from dataclasses import dataclass
from pathlib import Path

from .config import Config
from .emit import emit_file, emit_show
from .errors import ErrorCollector, PscError
from .flatten import STOP, Emission, LayerTrack, flatten_light
from .hwmap import HardwareMap, build_map
from .patterns import Keyframe, expand_layer
from .render import render
from .shows import Show, parse_show
from .sync import plan_sync
from .table import Table
from .values import GRID_MS, quantize

DEFAULT_EMPTY_LENGTH = 1000
SHOW_NAME_RE = re.compile(r'CreateGlfShow\(\s*"([^"]+)"\s*\)')


@dataclass
class CompiledShow:
    name: str
    vbs: str
    steps: int
    length: int
    lights: int


def show_timeline(show: Show, hw: HardwareMap, shows: dict[str, Show], stack: tuple = ()) -> tuple[dict[str, list[Emission]], int]:
    """Flattened (not yet fade-rendered) emissions per light, and the show length."""
    if show.name.lower() in stack:
        chain = " -> ".join([*stack, show.name.lower()])
        raise PscError(f"{show.path.name}: shows include each other in a loop: {chain}")
    stack = (*stack, show.name.lower())

    per_light: dict[str, list[LayerTrack]] = {}
    raw_frames: dict[str, list] = {}
    content = 0
    previous_end = 0
    for layer in show.layers:
        if layer.start_after:
            layer = dataclasses.replace(layer, start=previous_end, start_after=False)
        if layer.pattern == "show":
            frames_by_light, end = expand_show_layer(layer, show, hw, shows, stack)
        else:
            frames_by_light, end = expand_layer(layer, hw, show.resolution)
        content = max(content, end)
        previous_end = end
        for light, frames in frames_by_light.items():
            per_light.setdefault(light, []).append(LayerTrack((layer.priority, layer.index), frames))
            raw_frames.setdefault(light, []).append(frames)

    if show.length is not None:
        length = int(math.ceil(show.length / GRID_MS)) * GRID_MS
        latest = max((kf.t for layers in raw_frames.values() for fr in layers for kf in fr), default=0)
        if latest > length:
            raise PscError(f"{show.path.name}: length {length}ms is shorter than the show's content ({latest}ms)")
    elif show.tempo is not None:
        # musical shows loop on whole bars
        # (content may overshoot a bar line by up to one grid step of rounding)
        bars = max(1, math.ceil((content - show.resolution) / show.tempo.bar_ms))
        length = int(math.ceil(bars * show.tempo.bar_ms / GRID_MS)) * GRID_MS
    else:
        length = content
    if length <= 0:
        length = DEFAULT_EMPTY_LENGTH

    return {light: flatten_light(tracks, length) for light, tracks in per_light.items()}, length


def expand_show_layer(layer, parent: Show, hw: HardwareMap, shows: dict[str, Show], stack: tuple):
    """Inline another show: its flattened timeline becomes this layer's
    keyframes, repeated `count` times back to back."""
    name = layer.params["show"]
    child = shows.get(name.lower())
    if child is None:
        raise PscError(f"{layer.where}: unknown show {name!r} (only PSC shows can be included)")
    if layer.params["count"] < 1:
        raise PscError(f"{layer.where}: count must be at least 1")
    emissions, child_length = show_timeline(child, hw, shows, stack)
    grid = parent.resolution
    frames: dict[str, list[Keyframe]] = {}
    seq = 0
    for i in range(layer.params["count"]):
        offset = layer.start + i * child_length
        for light, events in emissions.items():
            out = frames.setdefault(light, [])

            def add(t, value, fade):
                nonlocal seq
                seq += 1
                out.append(Keyframe(quantize(t + offset, grid), value, quantize(fade, grid), seq))

            skip_stop_at = None
            for k, e in enumerate(events):
                if e.out is STOP:
                    if e.t != skip_stop_at:
                        add(e.t, None, 0)
                    continue
                nxt = events[k + 1] if k + 1 < len(events) else None
                ends_in_stop = nxt is not None and nxt.out is STOP and nxt.t == e.t + e.fade
                ends_with_show = nxt is None and e.t + e.fade >= child_length  # stop dropped at show end
                if e.out.brightness <= 0 and e.fade > 0 and (ends_in_stop or ends_with_show):
                    # "fade to black, then stop" is how a tail with nothing
                    # beneath compiles; here it becomes a fade to whatever is
                    # beneath this layer
                    add(e.t, None, e.fade)
                    skip_stop_at = nxt.t if ends_in_stop else None
                    continue
                add(e.t, e.out, e.fade)
            # the included show is over: let go of its lights, as GLF does when
            # a show ends (the next repetition's t=0 frames take over)
            add(child_length, None, 0)
    return frames, quantize(layer.start + layer.params["count"] * child_length, grid)


def compile_show(show: Show, hw: HardwareMap, shows: dict[str, Show] | None = None) -> CompiledShow:
    flattened, length = show_timeline(show, hw, shows or {show.name.lower(): show})
    emissions = render(flattened, length, show.resolution)
    order = [n for n in hw.order if n in emissions]
    vbs = emit_show(show.name, length, emissions, order)
    steps = len({e.t for es in emissions.values() for e in es})
    return CompiledShow(show.name, vbs, steps, length, len(emissions))


def existing_show_names(cfg: Config) -> dict[str, Path]:
    names: dict[str, Path] = {}
    if cfg.script_src is None or not cfg.script_src.is_dir():
        return names
    for path in sorted(cfg.script_src.rglob("*.vbs")):
        if path.resolve() == cfg.output_file:
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for name in SHOW_NAME_RE.findall(text):
            names.setdefault(name.lower(), path)
    return names


def check_sync(cfg: Config, table: Table):
    pending = plan_sync(cfg, table)
    if pending:
        lines = [f"the table JSON is out of date with {cfg.path.name} ({len(pending)} change(s)); run `psc sync`:"]
        lines += [f"  {c.describe()}" for c in pending[:20]]
        if len(pending) > 20:
            lines.append(f"  ... and {len(pending) - 20} more")
        raise PscError(lines)


def compile_all(cfg: Config) -> tuple[list[CompiledShow], bool]:
    table = Table(cfg.table_dir)
    check_sync(cfg, table)
    hw = build_map(cfg, table)
    files = sorted([*cfg.shows_dir.glob("*.yaml"), *cfg.shows_dir.glob("*.yml")]) if cfg.shows_dir.is_dir() else []
    errors = ErrorCollector()
    existing = existing_show_names(cfg)
    shows: dict[str, Show] = {}
    for path in files:
        try:
            show = parse_show(path, hw)
            key = show.name.lower()
            if key in shows:
                raise PscError(f"{path.name}: show {show.name!r} is also defined in {shows[key].path.name}")
            if key in existing:
                raise PscError(f"{path.name}: show {show.name!r} already exists in {existing[key]}")
            shows[key] = show
        except PscError as e:
            errors.extend(e)
    errors.raise_if_any()
    compiled: list[CompiledShow] = []
    for show in shows.values():
        try:
            compiled.append(compile_show(show, hw, shows))
        except PscError as e:
            errors.extend(e)
    errors.raise_if_any()

    sources = os.path.relpath(cfg.shows_dir, cfg.output_file.parent)
    text = emit_file([c.vbs for c in compiled], hw, sources)
    old = cfg.output_file.read_text(encoding="utf-8") if cfg.output_file.is_file() else None
    changed = old != text
    if changed:
        cfg.output_file.parent.mkdir(parents=True, exist_ok=True)
        cfg.output_file.write_text(text, encoding="utf-8")
    return compiled, changed
