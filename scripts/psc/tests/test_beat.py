import re

import pytest

from conftest import write_config, write_show
from psc.errors import PscError
from psc.groups import light_universe, resolve_groups
from psc.hwmap import build_map
from psc.shows import parse_beat_pattern, parse_show
from psc.sync import apply_changes, plan_sync
from psc.table import Table
from psc.values import Tempo, parse_time
from test_compile import timeline

BASE = """
lights: { l1: ff0000, l2: 00ff00, l10: 0000ff, gi1: ffb464, FL1: ffffff }
groups:
  pair: { members: [l1, l2] }
"""


@pytest.fixture
def env(project):
    cfg = write_config(project, BASE)
    apply_changes(plan_sync(cfg, Table(cfg.table_dir)))
    return project, cfg, build_map(cfg, Table(cfg.table_dir))


def test_musical_time_units():
    tempo = Tempo(bpm=120)  # 500ms beats, 125ms steps, 2s bars
    assert parse_time("3 steps", "x", tempo) == 375
    assert parse_time("2 beats", "x", tempo) == 1000
    assert parse_time("1bar", "x", tempo) == 2000
    with pytest.raises(PscError, match="add a tempo"):
        parse_time("1 bar", "x")


def test_pattern_notation():
    hits, steps = parse_beat_pattern("x..X | -_o.  # comment\n x...", {"x": 50, "X": 100, "o": 25}, "t")
    assert steps == 12
    assert hits == [(0, 50), (3, 100), (6, 25), (8, 50)]
    with pytest.raises(PscError, match="unknown symbol 'q'"):
        parse_beat_pattern("x.q.", {"x": 100}, "t")


def test_beat_pulses_over_baseline(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "g", """
tempo: { bpm: 120 }
layers:
  - { target: pair, pattern: solid, brightness: 40 }
  - pattern: beat
    decay: 50ms
    accents: { x: 80, X: 100 }
    tracks:
      l1: "x...X..."
      pair: "..x....."
""")
    assert c.length == 2000  # one bar at 120bpm
    assert lights["l1"] == [(0, "l1|80|ff0000"), (10, "l1|40|ff0000|50"), (250, "l1|80|ff0000"),
                            (260, "l1|40|ff0000|50"), (500, "l1|100|ff0000"), (510, "l1|40|ff0000|50")]
    assert lights["l2"] == [(0, "l2|40|00ff00"), (250, "l2|80|00ff00"), (260, "l2|40|00ff00|50")]


def test_brighter_hit_wins_when_tracks_overlap(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "o", """
tempo: { bpm: 120 }
layers:
  - pattern: beat
    accents: { x: 30, X: 90 }
    tracks:
      l1: "x..."
      pair: "X..."
""")
    assert lights["l1"][0] == (0, "l1|90|ff0000")


def test_first_hit_attack_wraps_to_loop_end(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "w", """
tempo: { bpm: 120, beats_per_bar: 1 }
layers:
  - pattern: beat
    attack: 100ms
    tracks:
      l1: "x..."
""")
    assert c.length == 500
    assert lights["l1"] == [(0, "l1|100|ff0000"), (10, "l1|100|stop"), (400, "l1|100|ff0000|100")]


def test_beat_needs_tempo_and_tracks(env):
    project, cfg, hw = env
    with pytest.raises(PscError, match="needs a tempo"):
        parse_show(write_show(project, "a", "layers:\n  - { pattern: beat, tracks: { l1: 'x...' } }\n"), hw)
    with pytest.raises(PscError, match="takes tracks: instead of target"):
        parse_show(write_show(project, "b", "tempo: { bpm: 120 }\nlayers:\n  - { pattern: beat, target: l1, tracks: { l1: 'x' } }\n"), hw)


def test_area_groups(project):
    # l1 (100,1000) l2 (200,900) l10 (300,800) gi1 (50,1500) FL1 (400,400)
    cfg = write_config(project, BASE + """
  low_left: { members: ["@area:x<250,y>=900"] }
  top: { members: ["@area:y<500"] }
""")
    table = Table(cfg.table_dir)
    groups = resolve_groups(cfg, table, light_universe(cfg, table))
    assert groups["low_left"] == ["gi1", "l1", "l2"]
    assert groups["top"] == ["FL1"]
    cfg = write_config(project, "groups:\n  none: { members: ['@area:x<0'] }\n")
    with pytest.raises(PscError, match="contains no lights"):
        resolve_groups(cfg, table, light_universe(cfg, table))


