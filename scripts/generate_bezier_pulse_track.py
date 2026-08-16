"""
generate_bezier_pulse_track.py

Programmatically build Godot 4 "bezier" AnimationPlayer tracks that hold a
node's modulate alpha (or any float property) at a baseline value and pulse
it up to a peak value at specific times, then back down.

------------------------------------------------------------------------
THE FORMAT (reverse-engineered from Godot's own source,
scene/resources/animation.cpp):

    tracks/N/keys = {
        "times":        PackedFloat32Array(t0, t1, t2, ...)
        "points":       PackedFloat32Array(v0,inX0,inY0,outX0,outY0,  v1,inX1,inY1,outX1,outY1, ...)
        "handle_modes": PackedInt32Array(m0, m1, m2, ...)
    }

For every keyframe there are exactly 5 floats in "points", always in this
order:

    value        the actual value you set (e.g. 0.431 or 1.0)
    in_x, in_y   the "in" (left) tangent handle, as an OFFSET from (time, value)
    out_x, out_y the "out" (right) tangent handle, as an OFFSET from (time, value)

So len(points) == 5 * len(times) == 5 * len(handle_modes). A track with 20
keyframes has 100 floats in "points" -- that's why the flat array looks 5x
longer than the number of keys you placed. Only 1 out of every 5 numbers is
a value you actually set; the other 4 are tangent-handle offsets, which is
why the array is full of near-zero numbers (the handle Y-offset is 0
whenever the tangent is flat, which is exactly what you get at the top of a
spike or the bottom of a plateau -- i.e. most of the time in a min/max
pulse animation).

Also worth knowing: "handle_modes" (Free=0, Linear=1, Balanced=2,
Mirrored=3) is only read/written by the animation editor's curve-dragging
UI -- in Godot's C++ source it's compiled in under `#ifdef TOOLS_ENABLED`.
It has NO effect on playback. The actual curve shape at runtime is fully
determined by the raw in/out handle vectors, regardless of what
handle_modes says. So a script generating these doesn't need to get
handle_modes "right" for the animation to play correctly in-game -- it only
matters if you plan to keep hand-tweaking the curve afterwards in the
Godot editor (in which case matching mode to how you'd want to drag the
handle is a nicety, not a requirement).
------------------------------------------------------------------------
"""

from __future__ import annotations
from dataclasses import dataclass


@dataclass
class BezierKey:
    time: float
    value: float
    in_handle: tuple = (0.0, 0.0)
    out_handle: tuple = (0.0, 0.0)
    handle_mode: int = 1  # Linear -- cosmetic only, see module docstring


def build_pulse_keys(
    peak_times: list[float],
    min_value: float = 0.431,
    max_value: float = 1.0,
    interval: float = 0.1,
    smoothing: float = 0.0,
    clamp_start: bool = True,
    peak_values: list[float] | None = None,
) -> list[BezierKey]:
    """
    Build the keyframe list for a track that sits at `min_value`, spikes up
    to `max_value` at each time in `peak_times`, and returns to `min_value`
    `interval` seconds before / after each peak.

    smoothing:
        0.0 (default) = sharp linear ramps -- straight lines in and out of
            every key. This is a literal "quickly jumps up and back".
        > 0.0 (up to ~1.0) = rounds the corners by giving each key a flat
            (dy=0) tangent handle whose length is `smoothing * interval / 3`,
            similar to the flat-topped "Balanced" keys in a hand-authored
            curve -- eases in/out without changing the min/max values.

    clamp_start:
        If a peak is closer to t=0 than `interval`, its leading min-value
        keyframe would land at a negative time (Godot does allow negative
        key times, but it's rarely intentional). If True, that keyframe is
        clamped to t=0 instead, which just makes the initial ramp steeper.

    peak_values:
        Optional per-peak override for the height of each spike (e.g. for
        "accented" hits that should flash brighter than normal ones).
        Must be the same length as `peak_times` if given -- peak_values[i]
        is paired with peak_times[i] (they're sorted together). Falls back
        to a flat `max_value` for every peak when omitted.
    """
    if peak_values is not None:
        if len(peak_values) != len(peak_times):
            raise ValueError(
                f"peak_values (len {len(peak_values)}) must be the same "
                f"length as peak_times (len {len(peak_times)})."
            )
        paired = sorted(zip(peak_times, peak_values), key=lambda p: p[0])
        peak_times = [p[0] for p in paired]
        peak_values = [p[1] for p in paired]
    else:
        peak_times = sorted(peak_times)
        peak_values = [max_value] * len(peak_times)

    # Guard against overlapping triangles: peak[i]+interval must land
    # before peak[i+1]-interval, or keyframes would go out of chronological
    # order (which Godot won't accept).
    for a, b in zip(peak_times, peak_times[1:]):
        if b - a <= 2 * interval:
            raise ValueError(
                f"Peaks at {a} and {b} are only {b - a:.3f}s apart, but "
                f"need to be more than {2 * interval:.3f}s apart "
                f"(2 * interval) or their ramps will collide. Reduce "
                f"`interval` or space the peak times further apart."
            )

    raw_points: list[tuple[float, float]] = []
    for t, v_peak in zip(peak_times, peak_values):
        t_in = t - interval
        if clamp_start and t_in < 0:
            t_in = 0.0
        raw_points.append((t_in, min_value))
        raw_points.append((t, v_peak))
        raw_points.append((t + interval, min_value))

    # De-dupe consecutive identical times (can happen if clamp_start pulls
    # two leading keys both to t=0).
    dedup: list[tuple[float, float]] = []
    for pt in raw_points:
        if dedup and abs(dedup[-1][0] - pt[0]) < 1e-9:
            continue
        dedup.append(pt)

    keys: list[BezierKey] = []
    n = len(dedup)
    handle_len = smoothing * interval / 3.0
    for i, (t, v) in enumerate(dedup):
        in_handle = (-handle_len, 0.0) if i > 0 else (0.0, 0.0)
        out_handle = (handle_len, 0.0) if i < n - 1 else (0.0, 0.0)
        keys.append(BezierKey(time=t, value=v, in_handle=in_handle, out_handle=out_handle))

    return keys


