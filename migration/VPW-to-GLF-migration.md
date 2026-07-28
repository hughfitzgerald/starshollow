# Migrating a VPW-Example-Based Table to GLF

Notes from reading three repos:

- `francisdb/vpw-example-table-extracted` — VPW Example Table, version `1080`, extracted with vpxtool. Single `script.vbs`, 6,300+ lines. Confirmed this is the **non-ROM variant**: `core.vbs` is loaded only for `vpmTimer` / `cvpmDictionary`, there is no `Controller` object, no `SolCallback` wiring.
- `mpcarr/vpx-glf` — the framework itself. `scripts/vpx-glf.vbs` is a single 17,650-line include. Plus mkdocs documentation and five tutorial tables.
- `mpcarr/vpx-example-glf` — a working GLF table that is *explicitly a fork of the VPW example table*, restructured into a multi-file build. This is the Rosetta Stone for the migration.

---

## 1. The core mental model shift

VPW is a **library of physics and sound routines**. You call them from `_Hit` subs you write yourself, and your game logic lives wherever you put it — usually inline in those same subs, with global `Dim` variables holding state.

GLF is a **runtime that owns the game**. It is modeled on the Mission Pinball Framework: you *declare* devices, modes, shots, shows and event bindings; GLF generates the plumbing and dispatches events. Your VBScript becomes callbacks hanging off that runtime.

Concretely, in VPW you write:

```vb
Sub sw11_Hit
    Score = Score + 1000
    Light11.State = 1
    PlaySound "target"
End Sub
```

In GLF, none of that exists as a `_Hit` sub. GLF **generates** `Sub s_ST1_Hit` for you at `Glf_Init` time via `ExecuteGlobal`, and all it does is dispatch `"s_ST1_active"`. You then bind behaviour declaratively inside a mode:

```vb
With .EventPlayer()
    .Add "s_ST1_active", Array("score_1000", "play_sfx_target")
End With
```

**This is the single most important consequence for your migration:** every VPX object you register with GLF must *not* have a hand-written event sub, or VBScript will throw a duplicate-procedure error at init.

From `vpx-glf.vbs` (~line 180), for each member of `glf_switches`:

```vb
Glf_AddTablePart "Sub " & switch.Name & "_Hit() : If Not glf_gameTilted Then : " & _
    "DispatchPinEvent """ & switch.Name & "_active"", ActiveBall : ... End Sub"
```

The same happens for `glf_slingshots` (`_Slingshot`), `glf_spinners` (`_Spin`), and for the `.Switch` object of every `CreateGlfDroptarget` / `CreateGlfStanduptarget`.

---

## 2. What actually survives: a section-by-section audit

I measured how much of each GLF-example VPX subsystem file appears verbatim in the VPW example script (non-trivial lines, whitespace-normalised):

| GLF file | Verbatim from VPW | Verdict |
|---|---|---|
| `06_ZMAT_General_Math_Functions.vbs` | **100%** | copy as-is |
| `14_ZSHA_Ambient_ball_shadows.vbs` | **100%** | copy as-is |
| `17_ZFLE_Fleep_Mechanical_Sounds.vbs` | 98% | copy as-is |
| `15_ZBRL_Ball_Rolling_Sounds.vbs` | 97% | copy as-is |
| `10_ZDMP_Rubber_Dampeners.vbs` | 96% | copy as-is (TargetBouncer lives here) |
| `08_ZFLP_Flippers.vbs` | 93% | physics as-is; **callbacks rewritten** |
| `16_ZRRL_Ramp_Rolling_Sounds.vbs` | 88% | copy as-is |
| `13_ZRST_Standup_Targets.vbs` | 86% | Roth code as-is + event dispatch |
| `07_ZANI_Misc_Animations.vbs` | 78% | mostly as-is |
| `02_ZOPT_User_Options.vbs` | 77% | + `Glf_Options(eventId)` |
| `03_ZTIM_Timers.vbs` | 67% | mostly as-is |
| `12_ZRDT_Drop_Targets.vbs` | 66% | Roth code as-is + Keepup + dispatch |
| `18_ZFLD_Flupper_Domes.vbs` | 41% | rewired to GLF lights |
| `09_ZSLG_Slingshots.vbs` | 40% | **rewritten as callbacks** |
| `05_ZKEY_Key_Press_Handling.vbs` | 37% | **GLF takes flippers + nudge** |
| `04_ZINI_Table_Initialization_and_Exiting.vbs` | 33% | **rewritten** |
| `01_ZCON_Constants_and_Global_Variables.vbs` | 25% | **rewritten** |
| `11_ZSOL_Other_Solenoids.vbs` | 13% | **rewritten as callbacks** |
| `20_ZVRS_VR_Stuff.vbs` | 8% | table-specific anyway |

