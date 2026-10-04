import re

import pytest

from conftest import write_config, write_show
from psc.compiler import compile_all, compile_show
from psc.errors import PscError
from psc.hwmap import build_map
from psc.shows import parse_show
from psc.sync import apply_changes, plan_sync
from psc.table import Table

BASE = """
lights: { l1: ff0000, l2: ffffff, l10: ffffff, gi1: ffb464, FL1: ffffff }
anchors:
  drain: [100, 2000]
groups:
  pair: { members: [l1, l2] }
"""


@pytest.fixture
def env(project):
    cfg = write_config(project, BASE)
    apply_changes(plan_sync(cfg, Table(cfg.table_dir)))
    return project, cfg, build_map(cfg, Table(cfg.table_dir))


def timeline(project, hw, name, body):
    """Compile one show; return {light: [(t, string)]} plus the compiled show."""
    show = parse_show(write_show(project, name, body), hw)
    compiled = compile_show(show, hw)
    steps, current = [], None
    for line in compiled.vbs.splitlines():
        line = line.strip()
        if line.startswith("With .AddStep"):
            current = int(round(float(line.split("t=")[1].rstrip("s")) * 1000))
        elif not line.startswith("With"):
            steps += [(current, part) for part in re.findall(r'"([^"]+)"', line)]
    by_light = {}
    for t, s in steps:
        by_light.setdefault(s.split("|")[0], []).append((t, s))
    return by_light, compiled


def test_flash(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "f", """
layers:
  - { target: l1, pattern: flash, count: 2, on: 100ms }
""")
    assert lights["l1"] == [(0, "l1|100|ff0000"), (100, "l1|100|stop"), (200, "l1|100|ff0000"), (300, "l1|100|stop")]
    assert c.length == 400


def test_chase_over_solid_falls_back(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "c", """
length: 300ms
layers:
  - { target: pair, pattern: solid, color: 0000ff }
  - { target: pair, pattern: chase, interval: 100ms, color: 00ff00 }
""")
    assert lights["l1"] == [(0, "l1|100|00ff00"), (100, "l1|100|0000ff")]
    assert lights["l2"] == [(0, "l2|100|0000ff"), (100, "l2|100|00ff00"), (200, "l2|100|0000ff")]


def test_tail_with_nothing_beneath_fades_then_stops(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "t", """
length: 500ms
layers:
  - { target: l1, pattern: solid, duration: 100ms, tail: 200ms }
""")
    assert lights["l1"] == [(0, "l1|100|ff0000"), (100, "l1|100|000000|200"), (300, "l1|100|stop")]


def test_new_layer_cancels_pending_stop(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "p", """
length: 500ms
layers:
  - { target: l1, pattern: solid, duration: 100ms, tail: 200ms }
  - { target: l1, pattern: solid, start: 200ms, color: 00ff00 }
""")
    # the tail would be cut by the 200ms step, so PSC renders it as frames
    assert lights["l1"] == [
        (0, "l1|100|ff0000"),
        (100, "l1|85|ff0000"), (120, "l1|75|ff0000"), (150, "l1|60|ff0000"), (180, "l1|45|ff0000"),
        (200, "l1|100|00ff00"),
    ]


def test_native_fade_kept_when_uninterrupted(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "n", """
layers:
  - { target: l1, pattern: solid, duration: 100ms, tail: 200ms }
""")
    assert lights["l1"] == [(0, "l1|100|ff0000"), (100, "l1|100|000000|200")]
    assert c.length == 300


def test_reveal_mid_fade_continues_fade(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "b", """
layers:
  - { target: l1, pattern: breathe, period: 1000ms }
  - { target: l1, pattern: flash, start: 250ms, on: 100ms, color: 00ff00 }
""")
    seq = lights["l1"]
    rise = [s for t, s in seq if t < 250]
    assert [t for t, _ in seq if t < 250] == list(range(0, 250, 30))  # frames: cut by the flash
    assert rise[0] == "l1|6|ff0000" and rise[-1] == "l1|54|ff0000"
    assert [x for x in seq if x[0] >= 250] == [
        (250, "l1|100|00ff00"),
        (350, "l1|100|ff0000|150"),    # back to the breathe, finishing its rise natively
        (500, "l1|100|000000|500"),    # breathe down to min=0, native
    ]
    assert c.length == 1000


def test_lights_not_used_at_start_are_reset(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "r", """
layers:
  - { target: l2, pattern: solid, start: 200ms, duration: 100ms }
""")
    assert lights["l2"] == [(0, "l2|100|stop"), (200, "l2|100|ffffff")]


