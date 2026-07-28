# Clean slate: what to delete rather than migrate

You're right, and it changes the plan. I looked at what's actually in your ZDMD and scoring, and most of what I scoped as "migration work" is migration of someone else's demo content.

---

## The FlexDMD situation is different than I said

All nine of your FlexDMD scenes are VPW example demos:

| Scene | Content |
|---|---|
| `FlexScenes(0)` "Score" | four-player scoreboard with a `>>> Flex DMD <<<` scroller |
| `FlexScenes(1)` "Welcome" | VPW welcome |
| `FlexScenes(2)` "BonusX" | demo bonus multiplier |
| `FlexScenes(3)` "multiball" | demo |
| `FlexScenes(4)` "jackpot" | demo |
| `FlexScenes(5–8)` "nobonus", "bonus1–3" | drop-target bonus demo — orphaned, since `Kicker1` doesn't exist |

They render out of `./VPWExampleTableDMD/` using VPW's `bgdarker.png`, `sys80.fnt`, `TeenyTinyPixls5.fnt`. None of it is yours.

**So Phase 10 drops from 1–2 days to about two hours.** Of the ~270 lines in ZDMD:

- **Keep ~25 lines:** the `Flex_Init` header (`CreateObject`, `GameName`, `TableFile`, `RenderMode`, `Width`, `Height`, `Run`), `FlexFlasher`, and the `DMDPlayfield` / `DMDbackbox` / `FlexONPlayfield` display wiring. That's reusable plumbing.
- **Delete ~180 lines:** every `Set FlexScenes(n) = FlexDMD.NewGroup(...)` block and its actors, plus all the fonts.
- **Delete ~70 lines:** `DMDTimer_Timer`. It polls at 17 ms to read `PlayerScore()` and `BIP`, both of which are going away. GLF's `AddPlayerStateEventListener` pushes instead of you polling.

`.ProjectFolder` becomes `./StarsHollowShowdownDMD/`, and `cGameName` and `gamename.txt` change to match.

**Worth reconsidering the Godot decision.** The main argument for FlexDMD was that you already had scenes and didn't want to rebuild them. That argument just evaporated. If you're authoring DMD content from scratch either way, the tradeoff is now:

- **FlexDMD:** you keep writing VBScript scene code, and GLF gives you nothing — no `SlidePlayer`, no `WidgetPlayer`. Every DMD update is a hand-written event listener. But it's the workflow you already know, and it works today.
- **Godot/BCP:** `SlidePlayer` and `WidgetPlayer` become usable, which is a meaningful chunk of base mode and every feature mode you'd otherwise hand-roll. Cost is learning Godot and the `GMCDisplay` project, plus `VpxBcpController.msi`. It's also where GLF's development attention is going.

I'd still lean FlexDMD if you want to be playing sooner, and it's not a one-way door — keep the bridge thin and it's replaceable. But it's a genuine decision now rather than a default.

---

## The lifted scoring is an inventory, not config

`glf_callbacks.py` extracted this:

```
.Add "s_Bumper1_active", Array("score_250")
.Add "s_LeftSlingshot_active", Array("score_10")
.Add "s_ST11_active", Array("score_1000", "light_l11")
   ... ×8, all identical
```

Those values are VPW's demo numbers. Eight standups each awarding a flat 1000 with a lit insert is the example table demonstrating that targets work, not a game.

**Treat `_scoring.suggested.vbs` as a checklist of what's currently wired, then throw it away.** In GLF the natural primitive for a target bank isn't eight `EventPlayer` lines — it's a `ShotGroup`:

```vb
With .Shots("diner_1")
    .Profile = "diner"
    .Switch = "s_ST11"
End With
' ... ×8

With .ShotGroups("diner_bank")
    .Shots = Array("diner_1", ..., "diner_8")
    .EventsWhenComplete = Array("diner_danceoff_ready")
    .Rotate = True
End With
```

That gives you lit/unlit state per target, per-player persistence, rotation on flipper press, and a completion event — all of which you'd otherwise write by hand. Read `shot.md`, `shot-profile.md` and `shot-group.md` before deciding the target layout, because the framework's shape will influence what's cheap to build.

Same for the bumpers and slings: keep the sound and DOF in the migrated callbacks, but decide the point values as part of designing the game.

