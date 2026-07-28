# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
glf_scaffold.py - generate the boilerplate parts of a GLF migration.

Three subcommands, all pure generation. Nothing existing is read or modified
except where noted.

  project   the build pipeline: script.vbs loader, _main.vbs, Gruntfile.js,
            package.json, gamename.txt, directory skeleton
  sounds    CreateSounds() with real durations, read from an audio directory
            via ffprobe and classified by filename prefix
  modes     score.vbs (boilerplate from your ScoreArray) and a base.vbs
            skeleton with the BCP/Godot-only blocks already omitted

Usage:
    uv run glf_scaffold.py project --name StarsHollowShowdown --root .
    uv run glf_scaffold.py sounds  --audio ./sounds --out scripts/src/game/modes/sounds.vbs
    uv run glf_scaffold.py modes   --out scripts/src/game/modes \\
                                   --scores 10,250,1000,5000,10000
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

# --------------------------------------------------------------------------
# project
# --------------------------------------------------------------------------

LOADER = '''Include("scripts\\\\dest\\\\vpx\\\\tablescript.vbs")

Sub Include (strFile)
\tSet objFSO = CreateObject("Scripting.FileSystemObject")
\tSet objTextFile = objFSO.OpenTextFile(strFile, 1)
\tExecuteGlobal objTextFile.ReadAll
\tobjTextFile.Close
\tSet objFSO = Nothing
\tSet objTextFile = Nothing
End Sub
'''

MAIN = '''\'*********************************************************************
\' {name}
\'*********************************************************************
\'
\' Built on GLF (https://github.com/mpcarr/vpx-glf), which is itself an
\' adaptation of the VPW example table scripting approach.
\'
\' This file is concatenated FIRST (the leading underscore matters - the
\' grunt glob is alphabetical). Everything below runs before any other
\' source file.
\'
\' === TABLE OF CONTENTS ===
\'   ZCON: Constants and Global Variables
\'   ZOPT: User Options
\'   ZTIM: Timers
\'   ZINI: Table Initialization and Exiting
\'   ZKEY: Key Press Handling
\'   ZMAT: General Math Functions
\'   ZANI: Misc Animations
\'   ZFLP: Flippers
\'   ZSLG: Slingshots
\'   ZDMP: Rubber Dampeners
\'   ZSOL: Other Solenoids
\'   ZRST: Roth Stand-Up Targets
\'   ZSHA: Ambient Ball Shadows
\'   ZBRL: Ball Rolling and Drop Sounds
\'   ZRRL: Ramp Rolling Sounds
\'   ZFLE: Fleep Mechanical Sounds
\'   ZFLD: Flupper Domes
\'   ZFLB: Flupper Bumpers
\'   ZVRS: VR Stuff
\'   ZDMD: FlexDMD
\'   ZGCF: GLF Configurations
\'
\' DOF IDs
\' ------------
\'   E101 0/1 LeftFlipper
\'   E102 0/1 RightFlipper
\'   E103 2   LeftSlingshot
\'   E104 2   RightSlingshot
\'   E105 2   Bumper1


Option Explicit
Randomize
SetLocale 1033

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs In order To run this table, available In the vp10 package"
On Error GoTo 0
'''

GRUNTFILE = '''module.exports = function (grunt) {
  const SRC = [
    'src/vpx/**/*.vbs',
    'src/game/**/*.vbs',
    'src/glf/glf.vbs',
    'src/glf/shows/*.vbs',
    'src/glf/yamlshows/*.vbs',
    '!src/glf/yamlshows/*.yaml',
    '!src/**/*.test.vbs',
    '!src/**/*-mpf.vbs',
    '!src/**/*-ignore.vbs',
    '!src/**/*.suggested.vbs',
    '!src/_deleted/**',
  ];
  // glf.vbs is LAST on purpose. VBScript hoists Sub/Function/Class
  // declarations, so definitions resolve, but no GLF call may appear as a
  // top-level executable statement in src/game - wrap it in a Sub called
  // from ConfigureGlfDevices().
  grunt.initConfig({
    clean: { dest: ['dest/'] },
    mkdir: { dest: { options: { create: ['dest/vpx'] } } },
    concat: {
      vpx:  { src: SRC.concat(['!cached-functions.vbs']),
              dest: 'dest/vpx/tablescript.vbs' },
      prod: { src: SRC.concat(['../cached-functions.vbs']),
              dest: 'dest/vpx/tablescript.vbs' },
    },
    watch: {
      vpx: { files: 'src/**/*.vbs', tasks: ['concat:vpx'],
             options: { atBegin: true } },
    },
  });
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-mkdir');
  grunt.registerTask('default', ['clean:dest', 'mkdir:dest', 'concat']);
};
'''

