"""Reads backglass bulb geometry from a .directb2s file."""

import base64
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path

from .errors import PscError


@dataclass
class Backglass:
    width: float    # extent of the bulbs (what proxy positions are normalized to)
    height: float
    centers: dict[int, tuple[float, float]]
    rects: dict[int, tuple[float, float, float, float]] = field(default_factory=dict)  # b2s_id -> x, y, w, h
    image_size: tuple[int, int] | None = None   # pixel size of the embedded backglass picture


def image_size(data: bytes) -> tuple[int, int] | None:
    """Width and height from a PNG or JPEG header, else None."""
    if data[:8] == b"\x89PNG\r\n\x1a\n" and len(data) >= 24:
        return int.from_bytes(data[16:20], "big"), int.from_bytes(data[20:24], "big")
    if data[:3] == b"\xff\xd8\xff":
        i = 2
        while i + 9 < len(data):
            if data[i] != 0xFF:
                i += 1
                continue
            marker = data[i + 1]
            if marker in (0xD8, 0x01) or 0xD0 <= marker <= 0xD7:
                i += 2
                continue
            length = int.from_bytes(data[i + 2:i + 4], "big")
            if marker in (0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7, 0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF):
                h = int.from_bytes(data[i + 5:i + 7], "big")
                w = int.from_bytes(data[i + 7:i + 9], "big")
                return w, h
            i += 2 + length
    return None


def embedded_image(root) -> bytes | None:
    for tag in ("BackglassImage", "BackglassOffImage", "BackglassOnImage"):
        node = next(root.iter(tag), None)
        if node is not None and node.get("Value"):
            try:
                return base64.b64decode(node.get("Value"))
            except ValueError:
                return None
    return None


def read_backglass(path: Path) -> Backglass:
    try:
        root = ET.parse(path).getroot()
    except (OSError, ET.ParseError) as e:
        raise PscError(f"{path}: cannot read backglass file: {e}") from None
    width = height = 0.0
    centers: dict[int, tuple[float, float]] = {}
    rects: dict[int, tuple[float, float, float, float]] = {}
    for bulb in root.iter("Bulb"):
        if bulb.get("Parent", "Backglass") != "Backglass":
            continue
        try:
            x, y = float(bulb.get("LocX", 0)), float(bulb.get("LocY", 0))
            w, h = float(bulb.get("Width", 0)), float(bulb.get("Height", 0))
            b2s_id = int(bulb.get("B2SID", 0))
        except ValueError:
            continue
        width, height = max(width, x + w), max(height, y + h)
        if b2s_id > 0 and b2s_id not in centers:
            centers[b2s_id] = (x + w / 2, y + h / 2)
            rects[b2s_id] = (x, y, w, h)
    if width <= 0 or height <= 0:
        raise PscError(f"{path}: no backglass bulbs found")
    picture = embedded_image(root)
    return Backglass(width, height, centers, rects, image_size(picture) if picture else None)