---

## Delete rather than fix

**`BonusX()` / `CheckBonusX`.** Half-built VPW demo — tests four indices, only two switches set any of them. Don't port a half-finished rule into GLF player vars. Delete it, and design the bonus lanes as a `Counter` or `ShotGroup` when you get there.

**`ToggleGI`, `Flash1`–`Flash4`.** Demo flasher pulses inside `STAction` and `Bumper*_Hit`. GLF's `ShowPlayer` with a `flash_color_with_fade` show does this properly, per-mode, with priority. Delete the calls.

**Shot-tester objects, in the `.vpx` not just the script.** `debug_BLW1`/`BLP1`/`BLR1`, `debug_BLW2`…, `debugKicker`, and the `Shot_tester` layer. ZTST is already deleted from the script; the objects are dead weight in the table.

**VPW's sound assets.** The example's callouts and sfx aren't yours. Start `CreateSounds()` empty and add as you author — `glf_scaffold.py sounds` will regenerate it with correct durations whenever you drop new files in.

**Dead lights.** The audit found `l6`, `l7`, `l41` referenced in ZFLD but absent from the table. Pre-existing, unrelated to the migration, but worth clearing while you're in there.

---

## One thing to do *now* that gets expensive later

**Rename the lights semantically, alongside the `s_` switch renames.**

Same argument as the switch prefix, and it applies harder to lights. `l11`–`l18`, `l1`/`l2`/`l3`, `gi006`–`gi024` are VPW example names. Under GLF, light names appear as string literals in every `LightPlayer`, `ShowPlayer` token, and shot profile you write — potentially hundreds of references. `l_diner_1` reads; `l11` doesn't.

`glf_rename.py` handles lights exactly like switches (gameitem file, name field, index, collections, cross-references, script identifiers), and it's boundary-aware, so `l11` → `l_diner_1` won't touch `l111`. Doing it in the same pass costs nothing. Doing it after you've written six modes means editing config you'll have to re-verify by hand.

---

## What you should *not* clean-slate

Your physics tuning is genuinely yours and diverges from stock VPW:

- `EOSReturn` = 0.025 (mid-90s profile)
- sling correction curve at `0.40, -30` / `0.60, +30` — much steeper than VPW's flat default
- `STMass` / `DTMass` = 0.1
- the removed `aBall.velz = aBall.velz * coef` line in the dampener

None of that is touched by GLF, and all of it survives the migration untouched. Same for Fleep wiring, Flupper domes and bumpers, and the ambient shadows.

---

## Revised effort

| Phase | Before | Clean slate |
|---|---|---|
| 0–5 build wiring, ZCON/ZINI/ZKEY/ZOPT/ZTIM | ~1 day | unchanged |
| 6 devices and callbacks | 1–2 days | 1 day — scripts do the bodies |
| 7 gut STHit | 1 hour | 15 min — just delete `STAction`'s cases |
| 8 sounds | ½ day | ~0 until you have assets |
| 9 score/base modes | 1 day | ½ day — scaffold generates them |
| 10 FlexDMD | 1–2 days | ~2 hours |
| 11 your nine modes | open-ended | open-ended |

Roughly a week of scaffolding turns into two or three days. The saving is entirely from *not* carrying VPW's demo content forward.

---

## So: is it a clean slate after the scripts?

Close, but not quite. After running all six you'd have a table that loads and plays with VPW's demo scoring and demo DMD scenes still attached. That's a working checkpoint and worth reaching — Milestone A proves the physics survived. But then delete the demo layer deliberately rather than building on top of it.

Concretely, after Milestone A:

1. Delete the nine `FlexScenes` blocks and `DMDTimer_Timer`; keep the `Flex_Init` plumbing
2. Discard `_scoring.suggested.vbs` after using it as a wiring checklist
3. Delete `BonusX`, `CheckBonusX`, `ToggleGI`, the `Flash1`–`Flash4` demo calls
4. Delete the shot-tester objects from the `.vpx`
5. Rename lights semantically (do this in the Phase 2 rename pass instead, if you can decide the naming that early)
6. Then start on shots and shot profiles with nothing inherited

`glf_audit.py --scripts src --glf ...` after each of those tells you what you broke.