def format_number(x: float) -> str:
    """Clean float literal formatting (rounds off binary-float noise)."""
    x = round(x, 6)
    if x == int(x):
        return str(int(x))
    return repr(x)


def keys_to_tres_dict_block(keys: list[BezierKey]) -> str:
    times = ", ".join(format_number(k.time) for k in keys)
    modes = ", ".join(str(k.handle_mode) for k in keys)
    pts: list[float] = []
    for k in keys:
        pts += [k.value, k.in_handle[0], k.in_handle[1], k.out_handle[0], k.out_handle[1]]
    points = ", ".join(format_number(p) for p in pts)

    return (
        "{\n"
        f'"handle_modes": PackedInt32Array({modes}),\n'
        f'"points": PackedFloat32Array({points}),\n'
        f'"times": PackedFloat32Array({times})\n'
        "}"
    )


def build_animation_tres(
    resource_id: str,
    resource_name: str,
    tracks: list[dict],
    length: float | None = None,
) -> str:
    """
    Build a full `[sub_resource type="Animation" ...]` text block containing
    one bezier track per entry in `tracks`.

    tracks: list of dicts, each:
        {
            "path": "LowerLeft:modulate:a",   # required, NodePath string
            "peak_times": [1.28, 2.55, 5.02], # required
            "min_value": 0.431,               # optional, defaults below
            "max_value": 1.0,                 # optional
            "interval": 0.1,                  # optional
            "smoothing": 0.0,                 # optional
            "peak_values": None,               # optional, per-peak accent override
        }

    length: animation length in seconds. Defaults to (last peak + interval)
        across all tracks if not given.
    """
    lines = [f'[sub_resource type="Animation" id="{resource_id}"]']
    lines.append(f'resource_name = "{resource_name}"')

    all_peaks = [t for tr in tracks for t in tr["peak_times"]]
    interval_max = max((tr.get("interval", 0.1) for tr in tracks), default=0.1)
    if length is None:
        length = (max(all_peaks) + interval_max) if all_peaks else 1.0
    lines.append(f"length = {format_number(length)}")

    for i, tr in enumerate(tracks):
        keys = build_pulse_keys(
            tr["peak_times"],
            min_value=tr.get("min_value", 0.431),
            max_value=tr.get("max_value", 1.0),
            interval=tr.get("interval", 0.1),
            smoothing=tr.get("smoothing", 0.0),
            peak_values=tr.get("peak_values"),
        )
        lines.append(f'tracks/{i}/type = "bezier"')
        lines.append("tracks/{}/imported = false".format(i))
        lines.append("tracks/{}/enabled = true".format(i))
        lines.append(f'tracks/{i}/path = NodePath("{tr["path"]}")')
        lines.append(f"tracks/{i}/interp = 1")
        lines.append(f"tracks/{i}/loop_wrap = true")
        lines.append(f"tracks/{i}/keys = {keys_to_tres_dict_block(keys)}")

    return "\n".join(lines)


if __name__ == "__main__":
    # Example: 6 objects, each flashing at its own set of times.
    # Swap in your real node names / paths and timing.
    tracks = [
        {"path": "LowerLeft:modulate:a",  "peak_times": [1.28, 2.55, 5.02, 6.23, 8.18, 8.72]},
        {"path": "LowerRight:modulate:a", "peak_times": [1.6, 3.0, 5.4]},
        {"path": "UpperLeft:modulate:a",  "peak_times": [2.0, 4.2, 6.6]},
        {"path": "UpperRight:modulate:a", "peak_times": [2.3, 4.5, 6.9]},
        {"path": "MidLeft:modulate:a",    "peak_times": [1.9, 3.8, 6.0]},
        {"path": "MidRight:modulate:a",   "peak_times": [2.2, 4.0, 6.3]},
    ]
    print(build_animation_tres("Animation_generated", "generated_flash", tracks))