**Good news:** the entire VPW physics and mechanical-sound stack — nFozzy/Roth flipper polarity, cor tracking, live catch, flipper tricks, rubber dampeners, TargetBouncer, Fleep sounds, ball rolling, ramp rolling, ambient shadows — moves across essentially untouched. That is the bulk of the value in a VPW table and the bulk of the tuning work you've already done.

**The work is concentrated in:** anything that touched game state, and anything that was an event *entry point*.

### VPW sections with no counterpart in the GLF example

These are absent from `vpx-example-glf` entirely — either replaced by GLF, or simply dropped:

| VPW section | Fate |
|---|---|
| `ZDRN` Drain, Trough, Ball Release | **Replaced.** GLF ships its own trough at the bottom of `vpx-glf.vbs` (`swTrough1_Hit`…`swTrough7_Hit`, `Drain_Hit`, `UpdateTroughDebounced`). Delete yours. |
| `ZSCR` Scoring | **Replaced** by GLF player vars + `score_NNNN` events. |
| `ZBMP` Bumpers | **Replaced** by `CreateGlfAutoFireDevice`. |
| `ZKIC` Kickers/Saucers | **Replaced** by `CreateGlfBallDevice` + `EjectCallback`. |
| `ZTRI` Triggers | **Replaced** by `glf_switches` auto-generated dispatch. |
| `ZTAR` Targets | **Replaced** by GLF drop/standup target devices. |
| `ZGII` GI | Handled via GLF light shows / `glf_lights`. |
| `ZDMD` FlexDMD | **Replaced** by GLF slide player + BCP/Godot, or GLF segment displays. |
| `ZLIS` ROM SoundCommand Listener | N/A — GLF *is* the ROM. |
| `ZQUE` VPW Queuing System | Dropped. GLF has `SetDelay` and its own `GlfTimer`. |
| `ZTST` Debug Shot Tester | Dropped. |
| `ZCRD` Instruction Card Zoom | Dropped. |
| `ZLOG` Error Logs | Replaced by `glf_debugLog`. |
| `ZFLB` Flupper Bumpers | Dropped from example (not a GLF conflict — you can keep it). |
| `ZBOU` TargetBouncer | Survives, folded into `10_ZDMP`. |

---

## 3. Hard requirements checklist

Before any script work, the `.vpx` file itself needs these. Missing any of them produces failures at init that are not always obvious.

**Collections** (F8 collection manager):
- `glf_lights` — every light GLF may address
- `glf_switches` — rollovers, triggers, plunger lane, scoop switches, bumper switches
- `glf_slingshots`
- `glf_spinners`

**Timers:**
- `Glf_GameTimer` — Enabled, Interval `-1`
- `UpdateTroughTimer` — Interval `100`, initially **disabled**
- Keep VPW's `FrameTimer` (`-1`) and `CorTimer` (`10`)

**Named objects GLF hardcodes:**
- `swTrough1` … `swTrough7` (kickers, as many as `tnob`)
- `Drain`

Your VPW table already uses `swTrough1..N` and `Drain`, so this should be free.

**Globals that must exist:**

```vb
Const cGameName = "YourTable"
Const BallSize = 50
Const BallMass = 1
Const tnob = 5      ' playable balls in trough
Const lob  = 0      ' locked / captive balls
Dim gBOT
Dim tablewidth  : tablewidth  = Table1.width
Dim tableheight : tableheight = Table1.height
```

**Four hooks:**

