"""`psc edit`: a local web editor for light groups.

Serves editor.html on localhost. The page draws every GLF light on the
playfield image (and backglass bulbs on the backglass image), shows the
groups from hardware.yaml, and lets you select lights by clicking or
dragging a box to create groups or change their members. Edits go through
hwedit, so hardware.yaml keeps its comments and layout."""

import copy
import json
import webbrowser
import xml.etree.ElementTree as ET
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from .b2s import Backglass, embedded_image, read_backglass
from .config import Config, load_config
from .errors import PscError
from .groups import light_positions, light_universe, resolve_groups
from .hwedit import declared, delete_group, update_group
from .sync import PROXY_MARGIN, PROXY_SPAN
from .table import Table

HTML = Path(__file__).with_name("editor.html")
IMAGE_TYPES = {".png": "image/png", ".webp": "image/webp", ".jpg": "image/jpeg", ".jpeg": "image/jpeg"}


def find_table_image(table: Table, name: str) -> Path | None:
    images = table.dir / "images"
    if not images.is_dir():
        return None
    for path in sorted(images.iterdir()):
        if path.stem.lower() == name.lower() and path.suffix.lower() in IMAGE_TYPES:
            return path
    return None


def playfield_image(cfg: Config, table: Table) -> tuple[bytes, str] | None:
    path = find_table_image(table, table.image or "playfield")
    return (path.read_bytes(), IMAGE_TYPES[path.suffix.lower()]) if path else None


def _sniff(data: bytes) -> str:
    if data[:8] == b"\x89PNG\r\n\x1a\n":
        return "image/png"
    if data[:3] == b"\xff\xd8\xff":
        return "image/jpeg"
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return "image/webp"
    return "application/octet-stream"


def backglass_image(cfg: Config, table: Table) -> tuple[bytes, str] | None:
    """backglass.image in hardware.yaml (a table image name or a file), else
    the image inside the .directb2s, else a table image named like 'backglass'."""
    if cfg.backglass_image:
        path = (cfg.path.parent / cfg.backglass_image).resolve()
        if not path.is_file():
            path = find_table_image(table, cfg.backglass_image)
        if path is None or not path.is_file():
            raise PscError(f"backglass.image: {cfg.backglass_image!r} is neither a file nor a table image")
        return path.read_bytes(), IMAGE_TYPES.get(path.suffix.lower(), _sniff(path.read_bytes()))
    if cfg.directb2s and cfg.directb2s.is_file():
        try:
            data = embedded_image(ET.parse(cfg.directb2s).getroot())
        except ET.ParseError:
            data = None
        if data:
            return data, _sniff(data)
    images = table.dir / "images"
    if images.is_dir():
        for path in sorted(images.iterdir()):
            if "backglass" in path.stem.lower() and path.suffix.lower() in IMAGE_TYPES:
                return path.read_bytes(), IMAGE_TYPES[path.suffix.lower()]
    return None


def build_state(cfg: Config) -> dict:
    table = Table(cfg.table_dir)
    universe = light_universe(cfg, table)
    error = None
    try:
        groups = resolve_groups(cfg, table, universe)
    except PscError as e:
        groups, error = {}, "; ".join(e.messages)
    try:
        positions = light_positions(cfg, table, universe)
    except PscError:
        positions = {n: (r.x, r.y) for n in universe if (r := table.light(n))}
    group_colors = {g.name: g.color for g in cfg.groups.values() if g.color}
    bulbs = {b.name.lower(): b for b in cfg.bulbs.values()}
    # With the .directb2s at hand, bulbs are drawn from their own rectangles
    # over the picture's real size, as B2S Designer shows them.
    b2s: Backglass | None = None
    if cfg.directb2s and cfg.directb2s.is_file():
        try:
            b2s = read_backglass(cfg.directb2s)
        except PscError:
            b2s = None

    lights = []
    for name in universe:
        if name not in positions:
            continue
        record = table.light(name)
        bulb = bulbs.get(name.lower())
        color = cfg.light_colors.get(name.lower())
        if color is None:
            owners = sorted({group_colors[g] for g, members in groups.items() if g in group_colors and name in members})
            color = owners[0] if len(owners) == 1 else None
        if color is None and bulb and bulb.color:
            color = bulb.color
        light = {
            "name": name,
            "x": positions[name][0], "y": positions[name][1],
            "color": color or (record.color if record else "ffffff"),
            "proxy": bulb is not None,
            "b2s_id": bulb.b2s_id if bulb else None,
            "groups": [g for g, members in groups.items() if name in members],
        }
        if bulb and b2s and bulb.b2s_id in b2s.rects:
            x, y, w, h = b2s.rects[bulb.b2s_id]
            light["b2s"] = {"x": x, "y": y, "w": w, "h": h}
        lights.append(light)
    text = cfg.path.read_text(encoding="utf-8")
    out_groups = {}
    for name in cfg.groups:
        members_decl, exclude = declared(text, name)
        out_groups[name] = {
            "members": groups.get(name, []),
            "declared": members_decl,
            "exclude": exclude,
            "color": group_colors.get(name),
        }
    return {
        "config": str(cfg.path),
        "table": {"left": table.left, "top": table.top, "right": table.right, "bottom": table.bottom},
        "lights": lights,
        "groups": out_groups,
        "anchors": {k: list(v) for k, v in cfg.anchors.items()},
        "backglass": {
            "margin": PROXY_MARGIN, "span": PROXY_SPAN,
            # the coordinate space of the b2s rectangles: the picture's pixel
            # size when known, else the extent of the bulbs
            "size": list(b2s.image_size) if b2s and b2s.image_size else ([b2s.width, b2s.height] if b2s else None),
        },
        "error": error,
    }


