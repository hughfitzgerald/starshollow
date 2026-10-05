import pytest

from psc.errors import PscError
from psc.midi import midi_to_beat, read_midi


def vlq(n):
    assert n >= 0, "delta times can't be negative"
    out = [n & 0x7F]
    n >>= 7
    while n:
        out.insert(0, 0x80 | (n & 0x7F))
        n >>= 7
    return bytes(out)


def track(events):
    """events: (delta, bytes). Returns an MTrk chunk with end-of-track."""
    body = b"".join(vlq(d) + e for d, e in events) + vlq(0) + b"\xff\x2f\x00"
    return b"MTrk" + len(body).to_bytes(4, "big") + body


def midi_file(tracks, division=480, fmt=1):
    return b"MThd" + (6).to_bytes(4, "big") + fmt.to_bytes(2, "big") + len(tracks).to_bytes(2, "big") + division.to_bytes(2, "big") + b"".join(tracks)


def on(note, vel, ch=9):
    return bytes([0x90 | ch, note, vel])


def off(note, ch=9):
    return bytes([0x80 | ch, note, 0])


def test_two_bar_groove():
    tempo = b"\xff\x51\x03" + (480_000).to_bytes(3, "big")   # 125 bpm: a 120ms step
    sig = b"\xff\x58\x04\x04\x02\x18\x08"                    # 4/4
    meta = track([(0, tempo), (0, sig)])
    # 480 ticks per beat: kick on 1 and 3, snare on 2 and 4 (loud on 4), hats on every 8th (soft)
    events = []
    t = 0
    hits = []
    for bar in range(2):
        for beat in range(4):
            tick = (bar * 4 + beat) * 480
            if beat in (0, 2):
                hits.append((tick, 36, 100))
            if beat in (1, 3):
                hits.append((tick, 38, 110 if beat == 3 else 80))
            hits.append((tick, 42, 60))
            hits.append((tick + 240, 42, 60))
    hits.append((7 * 480 + 360, 36, 100))  # a pickup kick on the last 16th, slightly late (quantizes to step 31)
    hits.sort()
    for tick, note, vel in hits:
        events.append((tick - t, on(note, vel)))
        events.append((0, off(note)))
        t = tick
    drums = track(events)
    midi = read_midi(midi_file([meta, drums]))
    assert midi.division == 480 and midi.tempos[0][1] == 125.0 and midi.signatures[0][1:] == (4, 4)
    out = midi_to_beat(midi, source="groove.mid")
    assert out == (
        "# from groove.mid: 125 bpm, 4/4, 2 bar(s), 16 steps per bar\n"
        "tempo: { bpm: 125, steps_per_beat: 4 }\n"
        "layers:\n"
        "  - pattern: beat\n"
        "    attack: 40ms\n"
        "    decay: 120ms\n"
        "    accents: { x: 70, X: 100 }\n"
        "    tracks:\n"
        "      kick: |   # MIDI 36\n"
        "        X... .... X... ....\n"
        "        X... .... X... ...X\n"
        "      snare: |   # MIDI 38\n"
        "        .... x... .... X...\n"
        "        .... x... .... X...\n"
        "      hihat: |   # MIDI 42\n"
        "        x.x. x.x. x.x. x.x.\n"
        "        x.x. x.x. x.x. x.x.\n"
    )
    # the output parses as a show's beat layer
    import yaml
    doc = yaml.load(out, Loader=yaml.BaseLoader)
    from psc.shows import DEFAULT_ACCENTS, parse_beat_pattern
    hits_, steps = parse_beat_pattern(doc["layers"][0]["tracks"]["kick"], {"x": 70, "X": 100}, "t")
    assert steps == 32 and [i for i, _ in hits_] == [0, 8, 16, 24, 31]
    # options
    out = midi_to_beat(midi, bars=1, names={"kick": "groove_lower_left"}, accent_velocity=120)
    assert "      groove_lower_left: |   # MIDI 36 kick\n        x... .... x... ....\n" in out
    assert "# dropped hits after bar 1: hihat, kick, snare" in out
    out = midi_to_beat(midi, steps_per_beat=2)
    assert "      hihat: |   # MIDI 42\n        xx xx xx xx\n" in out


def test_odd_meter_and_other_channels():
    tempo = b"\xff\x51\x03" + (400_000).to_bytes(3, "big")   # 150 bpm -> 100ms steps
    sig = b"\xff\x58\x04\x03\x02\x18\x08"                    # 3/4
    piano = track([(0, tempo), (0, sig), (0, on(60, 100, ch=0)), (480, off(60, ch=0)), (0, on(64, 100, ch=0)), (480, off(64, ch=0))])
    midi = read_midi(midi_file([piano]))
    out = midi_to_beat(midi)
    assert "tempo: { bpm: 150, steps_per_beat: 4 }" in out and "note_60: |" in out and "note_64: |" in out
    # 12 steps to the bar, one track per pitch; velocity 100 is an accent
    assert "      note_60: |   # MIDI 60\n        X... .... ....\n      note_64: |   # MIDI 64\n        .... X... ....\n" in out
    assert "drifts" not in out
    out = midi_to_beat(read_midi(midi_file([track([(0, b"\xff\x51\x03" + (468_750).to_bytes(3, "big")), (0, on(36, 100))])])))
    assert "bpm: 128" in out and "117.19ms" in out and "drifts" in out


def test_errors():
    with pytest.raises(PscError, match="not a standard MIDI"):
        read_midi(b"RIFF....")
    with pytest.raises(PscError, match="no notes"):
        midi_to_beat(read_midi(midi_file([track([])])))
    with pytest.raises(PscError, match="truncated"):
        read_midi(midi_file([b"MTrk" + (3).to_bytes(4, "big") + b"\x00\x99\x24"]))
