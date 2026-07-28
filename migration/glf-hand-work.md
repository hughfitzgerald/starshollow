# The hand work, in order

Partly covered already, and scattered — worth consolidating.

What you already have:

- **Callback signatures** — §4 of `VPW-to-GLF-migration.md`. The four shapes, with examples.
- **Your device inventory and what each object becomes** — §3 of `stars-hollow-glf-plan.md`.
- **A devices-only `ConfigureGlfDevices`** — `_configuration.vbs`, wired to your objects.
- **The FlexDMD problem and the bridge option** — §4 of `stars-hollow-glf-plan.md`.

What was missing, and is below: the build wiring, the ZCON/ZINI/ZKEY/ZOPT/ZTIM rewrites, what to gut out of `STHit`, how sounds and modes get registered, and the order to do it in with a definition of "done" at each step.

Rough effort figures are per phase, for someone who knows VPX scripting but is new to GLF. They assume you're reading `vpx-glf.vbs` when the docs run out, which you will be.

---

## Phase 0 — Build wiring (½ day)

Nothing works until the concat pipeline exists. Do this first, on the *unmodified* GLF example, before touching your table.

**In-VPX `script.vbs` becomes 17 lines.** This is the whole thing:

```vb
Include("scripts\dest\vpx\tablescript.vbs")

Sub Include (strFile)
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objTextFile = objFSO.OpenTextFile(strFile, 1)
    ExecuteGlobal objTextFile.ReadAll
    objTextFile.Close
    Set objFSO = Nothing
    Set objTextFile = Nothing
End Sub
```

Everything else lives on disk. Save a `.vbs`, hit F5 in VPX, done — no script editor, no re-import.

**Create `src/vpx/_main.vbs`.** The leading underscore matters: the grunt glob is alphabetical, and this must land first. It holds your header comment, the table of contents, the DOF/B2S ID map, and then:

```vb
Option Explicit
Randomize
SetLocale 1033

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs In order To run this table, ..."
On Error GoTo 0
```

`glf_split.py` puts your existing preamble in `00_ZPRE_Preamble.vbs`. Rename it `_main.vbs` and prune the VPW changelog.

**Concat order is load-bearing.** `src/vpx/**` → `src/game/**` → `src/glf/glf.vbs`. Since `glf.vbs` is *last*, no GLF function may be called at top level in your game files. VBScript hoists `Sub`/`Function`/`Class` declarations, so definitions are fine; top-level executable statements are not. That's why every mode in the example is `Sub CreateXxxMode()` and only runs when `ConfigureGlfDevices()` is called at `Table1_Init`.

**Run `npm run update-glf` immediately.** The example ships `glf.vbs` at 17,275 lines; upstream is 17,650.

**Done when:** the stock example table builds, launches, and you can serve a ball. You've changed nothing of your own yet.

---

## Phase 1 — ZCON (1 hour)

Strip it to GLF's required globals plus your table's own. The example's entire ZCON:

```vb
Const cGameName = "StarsHollowShowdown"
Const TestVR = False
Const BallSize = 50
Const BallMass = 1
Const tnob = 5
Const lob = 0

Dim tablewidth : tablewidth = Table1.width
Dim tableheight : tableheight = Table1.height
Dim DesktopMode : DesktopMode = Table1.ShowDT
Dim gBOT
```

**Delete from yours:** `PlayerScore()`, `CurrentPlayer`, `BIP`, `BIPL`, `BonusX()`, `Dim queue : Set queue = New vpwQueueManager`. That last one is the load-time crash the audit found — it runs at top level and its class went out with ZQUE.

**Keep:** `VolumeDial`, `BallRollVolume`, `RampRollVolume`, `ColorLUT`, `LightLevel`, `StagedFlipper`, `VRRoom`, `Const TestVR`. The Fleep and physics code reads all of these.

**Add:** `ScoreArray`, your colour constants, and light-group name arrays (`GILightNames`, `StandupLightNames`). These belong in `_configuration.vbs` — see the skeleton.

**Done when:** `glf_audit.py --scripts src` no longer reports `queue`, `vpwQueueManager`, `PlayerScore`, `BIP` unresolved.

---

## Phase 2 — ZINI (30 minutes)

This one's short. The GLF example's `Table1_Init` in full:

