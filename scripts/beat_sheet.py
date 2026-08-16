"""
beat_sheet.py

A tiny, human-typable text format for drum-style beat patterns, designed to
be trivial to parse with the standard library and to feed straight into
generate_bezier_pulse_track.build_animation_tres().

There's real prior art here worth knowing about before you invent your own:

  - ASCII drum tabs: the format drummers already use on tab sites --
    one line per instrument, '-' or '.' for rest, 'x' for hit, e.g.
        HH: x-x-x-x-x-x-x-x-
        SN: ----o-------o---
    This is the most common "textual beats" convention in the wild.

  - TidalCycles mini-notation (used in live coding): whitespace-separated
    steps like "x ~ x ~ x x ~ x", with brackets for subdivision/polymeter,
    "*"/"!" for repeats, etc. Much more expressive, but it's a real
    grammar -- more than you need for "trigger 6 objects at points in
    time," and pulls in a parser dependency.

This format below is a simple grid/tab notation (closer to the drum-tab
family), because your case is just "which step, if any, does each object
fire on" -- a fixed-subdivision grid captures that with zero ambiguity and
parses in about 30 lines of Python.

------------------------------------------------------------------------
THE FORMAT

    # comments start with '#', blank lines ignored
    bpm: 128
    steps_per_beat: 4          # optional, defaults to 4 (16th notes)

    LowerLeft:  x...x...x...x...
    LowerRight: ..x...x...x...x.
    UpperLeft:  x.x.x.x.x.x.x.x.
    UpperRight: ....X...........   # capital X = accent (see hit_values)
    MidLeft:    x..x..x..x..x..x..
    MidRight:   ......x.....x.....

Rules:
  - "Name: pattern" -- everything after the first ':' is the pattern.
  - Within a pattern, '.', '-', '_' are rests; any other non-whitespace,
    non-'|' character is a hit. '|' and spaces are purely visual and are
    stripped -- "x . . ." and "x..." and "x.|.." all mean the same thing.
  - Each character position is one grid step, `60 / bpm / steps_per_beat`
    seconds long, counted from the start of the pattern (t=0).
  - The same track name can appear on multiple lines -- the patterns are
    concatenated in order, so you can write one bar per line:
        LowerLeft: x...x...
        LowerLeft: x.......   # bar 2
  - By default 'x' and 'X' are both hits mapped to the same value; pass a
    custom `hit_values` dict to `parse_beat_sheet()` to use other symbols
    or give different symbols different accent heights (e.g. {'x': 0.8,
    'X': 1.0, 'o': 0.5}).
------------------------------------------------------------------------
"""

from __future__ import annotations
import re
from dataclasses import dataclass, field

REST_CHARS = set(".-_")
IGNORE_CHARS = set("| \t")
DEFAULT_HIT_VALUES = {"x": 1.0, "X": 1.0}

_BPM_RE = re.compile(r"^\s*bpm\s*[:=]\s*([\d.]+)\s*$", re.IGNORECASE)
_SPB_RE = re.compile(r"^\s*steps_per_beat\s*[:=]\s*(\d+)\s*$", re.IGNORECASE)


@dataclass
class BeatTrack:
    name: str
    hit_times: list[float] = field(default_factory=list)
    hit_values: list[float] = field(default_factory=list)


