"""Turns flattened emissions into what GLF can actually play.

GLF quirk: when a show runs a step that has lights, it cancels every fade the
show's previous light step started, and those lights jump to their targets.
So a native GLF fade (the 4th light field) only survives if no other light
step in the same show lands inside it. Fades that would be cut are rendered
by PSC as explicit frames instead."""

from .flatten import BLACK, STOP, Emission, lerp
from .patterns import Value

FADE_FRAME_MS = 30


def _simulate(emissions: list[Emission], upto: int, until: float, shown: Value) -> Value:
    """Displayed value at `until`, playing emissions[:upto] from `shown`."""
    for i in range(upto):
        e = emissions[i]
        nxt = emissions[i + 1].t if i + 1 < upto else until
        target = BLACK if e.out is STOP else e.out
        if e.fade > 0 and nxt < e.t + e.fade:
            shown = lerp(shown, target, (nxt - e.t) / e.fade)
        else:
            shown = target
    return shown


def _shown_before(emissions: list[Emission], idx: int, length: int) -> Value:
    """The light's displayed value just before emissions[idx] starts. For the
    first emission that is where the previous loop left the light, so looping
    shows render seamlessly."""
    if idx == 0:
        return _simulate(emissions, len(emissions), length, BLACK)
    return _simulate(emissions, idx, emissions[idx].t, BLACK)


def _frames(emissions: list[Emission], idx: int, length: int, frame_ms: int) -> list[Emission]:
    e = emissions[idx]
    stop_at = min(emissions[idx + 1].t if idx + 1 < len(emissions) else length, length)
    frm = _shown_before(emissions, idx, length)
    out = []
    # Frames sit on a show-wide grid (multiples of FADE_FRAME_MS) so frames
    # from different lights share steps. The first frame is at the fade's start.
    t = e.t
    while t < stop_at:
        p = min(1.0, (t - e.t + frame_ms) / e.fade)
        out.append(Emission(t, lerp(frm, e.out, p), 0))
        if p >= 1.0:
            break
        t = (t // frame_ms + 1) * frame_ms
    return out


def render(emissions: dict[str, list[Emission]], length: int, resolution: int = 10) -> dict[str, list[Emission]]:
    frame_ms = max(FADE_FRAME_MS, resolution)
    frame_ms = -(-frame_ms // resolution) * resolution  # a multiple of the show's resolution
    fades = [(light, i) for light, es in emissions.items() for i, e in enumerate(es) if e.fade > 0]
    native = set(fades)
    while True:
        times = {e.t for es in emissions.values() for e in es}
        for light, i in fades:
            if (light, i) not in native:
                times.update(f.t for f in _frames(emissions[light], i, length, frame_ms))
        cut = {(light, i) for light, i in native
               if any(emissions[light][i].t < t < emissions[light][i].t + emissions[light][i].fade for t in times)}
        if not cut:
            break
        native -= cut

    rendered: dict[str, list[Emission]] = {}
    for light, es in emissions.items():
        out = []
        for i, e in enumerate(es):
            if e.fade > 0 and (light, i) not in native:
                out.extend(_frames(es, i, length, frame_ms))
            else:
                out.append(e)
        rendered[light] = out
    return rendered
