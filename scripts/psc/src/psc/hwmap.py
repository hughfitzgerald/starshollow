"""The compile-time hardware map. Group membership is read back from the
light JSON tags; group order comes from hardware.yaml."""

import fnmatch
from dataclasses import dataclass

from .config import Config
from .errors import ErrorCollector, PscError
from .groups import light_universe, natural_key, resolve_groups
from .table import Table, tags_of


@dataclass
class HwLight:
    name: str
    x: float
    y: float
    tags: tuple[str, ...]
    color: str
    color_source: str
    proxy: bool
    b2s_id: int | None = None
    threshold: int = 0


@dataclass
class HardwareMap:
    lights: dict[str, HwLight]          # keyed by lowercase name
    order: list[str]                    # canonical names in collection order
    groups: dict[str, list[str]]
    anchors: dict[str, tuple[float, float]]

    def light(self, name: str) -> HwLight | None:
        return self.lights.get(name.lower())

    def group(self, name: str) -> list[str] | None:
        for group, members in self.groups.items():
            if group.lower() == name.lower():
                return members
        return None

    def resolve_target(self, target, where: str) -> list[str]:
        items = target if isinstance(target, list) else [target]
        if not items:
            raise PscError(f"{where}: target is empty")
        out: list[str] = []
        for item in items:
            if not isinstance(item, str):
                raise PscError(f"{where}: target entries must be names, got {item!r}")
            members = self.group(item)
            if members is None:
                light = self.light(item)
                if light is None:
                    raise PscError(f"{where}: unknown target {item!r} (not a group or GLF light)")
                members = [light.name]
            for m in members:
                if m not in out:
                    out.append(m)
        return out

    def resolve_each(self, spec, where: str) -> list[tuple[str, list[str]]]:
        """`each:` fans a layer out: one (name, target list) per entry. An entry
        is a group, a light, or a glob over group names such as `groove_*`."""
        items = spec if isinstance(spec, list) else [spec]
        if not items:
            raise PscError(f"{where}: each is empty")
        sets: list[tuple[str, list[str]]] = []
        for item in items:
            if not isinstance(item, str):
                raise PscError(f"{where}: each entries must be names, got {item!r}")
            if any(ch in item for ch in "*?["):
                names = sorted((g for g in self.groups if fnmatch.fnmatchcase(g.lower(), item.lower())), key=natural_key)
                if not names:
                    raise PscError(f"{where}: no group matches {item!r}")
                for g in names:
                    if not self.groups[g]:
                        raise PscError(f"{where}: group {g!r} has no lights")
                    sets.append((g, list(self.groups[g])))
            else:
                members = self.resolve_target(item, where)
                if not members:
                    raise PscError(f"{where}: {item!r} has no lights")
                sets.append((item, members))
        return sets


def build_map(cfg: Config, table: Table) -> HardwareMap:
    universe = light_universe(cfg, table)
    config_groups = resolve_groups(cfg, table, universe)
    errors = ErrorCollector()
    bulbs = {b.name.lower(): b for b in cfg.bulbs.values()}

    lights: dict[str, HwLight] = {}
    for name in universe:
        record = table.light(name)
        if record is None:
            errors.add(f"light {name} is missing from gameitems; run `psc sync`")
            continue
        bulb = bulbs.get(name.lower())
        lights[name.lower()] = HwLight(
            name=record.name, x=record.x, y=record.y,
            tags=tuple(tags_of(record.blink_pattern)), color="", color_source="",
            proxy=bulb is not None,
            b2s_id=bulb.b2s_id if bulb else None,
            threshold=bulb.threshold if bulb else 0,
        )
    errors.raise_if_any()

    groups: dict[str, list[str]] = {}
    for group, ordered in config_groups.items():
        tagged = {l.name for l in lights.values() if group in l.tags}
        groups[group] = [n for n in ordered if n in tagged] + sorted(tagged - set(ordered))

    group_colors = {g.name: g.color for g in cfg.groups.values() if g.color}
    # Every light's default color comes from hardware.yaml: its own entry,
    # else a group color, else (backglass bulbs) the bulb entry.
    missing = []
    for light in lights.values():
        if light.name.lower() in cfg.light_colors:
            light.color, light.color_source = cfg.light_colors[light.name.lower()], "light"
            continue
        owners = {g: group_colors[g] for g in light.tags if g in group_colors}
        if len(set(owners.values())) > 1:
            listed = ", ".join(f"{g}={c}" for g, c in owners.items())
            errors.add(f"light {light.name}: groups disagree on color ({listed}); give it its own color under lights:")
        elif owners:
            group, color = next(iter(owners.items()))
            light.color, light.color_source = color, f"group {group}"
        elif light.proxy and bulbs[light.name.lower()].color:
            light.color, light.color_source = bulbs[light.name.lower()].color, "bulb"
        else:
            missing.append(light.name)
    if missing:
        errors.add(f"{len(missing)} light(s) have no color in {cfg.path.name}; add them under lights: "
                   f"(e.g. `{missing[0]}: ffffff`): {', '.join(missing)}")
    errors.raise_if_any()

    order = [lights[n.lower()].name for n in universe if n.lower() in lights]
    return HardwareMap(lights=lights, order=order, groups=groups, anchors=dict(cfg.anchors))