def test_group_exclude(project):
    cfg = write_config(project, BASE + """
  most: { members: ["l*", FL1], exclude: [l2, "@area:y<500"] }
  rest: { members: ["@pair"], exclude: ["@pair"] }
""")
    table = Table(cfg.table_dir)
    with pytest.raises(PscError, match="group rest: has no members"):
        resolve_groups(cfg, table, light_universe(cfg, table))
    cfg = write_config(project, BASE + """
  most: { members: ["l*", FL1], exclude: [l2, "@area:y<500"] }
""")
    groups = resolve_groups(cfg, table, light_universe(cfg, table))
    assert groups["most"] == ["l1", "l10"]


def test_show_layers_inline_and_repeat(env):
    project, cfg, hw = env
    write_show(project, "blink", "layers:\n  - { target: l1, pattern: flash, on: 100ms }\n")
    write_show(project, "wipe", "layers:\n  - { target: pair, pattern: chase, interval: 50ms }\n")
    write_show(project, "medley", """
layers:
  - { pattern: show, show: blink, count: 2 }
  - { pattern: show, show: wipe, start: after }
""")
    from psc.compiler import compile_all
    compiled = {c.name: c for c in compile_all(cfg)[0]}
    assert compiled["medley"].length == 2 * 200 + 100
    events, t = [], None
    for line in compiled["medley"].vbs.splitlines():
        if "t=" in line:
            t = int(round(float(line.split("t=")[1].rstrip("s")) * 1000))
        events += [(t, s) for s in re.findall(r'"([^"]+)"', line) if "|" in s]
    assert [e for e in events if e[1].startswith("l1|")] == [
        (0, "l1|100|ff0000"), (100, "l1|100|stop"), (200, "l1|100|ff0000"), (300, "l1|100|stop"),
        (400, "l1|100|ff0000"), (450, "l1|100|stop")]       # blink twice, then wipe's first light
    assert [e for e in events if e[1].startswith("l2|")] == [(0, "l2|100|stop"), (450, "l2|100|00ff00")]


def test_show_layer_errors(env):
    project, cfg, hw = env
    from psc.compiler import compile_all
    write_show(project, "a", "layers:\n  - { pattern: show, show: b }\n")
    write_show(project, "b", "layers:\n  - { pattern: show, show: a }\n")
    with pytest.raises(PscError, match="include each other in a loop"):
        compile_all(cfg)
    write_show(project, "b", "layers:\n  - { pattern: show, show: nope }\n")
    with pytest.raises(PscError, match="unknown show 'nope'"):
        compile_all(cfg)


def _events(vbs):
    events, t = [], None
    for line in vbs.splitlines():
        if "t=" in line:
            t = int(round(float(line.split("t=")[1].rstrip("s")) * 1000))
        events += [(t, s) for s in re.findall(r'"([^"]+)"', line) if "|" in s]
    return events


def test_included_show_plays_like_itself(env):
    project, cfg, hw = env
    from psc.compiler import compile_all
    write_show(project, "sweeps", """
layers:
  - { target: [l1, l2, l10], pattern: sweep, direction: up, speed: 1000, width: 50, tail: 100ms }
  - { target: [l1, l2, l10], pattern: sweep, direction: down, speed: 1000, width: 50, tail: 100ms, start: after }
""")
    write_show(project, "wrapper", "layers:\n  - { pattern: show, show: sweeps }\n")
    compiled = {c.name: c for c in compile_all(cfg)[0]}
    assert _events(compiled["wrapper"].vbs) == _events(compiled["sweeps"].vbs)
    assert compiled["wrapper"].length == compiled["sweeps"].length


def test_included_show_releases_its_lights_when_it_ends(env):
    project, cfg, hw = env
    from psc.compiler import compile_all
    write_show(project, "base", "length: 200ms\nlayers:\n  - { target: l1, pattern: solid, brightness: 40 }\n")
    write_show(project, "pop", "layers:\n  - { target: l1, pattern: solid, duration: 100ms, tail: 100ms }\n")
    write_show(project, "seq", """
layers:
  - { pattern: show, show: base }
  - { pattern: show, show: pop, start: after }
""")
    write_show(project, "over", """
layers:
  - { target: l1, pattern: solid, brightness: 40 }
  - { pattern: show, show: pop }
""")
    compiled = {c.name: c for c in compile_all(cfg)[0]}
    # the baseline is gone once its show ends, so the pop plays as it does alone
    assert _events(compiled["seq"].vbs) == [
        (0, "l1|40|ff0000"), (200, "l1|100|ff0000"), (300, "l1|100|000000|100")]  # show ends at 400
    # layered over a baseline on purpose, the tail settles onto the baseline
    assert _events(compiled["over"].vbs) == [(0, "l1|100|ff0000"), (100, "l1|40|ff0000|100")]
