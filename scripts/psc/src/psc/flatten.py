"""Merges a show's layers into one timeline per light.

At any moment a light shows its highest-priority layer that holds it. When
that layer releases the light, the light falls back to the layer beneath,
using that layer's interpolated value, or stops if no layer holds it.

GLF cannot fade to "stop", so a release with a fade and nothing beneath
becomes a fade to black followed by a stop."""

import bisect
from dataclasses import dataclass

from .patterns import Keyframe, Value
from .values import HEX_RE

STOP = "stop"
BLACK = Value(0, "000000")


@dataclass(frozen=True)
class Emission:
    t: int
    out: object  # Value or STOP
    fade: int


def _rgb(v: Value):
    c = int(v.color, 16)
    scale = v.brightness / 100
    return [((c >> s) & 255) * scale for s in (16, 8, 0)]


def lerp(a: Value, b: Value, p: float) -> Value:
    p = max(0.0, min(1.0, p))
    if p >= 1:
        return b
    if a.color == b.color:
        return Value(a.brightness + (b.brightness - a.brightness) * p, b.color)
    if a.brightness <= 0:  # fading up from black
        return Value(b.brightness * p, b.color)
    if b.brightness <= 0:  # fading down to black
        return Value(a.brightness * (1 - p), a.color)
    if HEX_RE.match(a.color) and HEX_RE.match(b.color):
        ca, cb = _rgb(a), _rgb(b)
        mixed = [round(x + (y - x) * p) for x, y in zip(ca, cb)]
        return Value(100, "".join(f"{max(0, min(255, c)):02x}" for c in mixed))
    return b if p > 0 else a


class LayerTrack:
    """One layer's keyframes for one light, with O(log n) state lookup."""

    def __init__(self, priority: tuple, frames: list[Keyframe]):
        self.priority = priority
        self.frames = sorted(frames, key=lambda k: (k.t, k.seq))
        self.times = [k.t for k in self.frames]
        self.start_values: list[Value | None] = []
        for i, kf in enumerate(self.frames):
            self.start_values.append(self._eval(i, kf.t))

    def _eval(self, upto: int, t: float) -> Value | None:
        """State at time t considering only frames[:upto]."""
        if upto == 0:
            return None
        kf = self.frames[upto - 1]
        if kf.value is None:
            return None
        if kf.fade <= 0 or t >= kf.t + kf.fade:
            return kf.value
        frm = self.start_values[upto - 1] or Value(0, kf.value.color)
        return lerp(frm, kf.value, (t - kf.t) / kf.fade)

    def state(self, t: float) -> Value | None:
        return self._eval(bisect.bisect_right(self.times, t), t)

    def active_frame(self, t: float) -> Keyframe | None:
        i = bisect.bisect_right(self.times, t)
        return self.frames[i - 1] if i else None

    def frame_at(self, t: int) -> Keyframe | None:
        """The last (winning) keyframe exactly at t, if any."""
        i = bisect.bisect_right(self.times, t)
        return self.frames[i - 1] if i and self.frames[i - 1].t == t else None


def flatten_light(tracks: list[LayerTrack], length: int) -> list[Emission]:
    tracks = sorted(tracks, key=lambda tr: tr.priority, reverse=True)
    times = sorted({kf.t for tr in tracks for kf in tr.frames})
    out: list[Emission] = []
    prev_top: LayerTrack | None = None
    shown: Value | None = None
    pending_stop: int | None = None

    def emit(t, value, fade):
        nonlocal shown
        out.append(Emission(t, value, fade))
        shown = None if value is STOP else value

    i = 0
    while i < len(times):
        t = times[i]
        i += 1
        top = next((tr for tr in tracks if tr.state(t) is not None), None)
        if top is None:
            if prev_top is not None:
                kf = prev_top.frame_at(t)
                fade = kf.fade if kf is not None and kf.value is None else 0
                if fade > 0:
                    emit(t, Value(0, shown.color if shown else "000000"), fade)
                    pending_stop = t + fade
                    if pending_stop not in times:
                        bisect.insort(times, pending_stop, lo=i)
                else:
                    emit(t, STOP, 0)
            elif pending_stop == t:
                emit(t, STOP, 0)
                pending_stop = None
        else:
            pending_stop = None
            kf = top.frame_at(t)
            if kf is not None and kf.value is not None:
                emit(t, kf.value, kf.fade)
            elif top is not prev_top:
                # revealed: the layer above released this light
                above = prev_top.frame_at(t) if prev_top else None
                fade = above.fade if above is not None and above.value is None else 0
                active = top.active_frame(t)
                remaining = active.t + active.fade - t
                if remaining > 0:
                    # mid-fade: continue toward the layer's target
                    emit(t, active.value, max(remaining, fade))
                else:
                    emit(t, top.state(t), fade)
        prev_top = top

    out = [e for e in out if e.t < length]
    if not out or out[0].t != 0:
        # reset at the start of every loop, so nothing carries over
        out.insert(0, Emission(0, STOP, 0))
    return out

