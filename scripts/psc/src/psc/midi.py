"""`psc midi`: turn a MIDI drum beat into PSC beat-layer notation.

Every note-on becomes a hit on the tempo step nearest to it; the note
number picks the track (named after the General MIDI drum map) and the
velocity picks the accent symbol. The tempo and time signature come from
the file. The output is a YAML snippet to paste into a show; rename the
tracks to light groups, or pass --map."""

import math
from dataclasses import dataclass, field
from pathlib import Path

from .errors import PscError

GM_DRUMS = {
    35: "kick_2", 36: "kick", 37: "sidestick", 38: "snare", 39: "clap", 40: "snare_2",
    41: "tom_floor_low", 42: "hihat", 43: "tom_floor", 44: "hihat_pedal", 45: "tom_low",
    46: "hihat_open", 47: "tom_mid", 48: "tom_high", 49: "crash", 50: "tom_high_2",
    51: "ride", 52: "china", 53: "ride_bell", 54: "tambourine", 55: "splash", 56: "cowbell",
    57: "crash_2", 58: "vibraslap", 59: "ride_2", 60: "bongo_high", 61: "bongo_low",
    62: "conga_mute", 63: "conga_open", 64: "conga_low", 65: "timbale_high", 66: "timbale_low",
    67: "agogo_high", 68: "agogo_low", 69: "cabasa", 70: "maracas", 71: "whistle_short",
    72: "whistle_long", 73: "guiro_short", 74: "guiro_long", 75: "claves", 76: "woodblock_high",
    77: "woodblock_low", 78: "cuica_mute", 79: "cuica_open", 80: "triangle_mute", 81: "triangle_open",
}
DRUM_CHANNEL = 9  # MIDI channel 10


@dataclass
class Note:
    tick: int
    number: int
    velocity: int
    channel: int


@dataclass
class Midi:
    division: int                    # ticks per quarter note
    notes: list[Note] = field(default_factory=list)
    tempos: list[tuple[int, float]] = field(default_factory=list)        # (tick, bpm)
    signatures: list[tuple[int, int, int]] = field(default_factory=list)  # (tick, numerator, denominator)


def _vlq(data: bytes, i: int) -> tuple[int, int]:
    value = 0
    while True:
        b = data[i]
        i += 1
        value = (value << 7) | (b & 0x7F)
        if not b & 0x80:
            return value, i


def read_midi(data: bytes, where: str = "midi") -> Midi:
    if data[:4] != b"MThd" or len(data) < 14:
        raise PscError(f"{where}: not a standard MIDI file")
    division = int.from_bytes(data[12:14], "big")
    if division & 0x8000:
        raise PscError(f"{where}: SMPTE time division is not supported")
    midi = Midi(division=division)
    i = 8 + int.from_bytes(data[4:8], "big")
    while i + 8 <= len(data):
        kind, length = data[i:i + 4], int.from_bytes(data[i + 4:i + 8], "big")
        chunk = data[i + 8:i + 8 + length]
        i += 8 + length
        if kind != b"MTrk":
            continue
        tick, j, status = 0, 0, 0
        try:
            while j < len(chunk):
                delta, j = _vlq(chunk, j)
                tick += delta
                b = chunk[j]
                if b == 0xFF:
                    meta = chunk[j + 1]
                    length, j = _vlq(chunk, j + 2)
                    body = chunk[j:j + length]
                    j += length
                    if meta == 0x51 and length == 3:
                        midi.tempos.append((tick, 60_000_000 / int.from_bytes(body, "big")))
                    elif meta == 0x58 and length >= 2:
                        midi.signatures.append((tick, body[0], 2 ** body[1]))
                    elif meta == 0x2F:
                        break
                elif b in (0xF0, 0xF7):
                    length, j = _vlq(chunk, j + 1)
                    j += length
                else:
                    if b & 0x80:
                        status, j = b, j + 1
                    kind = status & 0xF0
                    if kind in (0xC0, 0xD0):
                        j += 1
                    else:
                        d1, d2 = chunk[j], chunk[j + 1]
                        j += 2
                        if kind == 0x90 and d2 > 0:
                            midi.notes.append(Note(tick, d1, d2, status & 0x0F))
        except IndexError:
            raise PscError(f"{where}: truncated MIDI track") from None
    midi.notes.sort(key=lambda n: (n.tick, n.number))
    return midi


