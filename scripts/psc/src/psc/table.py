"""Reads (and carefully writes) the vpxtool extraction of the table."""

import json
import re
from dataclasses import dataclass
from pathlib import Path

from .errors import PscError


@dataclass
class LightRecord:
    name: str
    path: Path
    x: float
    y: float
    color: str
    blink_pattern: str
    visible: bool


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise PscError(f"{path}: file not found") from None
    except json.JSONDecodeError as e:
        raise PscError(f"{path}: invalid JSON: {e}") from None


def dump_json(data) -> str:
    """vpxtool's format: 2-space indent, non-ASCII kept, no trailing newline."""
    return json.dumps(data, indent=2, ensure_ascii=False)


def rewrite_json(path: Path, mutate):
    """Apply `mutate(data)` and write back. Refuses to touch a file whose
    formatting would not survive a round trip, so diffs stay minimal."""
    raw = path.read_text(encoding="utf-8")
    data = json.loads(raw)
    trailing = raw[len(raw.rstrip("\n")):]
    if dump_json(data) != raw.rstrip("\n"):
        raise PscError(f"{path}: formatting is not vpxtool's standard; refusing to rewrite it")
    mutate(data)
    path.write_text(dump_json(data) + trailing, encoding="utf-8")


BLINK_RE = re.compile(r'("blink_pattern":\s*)"(?:[^"\\]|\\.)*"')


def set_blink_pattern(path: Path, value: str):
    raw = path.read_text(encoding="utf-8")
    new, count = BLINK_RE.subn(lambda m: m.group(1) + json.dumps(value, ensure_ascii=False), raw, count=1)
    if count != 1:
        raise PscError(f"{path}: no blink_pattern field found")
    path.write_text(new, encoding="utf-8")


class Table:
    def __init__(self, directory: Path):
        self.dir = directory
        if not (directory / "gameitems").is_dir():
            raise PscError(f"{directory}: not a vpxtool extraction (no gameitems folder)")
        self.lights: dict[str, LightRecord] = {}
        for path in sorted((directory / "gameitems").glob("Light.*.json")):
            light = read_json(path)["Light"]
            center = light.get("center", {})
            self.lights[light["name"].lower()] = LightRecord(
                name=light["name"],
                path=path,
                x=float(center.get("x", 0.0)),
                y=float(center.get("y", 0.0)),
                color=str(light.get("color", "#ffffff")).lstrip("#").lower(),
                blink_pattern=light.get("blink_pattern", ""),
                visible=bool(light.get("visible", True)),
            )
        self.collections_path = directory / "collections.json"
        self.gameitems_path = directory / "gameitems.json"
        self.collections = read_json(self.collections_path)
        gamedata = read_json(directory / "gamedata.json")
        self.left = float(gamedata.get("left", 0.0))
        self.top = float(gamedata.get("top", 0.0))
        self.right = float(gamedata.get("right", 952.0))
        self.bottom = float(gamedata.get("bottom", 2162.0))

    def light(self, name: str) -> LightRecord | None:
        return self.lights.get(name.lower())

    def collection_items(self, name: str) -> list[str] | None:
        for collection in self.collections:
            if collection.get("name", "").lower() == name.lower():
                return list(collection.get("items", []))
        return None


def tags_of(blink_pattern: str) -> list[str]:
    return [t.strip() for t in blink_pattern.split(",") if t.strip()]