PACKAGE = {
    "name": "PLACEHOLDER",
    "version": "1.0.0",
    "scripts": {
        "extract-vpx": "powershell -Command \"$gameName = Get-Content "
                       "../gamename.txt | Select-Object -First 1; vpxtool "
                       "extract ../$gameName.vpx\"",
        "assemble-vpx": "powershell -Command \"$gameName = Get-Content "
                        "../gamename.txt | Select-Object -First 1; vpxtool "
                        "assemble ../$gameName\"",
        "script-watcher": "grunt watch:vpx",
        "concat-vpx": "grunt concat:prod",
        "update-glf": "curl -o ./src/glf/glf.vbs https://raw.githubusercontent"
                      ".com/mpcarr/vpx-glf/refs/heads/main/scripts/vpx-glf.vbs",
    },
    "license": "ISC",
    "dependencies": {
        "grunt": "^1.3.0",
        "grunt-contrib-concat": "^1.0.1",
        "grunt-contrib-watch": "^1.1.0",
        "js-yaml": "^4.1.0",
    },
    "devDependencies": {
        "grunt-contrib-clean": "^2.0.1",
        "grunt-mkdir": "^1.1.0",
    },
}

ZINI = '''

\'*******************************************
\'  ZINI: Table Initialization and Exiting
\'*******************************************

Sub LoadCoreFiles
\tOn Error Resume Next
\tExecuteGlobal GetTextFile("core.vbs")
\tIf Err Then MsgBox "Can't open core.vbs"
\tOn Error GoTo 0
End Sub


Sub Table1_Init
\t\' core.vbs still needed for cvpmMagnet, vpmTimer, DOF constants
\tLoadCoreFiles

\t\' cvpmMagnet / other core.vbs device setup goes here, before Glf_Init

\t\' GLF - ConfigureGlfDevices must run first; Glf_Init consumes it
\tConfigureGlfDevices()
\tGlf_Init(Table1)

\t\' VPW physics init - unchanged
\tInitRolling()
\tInitPolarity()
\tInitSlingCorrection()

\tInitVR()
End Sub


Sub Table1_Exit
\tGlf_Exit()
\tIf B2SOn Then
\t\tController.Pause = False
\t\tController.Stop
\tEnd If
End Sub

Sub Table1_Paused
End Sub

Sub Table1_UnPaused
End Sub

\' NOTE: deliberately absent, compared to a stock VPW Table1_Init:
\'   - ETBall1..N creation      Glf_Init calls DestroyBall and makes its own
\'   - vpmMapLights AllLamps    ROM lamp mapping, meaningless without a ROM
\'   - For Each xx In GI        GI is now a glf_lights show
\'   - Set queue = New vpwQueueManager    replaced by SetDelay / GlfTimer
\'   - Flex_Init                move to a GLF event listener (see the DMD bridge)
'''


def cmd_project(args: argparse.Namespace) -> int:
    root: Path = args.root
    scripts = root / "scripts"
    made = []

    for d in ("src/vpx", "src/game/modes", "src/game/shows", "src/glf",
              "src/glf/shows", "dest/vpx"):
        (scripts / d).mkdir(parents=True, exist_ok=True)

    def write(path: Path, content: str) -> None:
        if path.exists() and not args.force:
            print(f"  skip (exists)  {path}")
            return
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        made.append(path)
        print(f"  wrote          {path}")

    write(root / "gamename.txt", args.name + "\n")
    write(root / f"{args.name}_script.vbs", LOADER)
    write(scripts / "src/vpx/_main.vbs", MAIN.format(name=args.name))
    write(scripts / "Gruntfile.js", GRUNTFILE)
    pkg = dict(PACKAGE)
    pkg["name"] = re.sub(r"[^a-z0-9\-]", "-", args.name.lower())
    write(scripts / "package.json", json.dumps(pkg, indent=2) + "\n")
    if args.zini:
        write(scripts / "src/vpx/04_ZINI_Table_Initialization_and_Exiting.vbs",
              ZINI)

    print(f"\n{len(made)} file(s) created.\n")
    print("Next:")
    print(f"  1. paste {root / (args.name + '_script.vbs')} into the VPX script")
    print("     editor as the ENTIRE table script, then save the .vpx")
    print("  2. cd scripts && npm install && npm run update-glf")
    print("  3. npm run script-watcher")
    print("\nVerify the loop works before migrating anything: edit a .vbs, save,")
    print("press F5 in VPX, confirm the change took effect.")
    return 0


