import json
import textwrap
from pathlib import Path

import pytest

from psc.config import load_config
from psc.table import colorref

LIGHTS = {  # name: (x, y, color, blink_pattern)
    "l1": (100, 1000, "#ff0000", "10"),
    "l2": (200, 900, "#ffffff", "10"),
    "l10": (300, 800, "#ffffff", "inserts"),
    "gi1": (50, 1500, "#ffb464", "GI"),
    "FL1": (400, 400, "#ffffff", "10"),
    "other": (0, 0, "#ffffff", "10"),   # not in glf_lights
}


def light_json(x, y, color, blink):
    return {
        "$type": "light",
        "center": {"x": float(x), "y": float(y)},
        "timer_enabled": False,
        "dragpoints": [{"center": {"x": float(x) + 10, "y": float(y)}},
                       {"center": {"x": float(x) - 10, "y": float(y)}}],
        "desktop_backdrop": False,
        "blink_pattern": blink,
        "color": colorref(color),
        "visible": True,
    }


def dump(data):
    return json.dumps(data, indent=2, ensure_ascii=False)


@pytest.fixture
def project(tmp_path: Path):
    table = tmp_path / "table"
    (table / "parts").mkdir(parents=True)
    (table / "collections").mkdir()
    for name, (x, y, color, blink) in LIGHTS.items():
        (table / "parts" / f"{name}.json").write_text(dump(light_json(x, y, color, blink)))
    collections = {"glf_lights": ["l1", "l2", "l10", "gi1", "FL1"], "GI": ["gi1"]}
    for name, parts in collections.items():
        (table / "collections" / f"{name}.json").write_text(dump({"$type": "collection", "parts": parts}))
    (table / "table.json").write_text(dump({
        "$type": "table", "left": 0.0, "top": 0.0, "right": 1000.0, "bottom": 2000.0,
        "parts": list(LIGHTS), "collections": list(collections)}))
    (tmp_path / "src" / "psc" / "shows").mkdir(parents=True)
    (tmp_path / "src" / "game").mkdir(parents=True)
    return tmp_path


def write_config(project: Path, body: str):
    path = project / "src" / "psc" / "hardware.yaml"
    path.write_text(textwrap.dedent("""\
        paths:
          table: ../../table
          output: ../game/psc_shows.vbs
        """) + textwrap.dedent(body))
    return load_config(path)


def write_show(project: Path, name: str, body: str):
    path = project / "src" / "psc" / "shows" / f"{name}.yaml"
    path.write_text(f"show: {name}\n" + textwrap.dedent(body))
    return path
