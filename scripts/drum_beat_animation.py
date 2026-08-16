from beat_sheet import beat_sheet_to_tracks
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
    "LowerLeft": "LowerLeft:modulate:a",
    "LowerRight": "LowerRight:modulate:a",
    "MidLeft": "LeftRampInserts:modulate:a",
    "MidRight": "RightRampInserts:modulate:a",
    "UpperLeft": "UpperLeft:modulate:a",
    "UpperRight": "UpperRight:modulate:a",
}

tracks, bpm = beat_sheet_to_tracks(SHEET, NODE_PATHS, interval=0.08)
tres_text = build_animation_tres("Animation_generated", "generated_flash", tracks)
