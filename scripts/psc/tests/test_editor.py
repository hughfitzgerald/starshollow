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
