"""Reads backglass bulb geometry from a .directb2s file."""

import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path

from .errors import PscError


@dataclass
class Backglass:
    width: float
    height: float
    centers: dict[int, tuple[float, float]]


def read_backglass(path: Path) -> Backglass:
    try:
        root = ET.parse(path).getroot()
    except (OSError, ET.ParseError) as e:
        raise PscError(f"{path}: cannot read backglass file: {e}") from None
    width = height = 0.0
    centers: dict[int, tuple[float, float]] = {}
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
    if width <= 0 or height <= 0:
        raise PscError(f"{path}: no backglass bulbs found")
    return Backglass(width, height, centers)
