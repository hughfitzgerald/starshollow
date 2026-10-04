import json

import pytest

from conftest import write_config
from psc.errors import PscError
from psc.groups import light_universe, resolve_groups
from psc.hwmap import build_map
from psc.sync import apply_changes, plan_sync
from psc.table import Table

COLORS = """
lights:
  l1: ff0000
  l2: ffffff
  l10: ffffff
  FL1: ffffff
"""

GROUPS = COLORS + """
groups:
  GI: { members: ["@collection:GI"], color: ffb464 }
  inserts: { members: ["l*"] }
  left: { members: [l1, gi1] }
  combo: { members: ["@left", FL1] }
"""


def test_group_resolution(project):
    cfg = write_config(project, GROUPS)
    table = Table(cfg.table_dir)
    groups = resolve_groups(cfg, table, light_universe(cfg, table))
    assert groups["inserts"] == ["l1", "l2", "l10"]  # natural order, "other" excluded
    assert groups["combo"] == ["l1", "gi1", "FL1"]
    assert groups["GI"] == ["gi1"]


@pytest.mark.parametrize("body, message", [
    ("groups:\n  a: { members: [nope] }\n", "unknown light"),
    ("groups:\n  a: { members: ['@b'] }\n  b: { members: ['@a'] }\n", "cycle"),
    ("groups:\n  a: { members: ['zz*'] }\n", "matches no lights"),
    ("groups:\n  l1: { members: [l2] }\n", "same name as a light"),
    ("groups:\n  a: { members: [other] }\n", "unknown light"),
])
def test_group_errors(project, body, message):
    cfg = write_config(project, body)
    table = Table(cfg.table_dir)
    with pytest.raises(PscError, match=message):
        resolve_groups(cfg, table, light_universe(cfg, table))


def test_sync_writes_tags_surgically(project):
    cfg = write_config(project, GROUPS)
    path = project / "table" / "gameitems" / "Light.l1.json"
    before = path.read_text().splitlines()
    apply_changes(plan_sync(cfg, Table(cfg.table_dir)))
    after = path.read_text().splitlines()
    diff = [(a, b) for a, b in zip(before, after) if a != b]
    assert diff == [('    "blink_pattern": "10",', '    "blink_pattern": "combo,inserts,left",')]
    assert plan_sync(cfg, Table(cfg.table_dir)) == []
    untouched = json.loads((project / "table" / "gameitems" / "Light.other.json").read_text())
    assert untouched["Light"]["blink_pattern"] == "10"


def test_sync_creates_proxies(project):
    cfg = write_config(project, GROUPS + """
  bgfx: { members: [bg_a, FL1] }
backglass:
  template: FL1
  bulbs:
    bg_a: { b2s_id: 2, position: [500, -200], color: ffffff }
""")
    apply_changes(plan_sync(cfg, Table(cfg.table_dir)))
    table = Table(cfg.table_dir)
    proxy = json.loads((project / "table" / "gameitems" / "Light.bg_a.json").read_text())["Light"]
    assert proxy["center"] == {"x": 500.0, "y": -200.0}
    assert proxy["visible"] is False
    assert proxy["blink_pattern"] == "bgfx"
    assert [p["x"] for p in proxy["drag_points"]] == [510.0, 490.0]
    assert "bg_a" in table.collection_items("glf_lights")
    index = json.loads((project / "table" / "gameitems.json").read_text())
    assert index[-1]["file_name"] == "Light.bg_a.json"
    assert plan_sync(cfg, table) == []

    hw = build_map(cfg, table)
    assert hw.light("bg_a").proxy and hw.light("bg_a").b2s_id == 2
    assert hw.groups["bgfx"] == ["bg_a", "FL1"]

    # moving the bulb in config moves the proxy on the next sync
    cfg = write_config(project, GROUPS + """
  bgfx: { members: [bg_a, FL1] }
backglass:
  bulbs:
    bg_a: { b2s_id: 2, position: [600, -200], color: ffffff }
""")
    kinds = [c.kind for c in plan_sync(cfg, table)]
    assert kinds == ["move"]


def test_colors_resolve(project):
    cfg = write_config(project, GROUPS.replace("l2: ffffff", "l2: { color: 00ff00 }") + """
  bgfx: { members: [bg_a] }
backglass:
  template: FL1
  bulbs:
    bg_a: { b2s_id: 2, position: [500, -200], color: 123456 }
""")
    apply_changes(plan_sync(cfg, Table(cfg.table_dir)))
    hw = build_map(cfg, Table(cfg.table_dir))
    assert (hw.light("gi1").color, hw.light("gi1").color_source) == ("ffb464", "group GI")
    assert (hw.light("l2").color, hw.light("l2").color_source) == ("00ff00", "light")
    assert (hw.light("bg_a").color, hw.light("bg_a").color_source) == ("123456", "bulb")


def test_every_light_needs_a_color(project):
    cfg = write_config(project, "lights:\n  l1: ff0000\n")
    with pytest.raises(PscError, match=r"4 light\(s\) have no color.*l2, l10, gi1, FL1"):
        build_map(cfg, Table(cfg.table_dir))


def test_group_color_conflict(project):
    cfg = write_config(project, """
lights: { l2: ffffff, l10: ffffff, gi1: ffffff, FL1: ffffff }
groups:
  a: { members: [l1], color: ff0000 }
  b: { members: [l1], color: 0000ff }
""")
    apply_changes(plan_sync(cfg, Table(cfg.table_dir)))
    with pytest.raises(PscError, match="groups disagree"):
        build_map(cfg, Table(cfg.table_dir))
