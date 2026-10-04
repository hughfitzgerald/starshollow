"""Loads hardware.yaml, the single source of truth for groups, colors,
anchors and backglass bulbs."""

import os
from dataclasses import dataclass, field
from pathlib import Path

from .errors import ErrorCollector, PscError
from .values import (check_keys, expect_mapping, parse_color, parse_int,
                     parse_name, parse_number, parse_point)
from .yamlio import load_yaml

CONFIG_SEARCH = [Path("scripts/src/psc/hardware.yaml"), Path("src/psc/hardware.yaml")]

DEFAULT_PATHS = {
    "table": "../../../starshollow",
    "shows": "shows",
    "output": "../game/shows/psc_shows.vbs",
    "script_src": "..",
}


@dataclass
class Group:
    name: str
    members: list[str]
    color: str | None = None
    exclude: list[str] = field(default_factory=list)


@dataclass
class Bulb:
    name: str
    b2s_id: int
    color: str | None = None
    position: tuple[float, float] | None = None
    threshold: int = 0


@dataclass
class Config:
    path: Path
    table_dir: Path
    shows_dir: Path
    output_file: Path
    script_src: Path | None
    directb2s: Path | None
    collection: str = "glf_lights"
    anchors: dict[str, tuple[float, float]] = field(default_factory=dict)
    light_colors: dict[str, str] = field(default_factory=dict)
    groups: dict[str, Group] = field(default_factory=dict)
    bulbs: dict[str, Bulb] = field(default_factory=dict)
    proxy_template: str | None = None
    backglass_image: str | None = None  # for the editor: a table image name or a file


def find_config(explicit: str | None) -> Path:
    if explicit:
        return Path(explicit).resolve()
    env = os.environ.get("PSC_CONFIG")
    if env:
        return Path(env).resolve()
    here = Path.cwd().resolve()
    for directory in [here, *here.parents]:
        for candidate in CONFIG_SEARCH:
            if (directory / candidate).is_file():
                return directory / candidate
    raise PscError("could not find hardware.yaml; pass --config or set PSC_CONFIG")


def load_config(path: Path) -> Config:
    raw = expect_mapping(load_yaml(path), str(path))
    where = path.name
    check_keys(raw, {"paths", "anchors", "lights", "groups", "backglass"}, where)
    errors = ErrorCollector()
    base = path.parent

    paths = dict(DEFAULT_PATHS)
    paths_raw = expect_mapping(raw.get("paths"), f"{where}: paths")
    check_keys(paths_raw, {"table", "shows", "output", "script_src", "collection"}, f"{where}: paths")
    paths.update(paths_raw)

    cfg = Config(
        path=path,
        table_dir=(base / paths["table"]).resolve(),
        shows_dir=(base / paths["shows"]).resolve(),
        output_file=(base / paths["output"]).resolve(),
        script_src=(base / paths["script_src"]).resolve() if paths.get("script_src") else None,
        directb2s=None,
        collection=paths.get("collection", "glf_lights"),
    )

    for name, point in expect_mapping(raw.get("anchors"), f"{where}: anchors").items():
        try:
            cfg.anchors[parse_name(name, f"{where}: anchors")] = parse_point(point, f"{where}: anchors.{name}")
        except PscError as e:
            errors.extend(e)

    for name, spec in expect_mapping(raw.get("lights"), f"{where}: lights").items():
        lw = f"{where}: lights.{name}"
        try:
            if isinstance(spec, str):  # shorthand: `l12: ff2020`
                spec = {"color": spec}
            spec = expect_mapping(spec, lw)
            check_keys(spec, {"color"}, lw)
            if "color" in spec:
                cfg.light_colors[name.lower()] = parse_color(spec["color"], lw)
        except PscError as e:
            errors.extend(e)

    for name, spec in expect_mapping(raw.get("groups"), f"{where}: groups").items():
        gw = f"{where}: groups.{name}"
        try:
            parse_name(name, f"{where}: groups")
            if isinstance(spec, list):
                spec = {"members": spec}
            spec = expect_mapping(spec, gw)
            check_keys(spec, {"members", "exclude", "color"}, gw)
            lists = {}
            for key in ("members", "exclude"):
                value = spec.get(key, [])
                if not isinstance(value, list) or not all(isinstance(m, str) for m in value):
                    raise PscError(f"{gw}: {key} must be a list of names")
                lists[key] = value
            color = parse_color(spec["color"], gw) if "color" in spec else None
            cfg.groups[name] = Group(name, lists["members"], color, lists["exclude"])
        except PscError as e:
            errors.extend(e)

    backglass = expect_mapping(raw.get("backglass"), f"{where}: backglass")
    check_keys(backglass, {"source", "template", "image", "bulbs"}, f"{where}: backglass")
    if backglass.get("source"):
        cfg.directb2s = (base / backglass["source"]).resolve()
    if backglass.get("image"):
        cfg.backglass_image = str(backglass["image"])
    if backglass.get("template"):
        cfg.proxy_template = backglass["template"]
    seen_ids = {}
    for name, spec in expect_mapping(backglass.get("bulbs"), f"{where}: backglass.bulbs").items():
        bw = f"{where}: backglass.bulbs.{name}"
        try:
            parse_name(name, f"{where}: backglass.bulbs")
            spec = expect_mapping(spec, bw)
            check_keys(spec, {"b2s_id", "color", "position", "threshold"}, bw)
            if "b2s_id" not in spec:
                raise PscError(f"{bw}: b2s_id is required")
            bulb = Bulb(
                name=name,
                b2s_id=parse_int(spec["b2s_id"], bw, minimum=1),
                color=parse_color(spec["color"], bw) if "color" in spec else None,
                position=parse_point(spec["position"], bw) if "position" in spec else None,
                threshold=parse_int(spec["threshold"], bw, 0, 254) if "threshold" in spec else 0,
            )
            if bulb.b2s_id in seen_ids:
                raise PscError(f"{bw}: b2s_id {bulb.b2s_id} is already used by {seen_ids[bulb.b2s_id]}")
            seen_ids[bulb.b2s_id] = name
            cfg.bulbs[name] = bulb
        except PscError as e:
            errors.extend(e)

    errors.raise_if_any()
    return cfg
