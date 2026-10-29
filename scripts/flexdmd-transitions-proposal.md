# FlexDMD Scene Transitions — Integration Proposal

**Status:** implemented as described below, not yet run on a table (see the test plan in section 11). One change from section 10: `eob_bonus` leaves with `move_out down`, the way it came in, rather than `move_out up`.
**Responds to:** "FlexDMD Scene Transitions — Design Guide and Integration Brief" (the brief).
**Files read:** `src/vpx/26_ZDMD_FlexDMD.vbs`, `src/vpx/28_ZFBC_FlexDMD_Bcp_Controller.vbs`,
`src/game/dmd/display_config.vbs`, `src/game/dmd/display_scenes.vbs`, the GLF slide and segment players
in `src/glf/glf.vbs`, the GMC addon in `godot/starshollow-shows/addons/mpf-gmc/`, and the FlexDMD
plugin source (`vpinball/vpinball` master, `plugins/flexdmd/`: `FlexDMDPlugin.cpp`, `actors/Actor.*`,
`actors/Group.*`, `actors/Frame.cpp`, `actors/AnimatedActor.cpp`, `FlexDMD.cpp`).

The brief's FlexDMD research and transition catalog (its sections 1–3) hold up and are kept. What
changes is how the transitions are configured, how they are chosen, and how the module touches the
stage.

---

## 1. Decisions