# --------------------------------------------------------------------------
# sounds
# --------------------------------------------------------------------------

PREFIX_KIND = [("mus_", "AddMusic"), ("voc_", "AddCallout"),
               ("sfx_", "AddSoundEffect")]


def probe_duration(path: Path) -> float | None:
    try:
        out = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", str(path)],
            capture_output=True, text=True, timeout=30)
        return round(float(out.stdout.strip()), 3)
    except Exception:
        return None


def cmd_sounds(args: argparse.Namespace) -> int:
    if shutil.which("ffprobe") is None:
        print("ffprobe not found on PATH. Durations must be accurate - GLF "
              "uses them\nfor sequencing - so install ffmpeg rather than "
              "estimating.", file=sys.stderr)
        return 2

    exts = {".wav", ".mp3", ".ogg", ".flac", ".m4a"}
    files = sorted(f for f in args.audio.rglob("*") if f.suffix.lower() in exts)
    if not files:
        print(f"no audio files under {args.audio}", file=sys.stderr)
        return 1

    buckets: dict[str, list[tuple[str, float]]] = {
        "AddMusic": [], "AddSoundEffect": [], "AddCallout": []}
    unclassified: list[str] = []
    for f in files:
        name = f.stem
        kind = next((k for p, k in PREFIX_KIND if name.lower().startswith(p)), None)
        if kind is None:
            unclassified.append(name)
            continue
        d = probe_duration(f)
        if d is None:
            print(f"  ! could not probe {f}", file=sys.stderr)
            continue
        buckets[kind].append((name, d))

    lines = [
        "",
        "'*******************************************",
        "'  Sounds Configuration",
        "'*******************************************",
        "'",
        "' Generated by glf_scaffold.py. Durations from ffprobe - GLF uses them",
        "' for sequencing, so do not round them by hand.",
        "'",
        "' IMPORTANT: every one of these must be positioned to the Backglass in",
        "' VPX's Sound Manager, or GLF's sound player will not find it.",
        "'",
        "' This is separate from Fleep. Mechanical sounds keep going through",
        "' PlaySound/SoundFX and never touch the GLF sound player.",
        "",
        "Sub CreateSounds()",
    ]
    if buckets["AddMusic"]:
        lines.append("")
        lines.append("\t' name, duration (seconds), loops (-1 = forever)")
        for n, d in buckets["AddMusic"]:
            lines.append(f'\tAddMusic "{n}", {d}, -1')
    if buckets["AddSoundEffect"]:
        lines.append("")
        for n, d in buckets["AddSoundEffect"]:
            lines.append(f'\tAddSoundEffect "{n}", {d}')
    if buckets["AddCallout"]:
        lines.append("")
        for n, d in buckets["AddCallout"]:
            lines.append(f'\tAddCallout "{n}", {d}')
    lines += ["", "End Sub", ""]

    if unclassified:
        lines += ["", "' Not classified - rename with an mus_ / sfx_ / voc_ "
                      "prefix, or add by hand:"]
        lines += [f"'   {n}" for n in unclassified]

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {args.out}")
    print(f"  {len(buckets['AddMusic'])} music, "
          f"{len(buckets['AddSoundEffect'])} sfx, "
          f"{len(buckets['AddCallout'])} callouts, "
          f"{len(unclassified)} unclassified")
    print("\nRemember to call CreateSounds() from ConfigureGlfDevices().")
    return 0


# --------------------------------------------------------------------------
# modes
# --------------------------------------------------------------------------