```vb
Sub Table1_Init
    LoadCoreFiles
    LoadEM

    ' any cvpmMagnet setup goes here

    ConfigureGlfDevices()
    Glf_Init(Table1)

    InitRolling()
    InitPolarity()
    InitSlingCorrection()
    InitVR()
End Sub

Sub Table1_Exit
    Glf_Exit()
    If B2SOn Then
        Controller.Pause = False
        Controller.Stop
    End If
End Sub
```

**Delete from your `Table1_Init`:** the `ETBall1`–`ETBall5` creation loop (`Glf_Init` calls `DestroyBall` and creates its own), `vpmMapLights AllLamps` (ROM lamp mapping, meaningless here), `Flex_Init` (move it — see Phase 11), the `For Each xx In GI : xx.state = 1` loop (becomes a light show), and the queue init.

`LoadEM` is a core.vbs helper the example calls; check whether you actually need it before copying it in — `LoadCoreFiles` alone covers `cvpmMagnet`.

**Done when:** the table loads without a script error. It will not play yet.

---

## Phase 3 — ZKEY (1–2 hours)

The single most important line is the first one in each handler:

```vb
Sub Table1_KeyDown(ByVal keycode)
    Glf_KeyDown(keycode)
    ...
End Sub
```

**GLF now owns:** both flipper keys (dispatched as `s_left_flipper_active` etc.), staged flippers, magna-save, start button, add-credit, and **nudge**. In the example the `Nudge 90, 2` calls are commented out with `'This is set in GLF` — the sound calls stay:

```vb
If keycode = LeftTiltKey Then
    'Nudge 90, 2    'This is set in GLF
    SoundNudgeLeft
End If
```

**You keep:** the plunger (`Plunger.Pullback` / `Plunger.Fire` plus sounds), coin and start-button sounds, VR button animations, and any debug keys.

**Delete:** every flipper branch — `LeftFlipper.RotateToEnd`, `FlipperActivate`, `LF.Fire`, `SolLFlipper True`. Those bodies move to `LeftFlipperAction` in Phase 6, not here.

**Your `Diverter` hack goes here and does not come back.** `Diverter.RotateToEnd` inside `Table1_KeyDown` on `LeftFlipperKey` will simply stop running once `Glf_KeyDown` takes the key. It becomes a `CreateGlfDiverter` bound to `s_left_flipper_active`. This is the one behavioural regression that fails silently, so verify it explicitly.

Also delete the `DebugShotTableKeyDownCheck` / `DebugShotTableKeyUpCheck` calls — the audit flagged them; ZTST is gone.

**Done when:** flippers do nothing (correct — no `CreateGlfFlipper` yet), plunger works, no script errors.

---

## Phase 4 — ZOPT (30 minutes)

Three edits:

```vb
Dim dspTriggered : dspTriggered = False
Sub Table1_OptionEvent(ByVal eventId)
    If eventId = 1 And Not dspTriggered Then dspTriggered = True : DisableStaticPreRendering = True : End If

    ' ... all your existing Table1.Option calls, unchanged ...

    Glf_Options(eventId)

    If eventId = 3 And dspTriggered Then dspTriggered = False : DisableStaticPreRendering = False : End If
End Sub
```

`Glf_Options` registers GLF's own options: Debug Log, Debug Log Level, Backbox Control Protocol, Virtual Segment DMD, production mode. You'll use the first two constantly.

If you're adopting the VR restructure, `SetupRoom` moves in here too so the room rebuilds when the option changes.

**Done when:** GLF's options appear in the VPX tweak UI (F6).

---

## Phase 5 — ZTIM (15 minutes)

```vb
FrameTimer.Interval = -1
Sub FrameTimer_Timer()
    FrameTime = GameTime - InitFrameTime
    InitFrameTime = GameTime
    RollingUpdate
    DoSTAnim          ' DoDTAnim stays commented — no drop targets
    BSUpdate
End Sub

CorTimer.Interval = 10
Sub CorTimer_Timer(): Cor.Update: End Sub
```

Delete `queue.Tick`. Keep `DMDTimer` for now — Phase 11 decides its fate.

**Done when:** `glf_audit` shows no unresolved `queue`.

---

## Phase 6 — Devices and callbacks (1–2 days)

The bulk of it. Start from the `_configuration.vbs` skeleton and work through §4 of the first doc for the signatures. Four shapes, and they are *not* consistent:

| Device | Callback signature | Ball access |
|---|---|---|
| `CreateGlfFlipper` | `ActionCallback(Enabled)` | n/a |
| `CreateGlfAutoFireDevice` (slings, bumpers) | `ActionCallback(args)` | `args(1)`, may be `Null` |
| `CreateGlfBallDevice` (plunger, VUK) | `EjectCallback(ball)` | the parameter |
| `CreateGlfDiverter` | `ActionCallback(Enabled)` | n/a |