```vb
Sub Table1_Init
    LoadCoreFiles          ' still needed for cvpmMagnet etc.
    ConfigureGlfDevices()
    Glf_Init(Table1)
    InitRolling() : InitPolarity() : InitSlingCorrection()
End Sub

Sub Table1_Exit : Glf_Exit() : End Sub
Sub Table1_KeyDown(ByVal keycode) : Glf_KeyDown(keycode) : ... End Sub
Sub Table1_KeyUp(ByVal keycode)   : Glf_KeyUp(keycode)   : ... End Sub

Sub Table1_OptionEvent(ByVal eventId)
    If eventId = 1 And Not dspTriggered Then dspTriggered = True : DisableStaticPreRendering = True : End If
    ' ...your options...
    Glf_Options(eventId)
    If eventId = 3 And dspTriggered Then dspTriggered = False : DisableStaticPreRendering = False : End If
End Sub
```

---

## 4. Callback signature conversions

This is the mechanical part of the port. Four different shapes, and they are not consistent — worth a cheat sheet.

**Flippers — `ActionCallback(Enabled)`, scalar boolean:**

```vb
With CreateGlfFlipper("left")
    .Switch = "s_left_flipper"
    .ActionCallback = "LeftFlipperAction"
    .EnableEvents  = Array("ball_started","enable_flippers")
    .DisableEvents = Array("kill_flippers")
End With

Sub LeftFlipperAction(Enabled)
    If Enabled Then
        DOF 101, DOFOn
        FlipperActivate LeftFlipper, LFPress   ' <- unchanged VPW
        LF.Fire                                 ' <- unchanged VPW
        ...
```

The body is your existing `Table1_KeyDown`/`KeyUp` flipper branches, moved verbatim. **Remove the flipper key handling from `Table1_KeyDown`** — GLF owns it now.

**Autofire devices (slings + bumpers) — `ActionCallback(args)`, array:**

`args(0)` = enabled, `args(1)` = the ball (may be `Null`).

```vb
Sub LeftSlingshotAction(args)
    Dim enabled : enabled = args(0)
    If enabled Then
        If Not IsNull(args(1)) Then LS.VelocityCorrect(args(1))   ' <- was ActiveBall
        LStep = 0 : s_LeftSlingshot_Timer
        RandomSoundSlingshotLeft Sling2
        DOF 103, DOFPulse
    End If
End Sub
```

Note the change from `ActiveBall` to `args(1)` — the callback runs from GLF's dispatch, not from the VPX event, so `ActiveBall` is not reliable.

Bumpers use the same shape, and get `EnabledCallback`/`DisabledCallback` that toggle `Threshold` between `1.5` and `100`:

```vb
Sub Bumper1Action(args)
    Dim enabled : enabled = args(0)
    If IsNull(args(1)) And enabled Then s_Bumper1.PlayHit()
    If enabled Then RandomSoundBumperTop s_Bumper1 : DOF 105, DOFPulse
End Sub
Sub Bumper1Disabled(args) : s_Bumper1.Threshold = 100 : End Sub
Sub Bumper1Enabled(args)  : s_Bumper1.Threshold = 1.5 : End Sub
```

**Ball devices (kickers, scoops, plunger lane) — `EjectCallback(ball)`, single ball object:**

```vb
With CreateGlfBallDevice("kicker1")
    .BallSwitches = Array("s_Kicker1")
    .EjectTimeout = 2000
    .MechanicalEject = True
    .EjectAllEvents = Array("eject_kicker1")
    .EjectCallback = "Kicker1EjectCallback"
End With

Sub Kicker1EjectCallback(ball)
    KickBall ball, -85 + ..., 25.0 + ..., 5, 25
    SoundSaucerKick 1, s_Kicker1
End Sub
```

The plunger lane is itself a ball device with `.DefaultDevice = True`.

**Diverters / kickback / knocker — `ActionCallback(Enabled)`:** thin wrappers, closest to VPW's `SolCallback` style.

**Drop and standup targets — hybrid.** The Roth animation code is preserved almost intact. You add config:

```vb
With CreateGlfDroptarget("drop1")
    .Switch = "s_DT1"
    .KnockdownEvents = Array("DT1_knockdown")
    .ResetEvents = Array("ball_started","reset_target_bank")
    .ActionCallback = "DT1Callback"
    .UseRothDroptarget = True
    .RothDTSwitchID = 1
End With
```

`UseRothDroptarget = True` tells the generated `_Hit` sub to call `DTHit <id>` instead of dispatching directly; `DoDTAnim` then dispatches `<switchname>_active` at the right moment in the animation. The only change inside `DTHit` itself is a `Keepup` branch:

```vb
If DTArray(i).Keepup = True Then
    DTArray(i).animate = 3
Else
    DTArray(i).animate = DTCheckBrick(ActiveBall, DTArray(i).prim)
End If
```

plus new `DTRaise`, `DTDrop`, `DTEnableKeepup`, `DTDisableKeepup` helpers.

---

## 5. Object naming

The GLF example renamed every switch-bearing VPX object to an `s_` prefix: `s_ST1`, `s_DT1`, `s_Bumper1`, `s_LeftSlingshot`, `s_Plunger1`, `s_TopLane1`, `s_Kicker1`.

**This is convention, not a hard requirement** — GLF reads `switch.Name` from the collection and generates event names from it. But it matters a lot in practice, because event names are string literals scattered through your mode configs. Your VPW-derived table probably has objects named `sw11`, `sw12`, `Trigger001`, `LeftSlingShot`. You can either:

1. **Rename in the VPX editor now.** Painful once (every `sw11_Hit` reference, every collection membership), but every subsequent mode config reads clearly. This is what the GLF example did.
2. **Keep existing names** and write `.Add "sw11_active", ...` everywhere.

I'd do (1), before writing any mode logic. Renaming after you have 2,000 lines of declarative event strings is much worse.

Note: switch and light names are **case sensitive** in GLF configs. `_configuration.vbs` says so explicitly and it is a real source of silent no-ops.

---

## 6. The build toolchain — an optional but load-bearing decision

GLF *can* be used by pasting `vpx-glf.vbs` into the script editor. The example table does something much better, and I'd recommend adopting it.

**How it works:**

- The in-VPX `script.vbs` is **17 lines**. It does nothing but `ExecuteGlobal` the contents of `scripts\dest\vpx\tablescript.vbs` off disk at runtime.
- Source lives in `scripts/src/`, split three ways:
  - `src/vpx/` — the VPW physics/sound layer, one file per Z-section
  - `src/game/` — `_configuration.vbs` + `modes/*.vbs` + `shows/*.vbs`
  - `src/glf/` — `glf.vbs` (vendored framework) + converted YAML shows
- `grunt concat` globs those into `dest/vpx/tablescript.vbs`. `npm run script-watcher` rebuilds on save.
- `vpxtool` (francisdb, v0.13.0) does `extract` / `assemble` so the whole table is a git repo of JSON + assets, not an opaque binary.

**The payoff:** you edit a `.vbs` in VS Code, save, and hit F5 in VPX. No script-editor round trip, no re-import, and git diffs are meaningful. Given the VPX scripting you've been doing, this will feel like a significant upgrade over editing in the VPX editor.

**Concatenation order is load-bearing.** The glob is `src/vpx/**` → `src/game/**` → `src/glf/glf.vbs`. Since `glf.vbs` lands *last*, no GLF function may be called at top level in your game files. That's why every mode in the example is wrapped in `Sub CreateXxxMode()` and only invoked from `ConfigureGlfDevices()`, which runs at `Table1_Init`. VBScript hoists `Sub`/`Function`/`Class` declarations, so definitions are fine; executable top-level statements are not.

**Setup:**

```
git clone https://github.com/mpcarr/vpx-example-glf
cd vpx-example-glf/scripts
npm install
npm run rename-project -- MyTableName --git   # renames + resets git history
npm run assemble-vpx
npm run script-watcher
```

`npm run update-glf` pulls the latest `vpx-glf.vbs` from upstream. Worth running immediately — the example ships a 17,275-line `glf.vbs` while upstream is at 17,650, so the example is already behind.

**`cached-functions.vbs`:** GLF evaluates conditional event names like `"add_hit_count.1{current_player.target_hit_count >= 6}"` at runtime. In dev mode it writes every such expression out as a compiled named function into `cached-functions.vbs` in the table directory. The `concat:prod` grunt target includes that file in the release build so the interpreter isn't re-parsing conditions every dispatch. Practical implication: **run the table in dev mode after any config change, then rebuild prod** — otherwise the cache is stale.

---

## 7. Suggested migration order