SCORE_MODE = '''

\' Score Mode
\'
\' Owns scoring and multipliers. Award points by dispatching "score_NNNN",
\' where NNNN is a value in ScoreArray. Multipliers are applied here, so no
\' other mode should touch the score variable directly.

Sub CreateScoreMode()
\tDim x

\tWith CreateGlfMode("score", 2000)

\t\t.StartEvents = Array("game_start")
\t\t.StopEvents = Array("game_ended")

\t\tWith .VariablePlayer()

\t\t\t\' One score_NNNN event per value in ScoreArray
\t\t\tFor each x in ScoreArray
\t\t\t\tWith .EventName("score_"&x)
\t\t\t\t\tWith .Variable("score")
\t\t\t\t\t\t.Action = "add"
\t\t\t\t\t\t.Int = x&" * current_player.scoring_multiplier"
\t\t\t\t\tEnd With
\t\t\t\tEnd With
\t\t\tNext

\t\t\tWith .EventName("ball_started")
\t\t\t\tWith .Variable("scoring_multiplier")
\t\t\t\t\t.Action = "set"
\t\t\t\t\t.Int = 1
\t\t\t\tEnd With
\t\t\t\tWith .Variable("bonus_multiplier")
\t\t\t\t\t.Action = "set"
\t\t\t\t\t.Int = 1
\t\t\t\tEnd With
\t\t\tEnd With

\t\t\tWith .EventName("reset_scoring_multiplier")
\t\t\t\tWith .Variable("scoring_multiplier")
\t\t\t\t\t.Action = "set"
\t\t\t\t\t.Int = 1
\t\t\t\tEnd With
\t\t\tEnd With

\t\tEnd With

\tEnd With
End Sub
'''

BASE_MODE = '''

\' Base Mode
\'
\' Runs whenever a ball is in play, so it handles anything independent of the
\' feature modes: ball save, GI, minor scoring, music.
\'
\' Priority 110 - above attract (100), below feature modes (700+) and score
\' (2000). When two running modes address the same light, priority decides.
\'
\' NOTE: the GLF example's .SlidePlayer(), .WidgetPlayer() and
\' .SegmentDisplayPlayer() blocks are deliberately absent here. The first two
\' need BCP + the Godot GMCDisplay; the third needs GlfLightSegmentDisplay
\' light groups. On a FlexDMD table none of them do anything.

Sub CreateBaseMode()

\tWith CreateGlfMode("base", 110)

\t\t.StartEvents = Array("ball_started")
\t\t.StopEvents = Array("ball_ended", "tilt")

\t\tWith .EventPlayer()

\t\t\t.Add "mode_base_started", Array("new_ball_started", "stop_attract_mode")
\t\t\t.Add "mode_base_stopping", Array()

\t\t\t\' Leaving the plunger lane for the first time starts the ball proper
\t\t\t.Add "{plunger_switch}_inactive{{current_player.ball_just_started == 1}}", Array("new_ball_active")

{bindings}
\t\tEnd With

\t\t\' Ball save at the start of each ball
\t\tWith .BallSaves("new_ball")
\t\t\t.ActiveTime = 6000
\t\t\t.HurryUpTime = 3000
\t\t\t.GracePeriod = 2000
\t\t\t.BallsToSave = 1
\t\t\t.AutoLaunch = True
\t\t\t.EnableEvents = Array("new_ball_active")
\t\tEnd With

\t\t\' GI on at mode start. This replaces the old
\t\t\'   For Each xx In GI : xx.state = 1
\t\t\' loop in Table1_Init. Every member of GILightNames must be in the
\t\t\' glf_lights collection or it stays dark - Glf_Init blanks them all.
\t\tWith .LightPlayer()
\t\t\tWith .EventName("mode_base_started")
\t\t\t\tWith .Lights("GI")
\t\t\t\t\t.Color = GIColor2700k
\t\t\t\t\t.Fade = 300
\t\t\t\tEnd With
\t\t\tEnd With
\t\tEnd With

\t\t\' Hold start for 2s to cancel the game
\t\tWith .TimedSwitches("cancel_game")
\t\t\t.Switches = Array("s_start")
\t\t\t.Time = 2000
\t\t\t.EventsWhenActive = Array("glf_game_cancel")
\t\tEnd With

\t\tWith .VariablePlayer()
\t\t\tWith .EventName("mode_base_started")
\t\t\t\tWith .Variable("ball_just_started")
\t\t\t\t\t.Action = "set"
\t\t\t\t\t.Int = 1
\t\t\t\tEnd With
\t\t\tEnd With
\t\t\tWith .EventName("new_ball_active")
\t\t\t\tWith .Variable("ball_just_started")
\t\t\t\t\t.Action = "set"
\t\t\t\t\t.Int = 0
\t\t\t\tEnd With
\t\t\tEnd With
\t\tEnd With

\tEnd With

End Sub
'''