**The `ActiveBall` trap.** Autofire callbacks run from GLF's dispatch, not from the VPX event, so `ActiveBall` is unreliable. Your slingshot correction is the code most exposed to this — you're running an unusually aggressive curve (`AddSlingsPt 2, 0.40, -30`), so a correction applied to the wrong ball would be both very visible and very annoying to trace. Write `LS.VelocityCorrect(args(1))`, never `LS.VelocityCorrect(ActiveBall)`.

**Bumpers need an enable/disable pair** that toggles `Threshold` — GLF has no other way to switch a bumper off:

```vb
Sub Bumper1Disabled(args) : s_Bumper1.Threshold = 100 : End Sub
Sub Bumper1Enabled(args)  : s_Bumper1.Threshold = 1.5 : End Sub
```

**Delete every handler GLF now generates.** `glf_collections.py` blocks on this, so you'll be told. But the failure mode without it is a duplicate-procedure error at `Glf_Init` with a message that won't name the file.

**Your VUK's 1500 ms hold becomes GLF's, not VPX's.** Delete `VUK1.TimerInterval = 1500` and `VUK1_Timer`; use `EjectTimeout` and an `eject_vuk1` event.

**Done when:** the milestone below.

---

## Phase 7 — Gut the scoring out of `STHit` (1 hour)

Lines ~3450–3499 of your script are game logic sitting inside physics code:

```vb
Case 14: Addscore 1000 : Flasherflash1.Visible = 1 : l14.state = 1
```

All of it goes. `DoSTAnim` dispatches `s_ST14_active`, and the scoring becomes an `EventPlayer` line in a mode:

```vb
.Add "s_ST14_active", Array("score_1000", "light_st14")
```

Strip the `Select Case` to nothing. This also clears the last `Addscore` call sites the audit flagged.

Same treatment for `sw8`/`sw9` and the `BonusX()` logic — but resolve the `BonusX(0)`/`BonusX(1)` question first. `CheckBonusX` tests all four indices and only two switches exist to set them. Encoding a half-built rule as GLF player vars will be worse than fixing it now.

---

## MILESTONE A — silent but playable

Ball serves from trough → plunger lane → playfield. Flippers work with your polarity and live-catch tuning. Slings and bumpers fire with correct Fleep sounds and DOF. All eight standups animate and bounce. VUK ejects. Ball drains and re-serves. Diverter responds to the left flipper.

No scoring, no DMD, no modes.

**Verify with:** `glf_audit.py --table ./MyTable --scripts src --glf src/glf/glf.vbs`. Section 7 should be down to `vpmTimer` and the `DOF*` constants, which come from `core.vbs` at runtime and always show unresolved.

If the physics feels wrong here, it's a callback wiring problem, not GLF — none of your ZNFF/ZSSC/ZDMP tuning was touched.

---

## Phase 8 — Sounds (½ day, mostly asset work)

GLF wants its game audio registered by name and duration, and routed through buses:

```vb
Sub CreateSounds()
    AddMusic "mus_lukes_diner", 235.848, -1      ' name, seconds, loops (-1 = forever)
    AddSoundEffect "sfx_jackpot", 1.386
    AddCallout "voc_multiball_ready", 1.442
End Sub
```

Two constraints that will bite:

- **Durations must be accurate.** GLF uses them for sequencing. Get them from ffprobe rather than by hand.
- **All game sounds must be positioned to the Backglass in VPX's Sound Manager.** The example says so in a comment and it's easy to miss.

This is entirely separate from Fleep. Your mechanical sounds keep going through `PlaySound`/`SoundFX` and never touch GLF's sound player.

Buses are declared in `ConfigureGlfDevices` — `mus`, `sfx`, `voc`, each with `SimultaneousSounds` and `Volume`. Already in the skeleton.

---

## Phase 9 — Score and base modes (1 day)

**`CreateScoreMode()`** is nearly boilerplate — copy the example's and change `ScoreArray`. It loops your score values and creates a `score_NNNN` event for each, applying `current_player.scoring_multiplier`:

```vb
For each x in ScoreArray
    With .EventName("score_"&x)
        With .Variable("score")
            .Action = "add"
            .Int = x&" * current_player.scoring_multiplier"
        End With
    End With
Next
```

