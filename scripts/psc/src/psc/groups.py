"""Resolves group member expressions to ordered light names."""

import fnmatch
import re

from .config import Config
from .errors import ErrorCollector, PscError
from .table import Table

GLOB_CHARS = set("*?[")
AREA_RE = re.compile(r"^\s*([xy])\s*(<=|>=|<|>)\s*(-?\d+(?:\.\d+)?)\s*$")
AREA_OPS = {"<": lambda a, b: a < b, "<=": lambda a, b: a <= b,
            ">": lambda a, b: a > b, ">=": lambda a, b: a >= b}


def parse_area(spec: str, where: str):
    """`x<476,y<700` -> list of (axis index, op, value)."""
    conditions = []
    for part in spec.split(","):
        m = AREA_RE.match(part)
        if not m:
            raise PscError(f"{where}: bad area condition {part.strip()!r}; use e.g. @area:x<476,y>=700")
        conditions.append((0 if m.group(1) == "x" else 1, AREA_OPS[m.group(2)], float(m.group(3))))
    return conditions


def light_positions(cfg: Config, table: Table, universe: list[str]) -> dict[str, tuple[float, float]]:
    """Table positions, plus computed positions for proxies not yet created."""
    positions = {}
    missing = []
    for name in universe:
        record = table.light(name)
        if record is not None:
            positions[name] = (record.x, record.y)
        else:
            missing.append(name)
    if missing:
        from .sync import proxy_positions  # local import: sync depends on this module
        computed = proxy_positions(cfg, table)
        for name in missing:
            positions[name] = computed[name]
    return positions


def natural_key(name: str):
    return [int(p) if p.isdigit() else p.lower() for p in re.split(r"(\d+)", name)]


def light_universe(cfg: Config, table: Table) -> list[str]:
    """Every light PSC manages: the GLF light collection plus backglass proxies."""
    items = table.collection_items(cfg.collection)
    if items is None:
        raise PscError(f"collection {cfg.collection!r} not found in {table.collections_path}")
    errors = ErrorCollector()
    names = []
    seen = set()
    for item in items:
        record = table.light(item)
        if record is None:
            errors.add(f"collection {cfg.collection}: {item!r} is not a Light in gameitems")
            continue
        if record.name.lower() not in seen:
            seen.add(record.name.lower())
            names.append(record.name)
    for bulb in cfg.bulbs.values():
        if bulb.name.lower() not in seen:
            seen.add(bulb.name.lower())
            names.append(bulb.name)
    errors.raise_if_any()
    return names


def resolve_groups(cfg: Config, table: Table, universe: list[str]) -> dict[str, list[str]]:
    by_lower = {n.lower(): n for n in universe}
    errors = ErrorCollector()
    for name in cfg.groups:
        if name.lower() in by_lower:
            errors.add(f"group {name!r} has the same name as a light")
    lowered = {}
    for name in cfg.groups:
        if name.lower() in lowered:
            errors.add(f"groups {lowered[name.lower()]!r} and {name!r} differ only by case")
        lowered[name.lower()] = name
    errors.raise_if_any()

    resolved: dict[str, list[str]] = {}
    visiting: list[str] = []
    positions: dict[str, tuple[float, float]] = {}

    def resolve(group_name: str) -> list[str]:
        if group_name in resolved:
            return resolved[group_name]
        if group_name in visiting:
            cycle = " -> ".join(visiting[visiting.index(group_name):] + [group_name])
            raise PscError(f"group cycle: {cycle}")
        visiting.append(group_name)
        out: list[str] = []
        for member in cfg.groups[group_name].members:
            for light in resolve_member(group_name, member):
                if light not in out:
                    out.append(light)
        excluded = set()
        for member in cfg.groups[group_name].exclude:
            excluded.update(resolve_member(group_name, member))
        out = [light for light in out if light not in excluded]
        visiting.pop()
        resolved[group_name] = out
        return out

    def resolve_member(group_name: str, member: str) -> list[str]:
        where = f"group {group_name}"
        if member.startswith("@collection:"):
            coll = member[len("@collection:"):]
            items = table.collection_items(coll)
            if items is None:
                raise PscError(f"{where}: collection {coll!r} not found")
            out = []
            for item in items:
                if item.lower() not in by_lower:
                    raise PscError(f"{where}: {item!r} from collection {coll} is not a GLF light")
                out.append(by_lower[item.lower()])
            return out
        if member.startswith("@area:"):
            conditions = parse_area(member[len("@area:"):], where)
            if not positions:
                positions.update(light_positions(cfg, table, universe))
            matches = [n for n in universe
                       if all(op(positions[n][axis], value) for axis, op, value in conditions)]
            if not matches:
                raise PscError(f"{where}: {member!r} contains no lights")
            return sorted(matches, key=natural_key)
        if member.startswith("@"):
            ref = member[1:]
            if ref not in cfg.groups:
                raise PscError(f"{where}: unknown group {ref!r}")
            return resolve(ref)
        if GLOB_CHARS & set(member):
            matches = [n for n in universe if fnmatch.fnmatchcase(n.lower(), member.lower())]
            if not matches:
                raise PscError(f"{where}: pattern {member!r} matches no lights")
            return sorted(matches, key=natural_key)
        if member.lower() not in by_lower:
            raise PscError(f"{where}: unknown light {member!r}")
        return [by_lower[member.lower()]]

    for name in cfg.groups:
        try:
            members = resolve(name)
            if not members:
                errors.add(f"group {name}: has no members")
        except PscError as e:
            errors.extend(e)
            visiting.clear()
    errors.raise_if_any()
    return {name: resolved[name] for name in cfg.groups}


def desired_tags(groups: dict[str, list[str]], universe: list[str]) -> dict[str, str]:
    """blink_pattern value for every managed light: sorted group names."""
    tags = {n: [] for n in universe}
    for group, members in groups.items():
        for light in members:
            tags[light].append(group)
    return {light: ",".join(sorted(names, key=str.lower)) for light, names in tags.items()}