ATTRACT_MODE = '''

\' Attract Mode

Sub CreateAttractMode()

\tWith CreateGlfMode("attract", 100)
\t\t.StartEvents = Array("reset_complete", "game_ended")
\t\t.StopEvents = Array("game_started", "stop_attract_mode")

\t\tWith .EventPlayer()
\t\t\t\' Drive attract sequencing off timer ticks - see the GLF example's
\t\t\t\' attract.vbs for the conditional-event pattern:
\t\t\t\'   .Add "timer_attract_display_tick{devices.timers.attract_display.ticks == 7}", Array("...")
\t\tEnd With

\t\tWith .Timers("attract_display")
\t\t\t.TickInterval = 1000
\t\t\t.StartValue = 0
\t\t\t.EndValue = 30
\t\t\t.Direction = "up"
\t\t\t.StartRunning = True
\t\t\t.RestartOnComplete = True
\t\tEnd With

\tEnd With
End Sub
'''


def cmd_modes(args: argparse.Namespace) -> int:
    args.out.mkdir(parents=True, exist_ok=True)
    bindings = ""
    if args.scoring:
        bindings = args.scoring.read_text(encoding="utf-8")
        bindings = "\n".join(
            "\t\t\t" + l.strip() for l in bindings.split("\n")
            if l.strip().startswith(".Add"))
        bindings = "\n\t\t\t' lifted out of the physics handlers\n" + bindings + "\n"

    files = {
        "score.vbs": SCORE_MODE,
        "base.vbs": BASE_MODE.format(plunger_switch=args.plunger_switch,
                                     bindings=bindings),
        "attract.vbs": ATTRACT_MODE,
    }
    for name, content in files.items():
        p = args.out / name
        if p.exists() and not args.force:
            print(f"  skip (exists)  {p}")
            continue
        p.write_text(content, encoding="utf-8")
        print(f"  wrote          {p}")

    scores = [s.strip() for s in args.scores.split(",") if s.strip()]
    print("\nAdd to _configuration.vbs:")
    print(f"    Dim ScoreArray : ScoreArray = Array({', '.join(scores)})")
    print("and call from ConfigureGlfDevices():")
    print("    CreateAttractMode()")
    print("    CreateBaseMode()")
    print("    CreateScoreMode()")
    return 0




# --------------------------------------------------------------------------
# segments  (GLF alphanumeric / segment display)
# --------------------------------------------------------------------------

# GlfLightSegmentDisplay.CalculateLights() does Eval(lightgroup & index) and
# requires a real Light object at every position, whether or not you ever
# render to a physical display. Virtual-DMD mode (Glf_EnableVirtualSegmentDmd)
# hides them at runtime via .Visible - it does not remove the requirement
# that they exist. So even the "just render it as a virtual DMD" path needs
# these placeholder Light objects created in the table first.

SEGMENT_LIGHTS_PER_CHAR = {"7": 8, "14": 15}

LIGHT_TEMPLATE = {
    "height": 30.0, "falloff_radius": 50.0, "falloff_power": 2.0,
    "state_u32": 0, "state": 0.0, "color": "#ffffff", "color2": "#ffffff",
    "is_timer_enabled": False, "timer_interval": 100, "blink_pattern": "10",
    "off_image": "", "blink_interval": 125, "intensity": 1.0,
    "transmission_scale": 0.1, "surface": "", "is_backglass": False,
    "depth_bias": 0.0, "fade_speed_up": 20000.0, "fade_speed_down": 20000.0,
    "is_bulb_light": True, "is_image_mode": False, "show_bulb_mesh": False,
    "has_static_bulb_mesh": True, "show_reflection_on_ball": False,
    "mesh_radius": 5.0, "bulb_modulate_vs_add": 1.0, "bulb_halo_height": 30.0,
    "shadows": "none", "fader": "linear", "visible": True,
}


def parse_displays(spec: str) -> list[tuple[str, int, str]]:
    """"player1:8:14,ball:2:7" -> [("player1", 8, "14"), ("ball", 2, "7")]."""
    out = []
    for chunk in spec.split(","):
        chunk = chunk.strip()
        if not chunk:
            continue
        parts = chunk.split(":")
        if len(parts) != 3 or parts[2] not in ("7", "14"):
            raise SystemExit(
                f"bad display spec {chunk!r} - want name:chars:segtype, "
                "segtype is 7 or 14, e.g. player1:8:14")
        out.append((parts[0], int(parts[1]), parts[2]))
    return out