Priority 2000, starts on `game_start`.

**`CreateBaseMode()`** runs whenever a ball is in play, priority 110. Copy the example's and strip hard. **Delete the `.SlidePlayer()`, `.WidgetPlayer()` and `.SegmentDisplayPlayer()` blocks** — the first two need BCP/Godot, the third needs `GlfLightSegmentDisplay` light groups you're not building. That removes about half the file.

What you keep and adapt:

- `.BallSaves("new_ball")` — 6 s active, 3 s hurry-up, auto-launch
- `.EventPlayer()` bindings for slings and bumpers → `score_5000`
- `.LightPlayer()` turning GI on at `mode_base_started` — this replaces your deleted `For Each xx In GI` loop
- `.VariablePlayer()` maintaining `ball_just_started`
- `.SoundPlayer()` for music start/stop

**Priority is a real design axis.** Attract 100, base 110, feature modes 700+, score 2000. When two modes address the same light, priority decides. Getting this wrong produces lights that flicker between two modes' opinions, which reads as a bug in the light code and isn't.

---

## Phase 10 — FlexDMD bridge (1–2 days)

Covered in §4 of `stars-hollow-glf-plan.md`. The shape:

Keep `21_ZDMD_FlexDMD.vbs` entirely. Replace its **data sources**:

```vb
' was: PlayerScore(i)
label.Text = FormatNumber(GetPlayerStateForPlayer(i, "score"), 0)
```

and its **triggers**:

```vb
AddPinEventListener "jackpot_awarded", "dmd_jackpot", "ShowJackpotScene", 100, Null
Function ShowJackpotScene(args)
    ShowScene flexScenes(4), FlexDMD_RenderMode_DMD_RGB, 5
End Function
```

`AddPlayerStateEventListener "score", "dmd_score", 0, "UpdateDMDScore", 1000, Null` gives you push updates instead of polling `DMDTimer` at 17 ms.

`Flex_Init` moves out of `Table1_Init` into a listener on GLF's init or `game_start`, so it doesn't run before `Glf_Init`.

Your `dropBonus0` scene is currently orphaned — `Kicker1_Hit` was its only caller and that object doesn't exist. Either wire it to something real or drop the scene.

---

## Phase 11 — Your nine modes (the actual game)

Everything above is scaffolding. This is where "Luke Danes' Diner Danceoff" gets built, and there's no shortcut in this document for it.

The vocabulary you'll be composing from, roughly in order of how often you'll reach for it:

| Thing | What it's for |
|---|---|
| `CreateGlfMode(name, priority)` | container; `.StartEvents` / `.StopEvents` |
| `.EventPlayer()` | event → event fan-out. The workhorse. |
| `.Shots()` / `.ShotProfiles()` | a lamp+switch with states; the core scoring primitive |
| `.ShotGroups()` | banks of shots, rotation, completion events |
| `.VariablePlayer()` | read/write player and machine vars |
| `.LightPlayer()` / `.ShowPlayer()` | direct light control vs. named shows |
| `.SoundPlayer()` | music, sfx, callouts by name |
| `.Counters()` | count events, fire at N |
| `.Timers()` | tick-based sequencing (see attract mode) |
| `.SequenceShots()` | ordered switch sequences — your orbits |
| `.MultiballLocks()` / `.Multiballs()` | lock and release |
| `.BallSaves()` | grace periods |

Conditional event names are the thing worth learning early:

```vb
.Add "timer_attract_display_tick{devices.timers.attract_display.ticks == 7}", Array("show_attract_hs1")
.Add "s_Plunger1_inactive{current_player.ball_just_started == 1}", Array("new_ball_active")
```

The `{...}` expression is evaluated against player state, machine vars and device state. This is also where `cached-functions.vbs` comes from — GLF compiles each expression to a named function in dev mode and the prod build inlines them. So: **run in dev mode after any config change, then rebuild prod**, or the cache is stale.

**Read `shot.md`, `shot-profile.md` and `light-player.md` before writing a mode.** They're the most complete docs in the repo. `getting-started.md` is a zero-byte file, so don't go looking there.

---

## Where the time actually goes

Phases 0–7 are mechanical and bounded — a week or so, most of it in Phase 6. Phases 8–10 are another week and are mostly asset and glue work. Phase 11 is the game, and it's open-ended.

The framework-migration part is the small part. That's the good news: if Milestone A feels right, the remaining risk is about designing a pinball game, not about GLF.
