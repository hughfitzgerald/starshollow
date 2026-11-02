"""Reads (and carefully writes) the table pack folder vpinball plays and saves."""

import json
import re
import struct
from dataclasses import dataclass
from decimal import Decimal
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


class Number(float):
    """A float that remembers how vpinball wrote it. vpinball doesn't print the
    shortest round-trip form Python does (518.7351684570313, not ...312), so
    rewriting a file would otherwise churn digits on every untouched number."""

    def __new__(cls, text: str):
        number = super().__new__(cls, text)
        number.text = text
        return number


def parse_json(raw: str):
    return json.loads(raw, parse_float=Number)


def read_json(path: Path):
    try:
        return parse_json(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise PscError(f"{path}: file not found") from None
    except json.JSONDecodeError as e:
        raise PscError(f"{path}: invalid JSON: {e}") from None


def vp_float(value):
    """A new float the way vpinball saves it: rounded to float32, shortest text
    that reads back, and a tie in the last digit rounded away from zero
    (Python rounds it to even)."""
    f = struct.unpack("f", struct.pack("f", value))[0]
    text = repr(f)
    if "e" in text or not text[-1].isdigit():
        return text
    shown = Decimal(text)
    unit = Decimal(1).scaleb(shown.as_tuple().exponent)
    if abs(Decimal(f)) - abs(shown) == unit / 2:
        bumped = str(shown + unit.copy_sign(shown))
        if float(bumped) == f:
            return bumped
    return text


def dump_json(data, indent: str = "") -> str:
    """vpinball's format: 2-space indent, non-ASCII kept, no trailing newline."""
    inner = indent + "  "
    if isinstance(data, dict):
        if not data:
            return "{}"
        items = (f"{inner}{json.dumps(k, ensure_ascii=False)}: {dump_json(v, inner)}" for k, v in data.items())
        return "{\n" + ",\n".join(items) + f"\n{indent}}}"
    if isinstance(data, list):
        if not data:
            return "[]"
        return "[\n" + ",\n".join(f"{inner}{dump_json(v, inner)}" for v in data) + f"\n{indent}]"
    if isinstance(data, Number):
        return data.text
    if isinstance(data, float):
        return vp_float(data)
    return json.dumps(data, ensure_ascii=False)


def rewrite_json(path: Path, mutate):
    """Apply `mutate(data)` and write back. Refuses to touch a file whose
    formatting would not survive a round trip, so diffs stay minimal."""
    raw = path.read_text(encoding="utf-8")
    data = parse_json(raw)
    trailing = raw[len(raw.rstrip("\n")):]
    if dump_json(data) != raw.rstrip("\n"):
        raise PscError(f"{path}: formatting is not vpinball's standard; refusing to rewrite it")
    mutate(data)
    path.write_text(dump_json(data) + trailing, encoding="utf-8")


BLINK_RE = re.compile(r'("blink_pattern":\s*)"(?:[^"\\]|\\.)*"')


def set_blink_pattern(path: Path, value: str):
    raw = path.read_text(encoding="utf-8")
    new, count = BLINK_RE.subn(lambda m: m.group(1) + json.dumps(value, ensure_ascii=False), raw, count=1)
    if count != 1:
        raise PscError(f"{path}: no blink_pattern field found")
    path.write_text(new, encoding="utf-8")


def hex_color(value: int) -> str:
    """vpinball stores colors as a Windows COLORREF (0x00BBGGRR)."""
    return f"{value & 0xff:02x}{(value >> 8) & 0xff:02x}{(value >> 16) & 0xff:02x}"


def colorref(hex_rgb: str) -> int:
    rgb = int(hex_rgb.lstrip("#"), 16)
    return ((rgb >> 16) & 0xff) | (rgb & 0xff00) | ((rgb & 0xff) << 16)


class Table:
    def __init__(self, directory: Path):
        self.dir = directory
        self.table_path = directory / "table.json"
        if not (directory / "parts").is_dir() or not self.table_path.is_file():
            raise PscError(f"{directory}: not a vpinball table pack (no parts folder or table.json)")
        self.lights: dict[str, LightRecord] = {}
        for path in sorted((directory / "parts").glob("*.json")):
            light = read_json(path)
            if light.get("$type") != "light":
                continue
            center = light.get("center", {})
            self.lights[path.stem.lower()] = LightRecord(
                name=path.stem,
                path=path,
                x=float(center.get("x", 0.0)),
                y=float(center.get("y", 0.0)),
                color=hex_color(int(light.get("color", 0xffffff))),
                blink_pattern=light.get("blink_pattern", ""),
                visible=bool(light.get("visible", True)),
            )
        self.collections_dir = directory / "collections"
        table = read_json(self.table_path)
        self.left = float(table.get("left", 0.0))
        self.top = float(table.get("top", 0.0))
        self.right = float(table.get("right", 952.0))
        self.bottom = float(table.get("bottom", 2162.0))
        self.image = str(table.get("image", "") or "")

    def light(self, name: str) -> LightRecord | None:
        return self.lights.get(name.lower())

    def collection_path(self, name: str) -> Path | None:
        if not self.collections_dir.is_dir():
            return None
        for path in sorted(self.collections_dir.glob("*.json")):
            if path.stem.lower() == name.lower():
                return path
        return None

    def collection_items(self, name: str) -> list[str] | None:
        path = self.collection_path(name)
        return list(read_json(path).get("parts", [])) if path else None


def tags_of(blink_pattern: str) -> list[str]:
    return [t.strip() for t in blink_pattern.split(",") if t.strip()]
