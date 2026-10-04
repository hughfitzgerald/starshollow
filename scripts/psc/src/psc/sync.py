"""Plans and applies changes to the extracted table JSON: group tags in each
light's blink_pattern, and hidden proxy lights for backglass bulbs."""

import copy
import json
from dataclasses import dataclass
from typing import Callable

from .b2s import read_backglass
from .config import Bulb, Config
from .errors import ErrorCollector, PscError
from .groups import desired_tags, light_universe, resolve_groups
from .table import (Table, dump_json, read_json, rewrite_json,
                    set_blink_pattern)

# Proxies sit above the playfield's top edge, mirroring the backglass layout:
# the bottom of the backglass is nearest the playfield.
PROXY_MARGIN = 100.0
PROXY_SPAN = 400.0
POSITION_TOLERANCE = 0.01


@dataclass
class Change:
    kind: str
    target: str
    detail: str
    apply: Callable[[], None]

    def describe(self) -> str:
        return f"{self.kind:<8} {self.target}: {self.detail}"


def proxy_positions(cfg: Config, table: Table) -> dict[str, tuple[float, float]]:
    errors = ErrorCollector()
    backglass = None
    needs_b2s = [b for b in cfg.bulbs.values() if b.position is None]
    if needs_b2s:
        if cfg.directb2s is None or not cfg.directb2s.is_file():
            names = ", ".join(b.name for b in needs_b2s)
            raise PscError(f"backglass bulbs {names} have no position and the backglass file "
                           f"({cfg.directb2s or 'backglass.source'}) is missing; set position: [x, y]")
        backglass = read_backglass(cfg.directb2s)
    positions = {}
    width = table.right - table.left
    for bulb in cfg.bulbs.values():
        if bulb.position is not None:
            positions[bulb.name] = bulb.position
            continue
        center = backglass.centers.get(bulb.b2s_id)
        if center is None:
            errors.add(f"backglass bulb {bulb.name}: B2SID {bulb.b2s_id} not found in {cfg.directb2s.name}")
            continue
        bx, by = center
        x = table.left + bx / backglass.width * width
        y = table.top - PROXY_MARGIN - (1 - by / backglass.height) * PROXY_SPAN
        positions[bulb.name] = (round(x, 4), round(y, 4))
    errors.raise_if_any()
    return positions


def pick_template(cfg: Config, table: Table, universe: list[str]):
    proxies = {b.name.lower() for b in cfg.bulbs.values()}
    if cfg.proxy_template:
        record = table.light(cfg.proxy_template)
        if record is None:
            raise PscError(f"backglass.template: light {cfg.proxy_template!r} not found")
        return record
    for name in universe:
        if name.lower() not in proxies and table.light(name):
            return table.light(name)
    raise PscError("no light available to use as the proxy template; set backglass.template")


def _move_light(light: dict, x: float, y: float):
    old = light.get("center", {"x": 0.0, "y": 0.0})
    dx, dy = x - old.get("x", 0.0), y - old.get("y", 0.0)
    light["center"] = {"x": x, "y": y}
    for point in light.get("drag_points", []):
        point["x"] = round(point["x"] + dx, 4)
        point["y"] = round(point["y"] + dy, 4)


def plan_sync(cfg: Config, table: Table) -> list[Change]:
    universe = light_universe(cfg, table)
    groups = resolve_groups(cfg, table, universe)
    tags = desired_tags(groups, universe)
    changes: list[Change] = []

    if cfg.bulbs:
        positions = proxy_positions(cfg, table)
        template = None
        collection_items = {i.lower() for i in table.collection_items(cfg.collection) or []}
        for bulb in cfg.bulbs.values():
            x, y = positions[bulb.name]
            record = table.light(bulb.name)
            if record is None:
                template = template or pick_template(cfg, table, universe)
                changes.append(_create_proxy(cfg, table, template, bulb, x, y, tags[bulb.name]))
            else:
                if abs(record.x - x) > POSITION_TOLERANCE or abs(record.y - y) > POSITION_TOLERANCE:
                    changes.append(Change("move", record.name, f"({record.x:g}, {record.y:g}) -> ({x:g}, {y:g})",
                                          _rewrite_light(record.path, lambda d, x=x, y=y: _move_light(d, x, y))))
                if record.visible:
                    changes.append(Change("hide", record.name, "visible -> false",
                                          _rewrite_light(record.path, lambda d: d.__setitem__("visible", False))))
            if bulb.name.lower() not in collection_items:
                changes.append(Change("collect", bulb.name, f"add to {cfg.collection}",
                                      lambda name=bulb.name: _add_to_collection(table, cfg.collection, name)))

    for name in universe:
        record = table.light(name)
        if record is None:
            continue  # proxy being created; its tags are set at creation
        if record.blink_pattern != tags[name]:
            changes.append(Change("tags", record.name, f"{record.blink_pattern!r} -> {tags[name]!r}",
                                  lambda path=record.path, value=tags[name]: set_blink_pattern(path, value)))
    return changes


def _rewrite_light(path, mutate):
    return lambda: rewrite_json(path, lambda data: mutate(data["Light"]))


def _create_proxy(cfg: Config, table: Table, template, bulb: Bulb, x: float, y: float, tags: str) -> Change:
    def apply():
        data = copy.deepcopy(read_json(template.path))
        light = data["Light"]
        light["name"] = bulb.name
        _move_light(light, x, y)
        light["visible"] = False
        light["blink_pattern"] = tags
        light["is_timer_enabled"] = False
        light["is_backglass"] = False
        if bulb.color:
            light["color"] = "#" + bulb.color
        path = table.dir / "gameitems" / f"Light.{bulb.name}.json"
        path.write_text(dump_json(data), encoding="utf-8")

        def add_index(items):
            file_name = f"Light.{bulb.name}.json"
            if any(i.get("file_name") == file_name for i in items):
                return
            entry = next((dict(i) for i in items if i.get("file_name") == template.path.name),
                         {"is_locked": False, "editor_layer": 0, "editor_layer_visibility": True})
            entry["file_name"] = file_name
            items.append(entry)
        rewrite_json(table.gameitems_path, add_index)

    return Change("create", bulb.name, f"proxy light at ({x:g}, {y:g}) cloned from {template.name}", apply)


def _add_to_collection(table: Table, collection: str, name: str):
    def mutate(collections):
        for c in collections:
            if c.get("name", "").lower() == collection.lower():
                if name.lower() not in (i.lower() for i in c["items"]):
                    c["items"].append(name)
                return
        raise PscError(f"collection {collection!r} not found")
    rewrite_json(table.collections_path, mutate)


def apply_changes(changes: list[Change]):
    order = {"create": 0, "move": 1, "hide": 2, "collect": 3, "tags": 4}
    for change in sorted(changes, key=lambda c: order.get(c.kind, 9)):
        change.apply()


def import_groups(cfg: Config, table: Table) -> str:
    """YAML for a `groups:` block built from the tags currently in the JSON."""
    universe = light_universe(cfg, table)
    groups: dict[str, list[str]] = {}
    for name in universe:
        record = table.light(name)
        if record is None:
            continue
        for tag in [t.strip() for t in record.blink_pattern.split(",") if t.strip()]:
            if tag == "10":  # VPX's default blink pattern, not a real tag
                continue
            groups.setdefault(tag, []).append(record.name)
    lines = ["groups:"]
    for tag, members in groups.items():
        lines.append(f"  {tag}:")
        lines.append(f"    members: [{', '.join(members)}]")
    return "\n".join(lines) + "\n"
