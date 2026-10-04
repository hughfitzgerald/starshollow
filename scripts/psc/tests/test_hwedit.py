import textwrap

import pytest
import yaml

from psc.errors import PscError
from psc.hwedit import declared, delete_group, update_group

SAMPLE = textwrap.dedent("""\
    paths:
      table: ../../table

    lights:
      l1: ff0000   # red

    groups:
      GI:
        color: ffa957 # warm
        members: ["@collection:GI"]
      flashers:
        members: [FL1, FL2]
      backglass:
        members:
          [
            bg_logo,
            bg_flash,
          ]
      # Two regions for the groove show.
      groove_left: { members: ["@area:x<476"], exclude: [bg_logo] }   # left half
      all_lights: ["*"]

    # Bulbs are on/off.
    backglass:
      bulbs:
        bg_logo: { b2s_id: 1 }
    """)


def loaded(text):
    return yaml.load(text, Loader=yaml.BaseLoader)


def test_add_members_keeps_style_and_comments():
    out = update_group(SAMPLE, "flashers", ["FL1", "FL2", "FL3"])
    assert "  flashers:\n    members: [FL1, FL2, FL3]\n" in out
    out2 = update_group(SAMPLE.replace("  flashers:\n", "  flashers: # pf\n"), "flashers", ["FL1"])
    assert "  flashers: # pf\n    members: [FL1]\n" in out2
    assert loaded(out)["groups"]["flashers"] == {"members": ["FL1", "FL2", "FL3"]}
    assert "color: ffa957 # warm" in out and "# Two regions" in out and "# Bulbs are on/off." in out
    # nothing else moved
    assert out.replace("[FL1, FL2, FL3]", "[FL1, FL2]") == SAMPLE


def test_block_entry_keeps_color_line_and_adds_exclude():
    out = update_group(SAMPLE, "GI", ["@collection:GI"], exclude=["gi050"])
    assert '  GI:\n    color: ffa957 # warm\n    members: ["@collection:GI"]\n    exclude: [gi050]\n' in out
    assert loaded(out)["groups"]["GI"] == {"color": "ffa957", "members": ["@collection:GI"], "exclude": ["gi050"]}


def test_multiline_flow_list_collapses():
    out = update_group(SAMPLE, "backglass", ["bg_logo", "bg_flash", "bg_new"])
    assert "  backglass:\n    members: [bg_logo, bg_flash, bg_new]\n  # Two regions" in out
    assert loaded(out)["groups"]["backglass"]["members"] == ["bg_logo", "bg_flash", "bg_new"]


def test_inline_entry_stays_inline():
    out = update_group(SAMPLE, "groove_left", ["@area:x<476"], exclude=["bg_logo", "l1"])
    assert '  groove_left: { members: ["@area:x<476"], exclude: [bg_logo, l1] }   # left half\n' in out
    out = update_group(SAMPLE, "groove_left", ["@area:x<476", "l1"], exclude=[])
    assert '  groove_left: { members: ["@area:x<476", l1] }   # left half\n' in out


def test_bare_list_entry():
    out = update_group(SAMPLE, "all_lights", ["*", "bg_logo"])
    assert '  all_lights: ["*", bg_logo]\n' in out
    out = update_group(SAMPLE, "all_lights", ["*"], exclude=["bg_logo"])
    assert '  all_lights:\n    members: ["*"]\n    exclude: [bg_logo]\n' in out
    assert loaded(out)["groups"]["all_lights"] == {"members": ["*"], "exclude": ["bg_logo"]}


def test_new_group_goes_after_the_last_entry():
    out = update_group(SAMPLE, "jess", ["l11", "l12"], color="0023cc")
    assert '  all_lights: ["*"]\n  jess:\n    color: 0023cc\n    members: [l11, l12]\n\n# Bulbs are on/off.\n' in out
    assert loaded(out)["groups"]["jess"] == {"color": "0023cc", "members": ["l11", "l12"]}


def test_delete_group():
    out = delete_group(SAMPLE, "backglass")
    assert "bg_flash" not in out and "  # Two regions" in out and "flashers" in out
    assert "backglass" not in loaded(out)["groups"]
    with pytest.raises(PscError, match="not found"):
        delete_group(SAMPLE, "nope")


def test_declared_and_validation():
    assert declared(SAMPLE, "groove_left") == (["@area:x<476"], ["bg_logo"])
    assert declared(SAMPLE, "all_lights") == (["*"], [])
    with pytest.raises(PscError, match="valid group name"):
        update_group(SAMPLE, "bad name", ["l1"])
    with pytest.raises(PscError, match="at least one member"):
        update_group(SAMPLE, "x", [])


def test_file_without_groups_block():
    out = update_group("lights:\n  l1: ff0000\n", "pair", ["l1", "l2"])
    assert loaded(out)["groups"] == {"pair": {"members": ["l1", "l2"]}}
