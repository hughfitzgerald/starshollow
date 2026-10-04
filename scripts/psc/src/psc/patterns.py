"""Expands a layer into per-light keyframes.

A keyframe means "starting at t, fade to value over `fade` ms". A value of
None is a release: the layer lets go of the light, and whatever is beneath
shows through (fading over `fade` ms)."""

import dataclasses
import math
from dataclasses import dataclass

from .errors import PscError
from .hwmap import HardwareMap
from .shows import Layer
from .values import quantize


@dataclass(frozen=True)
class Value:
    brightness: float  # 0-100
    color: str         # 6 hex digits, or a GLF token like (color)


@dataclass(frozen=True)
class Keyframe:
    t: int
    value: Value | None
    fade: int
    seq: int  # generation order; breaks ties at equal t (later wins)


class _Builder:
    def __init__(self, grid: int):
        self.grid = grid
        self.frames: dict[str, list[Keyframe]] = {}
        self.seq = 0
        self.end = 0  # when the layer's pattern is over, including trailing off-time

    def until(self, t: float):
        self.end = max(self.end, quantize(t, self.grid))

    def add(self, light: str, t: float, value: Value | None, fade: float = 0):
        self.seq += 1
        self.frames.setdefault(light, []).append(Keyframe(quantize(t, self.grid), value, quantize(fade, self.grid), self.seq))
        self.until(t + fade)


def light_value(layer: Layer, hw: HardwareMap, name: str, brightness: float | None = None) -> Value:
    color = layer.color or hw.light(name).color
    return Value(layer.brightness if brightness is None else brightness, color)


DIRECTIONS = {
    "up": lambda x, y: -y,
    "down": lambda x, y: y,
    "left": lambda x, y: -x,
    "right": lambda x, y: x,
}


def _anchor(layer: Layer, hw: HardwareMap, name: str | None):
    if not name:
        raise PscError(f"{layer.where}: an anchor is required")
    if name not in hw.anchors:
        raise PscError(f"{layer.where}: unknown anchor {name!r}")
    return hw.anchors[name]


def order_lights(layer: Layer, hw: HardwareMap, order: str) -> list[str]:
    names = list(layer.targets)
    pos = {n: (hw.light(n).x, hw.light(n).y) for n in names}
    if order == "listed":
        return names
    if order in ("x", "-x", "y", "-y"):
        axis = 0 if order.endswith("x") else 1
        sign = -1 if order.startswith("-") else 1
        return sorted(names, key=lambda n: sign * pos[n][axis])
    kind, _, anchor_name = order.partition(":")
    if kind in ("angle", "distance"):
        ax, ay = _anchor(layer, hw, anchor_name)
        if kind == "distance":
            return sorted(names, key=lambda n: math.hypot(pos[n][0] - ax, pos[n][1] - ay))
        # clockwise from 12 o'clock; VPX y grows downward
        return sorted(names, key=lambda n: math.atan2(pos[n][0] - ax, -(pos[n][1] - ay)) % (2 * math.pi))
    raise PscError(f"{layer.where}: order must be listed, x, -x, y, -y, angle:<anchor> or distance:<anchor>, got {order!r}")


def expand_layer(layer: Layer, hw: HardwareMap, grid: int = 10) -> tuple[dict[str, list[Keyframe]], int]:
    """Returns (keyframes per light, end time of the pattern).

    A layer with `each:` has several target lists; the pattern runs once per
    list, all starting together, into one set of keyframes."""
    b = _Builder(grid)
    for targets in layer.target_sets or [layer.targets]:
        _expand_into(b, dataclasses.replace(layer, targets=targets), hw)
    return b.frames, b.end