def make_light_json(name: str, x: float, y: float) -> dict:
    d = dict(LIGHT_TEMPLATE)
    d["name"] = name
    d["center"] = {"x": x, "y": y}
    # A degenerate (single-point) shape is fine: these are never meant to be
    # seen. SetVirtualDMDLights toggles .Visible at runtime; until then they
    # just sit here as small, harmless dots.
    d["drag_points"] = [
        {"x": x - 5, "y": y - 5, "z": 0.0, "smooth": True, "is_slingshot": False,
         "has_auto_texture": True, "tex_coord": 0.0, "is_locked": False,
         "editor_layer": 0, "editor_layer_name": "", "editor_layer_visibility": True},
        {"x": x + 5, "y": y - 5, "z": 0.0, "smooth": True, "is_slingshot": False,
         "has_auto_texture": True, "tex_coord": 0.0, "is_locked": False,
         "editor_layer": 0, "editor_layer_name": "", "editor_layer_visibility": True},
        {"x": x + 5, "y": y + 5, "z": 0.0, "smooth": True, "is_slingshot": False,
         "has_auto_texture": True, "tex_coord": 0.0, "is_locked": False,
         "editor_layer": 0, "editor_layer_name": "", "editor_layer_visibility": True},
        {"x": x - 5, "y": y + 5, "z": 0.0, "smooth": True, "is_slingshot": False,
         "has_auto_texture": True, "tex_coord": 0.0, "is_locked": False,
         "editor_layer": 0, "editor_layer_name": "", "editor_layer_visibility": True},
    ]
    return {"Light": d}