def _fmt(value: float) -> str:
    text = f"{value:.2f}".rstrip("0").rstrip(".")
    return text or "0"


def midi_to_beat(midi: Midi, steps_per_beat: int = 4, bars: int | None = None, accent_velocity: int = 96,
                 names: dict[str, str] | None = None, all_channels: bool = False, source: str = "") -> str:
    """The YAML for a tempo: and a beat layer, as text."""
    if steps_per_beat < 1:
        raise PscError("steps per beat must be at least 1")
    notes = midi.notes if all_channels else [n for n in midi.notes if n.channel == DRUM_CHANNEL]
    if not notes and not all_channels:
        notes = midi.notes  # not a channel-10 file: take every note
    if not notes:
        raise PscError(f"{source or 'the file'}: no notes found")
    use_gm_names = all(n.channel == DRUM_CHANNEL for n in notes)  # GM drum names only mean something on channel 10
    bpm = midi.tempos[0][1] if midi.tempos else 120.0
    numerator, denominator = (midi.signatures[0][1], midi.signatures[0][2]) if midi.signatures else (4, 4)
    beats_per_bar = max(1, round(numerator * 4 / denominator))
    steps_per_bar = beats_per_bar * steps_per_beat
    step_ticks = midi.division / steps_per_beat

    hits: dict[int, dict[int, int]] = {}  # note number -> step -> velocity
    last = 0
    for n in notes:
        step = int(math.floor(n.tick / step_ticks + 0.5))
        row = hits.setdefault(n.number, {})
        row[step] = max(row.get(step, 0), n.velocity)
        last = max(last, step)
    total = bars * steps_per_bar if bars else max(1, math.ceil((last + 1) / steps_per_bar)) * steps_per_bar

    names = {k.lower(): v for k, v in (names or {}).items()}
    lines = []
    if source:
        lines.append(f"# from {source}: {_fmt(bpm)} bpm, {numerator}/{denominator}, {total // steps_per_bar} bar(s), "
                     f"{steps_per_bar} steps per bar")
    step_ms = 60000 / bpm / steps_per_beat
    if abs(step_ms / 10 - round(step_ms / 10)) > 1e-6:
        lines.append(f"# note: a step is {_fmt(step_ms)}ms, not a multiple of GLF's 10ms, so a loop drifts slightly")
    lines += [f"tempo: {{ bpm: {_fmt(bpm)}, steps_per_beat: {steps_per_beat} }}",
              "layers:",
              "  - pattern: beat",
              "    attack: 40ms",
              "    decay: 120ms",
              "    accents: { x: 70, X: 100 }",
              "    tracks:"]
    warned = []
    for number in sorted(hits):
        drum = GM_DRUMS.get(number, f"note_{number}") if use_gm_names else f"note_{number}"
        name = names.get(drum, names.get(str(number), drum))
        row = hits[number]
        chars = ["." for _ in range(total)]
        for step, velocity in row.items():
            if step < total:
                chars[step] = "X" if velocity >= accent_velocity else "x"
            else:
                warned.append(drum)
        lines.append(f"      {name}: |   # MIDI {number} {drum}" if name != drum else f"      {name}: |   # MIDI {number}")
        for b in range(0, total, steps_per_bar):
            bar = "".join(chars[b:b + steps_per_bar])
            lines.append("        " + " ".join(bar[k:k + steps_per_beat] for k in range(0, len(bar), steps_per_beat)))
    if warned:
        lines.append(f"# dropped hits after bar {total // steps_per_bar}: {', '.join(sorted(set(warned)))}")
    return "\n".join(lines) + "\n"


def convert_file(path: Path, **options) -> str:
    try:
        data = path.read_bytes()
    except OSError as e:
        raise PscError(f"{path}: {e.strerror}") from None
    return midi_to_beat(read_midi(data, path.name), source=path.name, **options)
