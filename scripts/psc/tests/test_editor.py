import http.client
import json
import threading

import pytest

from conftest import write_config
from psc.config import load_config
from psc.editor import apply_edit, build_state, make_server
from psc.errors import PscError
from psc.hwedit import declared

BASE = """
lights: { l1: ff0000, l2: ffffff, l10: ffffff, gi1: ffb464, FL1: ffffff }
anchors:
  drain: [100, 2000]
groups:
  pair: { members: [l1, l2] }   # two inserts
  gi: { color: ffb464, members: ["@collection:GI"] }
  all: ["*"]
"""


@pytest.fixture
def cfg(project):
    return write_config(project, BASE)


def test_build_state(cfg):
    state = build_state(cfg)
    assert state["table"] == {"left": 0.0, "top": 0.0, "right": 1000.0, "bottom": 2000.0}
    names = [l["name"] for l in state["lights"]]
    assert names == ["l1", "l2", "l10", "gi1", "FL1"]
    l1 = state["lights"][0]
    assert (l1["x"], l1["y"], l1["color"], l1["proxy"]) == (100.0, 1000.0, "ff0000", False)
    assert l1["groups"] == ["pair", "all"]
    gi1 = next(l for l in state["lights"] if l["name"] == "gi1")
    assert gi1["color"] == "ffb464" and gi1["groups"] == ["gi", "all"]
    assert state["groups"]["pair"] == {"members": ["l1", "l2"], "declared": ["l1", "l2"], "exclude": [], "color": None}
    assert state["groups"]["all"]["members"] == ["FL1", "gi1", "l1", "l2", "l10"]
    assert state["anchors"] == {"drain": [100.0, 2000.0]}
    assert state["error"] is None


def test_edits_round_trip(cfg):
    apply_edit(cfg, "create", "inserts", ["l10", "l1"], color="00ff00")
    cfg = load_config(cfg.path)
    assert build_state(cfg)["groups"]["inserts"] == {"members": ["l10", "l1"], "declared": ["l10", "l1"],
                                                       "exclude": [], "color": "00ff00"}
    # add: already-resolved lights are not listed twice
    apply_edit(cfg, "add", "inserts", ["l1", "l2"])
    assert declared(cfg.path.read_text(), "inserts") == (["l10", "l1", "l2"], [])
    # remove a declared light: it leaves the list; remove a glob-resolved one: it is excluded
    apply_edit(load_config(cfg.path), "remove", "inserts", ["l10"])
    assert declared(cfg.path.read_text(), "inserts") == (["l1", "l2"], [])
    apply_edit(load_config(cfg.path), "remove", "all", ["gi1"])
    assert declared(cfg.path.read_text(), "all") == (["*"], ["gi1"])
    assert "gi1" not in build_state(load_config(cfg.path))["groups"]["all"]["members"]
    # adding it back clears the exclude
    apply_edit(load_config(cfg.path), "add", "all", ["gi1"])
    assert declared(cfg.path.read_text(), "all") == (["*"], [])
    apply_edit(load_config(cfg.path), "delete", "inserts")
    assert "inserts" not in load_config(cfg.path).groups
    assert "# two inserts" in cfg.path.read_text()


def test_bad_edits_leave_the_file_alone(cfg):
    before = cfg.path.read_text()
    with pytest.raises(PscError, match="already exists"):
        apply_edit(cfg, "create", "PAIR", ["l1"])
    with pytest.raises(PscError, match="select at least one"):
        apply_edit(cfg, "create", "x", [])
    with pytest.raises(PscError, match="not found"):
        apply_edit(cfg, "add", "nope", ["l1"])
    # removing the only members would leave an empty group
    with pytest.raises(PscError, match="at least one member"):
        apply_edit(cfg, "remove", "pair", ["l1", "l2"])
    # a change that parses but doesn't resolve is written, checked, and rolled back
    with pytest.raises(PscError, match="restored"):
        apply_edit(cfg, "add", "pair", ["@nope"])
    assert cfg.path.read_text() == before


def test_http_server(cfg):
    server = make_server(cfg.path, port=0)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        port = server.server_address[1]

        def call(method, path, body=None):
            conn = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
            conn.request(method, path, body=json.dumps(body) if body is not None else None,
                         headers={"Content-Type": "application/json"})
            resp = conn.getresponse()
            data = resp.read()
            conn.close()
            return resp.status, resp.getheader("Content-Type"), data

        status, ctype, data = call("GET", "/")
        assert status == 200 and ctype.startswith("text/html") and b"Light groups" in data
        status, ctype, data = call("GET", "/api/state")
        assert status == 200 and json.loads(data)["groups"]["pair"]["members"] == ["l1", "l2"]
        status, _, data = call("POST", "/api/groups", {"op": "create", "group": "trio", "lights": ["l10", "gi1", "FL1"]})
        assert status == 200 and json.loads(data)["groups"]["trio"]["members"] == ["l10", "gi1", "FL1"]
        status, _, data = call("POST", "/api/groups", {"op": "create", "group": "trio", "lights": ["l1"]})
        assert status == 400 and "already exists" in json.loads(data)["error"]
        status, _, _ = call("GET", "/img/playfield")
        assert status == 404  # the fixture has no images
    finally:
        server.shutdown()
        server.server_close()


def tiny_png(width: int, height: int) -> bytes:
    import struct
    import zlib

    def chunk(kind, body):
        return struct.pack(">I", len(body)) + kind + body + struct.pack(">I", zlib.crc32(kind + body) & 0xFFFFFFFF)

    raw = b"".join(b"\x00" + b"\x00\x00\x00" * width for _ in range(height))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))


def test_backglass_bulbs_come_from_the_directb2s(project):
    import base64

    png = tiny_png(400, 300)
    (project / "table.directb2s").write_text(
        '<DirectB2SData><Images><BackglassImage Value="%s"/></Images><Illumination>'
        '<Bulb ID="1" Parent="Backglass" B2SID="7" LocX="20" LocY="30" Width="40" Height="20"/>'
        '<Bulb ID="2" Parent="Backglass" B2SID="8" LocX="300" LocY="200" Width="40" Height="20"/>'
        '</Illumination></DirectB2SData>' % base64.b64encode(png).decode())
    cfg = write_config(project, """
lights: { l1: ff0000, l2: ffffff, l10: ffffff, gi1: ffb464, FL1: ffffff }
groups:
  pair: { members: [l1, l2] }
backglass:
  source: ../../table.directb2s
  template: FL1
  bulbs:
    bg_a: { b2s_id: 7, color: ffffff }
    bg_b: { b2s_id: 8, color: ffffff }
""")
    from psc.editor import backglass_image
    from psc.sync import apply_changes, plan_sync
    from psc.table import Table
    apply_changes(plan_sync(cfg, Table(cfg.table_dir)))
    state = build_state(load_config(cfg.path))
    assert state["backglass"]["size"] == [400, 300]  # the picture, not the bulbs' extent (340 x 220)
    a = next(l for l in state["lights"] if l["name"] == "bg_a")
    assert a["proxy"] and a["b2s_id"] == 7 and a["b2s"] == {"x": 20.0, "y": 30.0, "w": 40.0, "h": 20.0}
    assert backglass_image(cfg, Table(cfg.table_dir)) == (png, "image/png")