def apply_edit(cfg: Config, op: str, group: str, lights: list[str] | None = None, color: str | None = None) -> None:
    """One editor action on hardware.yaml. The file is restored if the
    result doesn't load and resolve."""
    lights = list(lights or [])
    path = cfg.path
    text = path.read_text(encoding="utf-8")
    existing = next((g for g in cfg.groups if g.lower() == group.lower()), None)
    if op == "create":
        if existing:
            raise PscError(f"group {existing} already exists")
        if not lights:
            raise PscError("select at least one light first")
        new_text = update_group(text, group, lights, color=color or None)
    elif op in ("add", "remove"):
        if existing is None:
            raise PscError(f"group {group}: not found")
        if not lights:
            raise PscError("select at least one light first")
        table = Table(cfg.table_dir)
        universe = light_universe(cfg, table)
        resolved = resolve_groups(cfg, table, universe).get(existing, [])
        members, exclude = declared(text, existing)
        lower = {l.lower() for l in lights}
        if op == "add":
            exclude = [e for e in exclude if e.lower() not in lower]
            # a light the members already cover (once un-excluded) isn't listed again
            unexcluded = copy.deepcopy(cfg)
            unexcluded.groups[existing].exclude = list(exclude)
            covered = resolve_groups(unexcluded, table, universe).get(existing, [])
            already = {m.lower() for m in members} | {m.lower() for m in covered}
            members = members + [l for l in lights if l.lower() not in already]
        else:
            declared_lower = {m.lower() for m in members}
            members = [m for m in members if m.lower() not in lower]
            for l in lights:
                if l.lower() not in declared_lower and l in resolved and l.lower() not in {e.lower() for e in exclude}:
                    exclude.append(l)
        new_text = update_group(text, existing, members, exclude)
    elif op == "delete":
        if existing is None:
            raise PscError(f"group {group}: not found")
        new_text = delete_group(text, existing)
    else:
        raise PscError(f"unknown edit {op!r}")
    path.write_text(new_text, encoding="utf-8")
    try:
        new_cfg = load_config(path)
        table = Table(new_cfg.table_dir)
        resolve_groups(new_cfg, table, light_universe(new_cfg, table))
    except PscError as e:
        path.write_text(text, encoding="utf-8")
        raise PscError([f"edit rejected, {path.name} restored:", *e.messages]) from None


class Handler(BaseHTTPRequestHandler):
    config_path: Path

    def log_message(self, format, *args):  # quiet
        pass

    def _send(self, status: int, body: bytes, content_type: str):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def _json(self, status: int, data):
        self._send(status, json.dumps(data).encode("utf-8"), "application/json")

    def do_GET(self):
        try:
            if self.path == "/":
                self._send(200, HTML.read_bytes(), "text/html; charset=utf-8")
            elif self.path == "/api/state":
                self._json(200, build_state(load_config(self.config_path)))
            elif self.path in ("/img/playfield", "/img/backglass"):
                cfg = load_config(self.config_path)
                table = Table(cfg.table_dir)
                found = playfield_image(cfg, table) if self.path.endswith("playfield") else backglass_image(cfg, table)
                if found is None:
                    self._send(404, b"no image", "text/plain")
                else:
                    self._send(200, found[0], found[1])
            elif self.path == "/favicon.ico":
                self._send(204, b"", "image/x-icon")
            else:
                self._send(404, b"not found", "text/plain")
        except PscError as e:
            self._json(400, {"error": "\n".join(e.messages)})

    def do_POST(self):
        if self.path != "/api/groups":
            self._send(404, b"not found", "text/plain")
            return
        try:
            length = int(self.headers.get("Content-Length") or 0)
            body = json.loads(self.rfile.read(length) or b"{}")
            cfg = load_config(self.config_path)
            apply_edit(cfg, body.get("op", ""), str(body.get("group", "")).strip(),
                       body.get("lights") or [], body.get("color") or None)
            self._json(200, build_state(load_config(self.config_path)))
        except PscError as e:
            self._json(400, {"error": "\n".join(e.messages)})
        except (ValueError, TypeError) as e:
            self._json(400, {"error": f"bad request: {e}"})


def make_server(config_path: Path, host: str = "127.0.0.1", port: int = 8765) -> ThreadingHTTPServer:
    handler = type("EditorHandler", (Handler,), {"config_path": config_path})
    return ThreadingHTTPServer((host, port), handler)


def serve(cfg: Config, port: int, open_browser: bool) -> int:
    build_state(cfg)  # fail early with a readable error
    server = make_server(cfg.path, port=port)
    url = f"http://127.0.0.1:{server.server_address[1]}/"
    print(f"psc editor: {url}  (editing {cfg.path}; Ctrl-C to stop)")
    if open_browser:
        webbrowser.open(url)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0