def test_sweep_timing_and_chase_order(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "s", """
layers:
  - { target: [l1, l2, l10], pattern: sweep, direction: up, speed: 1000, width: 50 }
""")
    # l1 y=1000, l2 y=900, l10 y=800 -> 0, 100, 200ms; on for 50ms
    assert [x[0] for x in lights["l1"]] == [0, 50]
    assert [x[0] for x in lights["l2"]] == [0, 100, 150]
    assert [x[0] for x in lights["l10"]] == [0, 200]  # release at 250 == length is dropped
    lights, c = timeline(project, hw, "o", """
layers:
  - { target: [l1, l2, l10], pattern: chase, order: -x, interval: 100ms }
""")
    assert lights["l10"][0] == (0, "l10|100|ffffff")
    assert lights["l1"][-1][0] == 200


def test_tokens_pass_through(env):
    project, cfg, hw = env
    lights, c = timeline(project, hw, "k", """
layers:
  - { target: l1, pattern: solid, color: (color), duration: 100ms }
""")
    assert lights["l1"][0] == (0, "l1|100|(color)")


def test_errors(env):
    project, cfg, hw = env
    with pytest.raises(PscError, match="unknown target"):
        parse_show(write_show(project, "e1", "layers:\n  - { target: nope, pattern: solid }\n"), hw)
    with pytest.raises(PscError, match="interval is required"):
        parse_show(write_show(project, "e2", "layers:\n  - { target: l1, pattern: chase }\n"), hw)
    with pytest.raises(PscError, match="unknown key"):
        parse_show(write_show(project, "e3", "layers:\n  - { target: l1, pattern: solid, colour: ff0000 }\n"), hw)
    with pytest.raises(PscError, match="shorter than"):
        compile_show(parse_show(write_show(project, "e4", "length: 100ms\nlayers:\n  - { target: l1, pattern: solid, start: 200ms }\n"), hw), hw)


def test_compile_all_writes_file_and_detects_collisions(env):
    project, cfg, hw = env
    write_show(project, "hello", "layers:\n  - { target: pair, pattern: flash, on: 100ms }\n")
    compiled, changed = compile_all(cfg)
    assert changed
    text = cfg.output_file.read_text()
    assert "Sub CreatePscShows()" in text and 'CreateGlfShow("hello")' in text
    assert "PscBackglassBulbs = Array()" in text
    assert compile_all(cfg)[1] is False  # unchanged on rerun

    (project / "src" / "game" / "old.vbs").write_text('With CreateGlfShow("hello")\nEnd With\n')
    with pytest.raises(PscError, match="already exists"):
        compile_all(cfg)


def test_compile_refuses_stale_json(env):
    project, cfg, hw = env
    path = project / "table" / "gameitems" / "Light.l1.json"
    path.write_text(path.read_text().replace('"blink_pattern": "pair"', '"blink_pattern": "10"'))
    with pytest.raises(PscError, match="run `psc sync`"):
        compile_all(cfg)


def test_steps_cover_full_length_with_end_marker(env):
    project, cfg, hw = env
    for body in ["layers:\n  - { target: l1, pattern: flash, on: 100ms }\n",
                 "layers:\n  - { target: pair, pattern: chase, interval: 100ms }\n",
                 "length: 1s\nlayers:\n  - { target: l1, pattern: solid }\n"]:
        show = parse_show(write_show(project, "m", body), hw)
        compiled = compile_show(show, hw)
        durations = [float(x) for x in re.findall(r"AddStep\(Null, Null, ([0-9.]+)\)", compiled.vbs)]
        assert round(sum(durations) * 1000) == compiled.length
        assert compiled.vbs.splitlines()[-3].strip() == "' end of show"


def test_resolution_coarsens_timing(env):
    project, cfg, hw = env
    body = "layers:\n  - { target: [l1, l2, l10], pattern: sweep, direction: up, speed: 1000, width: 50 }\n"
    lights, c = timeline(project, hw, "r10", body)
    assert [x[0] for x in lights["l2"]] == [0, 100, 150]
    lights, c = timeline(project, hw, "r40", "resolution: 40ms\n" + body)
    assert [x[0] for x in lights["l2"]] == [0, 120, 160]  # 100 -> 120 (halves round up), 150 -> 160
    with pytest.raises(PscError, match="multiple of 10ms"):
        parse_show(write_show(project, "bad", "resolution: 15ms\n" + body), hw)