| Question | Decision |
|---|---|
| Behaviour reference | **GMC** (GLF's real BCP partner) for *when* a transition plays; **MPF-MC** for the type and easing *names*. |
| Where a transition is configured | On the `GlfDmdEntry` in `display_config.vbs`, as `.Transition` and `.TransitionOut`. Nothing in `glf.vbs`, and no change to `PlaySlide`. |
| Config syntax | Both a one-line string and a With block, through the same property (section 3). |
| Table-wide default | Optional. `SetDmdDefaultTransition inSpec, outSpec`. Unset means cut, so transitions are opt-in per entry. |
| Arrival vs departure | Worked out from the stack at render time, the way GMC does it. No intent threaded through `Push`/`RemoveSlide`/`ModeStop`. |
| How the module touches the stage | Only inside one container group it owns. Never `Stage.RemoveAll`, and it never moves or resets a scene group. |
| Text (`DMDBigText`) | Shown exactly while its stack item is the top entry. It sits on top of everything and never animates (section 6). |
| Layers (`.Over`) | The new scene's layers ride in with it for free. The old scene's layers pop off at the start (v1). Animated layer in/out is v2. |
| Player option | Optional "DMD Transitions: On/Off" table option (section 9). |
| File | `src/vpx/29_ZDTX_FlexDMD_Transitions.vbs`. `27_` is taken by `27_ZRDT_Drop_Targets.vbs`. |

---

## 2. Why GMC is the reference, and what that buys us

GLF talks BCP to the Godot Media Controller, not to MPF-MC. GMC has **no** `slide_player`
transition settings. A GMC slide carries its own animations, named `created`, `active`, `inactive` and
`removed` (`addons/mpf-gmc/classes/mpf_scene_base.gd:24-37`). `mpf_display.gd` `_update_stack` decides
which of them play:

- When the new top slide has **higher** priority than the old one, the new slide's intro plays. The old
  slide is removed after it finishes, with no outro.
- When the old slide is **leaving** and sat on top (`old.priority >= new.priority`), its `removed`
  outro plays over the slide it uncovers.

So a transition belongs to the slide, not to the play. Our `GlfDmdEntry` is the slide, and that is
where `.Transition` / `.TransitionOut` go.

It also removes the hardest part of the brief (its section 6.2). `Render` does not need to know *why*
the backdrop changed. When the backdrop changes from `old` to `new`, it asks one question:

> **Is `old` still wanted by anything on the stack?**
> - **Yes:** something covered it, so this is an **arrival**.
> - **No:** it left, so this is a **departure**.

"Wanted" means a stack item is that entry, or names it as its backdrop (a layer's or a text entry's
`.Over`). Otherwise a mode panel brought up by a layer would count as "leaving" when it is only being
covered.

### Resolution order

Two rules decide it: **an entry's own setting beats a table default**, and **the leaving entry beats
the arriving one.**

| Change | First one that is set wins |
|---|---|
| Arrival (old covered) | `new.Transition` → table default in |
| Departure (old gone) | `old.TransitionOut` → `new.Transition` → table default out → table default in |

An explicit `"none"` counts as set, so it stops the search. That is how an entry opts out of a table
default.

### Always a cut, whatever is configured

- Nothing on the DMD yet (first present at boot).
- The backdrop is already on screen (a `forceKey` replay, such as countdown ticks).
- The top entry is a `.Text` entry. The change happens under opaque text, so nobody would see it
  (section 6).
- A transition started less than 250 ms ago, so rapid-fire changes collapse to cuts.
- The player option is Off.
- An unknown type in the spec. The spec parser logs it, then cuts.

### Compatibility notes

- MPF-MC vocabulary: types `none`, `push`, `move_in`, `move_out`, `wipe` and `fade`, plus DMD-only
  `flash` and `curtain`. Easing uses MPF/Kivy names (`linear`, `out_cubic`, `in_out_sine`, `out_back`,
  `out_bounce` and the rest), mapped internally to FlexDMD's `Interpolation` numbers. Direction is the
  way content **travels**, Kivy's convention: `left` means the new scene enters from the right.
- With the "Glf Backbox Control Protocol" option On (real Godot), none of this runs. Godot slides need
  their own `active`/`removed` animations. The entry fields are simply ignored, so no config has to
  change to switch.
- The brief's "per-play kwarg override" is dropped. The slide player forwards only the *triggering
  event's* kwargs, so mode config has no way to attach a `transition` kwarg to an event such as
  `mode_X_started`.

---

## 3. Config syntax (`display_config.vbs`)

There is one property per direction. Assigning a string sets it from a one-liner. Opening it in a With
block edits the same object field by field. VBScript allows a `Property Let` (the string) and a
`Property Get` (the object) under one name, so both forms work:

```vbscript
' One line - words in any order; anything left out takes the type's default.
With CreateDmdSlide("mode")
    .Builder       = "DmdBuild_Mode"
    .Ticker        = "DmdTick_Mode"
    .Transition    = "push left"
    .TransitionOut = "push right"
End With

' Field by field - same object, the GLF segment-player shape.
With CreateDmdSlide("mode")
    .Builder = "DmdBuild_Mode"
    With .Transition
        .TransitionType = "push"
        .Direction      = "left"
        .Duration       = 0.4
        .Easing         = "out_cubic"
    End With
End With

' Opt one entry out of a table default.
With CreateDmdSlide("mystery1_eb") : .Transition = "none" : End With
```

Field names copy GLF's own `GlfSegmentPlayerTransition` (`.TransitionType`, `.Direction`). `Type` is
reserved in VBScript, hence `TransitionType`.

### The string format

The string is space-separated words, case-insensitive, in any order:

| Word | Means |
|---|---|
| `none` `push` `move_in` `move_out` `wipe` `fade` `flash` `curtain` | type (required) |
| `left` `right` `up` `down` | direction the content travels (default `left`) |
| a number, such as `0.4` | duration in seconds |
| an easing name, such as `out_cubic` | easing |

Examples: `"push left 0.4 out_cubic"`, `"fade 0.5"`, `"move_in down 0.6 out_bounce"`, `"none"`.

### Defaults per type (tuned for 128×32)

| Type | Duration (horizontal / vertical) | Easing |
|---|---|---|
| push | 0.4 / 0.2 | out_cubic |
| move_in | 0.4 / 0.25 | out_back |
| move_out | 0.35 / 0.2 | in_cubic |
| wipe | 0.4 / 0.2 | linear |
| fade | 0.5 | n/a (stepped) |
| flash | 0.08 | n/a |
| curtain | 0.7 | in_cubic close, out_cubic open |

### Table-wide default

The default goes at the top of `CreateFlexDmdDisplay`:

```vbscript
' Every scene change pushes unless its entry says otherwise. Delete this
' line (or pass "none", "none") to make transitions opt-in per entry.
SetDmdDefaultTransition "push left", "push right"
```

The second argument is the departure default. `""` means "same as the first".

---

## 4. How the module owns the stage

The brief's module calls `Stage.RemoveAll` and resets every scene group to `0,0` with no actions.
Against this repo that breaks three things (section 7, items 1–3). The fix is to build a fixed
structure once and only ever work inside it:

```
FlexDMD.Stage
 ├─ dmdtx_root                      Group W×H, added once by DmdTx_Init
 │   ├─ dmdtx_slot0   (Clip = True) carrier; this is what moves
 │   │   └─ dmdtx_inner0            moves only for wipe (counter-motion)
 │   │       ├─ dmdtx_backing0      black filled Frame, W×H
 │   │       └─ <scene group>       untouched: own X/Y, own actions
 │   ├─ dmdtx_slot1   (same)
 │   └─ overlays, hidden at rest:   flash, black, shade25/50/75, doorL, doorR
 └─ DMDBigText's group              added by DMDBigText, always above dmdtx_root
```

- **Two slots, ping-pong.** The scene on screen sits in the current slot. A new scene goes into the
  other one, the slots animate, and at the end the old slot is emptied. The scene that is now on
  screen is never re-parented when the transition finishes.
- **Moving the carrier, not the scene,** leaves every scene's own coordinates and actions alone.
  Mystery stays at `0,2`, and Welcome's slide-in and blink actions keep running.
- **Clip is always on** for the slots. Without it, scenes that draw outside their own box bleed over
  the other slot mid-transition. Welcome's logo image sits at `x = -100` inside a group that does not
  clip.
- **The backing frame** makes every scene opaque, which cover, reveal and wipe need (section 7,
  item 3). It is a `Frame`, not `Group.ClearBackground`, because of a FlexDMD bug (section 7, item 4).
- **Draw order** (needed for reveal, where the new scene goes under the old) is set by
  `dmdtx_root.RemoveAll` plus re-adding in the wanted order. This is cheap and runs inside the lock.
  On-stage toggling does not rewind a GIF; `AnimatedActor` only rewinds on `Seek` or at loop end.
- Name lookups are unaffected. Every `dmdtx_*` name is unique, and at runtime ≤ 1008 `Get*` searches
  recursively. Every ticker already uses `entry.Scene().Get*` anyway (section 7, item 5).

---

## 5. File-by-file changes

### New: `src/vpx/29_ZDTX_FlexDMD_Transitions.vbs` (GLF-agnostic)

This file holds the `DmdTransition` class and its spec parser, the easing and default tables,
`SetDmdDefaultTransition`, and `DmdTx_Init` / `DmdTx_Start` / `DmdTx_Tick` / `DmdTx_Finish`. It makes
no `Glf_*` calls; it logs through `Debug.Print`. The full corrected code is in section 8.

### `src/vpx/26_ZDMD_FlexDMD.vbs`

- `Flex_Init`: call `DmdTx_Init()` after `.Run = True` and before `FlexDmd_BuildScenes()`. That way
  `dmdtx_root` is the Stage's first child, and anything `DMDBigText` adds later draws above it.
- `ShowScene(flexScene, render)` becomes `ShowScene(flexScene, render, transition)`. It still sets
  `RenderMode` and `FlexDMD.Show` (VR / playfield) under the lock. It no longer touches the Stage; it
  hands the scene to `DmdTx_Start flexScene, transition` (after unlocking). `transition` is a
  `DmdTransition` or `Nothing`. The only caller is `FlexDmd_Present`.
- `DMDTimer_Timer`: call `DmdTx_Tick` inside the lock, **before** `FlexDmd_Tick()`.
- New `DMDBigTextClear()`: takes the current text group off the Stage under the lock. Section 6 uses it.
- `DMDBigText`: wrap its Stage add/remove in `LockRenderThread` / `UnlockRenderThread`. Today it
  changes the Stage unlocked, from event context, while the render thread may be drawing. That is a
  latent race; the fix is two lines.
- Header comment: replace item 4 ("ShowScene untouched...") with a note about ZDTX.

### `src/vpx/28_ZFBC_FlexDMD_Bcp_Controller.vbs`

- `GlfDmdEntry`: add `.Transition` / `.TransitionOut` (Get returns the object, creating it on first
  use; Let takes a spec string). Add `TransitionIfSet()` / `TransitionOutIfSet()`, which return
  `Nothing` when unset so the resolver can tell "unset" from "none".
- New `FlexDmd_PickTransition(oldEntry, newEntry, leaving)`: the resolution table in section 2.
- `FlexDmd_Present(entry)` becomes `FlexDmd_Present(entry, transition)` and passes it to `ShowScene`.
  `ResetFrame` still zeroes `FlexFrame` at the start, not at the finish.
- `Render`:
  - On a backdrop change, work out `leaving = Not StackWants(FlexDmdCurrent)`, force a cut when the top
    entry is text, and present with `FlexDmd_PickTransition(...)`.
  - The `forceKey` re-present of the same backdrop passes `Nothing`.
  - The text rule in section 6: if the previously drawn key was text and the top key has changed, call
    `DMDBigTextClear`. Also do this when the stack empties.
  - The `.Callback` branch calls `DmdTx_Finish` before the callback draws.
- New private `StackWants(entry)`: True when any stack item is `entry`, or has `entry` as its
  `FlexDmd_Backdrop`.
- `Disconnect`: call `DmdTx_Finish`.
- `FlexDmd_Render` (the hand-wired route): treat its present as an arrival.
- Comments: the LAYERS/TEXT header and `FlexDmd_Backdrop` say a text widget "appears only if the
  scoreboard is up" and "the only thing that puts DMDBigText on screen is DmdTick_Score". Neither is
  true any more: `FlexDmd_DrawEntry` calls `DMDBigText` directly, over whatever is showing. Rewrite
  them to match section 6.

### `src/game/dmd/display_config.vbs`

- The EVERY FIELD block: add `.Transition` / `.TransitionOut` and the string format.
- Add `SetDmdDefaultTransition` (commented out, or set; see section 10).
- Per-entry transitions from section 10.
- `.RenderMode` doc says "default DMD_GRAY". The real default in `GlfDmdEntry.Init` is `DMD_GRAY_4`.
  Fix the comment.
- The `welcome` comment ("ticker keys on absolute frame numbers (88, 110)") is out of date:
  `DmdTick_Welcome` is empty and the intro runs on actions. Fix the comment.

### `src/game/dmd/display_scenes.vbs`

- The header (lines 27-30) says full-screen tickers "reach their actors through FlexDMD.Stage". Every
  ticker uses `entry.Scene()` now. Fix the comment, and add a line saying scene groups must not be
  moved by tickers at the group level. (No ticker does; this keeps it that way.)

### `src/vpx/02_ZOPT_User_Options.vbs` (if the option is wanted)

- `DmdTx_Enabled = (Table1.Option("DMD Transitions", 0, 1, 1, 1, 0, Array("Off", "On")) = 1)`

### `StarsHollowDMD/`

- `dmdtx_black25.png`, `dmdtx_black50.png`, `dmdtx_black75.png`: 128×32 RGBA, black at alpha 64 / 128
  / 192, generated with PIL. Only `fade` uses them. What `NewImage` does with a missing file is untested; if it
  errors, `DmdTx_Init` should create the shades under `On Error Resume Next` so fade degrades to a
  cut through black.

---

## 6. Text behaviour

Text is `DMDBigText`: a 128×32 group with `ClearBackground = True` at `0,0`, so it is **opaque**
across the whole DMD. It is added straight to the Stage, and an action on it removes it after its hold
time.

### What happens today

1. A text entry appears on top of whatever scene is showing. (Not only over the scoreboard, whatever
   the comments say.)
2. It goes away when its own hold timer runs out.
3. **Any** backdrop change wipes it, because `ShowScene` does `Stage.RemoveAll`. That includes a change
   *underneath* a text entry that is still the top of the stack. For example: "BALL SAVED" is up, and a
   lower-priority mode plays a full-screen slide in the same moment. The text vanishes early even
   though the stack says it should still show.
4. A higher-priority full-screen slide arriving also wipes it, through the same `RemoveAll`. That is
   correct, but only by accident.
5. If the text's stack item is removed early (`.Action = "remove"`, `SlidesClear`, mode stop), the
   text lingers until its own timer, up to its full `.Hold` / `.Expire`.

With transitions, (3) and (4) would get worse. The text would be wiped not at the scene change but
0.4 s later, when the transition finishes.

### The new rule

> **Text is on screen exactly while its stack item is the top entry, and never longer than its
> hold.**

In detail:

- **It draws on top of everything:** scenes, layers, and transition overlays (fade shades, flash,
  curtain doors). It stays opaque, as today.
- **It appears and disappears as a cut.** It never slides with a scene.
- **Scene changes underneath it don't touch it.** Changing the backdrop no longer clears the Stage, so
  the text stays up for its full time (fixes 3). Because a change under opaque text would be invisible,
  it is made a cut (section 2). That also means a hidden transition can't use up the 250 ms rate limit
  and turn the next visible one into a cut.
- **It is cleared the moment another entry becomes the top.** If a higher-priority slide arrives,
  `Render` sees the top key change and calls `DMDBigTextClear`. The new slide is then visible right
  away, including its arrival transition (fixes 4, on purpose this time). A new text replacing it
  works as today: `DMDBigText` swaps its own group.
- **It is cleared the moment its item leaves the stack:** a remove, its expiry, or its mode stopping
  (fixes 5).
- **A layer played above a text entry stays hidden under the text** until the text goes, because
  layers never count as "the top entry". Same as today.
- **Hand-wired `FlexDmd_ShowSlide` / `FlexDmd_ShowWidget`** don't use the stack, so their text keeps
  today's timer-only behaviour.

What a player sees: a text slide that brings the scoreboard up from the mode panel shows the text at
once, and when the text goes the scoreboard is simply there. "BALL SAVED" survives a lower-priority
slide change, and a jackpot slide played over a text widget replaces it immediately.

---

## 7. Corrections to the brief's reference module

1. **`Stage.RemoveAll` / `Stage.ClearActions` wipe text.** Covered in sections 4 and 6. The module now
   works only inside `dmdtx_root`, and its timelines run on `dmdtx_root`.
2. **`DmdTx_ResetActor` on scene groups breaks scenes.** `SetPosition 0,0` moves Mystery off its
   `0,2` (`DmdBuild_Mystery1`), and `ClearActions` would kill any group-level action a builder adds.
   Fixed by moving carriers instead.
3. **Cover, reveal and wipe show through.** No built scene sets `ClearBackground` (Score, Mode, Bonus,
   GameOver, HighScore, Mystery), and several have no size at all. `move_in` would draw the new scene's
   labels over the old scene's. Fixed by the backing frame in every slot.
4. **Don't use `Group.ClearBackground` on anything that moves.** `Group::Draw` translates to `(x,y)`
   and then calls `Actor::Draw`, which fills its rectangle at `(x,y)` again (`Group.cpp`, `Actor.cpp`),
   so the fill lands at twice the offset. `Frame` fills at its own `(x,y)` correctly. Scenes at `0,0`,
   such as Welcome and DMDBigText, are unaffected.
5. **The ticker/lookup collision (brief section 6.3) is already solved.** Every ticker in
   `display_scenes.vbs` uses `entry.Scene().Get*`. No ticker changes; only out-of-date comments.
6. **API checks against the plugin source:**
   - Confirmed: `Actor.Remove`, `Group.Clip`, `ClearBackground`, `AddActor`, `RemoveActor`,
     `RemoveAll`, `MoveTo`, `.Ease`, `Sequence`, `Wait` and `Show` are all script-exposed.
   - Confirmed: Stage actions run, because `FlexDMD.cpp` calls `Stage->Update(elapsed)` every frame.
   - Confirmed: `AddActor` does not detach from a previous parent. `DmdTx_Load` calls `.Remove` first.
   - Confirmed: on-stage toggling does not rewind a GIF.
   - Clock: FlexDMD tweens run on real elapsed time, while the finish check uses VPX's `GameTime`. They
     can drift (for example, while VPX is paused). That is harmless, because the finish snaps
     everything to its end state.
7. **`oldScene Is newScene`:** the module now tracks what it is showing itself, so the caller only
   passes the new scene. Re-presenting the scene already up is a no-op, the same as today's
   remove-and-re-add.
8. **Render lock:** `FlexDmd_Present` is reached only from event and delay context, never from
   `DMDTimer_Timer`'s lock (tickers must not play slides, as documented already). `DmdTx_Start` takes
   the lock itself.
9. **File number:** `27_` is taken, so the file is `29_ZDTX`. Grunt concatenates `src/vpx/**/*.vbs`
   alphabetically; nothing depends on the order, because everything runs from `Flex_Init` or later.

---

## 8. Corrected module (`29_ZDTX_FlexDMD_Transitions.vbs`)

Written against the plugin source but **not yet run**. It needs the test plan in section 11.

```vbscript
'*******************************************
'  ZDTX: FlexDMD scene transitions
'*******************************************
'
' Animated changes between full-screen scenes: push, move_in (cover),
' move_out (reveal), wipe, fade, flash and curtain. The names and easings
' are MPF's, so a transition written for MPF-MC reads the same here.
'
' This file knows nothing about GLF. ZFBC decides WHICH transition a
' scene change gets (see FlexDmd_PickTransition); this file only plays it.
'
' THE STAGE
'
' Everything lives in one group, dmdtx_root, added to the Stage once by
' DmdTx_Init. Inside it are two "slots", and the scene on the DMD sits in
' one of them. A new scene goes in the other, the slots move, and the old
' one is emptied at the end. The scene group itself is never moved,
' resized or stripped of its actions - only the slot carrying it is - so
' a scene drawn at 0,2 stays at 0,2 and its own animations keep running.
'
' Nothing here calls Stage.RemoveAll. Anything else on the Stage (the
' DMDBigText group) is left alone and stays on top.
'
' CONTRACT
'
'   DmdTx_Init          once, after FlexDMD.Run, before anything else is
'                       added to the Stage.
'   DmdTx_Start s, t    put scene s up with transition t (a DmdTransition,
'                       or Nothing for a cut). Render thread UNLOCKED.
'   DmdTx_Tick          every DMD frame, INSIDE the render lock.
'   DmdTx_Finish        snap any running transition to its end. Unlocked.

Const DmdTx_EndMarginMs = 25    ' let FlexDMD's own tweens land before the snap
Const DmdTx_MinGapMs = 250      ' a change closer than this to the last one is a cut

' The table option turns this off; Off means every change is a cut.
Dim DmdTx_Enabled : DmdTx_Enabled = True

' Table-wide defaults, Nothing until SetDmdDefaultTransition sets them.
Dim DmdTx_DefaultIn : Set DmdTx_DefaultIn = Nothing
Dim DmdTx_DefaultOut : Set DmdTx_DefaultOut = Nothing

Dim DmdTx_Root
Dim DmdTx_Slot(1), DmdTx_Inner(1), DmdTx_Shown(1)
Dim DmdTx_Cur : DmdTx_Cur = 0          ' slot holding the scene on the DMD
Dim DmdTx_Old : DmdTx_Old = -1         ' slot being emptied, while a transition runs
Dim DmdTx_Active : DmdTx_Active = False
Dim DmdTx_EndTime
Dim DmdTx_LastStart : DmdTx_LastStart = -100000
Dim DmdTx_Flash, DmdTx_Black, DmdTx_DoorL, DmdTx_DoorR
Dim DmdTx_Shade(2)


'*******************************************
'  The transition object
'*******************************************
' What an entry's .Transition / .TransitionOut holds. Set it field by
' field in a With block, or all at once from a string through .Spec:
'
'     "push left 0.4 out_cubic"    "fade 0.5"    "none"
'
' Words go in any order. Anything left out keeps the type's default.

Class DmdTransition
    Public TransitionType   ' none push move_in move_out wipe fade flash curtain
    Public Direction        ' left right up down - the way the content travels
    Public Duration         ' seconds; 0 means the type's default
    Public Easing           ' an MPF easing name; "" means the type's default

    Public default Function Init()
        TransitionType = "none"
        Direction = "left"
        Duration = 0
        Easing = ""
        Set Init = Me
    End Function

    Public Property Let Spec(text)
        Dim w
        For Each w In Split(LCase(Trim(text)), " ")
            If DmdTx_IsType(w) Then
                TransitionType = w
            ElseIf DmdTx_IsDirection(w) Then
                Direction = w
            ElseIf IsNumeric(w) Then
                Duration = CDbl(w)
            ElseIf DmdTx_EaseCode(w) >= 0 Then
                Easing = w
            ElseIf w <> "" Then
                Debug.Print "DMD transition: ignoring '" & w & "' in '" & text & "'"
            End If
        Next
    End Property
End Class

Function DmdTx_FromSpec(text)
    Dim t : Set t = (new DmdTransition)()
    t.Spec = text
    Set DmdTx_FromSpec = t
End Function

' Called from display_config.vbs. outSpec "" means "same as inSpec".
Sub SetDmdDefaultTransition(inSpec, outSpec)
    Set DmdTx_DefaultIn = DmdTx_FromSpec(inSpec)
    If outSpec = "" Then
        Set DmdTx_DefaultOut = Nothing
    Else
        Set DmdTx_DefaultOut = DmdTx_FromSpec(outSpec)
    End If
End Sub

Function DmdTx_IsType(w)
    Select Case w
        Case "none", "push", "move_in", "move_out", "wipe", "fade", "flash", "curtain"
            DmdTx_IsType = True
        Case Else
            DmdTx_IsType = False
    End Select
End Function

Function DmdTx_IsDirection(w)
    DmdTx_IsDirection = (w = "left" Or w = "right" Or w = "up" Or w = "down")
End Function

' MPF (Kivy) easing name -> FlexDMD Interpolation value, or -1.
Function DmdTx_EaseCode(name)
    Select Case name
        Case "linear"         : DmdTx_EaseCode = 0
        Case "in_elastic"     : DmdTx_EaseCode = 1
        Case "out_elastic"    : DmdTx_EaseCode = 2
        Case "in_out_elastic" : DmdTx_EaseCode = 3
        Case "in_quad"        : DmdTx_EaseCode = 4
        Case "out_quad"       : DmdTx_EaseCode = 5
        Case "in_out_quad"    : DmdTx_EaseCode = 6
        Case "in_cubic"       : DmdTx_EaseCode = 7
        Case "out_cubic"      : DmdTx_EaseCode = 8
        Case "in_out_cubic"   : DmdTx_EaseCode = 9
        Case "in_quart"       : DmdTx_EaseCode = 10
        Case "out_quart"      : DmdTx_EaseCode = 11
        Case "in_out_quart"   : DmdTx_EaseCode = 12
        Case "in_quint"       : DmdTx_EaseCode = 13
        Case "out_quint"      : DmdTx_EaseCode = 14
        Case "in_out_quint"   : DmdTx_EaseCode = 15
        Case "in_sine"        : DmdTx_EaseCode = 16
        Case "out_sine"       : DmdTx_EaseCode = 17
        Case "in_out_sine"    : DmdTx_EaseCode = 18
        Case "in_bounce"      : DmdTx_EaseCode = 19
        Case "out_bounce"     : DmdTx_EaseCode = 20
        Case "in_out_bounce"  : DmdTx_EaseCode = 21
        Case "in_circ"        : DmdTx_EaseCode = 22
        Case "out_circ"       : DmdTx_EaseCode = 23
        Case "in_out_circ"    : DmdTx_EaseCode = 24
        Case "in_expo"        : DmdTx_EaseCode = 25
        Case "out_expo"       : DmdTx_EaseCode = 26
        Case "in_out_expo"    : DmdTx_EaseCode = 27
        Case "in_back"        : DmdTx_EaseCode = 28
        Case "out_back"       : DmdTx_EaseCode = 29
        Case "in_out_back"    : DmdTx_EaseCode = 30
        Case Else             : DmdTx_EaseCode = -1
    End Select
End Function

' Durations are tuned for 128x32; a vertical move covers 32 pixels, not
' 128, so it gets a shorter one or it feels sluggish.
Function DmdTx_DefaultDuration(kind, vertical)
    Select Case kind
        Case "push"     : If vertical Then DmdTx_DefaultDuration = 0.2 Else DmdTx_DefaultDuration = 0.4
        Case "move_in"  : If vertical Then DmdTx_DefaultDuration = 0.25 Else DmdTx_DefaultDuration = 0.4
        Case "move_out" : If vertical Then DmdTx_DefaultDuration = 0.2 Else DmdTx_DefaultDuration = 0.35
        Case "wipe"     : If vertical Then DmdTx_DefaultDuration = 0.2 Else DmdTx_DefaultDuration = 0.4
        Case "fade"     : DmdTx_DefaultDuration = 0.5
        Case "flash"    : DmdTx_DefaultDuration = 0.08
        Case "curtain"  : DmdTx_DefaultDuration = 0.7
        Case Else       : DmdTx_DefaultDuration = 0
    End Select
End Function

Function DmdTx_DefaultEase(kind)
    Select Case kind
        Case "move_in"  : DmdTx_DefaultEase = 29   ' out_back
        Case "move_out" : DmdTx_DefaultEase = 7    ' in_cubic
        Case "wipe"     : DmdTx_DefaultEase = 0    ' linear
        Case Else       : DmdTx_DefaultEase = 8    ' out_cubic
    End Select
End Function


'*******************************************
'  Building the stage
'*******************************************

Function DmdTx_SolidFrame(name, w, h, color)
    Dim f : Set f = FlexDMD.NewFrame(name)
    f.SetBounds 0, 0, w, h
    f.Thickness = 0
    f.Fill = True
    f.FillColor = color
    Set DmdTx_SolidFrame = f
End Function

Sub DmdTx_Init()
    Dim W, H, i
    W = FlexDMD.Width : H = FlexDMD.Height

    Set DmdTx_Root = FlexDMD.NewGroup("dmdtx_root")
    DmdTx_Root.SetSize W, H

    ' Each slot clips to the DMD-sized box it carries, so a scene that
    ' draws outside its own bounds cannot bleed over the other slot. The
    ' black backing under the scene makes every scene opaque, which a
    ' cover or reveal needs. It is a Frame, not ClearBackground: a Group's
    ' ClearBackground fills at twice its offset once it moves.
    For i = 0 To 1
        Set DmdTx_Slot(i) = FlexDMD.NewGroup("dmdtx_slot" & i)
        DmdTx_Slot(i).SetSize W, H
        DmdTx_Slot(i).Clip = True
        Set DmdTx_Inner(i) = FlexDMD.NewGroup("dmdtx_inner" & i)
        DmdTx_Inner(i).SetSize W, H
        DmdTx_Inner(i).AddActor DmdTx_SolidFrame("dmdtx_backing" & i, W, H, RGB(0, 0, 0))
        DmdTx_Slot(i).AddActor DmdTx_Inner(i)
        Set DmdTx_Shown(i) = Nothing
    Next

    Set DmdTx_Flash = DmdTx_SolidFrame("dmdtx_flash", W, H, RGB(255, 255, 255))
    Set DmdTx_Black = DmdTx_SolidFrame("dmdtx_black", W, H, RGB(0, 0, 0))
    Set DmdTx_DoorL = DmdTx_SolidFrame("dmdtx_doorl", W \ 2, H, RGB(0, 0, 0))
    Set DmdTx_DoorR = DmdTx_SolidFrame("dmdtx_doorr", W - W \ 2, H, RGB(0, 0, 0))
    For i = 0 To 2   ' 25/50/75% black PNGs in the DMD project folder
        Set DmdTx_Shade(i) = FlexDMD.NewImage("dmdtx_shade" & i, "dmdtx_black" & ((i + 1) * 25) & ".png")
    Next

    FlexDMD.LockRenderThread
    DmdTx_ParkOverlays
    DmdTx_Arrange 0, -1
    FlexDMD.Stage.AddActor DmdTx_Root
    FlexDMD.UnlockRenderThread
End Sub

' Rebuild dmdtx_root's draw order: the bottom slot, the top slot (-1 for
' none), then the overlays. FlexDMD draws a group's children in the order
' they were added, and this is the only way to change it from script.
Sub DmdTx_Arrange(bottom, top)
    Dim i
    DmdTx_Root.RemoveAll
    DmdTx_Root.AddActor DmdTx_Slot(bottom)
    If top >= 0 Then DmdTx_Root.AddActor DmdTx_Slot(top)
    For i = 0 To 2 : DmdTx_Root.AddActor DmdTx_Shade(i) : Next
    DmdTx_Root.AddActor DmdTx_Black
    DmdTx_Root.AddActor DmdTx_Flash
    DmdTx_Root.AddActor DmdTx_DoorL
    DmdTx_Root.AddActor DmdTx_DoorR
End Sub

Sub DmdTx_ParkOverlays()
    Dim i
    For i = 0 To 2
        DmdTx_Shade(i).ClearActions : DmdTx_Shade(i).Visible = False
    Next
    DmdTx_Black.ClearActions : DmdTx_Black.Visible = False
    DmdTx_Flash.ClearActions : DmdTx_Flash.Visible = False
    DmdTx_DoorL.ClearActions : DmdTx_DoorL.Visible = False
    DmdTx_DoorR.ClearActions : DmdTx_DoorR.Visible = False
End Sub

' A slot back at rest: in place, visible, not moving.
Sub DmdTx_Home(i)
    DmdTx_Slot(i).ClearActions
    DmdTx_Slot(i).SetPosition 0, 0
    DmdTx_Slot(i).Visible = True
    DmdTx_Inner(i).ClearActions
    DmdTx_Inner(i).SetPosition 0, 0
End Sub

' Put a scene into a slot. Remove first: FlexDMD's AddActor does not take
' an actor away from a previous parent.
Sub DmdTx_Load(i, scene)
    DmdTx_Unload i
    DmdTx_Home i
    scene.Remove
    DmdTx_Inner(i).AddActor scene
    Set DmdTx_Shown(i) = scene
End Sub

Sub DmdTx_Unload(i)
    If DmdTx_Shown(i) Is Nothing Then Exit Sub
    DmdTx_Inner(i).RemoveActor DmdTx_Shown(i)
    Set DmdTx_Shown(i) = Nothing
End Sub


'*******************************************
'  Playing one
'*******************************************

Function DmdTx_Move(actor, x, y, dur, ease)
    Dim a : Set a = actor.ActionFactory.MoveTo(x, y, dur)
    a.Ease = ease
    Set DmdTx_Move = a
End Function

' One step of a show/hide timeline: show one actor, hide another, then
' wait. Either actor may be Nothing, and wait may be 0.
Sub DmdTx_Step(seq, showMe, hideMe, wait)
    If Not showMe Is Nothing Then seq.Add showMe.ActionFactory.Show(True)
    If Not hideMe Is Nothing Then seq.Add hideMe.ActionFactory.Show(False)
    If wait > 0 Then seq.Add DmdTx_Root.ActionFactory.Wait(wait)
End Sub

Sub DmdTx_Start(newScene, tx)
    Dim kind, dur, ease, W, H, dx, dy, nu, old, s, stepTime, half, tClose, tHold

    FlexDMD.LockRenderThread
    If DmdTx_Active Then DmdTx_FinishLocked

    ' Already up - nothing to change.
    If Not DmdTx_Shown(DmdTx_Cur) Is Nothing Then
        If DmdTx_Shown(DmdTx_Cur) Is newScene Then
            FlexDMD.UnlockRenderThread
            Exit Sub
        End If
    End If

    kind = "none"
    If Not tx Is Nothing Then kind = LCase(tx.TransitionType)
    If Not DmdTx_IsType(kind) Then kind = "none"
    If Not DmdTx_Enabled Then kind = "none"
    If DmdTx_Shown(DmdTx_Cur) Is Nothing Then kind = "none"
    If GameTime - DmdTx_LastStart < DmdTx_MinGapMs Then kind = "none"

    old = DmdTx_Cur
    nu = 1 - DmdTx_Cur
    DmdTx_Load nu, newScene
    DmdTx_Cur = nu

    If kind = "none" Then
        DmdTx_Unload old
        DmdTx_Arrange nu, -1
        FlexDMD.UnlockRenderThread
        Exit Sub
    End If

    W = FlexDMD.Width : H = FlexDMD.Height
    dx = 0 : dy = 0
    Select Case LCase(tx.Direction)
        Case "right" : dx = 1
        Case "up"    : dy = -1
        Case "down"  : dy = 1
        Case Else    : dx = -1
    End Select
    dur = tx.Duration
    If dur <= 0 Then dur = DmdTx_DefaultDuration(kind, dy <> 0)
    ease = DmdTx_EaseCode(LCase(tx.Easing))
    If ease < 0 Then ease = DmdTx_DefaultEase(kind)

    Select Case kind
        Case "push"
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).SetPosition -dx * W, -dy * H
            DmdTx_Slot(nu).AddAction DmdTx_Move(DmdTx_Slot(nu), 0, 0, dur, ease)
            DmdTx_Slot(old).AddAction DmdTx_Move(DmdTx_Slot(old), dx * W, dy * H, dur, ease)

        Case "move_in"
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).SetPosition -dx * W, -dy * H
            DmdTx_Slot(nu).AddAction DmdTx_Move(DmdTx_Slot(nu), 0, 0, dur, ease)

        Case "move_out"
            DmdTx_Arrange nu, old
            DmdTx_Slot(old).AddAction DmdTx_Move(DmdTx_Slot(old), dx * W, dy * H, dur, ease)

        Case "wipe"
            ' The slot's clip window sweeps in while the inner group moves the
            ' other way, so the scene itself stays still on screen.
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).SetPosition -dx * W, -dy * H
            DmdTx_Inner(nu).SetPosition dx * W, dy * H
            DmdTx_Slot(nu).AddAction DmdTx_Move(DmdTx_Slot(nu), 0, 0, dur, ease)
            DmdTx_Inner(nu).AddAction DmdTx_Move(DmdTx_Inner(nu), 0, 0, dur, ease)

        Case "fade"
            ' Seven equal steps: 25, 50, 75, black (swap), 75, 50, 25.
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).Visible = False
            stepTime = dur / 7   ' not "step" - that is a VBScript keyword
            Set s = DmdTx_Root.ActionFactory.Sequence()
            DmdTx_Step s, DmdTx_Shade(0), Nothing, stepTime
            DmdTx_Step s, DmdTx_Shade(1), DmdTx_Shade(0), stepTime
            DmdTx_Step s, DmdTx_Shade(2), DmdTx_Shade(1), stepTime
            DmdTx_Step s, DmdTx_Black, DmdTx_Shade(2), 0
            DmdTx_Step s, DmdTx_Slot(nu), DmdTx_Slot(old), stepTime
            DmdTx_Step s, DmdTx_Shade(2), DmdTx_Black, stepTime
            DmdTx_Step s, DmdTx_Shade(1), DmdTx_Shade(2), stepTime
            DmdTx_Step s, DmdTx_Shade(0), DmdTx_Shade(1), stepTime
            DmdTx_Step s, Nothing, DmdTx_Shade(0), 0
            DmdTx_Root.AddAction s

        Case "flash"
            DmdTx_Arrange nu, -1
            DmdTx_Flash.Visible = True
            Set s = DmdTx_Root.ActionFactory.Sequence()
            DmdTx_Step s, Nothing, Nothing, dur
            DmdTx_Step s, Nothing, DmdTx_Flash, 0
            DmdTx_Root.AddAction s

        Case "curtain"
            ' Doors close for 40%, hold for 20%, open for 40%; the scenes
            ' swap behind them halfway through the hold.
            half = W \ 2
            tClose = dur * 0.4 : tHold = dur * 0.2
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).Visible = False
            DmdTx_DoorL.SetPosition -half, 0 : DmdTx_DoorL.Visible = True
            DmdTx_DoorR.SetPosition W, 0     : DmdTx_DoorR.Visible = True

            Set s = DmdTx_DoorL.ActionFactory.Sequence()
            s.Add DmdTx_Move(DmdTx_DoorL, 0, 0, tClose, 7)
            s.Add DmdTx_DoorL.ActionFactory.Wait(tHold)
            s.Add DmdTx_Move(DmdTx_DoorL, -half, 0, tClose, 8)
            DmdTx_DoorL.AddAction s

            Set s = DmdTx_DoorR.ActionFactory.Sequence()
            s.Add DmdTx_Move(DmdTx_DoorR, half, 0, tClose, 7)
            s.Add DmdTx_DoorR.ActionFactory.Wait(tHold)
            s.Add DmdTx_Move(DmdTx_DoorR, W, 0, tClose, 8)
            DmdTx_DoorR.AddAction s

            Set s = DmdTx_Root.ActionFactory.Sequence()
            DmdTx_Step s, Nothing, Nothing, tClose + tHold / 2
            DmdTx_Step s, DmdTx_Slot(nu), DmdTx_Slot(old), 0
            DmdTx_Root.AddAction s
    End Select

    DmdTx_Old = old
    DmdTx_Active = True
    DmdTx_LastStart = GameTime
    DmdTx_EndTime = GameTime + dur * 1000 + DmdTx_EndMarginMs
    FlexDMD.UnlockRenderThread
End Sub

' Snap to the end state: the new scene alone, at rest, nothing moving.
' Caller MUST hold the render lock.
Sub DmdTx_FinishLocked()
    If Not DmdTx_Active Then Exit Sub
    DmdTx_Active = False
    DmdTx_Root.ClearActions
    DmdTx_ParkOverlays
    DmdTx_Home DmdTx_Cur
    If DmdTx_Old >= 0 Then
        DmdTx_Unload DmdTx_Old
        DmdTx_Home DmdTx_Old
    End If
    DmdTx_Old = -1
    DmdTx_Arrange DmdTx_Cur, -1
End Sub

Sub DmdTx_Finish()
    If Not DmdTx_Active Then Exit Sub
    FlexDMD.LockRenderThread
    DmdTx_FinishLocked
    FlexDMD.UnlockRenderThread
End Sub

' Every DMD frame, inside the render lock, before the tickers.
Sub DmdTx_Tick()
    If DmdTx_Active Then
        If GameTime >= DmdTx_EndTime Then DmdTx_FinishLocked
    End If
End Sub
```

### The ZFBC side, in sketch

```vbscript
' In GlfDmdEntry - Nothing until set, so "unset" and "none" stay different.
Private m_transition, m_transitionOut     ' Set to Nothing in Init

Public Property Get Transition()
    If m_transition Is Nothing Then Set m_transition = (new DmdTransition)()
    Set Transition = m_transition
End Property
Public Property Let Transition(spec) : Set m_transition = DmdTx_FromSpec(spec) : End Property
Public Function TransitionIfSet() : Set TransitionIfSet = m_transition : End Function
' ...and the same three for TransitionOut.


' The transition a backdrop change from oldEntry to newEntry gets, or
' Nothing for a cut. leaving is True when nothing on the stack wants
' oldEntry any more - it left, rather than being covered. An entry's own
' setting beats the table default, and the leaving entry beats the
' arriving one.
Function FlexDmd_PickTransition(oldEntry, newEntry, leaving)
    Dim t : Set t = Nothing
    If Not oldEntry Is Nothing Then
        If leaving Then Set t = oldEntry.TransitionOutIfSet()
        If t Is Nothing Then Set t = newEntry.TransitionIfSet()
        If t Is Nothing And leaving Then Set t = DmdTx_DefaultOut
        If t Is Nothing Then Set t = DmdTx_DefaultIn
    End If
    Set FlexDmd_PickTransition = t
End Function
```

In `Render`, the backdrop block becomes "present with a picked transition, unless the top entry is
text". The `forceKey` re-present passes `Nothing`. The text rule from section 6 runs just before
`FlexDmd_DrawEntry`:

```vbscript
If m_drawn <> "" And m_drawn <> topKey And m_drawnIsText Then DMDBigTextClear
```

---

## 9. The player option, and precedent

I know of no commercial machine, and nothing in MPF or GMC, that gives the *player* a switch for slide
transitions; they are purely the author's call. The closest precedents:

- **This table already uses the VPX F12 options menu** (`Table1.Option`) for player-chosen
  presentation and feel: Color Saturation, the volume sliders, Staged Flippers, Game Modes Enabled.
  The VPX community leans on that menu for exactly this kind of cosmetic toggle.
- **Reduce-motion settings** in operating systems and games exist for players who find screen motion
  uncomfortable or distracting. A cabinet DMD is in peripheral vision for the whole game.

**Recommendation:** a single **On/Off** option ("DMD Transitions"), default On. Off forces every change
to a cut. It costs one `Table1.Option` line and the `DmdTx_Enabled` flag already in the module. I
would **not** add a speed option: it would rescale timings the author tuned per entry, and "Fast" adds
little over "Off".

---

## 10. Suggested transitions for the existing entries

Table default: **left unset** for v1 (opt-in per entry), with the
`SetDmdDefaultTransition "push left", "push right"` line in the config, commented out, as an example.

| Entry | `.Transition` | `.TransitionOut` | Why |
|---|---|---|---|
| `score` | (none set) | (none set) | The home screen; whoever covers or uncovers it decides. |
| `welcome` (attract) | `fade 0.5` | `fade 0.5` | Attract ↔ game is a big context change. |
| `mode` | `push left` | `push right` | Forward into a mode, back out of it; exit mirrors entry. |
| `eob_bonus` | `move_in up` | `move_out down` | Rises over the score at ball end, then leaves the way it came. |
| `high_score` | `curtain` | `fade 0.5` | Arcade "intermission". |
| `game_over` | `fade 0.6` | `fade 0.5` | Ending. |
| `multiball` | `flash 0.08` | `move_out up` | "Something happened NOW." |
| `kirk-dances`, `logan-hit` | `move_in down 0.5 out_bounce` | `move_out up` | Short GIF takeovers; the bounce reads well on a DMD. |
| `mystery1` | `move_in down 0.5 out_bounce` | `move_out up` | Arrives over the score. |
| `mystery1_eb/_ab/_ib/_bs` | `none` | `move_out up` | Same look as `mystery1`: the variant replaces it with a cut, then leaves like `mystery1` would. |
| `luke_and_lorelei` (layer) | — | — | Layers don't transition in v1; the `mode` panel it brings up uses `mode`'s push. |
| text entries | — | — | Always cuts (section 6). |

The mystery sequence needs no special handling. `mystery1` plays, then the variant plays on top
(arrival: the variant's `none`, so a cut). Then `mystery1` is removed underneath (no backdrop change).
Finally the variant is removed (departure: the variant's `TransitionOut`).

---

## 11. Test plan

Run each item in the editor (macOS dev) and on Windows BGFX; VR / playfield items on the cabinet.

1. **Each type**, forward and back, every direction for push / move_in / move_out / wipe. Check for no
   1-pixel seams at the end, no bleed between slots (Welcome's wide logo is the best probe), and that
   transparent scenes (Mode, Bonus) don't show through on move_in/move_out.
2. **Mystery stays at y = 2** through a transition and after it.
3. **Interruption:**
   - Play a slide mid-push. The first snaps to its end, and the second is a cut if it came within
     250 ms; otherwise it animates from the snapped state.
   - Same mid-fade (at full black) and mid-curtain (doors shut).
4. **Rapid fire:** five slides in under a second. No stutter, ends on the right scene, nothing left
   attached in either slot (log `ChildCount` of `dmdtx_inner0/1`).
5. **Mode stop during a transition:** start a mode (push in), stop it at 0.2 s. It snaps, then the
   departure push back out plays (or cuts if inside 250 ms). No leftover layers.
6. **Departure vs arrival:**
   - Mode stop → `mode.TransitionOut` (push right).
   - A higher-priority slide over `mode` → the newcomer's `.Transition`.
   - `luke_and_lorelei` played → the mode panel pushes in with the layer riding along. Removing the
     layer → the mode panel leaves with `mode.TransitionOut`.
7. **Table default:** set it, check entries without settings use it, and that an entry with `"none"`
   cuts.
8. **Text:**
   - "BALL SAVED" survives a lower-priority slide change underneath.
   - A higher-priority slide clears it at once.
   - Mode stop clears that mode's text at once.
   - A text slide bringing the score up from the mode panel is a cut under the text.
9. **Countdown replays** (dance marathon): `forceKey` replays every tick, never transition, and never
   eat the rate limit.
10. **Welcome intro:** the logo slides in and blinks correctly when attract is entered through a fade.
11. **VR and FlexONPlayfield:** `FlexDMD.Show` is still set correctly, and `FlexFlasher` copies frames
    mid-transition without tearing.
12. **RenderMode:** a GRAY_4 → RGB change (temporarily set one entry to RGB) takes the new mode at the
    start of the transition.
13. **Option Off:** every change is a cut, and toggling it mid-game takes effect on the next change.
14. **Real BCP On:** no ZDTX calls, and nothing errors.
15. **Assets missing:** delete the shade PNGs and check what `NewImage` does; fade should still go
    through black, with no script error.