def cmd_segments(args: argparse.Namespace) -> int:
    displays = parse_displays(args.displays)

    total_chars = sum(chars for _n, chars, _t in displays)
    if total_chars > 32:
        print(f"REFUSING: {total_chars} total characters requested, but "
              f"glf_flex_alphadmd_segments() only holds 32.\n"
              "Either use fewer/shorter displays, or drop "
              "ExternalFlexDmdSegmentIndex on some\n"
              "of them and drive those via ExternalB2SSegmentIndex or real "
              "playfield lights\ninstead.", file=sys.stderr)
        return 2

    # ---- VBScript config --------------------------------------------------
    vbs = [
        "",
        "'*******************************************",
        "'  Segment displays (GLF alphanumeric)",
        "'*******************************************",
        "'",
        "' Generated by glf_scaffold.py segments. Call from ConfigureGlfDevices(),",
        "' after any lights the group name below refers to exist and are NOT in",
        "' the glf_lights collection (GLF drives them directly by name, and",
        "' would otherwise blank them at Glf_Init).",
        "'",
        "' To render these as a virtual alphanumeric DMD instead of building a",
        "' real light-segment display, turn on the table option Glf Virtual",
        "' Segment DMD (F6 tweak menu - persists in the table's saved options).",
        "' That creates GLF's OWN FlexDMD instance (glf_flex_alphadmd) - separate",
        "' from any FlexDMD object your own scene code creates. Turn off your",
        "' own FlexDMD scenes (e.g. Const UseFlexDMD = 0) so the two do not both",
        "' try to render.",
        "",
    ]
    offset = 0
    light_plan: list[tuple[str, str, int]] = []   # (display, lightgroup, count)
    for name, chars, segtype in displays:
        per_char = SEGMENT_LIGHTS_PER_CHAR[segtype]
        group = f"l_seg_{name}_"
        count = chars * per_char
        vbs += [
            f'With CreateGlfLightSegmentDisplay("{name}")',
            f'    .SegmentType = "{segtype}Segment"',
            f"    .SegmentSize = {chars}",
            f'    .LightGroup = "{group}"',
            f"    .ExternalFlexDmdSegmentIndex = {offset}   "
            f"' claims slots {offset}..{offset + chars - 1} of 32",
            f'    .DefaultColor = "ff8000"',
            "End With",
            "",
        ]
        light_plan.append((name, group, count))
        offset += chars

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(vbs), encoding="utf-8")
    print(f"wrote {args.out}")
    print(f"  {len(displays)} display(s), {total_chars}/32 character slots used")

    # ---- placeholder Light objects -----------------------------------------
    total_lights = sum(c for _n, _g, c in light_plan)
    print(f"\n  {total_lights} placeholder Light object(s) needed:")
    for name, group, count in light_plan:
        print(f"    {group}1 .. {group}{count}   ({count} lights for '{name}')")

    if not args.table:
        print("\n  (no --table given: Light gameitems not generated - pass "
              "--table and --apply\n"
              "  to create them directly, or add manually with these names)")
        return 0

    gi_dir = args.table / "gameitems"
    if not gi_dir.is_dir():
        print(f"\n  ! no gameitems/ under {args.table}", file=sys.stderr)
        return 2

    existing = {f.stem.split(".", 1)[1] for f in gi_dir.glob("*.json")
               if "." in f.stem}
    apply = args.apply and not args.dry_run
    print(f"\n[{'APPLYING' if apply else 'DRY RUN'}] placeholder lights "
          f"under {gi_dir}")

    new_files: dict[Path, dict] = {}
    x0, y0 = args.park_x, args.park_y
    i = 0
    for _name, group, count in light_plan:
        for k in range(1, count + 1):
            lname = f"{group}{k}"
            if lname in existing:
                continue
            # Fan out on a grid so nothing perfectly overlaps (harmless, but
            # tidier if you ever go looking for them in the editor).
            gx = x0 + (i % 20) * 12
            gy = y0 + (i // 20) * 12
            i += 1
            new_files[gi_dir / f"Light.{lname}.json"] = make_light_json(lname, gx, gy)

    print(f"  {len(new_files)} new light(s), {total_lights - len(new_files)} "
          "already present")

    if apply:
        for path, data in new_files.items():
            path.write_text(json.dumps(data, indent=2), encoding="utf-8")
        idx_path = args.table / "gameitems.json"
        if idx_path.is_file():
            idx = json.loads(idx_path.read_text(encoding="utf-8"))
            have = {e["file_name"] for e in idx}
            for path in new_files:
                if path.name not in have:
                    idx.append({"file_name": path.name})
            idx_path.write_text(json.dumps(idx, indent=2), encoding="utf-8")
        print(f"\n  wrote {len(new_files)} gameitem file(s) and updated "
              "gameitems.json")
        print("  Run `vpxtool assemble` to pull them into the .vpx.")
        print("  They park at ({},{}) and are tiny/unlit - move the whole "
              "block later if\n"
              "  it is ever in the way; their position has no effect on "
              "the segment display.".format(x0, y0))
    else:
        print("\n  Dry run - nothing written. Re-run with --apply.")
    return 0


# --------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("project", help="build pipeline and entry points")
    p.add_argument("--name", required=True, help="cGameName / gamename.txt")
    p.add_argument("--root", type=Path, default=Path("."))
    p.add_argument("--zini", action="store_true",
                   help="also emit a rewritten 04_ZINI")
    p.add_argument("--force", action="store_true")
    p.set_defaults(func=cmd_project)

    p = sub.add_parser("sounds", help="CreateSounds() with ffprobe durations")
    p.add_argument("--audio", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.set_defaults(func=cmd_sounds)

    p = sub.add_parser("segments",
                       help="GLF alphanumeric segment displays: config + "
                            "placeholder Light objects")
    p.add_argument("--displays", required=True,
                   help='comma-separated name:chars:segtype, e.g. '
                        '"player1:8:14,player2:8:14,ball:2:7"')
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--table", type=Path,
                   help="table dir; if given, generates the placeholder "
                        "Light gameitems too")
    p.add_argument("--park-x", type=float, default=-400.0,
                   help="off-table X to place the (invisible-when-active) "
                        "placeholder lights")
    p.add_argument("--park-y", type=float, default=-400.0)
    p.add_argument("--apply", action="store_true")
    p.add_argument("--dry-run", action="store_true")
    p.set_defaults(func=cmd_segments)

    p = sub.add_parser("modes", help="score / base / attract skeletons")
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--scores", default="10,100,250,1000,5000,10000,50000")
    p.add_argument("--plunger-switch", default="s_PlungerLane")
    p.add_argument("--scoring", type=Path,
                   help="_scoring.suggested.vbs from glf_callbacks.py; its "
                        ".Add lines get folded into base mode")
    p.add_argument("--force", action="store_true")
    p.set_defaults(func=cmd_modes)

    args = ap.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