def _expand_into(b: _Builder, layer: Layer, hw: HardwareMap):
    p = layer.params
    start = layer.start

    if layer.pattern == "solid":
        for n in layer.targets:
            b.add(n, start, light_value(layer, hw, n), p["fade"])
            if p["duration"] is not None:
                b.add(n, start + p["duration"], None, p["tail"])

    elif layer.pattern == "flash":
        on, off = p["on"], p["off"] if p["off"] is not None else p["on"]
        if p["count"] < 1:
            raise PscError(f"{layer.where}: count must be at least 1")
        for i in range(p["count"]):
            t = start + i * (on + off)
            for n in layer.targets:
                b.add(n, t, light_value(layer, hw, n), p["fade"])
                b.add(n, t + on, None, p["fade"])
        b.until(start + p["count"] * (on + off))

    elif layer.pattern == "chase":
        names = order_lights(layer, hw, p["order"])
        width, interval = p["width"], p["interval"]
        if width < 1 or (p["count"] > 1 and width >= len(names)):
            raise PscError(f"{layer.where}: width must be at least 1 and, when count > 1, less than the number of lights ({len(names)})")
        if interval <= 0:
            raise PscError(f"{layer.where}: interval must be greater than 0")
        for k in range(p["count"] * len(names)):
            n = names[k % len(names)]
            t_on = start + k * interval
            b.add(n, t_on, light_value(layer, hw, n), p["fade"])
            b.add(n, t_on + width * interval, None, p["tail"])

    elif layer.pattern == "sweep":
        direction = p["direction"]
        speed = p["speed"]
        if speed <= 0:
            raise PscError(f"{layer.where}: speed must be greater than 0")
        if direction in DIRECTIONS:
            progress = {n: DIRECTIONS[direction](hw.light(n).x, hw.light(n).y) for n in layer.targets}
        elif direction in ("out", "in"):
            ax, ay = _anchor(layer, hw, p["anchor"])
            sign = 1 if direction == "out" else -1
            progress = {n: sign * math.hypot(hw.light(n).x - ax, hw.light(n).y - ay) for n in layer.targets}
        else:
            raise PscError(f"{layer.where}: direction must be up, down, left, right, out or in, got {direction!r}")
        low = min(progress.values())
        span = max(progress.values()) - low
        on_ms = p["width"] / speed * 1000
        pass_ms = (span + p["width"]) / speed * 1000 + p["gap"]
        if p["count"] < 1:
            raise PscError(f"{layer.where}: count must be at least 1")
        for i in range(p["count"]):
            for n in layer.targets:
                t_on = start + i * pass_ms + (progress[n] - low) / speed * 1000
                b.add(n, t_on, light_value(layer, hw, n), p["fade"])
                b.add(n, t_on + on_ms, None, p["tail"])
        b.until(start + p["count"] * pass_ms)

    elif layer.pattern == "breathe":
        period = p["period"]
        if period < 20:
            raise PscError(f"{layer.where}: period must be at least 20ms")
        high = layer.brightness if p["max"] is None else p["max"]
        low = p["min"]
        if not (0 <= low <= 100 and 0 <= high <= 100):
            raise PscError(f"{layer.where}: min and max must be between 0 and 100")
        if p["cycles"] < 1:
            raise PscError(f"{layer.where}: cycles must be at least 1")
        half = period / 2
        for c in range(p["cycles"]):
            t = start + c * period
            for n in layer.targets:
                b.add(n, t, light_value(layer, hw, n, high), half)
                b.add(n, t + half, light_value(layer, hw, n, low), half)
        for n in layer.targets:
            b.add(n, start + p["cycles"] * period, None, 0)

    elif layer.pattern == "beat":
        step = p["step_ms"]
        attack, decay = p["attack"], p["decay"]
        hold = max(p["hold"], b.grid)  # a peak shows for at least one step
        if p["count"] < 1:
            raise PscError(f"{layer.where}: count must be at least 1")
        steps = max(track.steps for track in p["tracks"])
        peaks: dict[str, dict[int, float]] = {}
        for repeat in range(p["count"]):
            for track in p["tracks"]:
                for index, peak in track.hits:
                    for n in track.targets:
                        light = peaks.setdefault(n, {})
                        i = repeat * steps + index
                        light[i] = max(light.get(i, 0.0), peak)  # brighter hit wins
        loop_ms = steps * p["count"] * step
        for n, hits in peaks.items():
            order = sorted(hits)
            times = [start + i * step for i in order]
            rises = [t - attack for t in times]
            # A rise that would start before the layer begins wraps into the end
            # of the pattern, so the hit is anticipated when the show loops.
            wrap = rises[0] < start
            for k, t in enumerate(times):
                rise = max(start, rises[k])
                b.add(n, rise, light_value(layer, hw, n, hits[order[k]] * layer.brightness / 100), t - rise)
                release = t + hold
                if k + 1 < len(times):
                    next_rise = max(start, rises[k + 1])
                elif wrap:
                    next_rise = rises[0] + loop_ms
                else:
                    next_rise = None
                if next_rise is not None and release >= next_rise:
                    continue  # the next hit starts rising before this one lets go
                b.add(n, release, None, decay)
            if wrap:
                b.add(n, rises[0] + loop_ms, light_value(layer, hw, n, hits[order[0]] * layer.brightness / 100), attack)
        b.until(start + loop_ms)