def parse_beat_sheet(
    text: str,
    hit_values: dict[str, float] | None = None,
) -> tuple[dict[str, BeatTrack], float, int]:
    """
    Parse a beat-sheet string (see module docstring for the format).

    Returns (tracks, bpm, steps_per_beat) where `tracks` is an ordered
    dict of track name -> BeatTrack (hit_times in seconds, hit_values
    parallel list of the value each hit symbol maps to).
    """
    hit_values = hit_values or DEFAULT_HIT_VALUES

    bpm: float | None = None
    steps_per_beat = 4
    patterns: dict[str, str] = {}
    order: list[str] = []

    for lineno, raw_line in enumerate(text.splitlines(), start=1):
        line = raw_line.split("#", 1)[0].rstrip()
        if not line.strip():
            continue

        m = _BPM_RE.match(line)
        if m:
            bpm = float(m.group(1))
            continue

        m = _SPB_RE.match(line)
        if m:
            steps_per_beat = int(m.group(1))
            continue

        if ":" not in line:
            raise ValueError(f"Line {lineno}: can't parse (missing ':'): {raw_line!r}")

        name, pattern = line.split(":", 1)
        name = name.strip()
        pattern = "".join(ch for ch in pattern if ch not in IGNORE_CHARS)

        if name not in patterns:
            patterns[name] = ""
            order.append(name)
        patterns[name] += pattern

    if bpm is None:
        raise ValueError("No 'bpm: <number>' line found in the beat sheet.")
    if bpm <= 0:
        raise ValueError(f"bpm must be positive, got {bpm}")

    seconds_per_step = 60.0 / bpm / steps_per_beat

    tracks: dict[str, BeatTrack] = {}
    for name in order:
        bt = BeatTrack(name=name)
        for i, ch in enumerate(patterns[name]):
            if ch in REST_CHARS:
                continue
            if ch not in hit_values:
                raise ValueError(
                    f"Track {name!r}: unknown symbol {ch!r}. Use '.'/'-'/'_' "
                    f"for a rest, or add {ch!r} to hit_values if it's meant "
                    f"to be a hit (known hits: {sorted(hit_values)})."
                )
            bt.hit_times.append(round(i * seconds_per_step, 6))
            bt.hit_values.append(hit_values[ch])
        tracks[name] = bt

    return tracks, bpm, steps_per_beat


def beat_sheet_to_tracks(
    text: str,
    node_paths: dict[str, str],
    min_value: float = 0.431,
    max_value: float = 1.0,
    interval: float = 0.1,
    smoothing: float = 0.0,
    hit_values: dict[str, float] | None = None,
) -> tuple[list[dict], float]:
    """
    Parse a beat sheet and turn it directly into the `tracks` list that
    generate_bezier_pulse_track.build_animation_tres() expects.

    node_paths: maps each beat-sheet track name to its Godot NodePath, e.g.
        {"LowerLeft": "LowerLeft:modulate:a", "UpperLeft": "UpperLeft:modulate:a", ...}

    Returns (tracks, bpm) -- bpm is handed back in case you want it for
    logging/sanity-checking, or to compute the animation `length` yourself.
    """
    parsed, bpm, _steps_per_beat = parse_beat_sheet(text, hit_values=hit_values)

    tracks = []
    for name, bt in parsed.items():
        if not bt.hit_times:
            continue  # a track with no hits produces no keyframes -- skip it
        if name not in node_paths:
            raise KeyError(
                f"Beat sheet has a track named {name!r} but node_paths has "
                f"no entry for it. Add node_paths[{name!r}] = "
                f"'YourNode:modulate:a'."
            )
        # Only pass peak_values if the accents actually vary -- keeps the
        # generated .tres simpler when every hit is the same height.
        peak_values = bt.hit_values if len(set(bt.hit_values)) > 1 else None
        tracks.append({
            "path": node_paths[name],
            "peak_times": bt.hit_times,
            "peak_values": peak_values,
            "min_value": min_value,
            "max_value": max_value if peak_values is None else max(bt.hit_values),
            "interval": interval,
            "smoothing": smoothing,
        })
    return tracks, bpm


if __name__ == "__main__":
    from generate_bezier_pulse_track import build_animation_tres

    SHEET = """
    # Stars Hollow Showdown - flasher pattern
    bpm: 128
    steps_per_beat: 4

    LowerLeft:  x...x...x...x...
    LowerRight: ..x...x...x...x.
    UpperLeft:  x.x.x.x.x.x.x.x.
    UpperRight: ....X...........
    MidLeft:    x..x..x..x..x..x..
    MidRight:   ......x.....x.....
    """

    NODE_PATHS = {
        "LowerLeft":  "LowerLeft:modulate:a",
        "LowerRight": "LowerRight:modulate:a",
        "UpperLeft":  "UpperLeft:modulate:a",
        "UpperRight": "UpperRight:modulate:a",
        "MidLeft":    "MidLeft:modulate:a",
        "MidRight":   "MidRight:modulate:a",
    }

    tracks, bpm = beat_sheet_to_tracks(SHEET, NODE_PATHS, interval=0.08)
    print(f"# parsed at {bpm} BPM, {len(tracks)} tracks with hits\n")
    print(build_animation_tres("Animation_generated", "generated_flash", tracks))
