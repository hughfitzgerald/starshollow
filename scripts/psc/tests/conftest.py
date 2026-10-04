import json
import textwrap
from pathlib import Path

import pytest

from psc.config import load_config

LIGHTS = {  # name: (x, y, color, blink_pattern)
    "l1": (100, 1000, "#ff0000", "10"),
    "l2": (200, 900, "#ffffff", "10"),
    "l10": (300, 800, "#ffffff", "inserts"),
    "gi1": (50, 1500, "#ffb464", "GI"),
    "FL1": (400, 400, "#ffffff", "10"),
    "other": (0, 0, "#ffffff", "10"),   # not in glf_lights
}


def light_json(name, x, y, color, blink):
    return {"Light": {
        "center": {"x": float(x), "y": float(y)},
        "color": color,
        "blink_pattern": blink,
        "name": name,
        "visible": True,
        "is_timer_enabled": False,
        "is_backglass": False,
        "drag_points": [{"x": float(x) + 10, "y": float(y)}, {"x": float(x) - 10, "y": float(y)}],
    }}


def dump(data):
    return json.dumps(data, indent=2, ensure_ascii=False)


@pytest.fixture
def project(tmp_path: Path):
    table = tmp_path / "table"
    (table / "gameitems").mkdir(parents=True)
    index = []
    for name, (x, y, color, blink) in LIGHTS.items():
        (table / "gameitems" / f"Light.{name}.json").write_text(dump(light_json(name, x, y, color, blink)))
        index.append({"file_name": f"Light.{name}.json", "is_locked": False, "editor_layer": 0})
    (table / "gameitems.json").write_text(dump(index))
    (table / "collections.json").write_text(dump([
        {"name": "glf_lights", "items": ["l1", "l2", "l10", "gi1", "FL1"]},
        {"name": "GI", "items": ["gi1"]},
    ]))
    (table / "gamedata.json").write_text(dump({"left": 0.0, "top": 0.0, "right": 1000.0, "bottom": 2000.0}))
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
