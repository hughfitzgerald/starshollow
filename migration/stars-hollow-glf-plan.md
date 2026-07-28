# Stars Hollow Showdown → GLF: Specific Plan

Based on your `script.vbs` (6,421 lines) and `gameitems.json` (488 items).

---

## 1. Where the table actually is

**92.5% of your substantive script lines are verbatim from the VPW example table.** I diffed against v1080; your base is v1.7 (apophis changelog entries `1.6.1`–`1.7`). The custom deltas are:

| Change | Where |
|---|---|
| Mode list comment block (9 modes: Luke's Diner Danceoff, Jess & Dean, Logan Sucks, Babette, Get a Job, Miss Patty's, Lorelai's Breakup Breakaway, Paris & Rory, Why Did You Drop Out of Yale) | header |
| **All drop targets commented out** — `DT1–DT3`, `DTArray`, `DTHit`, `SolDT*`, and `DoDTAnim` removed from `FrameTimer_Timer` | ZRDT, ZTAR, ZTIM |
| Standups expanded **3 → 8** (`sw11`–`sw18`, `ST11`–`ST18`), `STMass` 0.2 → 0.1 | ZRST |
| `sw14`–`sw18` scoring cases added to `STHit` (1000 pts + flasher + `l14`–`l18`) | ZRST |
| `VUK1` kicker added (1500ms delay, kicks -19° @ 50) | ZKIC |
| `Diverter` flipper crudely bound to LeftFlipperKey in `Table1_KeyDown`/`KeyUp` | ZKEY |
| `EOSReturn` → 0.025 (mid-90s), sling correction curve retuned (much steeper: ±30 at 0.40/0.60) | ZNFF, ZSSC |
| Kicker1 drop-target bonus logic gutted to a single `dropBonus0` scene | ZKIC |
| Dampener: `aBall.velz = aBall.velz * coef` line removed | ZDMP |

That's it. **Almost nothing of yours is at risk in this port.** This is close to the best case — you're migrating framework scaffolding, not bespoke rules.

## 2. Dead code to delete before you start

I cross-referenced every `_Hit`/`_Timer`/`_Slingshot`/`_Spin` sub against the object list. These reference objects that no longer exist in the table:

```
Bumper2_Hit / Bumper2_Timer     ' only Bumper1, Bumper3, Bumper5 exist
Bumper4_Hit / Bumper4_Timer
TestSlingShot_Slingshot
Kicker1_Hit / Kicker1_Timer     ' no Kicker1 object — scoop was removed
Spinner_Spin                    ' no spinner object in the table
ramptrigger01_hit, ramptrigger02_hit/_unhit, ramptrigger03_hit/_unhit
sw6_Hit, sw7_Hit
```

Two of these matter beyond tidiness:

- **`Kicker1_Hit` is dead**, but it's also the only caller of your `dropBonus0` FlexDMD scene. So the scene never plays. If the scoop is coming back, it becomes a `CreateGlfBallDevice`.
- **`Sub RighttInlane_Hit`** — inherited typo from the VPW example (double `t`). Your object is `RightInlane`, so `rightInlaneSpeedLimit` has never fired. Your right inlane has no speed limiting and your left does. Worth knowing before you re-tune anything, since it means the two inlanes currently behave asymmetrically. Under GLF this becomes `s_RightInlane_active` and the typo class of bug disappears — event names are strings, but at least they're strings you write once.

Also worth noting: your `Table1_Init` calls `vpmMapLights AllLamps`, which is ROM-lamp mapping with `UsingROM = False`. Harmless no-op today, meaningless under GLF. Delete.

---

## 3. Object → GLF mapping

### `glf_switches` (GLF generates `_Hit`/`_UnHit`; delete your handlers)

| Current | Suggested rename | Notes |
|---|---|---|
| `Trigger1` | `s_PlungerLane` | Also the plunger ball device's `BallSwitches` |
| `LeftInlane` | `s_LeftInlane` | |
| `RightInlane` | `s_RightInlane` | |
| `sw8` | `s_BonusLaneL` | currently `l8` + `BonusX(2)` |
| `sw9` | `s_BonusLaneR` | currently `l9` + `BonusX(3)` |
| `Bumper1` | `s_Bumper1` | also an autofire device |
| `Bumper3` | `s_Bumper3` | |
| `Bumper5` | `s_Bumper5` | |

Your `BonusX(0)` and `BonusX(1)` are set somewhere I don't see a switch for — `CheckBonusX` tests all four but only `sw8`/`sw9` set indices 2 and 3, and `Table1_Init` clears 0–3. Two more inlane switches may be missing, or the logic is half-built. Worth resolving before you encode it as GLF player vars.

### `glf_slingshots`

`LeftSlingShot` → `s_LeftSlingshot`, `RightSlingShot` → `s_RightSlingshot`. Note your current casing is `SlingShot` (capital S); GLF configs are case-sensitive, so pick one form and be consistent.

### `glf_spinners`

**Empty, but the collection must still exist.** `Glf_Init` iterates it unconditionally.

### Standup targets — *not* in any collection

`sw11`–`sw18` → `s_ST11`–`s_ST18`. Keep your `psw11`–`psw18` primitives and the `sw11o`–`sw18o` bounce primitives exactly as they are; the Roth code is untouched.

```vb
With CreateGlfStanduptarget("target11")
    .Switch = "s_ST11"
    .UseRothStanduptarget = True
    .RothSTSwitchID = 11
End With
```

Your existing `Set ST11 = (new StandupTarget)(s_ST11, psw11, 11, 0)` lines and `STArray` stay. `RothSTSwitchID` must match the third constructor argument.

### Ball devices

- `Trigger1`/`s_PlungerLane` → `CreateGlfBallDevice("plunger")`, `MechanicalEject = True`, `DefaultDevice = True`. A trigger is fine here — the tutorial explicitly uses a trigger-style switch. The example's `PlungerEjectCallback` reads `BallCntOver` because theirs is a kicker for auto-launch; yours has no autoplunger, so the callback can be empty or just play a sound.
- `VUK1` → `CreateGlfBallDevice("vuk1")` with `EjectTimeout = 2000`, `EjectAllEvents = Array("eject_vuk1")`. Your `VUK1_Timer` body becomes `Vuk1EjectCallback(ball)`. The 1500ms `TimerInterval` hold becomes a GLF delay or an `EjectAllEvents` trigger — don't keep the VPX timer.

### Diverter

Your `Diverter` is a **Flipper** object driven directly off `LeftFlipperKey`. Under GLF this must become a `CreateGlfDiverter` with an `ActionCallback` — GLF owns the flipper keys, and your `Diverter.RotateToEnd` line in `Table1_KeyDown` will simply never run once `Glf_KeyDown` takes over. If you genuinely want it flipper-button-linked (a shooter-lane diverter style), the clean way is `.ActivateEvents = Array("s_left_flipper_active")` — GLF dispatches that virtual switch event on every left flipper press.

### Trough — leave alone

`swTrough1`–`swTrough5` and `Drain` already match GLF's hardcoded names, and `tnob = 5` matches `glf_troughSize`. **Delete your entire `ZDRN` section** (lines ~836–908) including `swTrough1_Hit`…`swTrough5_UnHit`, `Drain_Hit`, `UpdateTroughTimer_Timer`. GLF ships all of it. Also delete the `ETBall1`–`ETBall5` creation from `Table1_Init` — `Glf_Init` calls `DestroyBall` and re-creates them itself.

`debugKicker` — dev only, keep out of collections.

### `glf_lights`

You have 55 `Light` objects. Practical split:

- `l1`, `l2`, `l3`, `l8`, `l9`, `l11`–`l23` and the `l111`/`l131`/`l141`/`l151`/`l161`/`l171`/`l181` duplicates → inserts, all into `glf_lights`
- `gi006`–`gi024`, `gi050` → into `glf_lights`, then define a `GILightNames` array and drive them with a show, replacing your `For Each xx In GI : xx.state = 1` in `Table1_Init`
- `bumperbiglight*` / `bumpersmalllight*` → these are Flupper bumper internals driven by `FlBumperFadeTarget`. **Keep them out of `glf_lights`** or GLF will blank them at init and fight the ZFLB fade code.
- `Flasherlight1`–`4` → keep out; ZFLD Flupper dome code owns them.

That boundary — GLF-owned lights vs. Flupper-owned lights — is the one place I'd expect a confusing bug. `Glf_Init` ends with `For Each light In Glf_Lights: Glf_SetLight light.Name, "000000"`, so anything you add is forced dark and stays dark until a show drives it.

---

## 4. FlexDMD: the real decision, and it's not great news

You said FlexDMD over Godot. You should know what that costs, because **GLF has almost no FlexDMD integration.** I grepped all 17,650 lines: exactly one reference, in `Glf_EnableVirtualSegmentDmd`, which creates a FlexDMD at `RenderMode = 3` and pushes a 32-element `.Segments` array. That's an alphanumeric segment emulator — the "Glf Virtual Segment DMD" table option. It is not a scene/graphics DMD.

GLF's actual display story is `SlidePlayer` → BCP (`VpxBcpController.msi`) → Godot `GMCDisplay`. If you're not doing Godot, `SlidePlayer` gives you nothing.

Your existing DMD is a full FlexDMD scene system: `FlexScenes(0..8)`, `Flex_Init`, `ShowScene`, `DMDTimer_Timer` at 17ms with per-frame label/font manipulation, backed by a `VPWExampleTableDMD` project folder. **None of that is GLF-aware, and GLF won't drive it.**

Three honest options:

**(a) Bridge it yourself — my recommendation.** Keep the entire ZDMD section as-is. Replace its data sources with GLF's, and its triggers with event listeners:

```vb
' In DMDTimer_Timer, replace PlayerScore(i) / CurrentPlayer:
label.Text = FormatNumber(GetPlayerStateForPlayer(i, "score"), 0)

' Replace queue.Add "flexJackpot", ... with:
AddPinEventListener "jackpot_awarded", "dmd_jackpot", "ShowJackpotScene", 100, Null
Function ShowJackpotScene(args)
    ShowScene flexScenes(4), FlexDMD_RenderMode_DMD_RGB, 5
End Function
```

`AddPlayerStateEventListener "score", "dmd_score", 0, "UpdateDMDScore", 1000, Null` gets you push updates instead of polling. This is maybe 100–200 lines of glue and you keep all your scene work. You also get to delete `vpwQueueManager` (ZQUE, ~680 lines) since GLF's `SetDelay` and `GlfTimer` cover the sequencing.

**(b) Segment displays only.** Use GLF's `GlfLightSegmentDisplay` with `ExternalFlexDmdSegmentIndex`, driven by light groups you build in the table. Fully supported, zero custom code, but you get 14-segment alphanumerics — a very different game than your current scene-based DMD.

**(c) Reconsider Godot later.** Not now, but keep option (a)'s bridge thin so it's replaceable. The Godot path is where GLF's development attention is, so it'll get better while FlexDMD stays a manual integration forever.

Go with (a). Just budget for it explicitly rather than discovering mid-port that `SlidePlayer` does nothing.

---

## 5. VR: cheap to keep open

VR is orthogonal to GLF — it's `RenderingMode` detection, `VRRoom`, `SetupRoom`, and a layer of objects. You have the `Generic_24.VR` layer and a `VR_Logo` flasher already.

Two things to do now so you don't foreclose it:

1. **Adopt the GLF example's VR structure even though it's empty.** They moved `SetupRoom` into `Table1_OptionEvent` (so the VR room rebuilds when the option changes) and `InitVR()` into `Table1_Init`. That's cleaner than VPW 1.7's inline approach, and retrofitting it later means touching options code you'll have already customized. Create `20_ZVRS_VR_Stuff.vbs` with stubs.
2. **Keep `VRRoom`/`RenderingMode` in ZCON and the `VR Room` option in ZOPT.** The GLF example's ZOPT already includes `TestVR` for desktop testing. Free to carry.

One caution: your `DMDTimer_Timer` starts with `If VRroom > 0 Or FlexONPlayfield Then FlexFlasher`. If you take the FlexDMD bridge route, that dependency survives untouched. Good — that's an argument for (a) over (b).

---

## 6. File split

Your section headers map almost 1:1 onto the GLF example's layout:

```
src/vpx/
  01_ZCON_Constants.vbs           lines 292–329, minus BIP/BIPL/PlayerScore/queue
  02_ZOPT_User_Options.vbs        228–291   + Glf_Options(eventId)
  03_ZTIM_Timers.vbs              600–628   - queue.Tick
  04_ZINI_Init_and_Exit.vbs       629–710   REWRITE
  05_ZKEY_Key_Handling.vbs        919–1016  REWRITE (flippers/nudge → GLF)
  06_ZMAT_Math.vbs                711–814   as-is
  07_ZANI_Animations.vbs          815–835   as-is
  08_ZFLP_Flippers.vbs            1017–1078 + 1741–2555 (ZNFF)  callbacks rewritten, physics as-is
  09_ZSLG_Slingshots.vbs          1170–1232 + 2763–2915 (ZSSC) callbacks rewritten, correction as-is
  10_ZDMP_Dampeners.vbs           2556–2762 (incl. ZBOU) as-is
  11_ZSOL_Solenoids.vbs           1233–1272 + 1487–1499  REWRITE as callbacks
  13_ZRST_Standup_Targets.vbs     3288–3506 as-is + event dispatch
  14_ZSHA_Ball_Shadows.vbs        1650–1701 as-is
  15_ZBRL_Ball_Rolling.vbs        3507–3576 as-is
  16_ZRRL_Ramp_Rolling.vbs        3577–3750 as-is
  17_ZFLE_Fleep_Sounds.vbs        3751–4661 as-is
  18_ZFLD_Flupper_Domes.vbs       4662–4997 as-is
  19_ZFLB_Flupper_Bumpers.vbs     4998–5268 as-is (keep — GLF example dropped it, no conflict)
  20_ZVRS_VR_Stuff.vbs            6393–end  stubs
  21_ZDMD_FlexDMD.vbs             330–599   keep, rewire data sources

src/game/
  _configuration.vbs              new — see attached skeleton
  modes/*.vbs                     new
  shows/*.vbs                     new
```

**Delete outright:** ZDRN (836–908), ZSCR (909–918), ZBMP (1079–1138), ZGII (1139–1169), ZTRI (1273–1362), ZTAR (1363–1486), ZLIS (1500–1649), ZRDT (2916–3287, already commented), ZTST (5269–5602), ZQUE (5603–6282), ZLOG (6283–6355), ZCRD (6356–6392).

Note `ZPHY` (1702–1740) is pure comments — keep or drop, doesn't matter.

That's roughly 2,400 lines deleted, ~3,300 carried over unchanged, ~400 rewritten.

---

## 7. Order of operations

1. Toolchain: clone `vpx-example-glf`, `npm install`, `npm run rename-project -- StarsHollowShowdown --git`, confirm the stock example builds and runs. Then `npm run update-glf` — the example ships `glf.vbs` at 17,275 lines vs upstream 17,650.
2. `vpxtool extract` your table into the same repo shape.
3. Delete the dead subs from §2 and the sections from §6. Do this *before* splitting; it's easier in one file.
4. Split into `src/vpx/`.
5. VPX editor: create the four collections, add `Glf_GameTimer` (enabled, `-1`), rename objects per §3, populate collections. Delete `UpdateTroughTimer`? No — **keep it**, GLF's trough uses it. Keep `DMDTimer` too.
6. Delete every `_Hit`/`_UnHit`/`_Slingshot` sub for objects now in GLF collections or registered as devices.
7. Write `_configuration.vbs` devices-only (skeleton attached).
8. **Milestone:** ball launches from trough → plunger lane → playfield, flippers work, slings and bumpers fire with correct Fleep sound and DOF, all 8 standups animate, VUK ejects, ball drains and re-serves. No scoring, no DMD.
9. FlexDMD bridge (§4a).
10. Modes — start with `base` and `attract` from the example, stripped.

Step 8 is where you'll know whether the physics survived intact. Given how much of your tuning is in ZNFF/ZSSC/ZDMP and how little of that GLF touches, I'd expect it to.

---

## 8. Things I'd watch for

**`STHit` scoring must be gutted.** Lines ~3450–3499 have `Addscore 1000` + flasher + `lNN.state = 1` per switch. That's game logic sitting inside physics code. Under GLF, `DoSTAnim` dispatches `s_ST11_active` and the scoring moves to an `EventPlayer` entry. Strip the `Select Case` down to nothing.

**Your sling correction curve is aggressive.** `AddSlingsPt 2, 0.40, -30` and `3, 0.60, 30` vs. the VPW default of `0.48, 0` / `0.52, 0`. That's a deliberate, unusual tune. It carries over untouched — but GLF's slingshot callback passes `args(1)` where you currently rely on `ActiveBall`, so make sure `LS.VelocityCorrect(args(1))` is what actually gets called, not a stale `ActiveBall` reference. Silent wrong-ball corrections would be miserable to diagnose.

**The `Diverter` on the flipper key is the one behavioural thing that will break silently** during step 6. Handle it explicitly.

**`FlexONPlayfield`, `DMDPlayfield`, `DMDbackbox`** flashers are referenced by the DMD code; they're in your item list, so the FlexDMD bridge keeps working. Don't put them in `glf_lights`.