1. **Set up the toolchain first.** Clone `vpx-example-glf`, rename, confirm you can build and run it unmodified. Verify the watcher loop works. Don't touch your table yet.
2. **Extract your table with vpxtool** into the same repo layout.
3. **Split your monolithic `script.vbs`** along the existing `ZXXX` boundaries into `src/vpx/NN_ZXXX_*.vbs`. The section headers in the VPW script make this nearly mechanical.
4. **Delete the sections GLF replaces** (table in §2 above). Resist the urge to keep them "just in case" — duplicate `swTrough1_Hit` will bite you.
5. **VPX editor pass:** add the four collections, add `Glf_GameTimer` and `UpdateTroughTimer`, rename switch objects to `s_*`, populate collections.
6. **Delete every `_Hit`/`_UnHit`/`_Slingshot`/`_Spin` sub** for objects now registered with GLF.
7. **Write `ConfigureGlfDevices()`** — devices only at this stage: trough, plunger, flippers, slings, bumpers, kickers, targets. No modes.
8. **Convert callbacks** per §4. Goal at this milestone: ball launches, flippers work, slings and bumpers fire with correct sound and DOF, targets animate, ball drains and re-serves. No scoring yet.
9. **Only then start on modes.** Start with `base` and `attract` copied from the example and stripped down.
10. **Display last.** Decide between GLF segment displays driven through `glf_lights` (with `ExternalFlexDmdSegmentIndex` / `ExternalB2SSegmentIndex` bridging to your existing FlexDMD/B2S setup) or the full Godot `GMCDisplay` + `VpxBcpController.msi` BCP path. The latter is a much bigger commitment.

Step 8 is the natural checkpoint. If the table plays silently but correctly, the hard part is done.

---

## 8. Challenges worth anticipating

**The one-way door.** GLF replaces your game loop. There's no incremental "half GLF" state where some switches dispatch events and others use old handlers *and* GLF manages the ball — the trough and ball-device ownership is all-or-nothing. Budget for the port being a branch you either finish or abandon.

**Debugging shifts from "read the code" to "read the event log."** With declarative configs, a rule that doesn't fire is usually a typo in an event-name string, a case mismatch, a priority conflict between modes, or a mode that isn't started. `glf_debugLog` and the `Glf Debug Log` / `Glf Debug Log Level` table options are your instrument. Given your usual approach — testable hypotheses over speculation — I'd suggest turning the debug log on early and getting comfortable reading it *before* you have many modes.

**Mode priority is a real design axis.** The example uses `attract`, `base` (110), `targetbank` (700), etc. Shot profile states with the same lights across modes resolve by priority. Getting this wrong produces lights that flicker between two modes' opinions.

**Segment display config is verbose.** `_configuration.vbs` spends ~90 lines on six `GlfLightSegmentDisplay` objects. Each display is a light *group* — you need `p1_seg`, `p2_seg` etc. light groups defined in the table with correct ordering. If you don't want alphanumerics, skip this entirely.

**MPF export is a bonus feature, not a requirement.** With debug enabled, `Glf_Init` emits `switches.yaml`, `lights.yaml`, `coils.yaml`, `ball_devices.yaml` and a Godot light scene. Useful if you ever want to drive real hardware, ignorable otherwise — but it explains some of the odd code in `Glf_Init` (e.g. slingshot X/Y coordinates read out of `BlendDisableLighting`, a hack because slingshot objects have no `.x`).

**GLF is a young, single-maintainer framework.** ~17.6k lines of VBScript, docs that are thorough in places (`shot-profile.md`, `light-player.md`) and empty in others (`getting-started.md` is a zero-byte file). Support is a Discord you get invited to. Expect to read `vpx-glf.vbs` directly when the docs run out — it's readable, and the class definitions are the real API reference.

**Version pinning.** Vendoring `glf.vbs` into your repo (as the example does) is the right call, but means you own the upgrade. `npm run update-glf` overwrites it wholesale; diff before committing.

---

## 9. What I'd want from your table to give specific advice

- The full `script.vbs` — I can map your actual `ZXXX` sections against the table in §2 and tell you exactly what's deletable.
- `gameitems.json` (or the assembled `.vpx`) — so I can inventory switch objects, check trough/drain naming, and identify what needs renaming and which collections need populating.
- Whether you want the Godot/BCP display path or intend to keep FlexDMD/B2S.
- Whether the table is intended for VR, since `20_ZVRS` diverges most from stock VPW.

With those I can produce a concrete per-object rename list, a `ConfigureGlfDevices()` skeleton wired to your actual playfield, and a file-by-file split plan.
