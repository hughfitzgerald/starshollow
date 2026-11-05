"""DOF pulses: fire a DOF event each time a mapped light flashes in a show.

A pulse fires where a light's brightness rises past its threshold, so a dim
baseline stays quiet and each hit on top of it counts. This runs on the
flattened timeline, before fades are rendered into frames, so a fade is one
rise and its crossing time can be worked out exactly."""

from .flatten import STOP, Emission
from .hwmap import HardwareMap
from .values import GRID_MS, quantize


def _level(out) -> float:
    if out is STOP or out.color == "000000":
        return 0.0
    return float(out.brightness)


def rising_edges(events: list[Emission], length: int, threshold: float) -> list[float]:
    """Times (ms) where brightness rises past the threshold. Every loop starts
    from off, because a show resets its lights at time 0."""
    edges: list[float] = []
    level = 0.0
    for i, e in enumerate(events):
        target = _level(e.out)
        end = events[i + 1].t if i + 1 < len(events) else length
        reached = target
        if e.fade > 0 and end - e.t < e.fade:  # the next emission interrupts this fade
            reached = level + (target - level) * (end - e.t) / e.fade
        if level <= threshold < reached:
            edges.append(e.t + e.fade * (threshold - level) / (target - level) if e.fade > 0 else e.t)
        level = reached
    return edges


def show_pulses(emissions: dict[str, list[Emission]], length: int, hw: HardwareMap, grid: int = GRID_MS) -> dict[int, list[int]]:
    """{step time: [DOF events]} for one show's flattened timeline."""
    pulses: dict[int, list[int]] = {}
    last = max(length - GRID_MS, 0)
    for name in hw.order:
        pulse = hw.dof_pulses.get(name)
        if pulse is None or name not in emissions:
            continue
        previous = None
        for edge in rising_edges(emissions[name], length, pulse.threshold):
            t = min(quantize(edge, grid), last)
            if previous is None or t - previous >= pulse.min_gap:
                pulses.setdefault(t, []).append(pulse.event)
                previous = t
    return pulses
