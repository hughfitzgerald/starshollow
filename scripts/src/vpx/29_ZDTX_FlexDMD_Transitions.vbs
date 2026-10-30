'*******************************************
'  ZDTX: FlexDMD scene transitions
'*******************************************
'
' Animated changes between full-screen DMD scenes: push, move_in (cover),
' move_out (reveal), wipe, fade, flash and curtain. The type names and
' the easing names are MPF's, so a transition written for MPF-MC reads
' the same here:
'
'     "push left 0.4 out_cubic"    "fade 0.5"    "move_in down out_bounce"
'
' This file knows nothing about GLF. ZFBC decides WHICH transition a
' scene change gets (FlexDmd_PickTransition, and the .Transition /
' .TransitionOut fields on each entry in display_config.vbs); this file
' only plays it.
'
' THE STAGE
'
' Every scene lives in one group, dmdtx_root, which DmdTx_Init adds to
' the Stage before anything else. Inside it are two "slots", and the
' scene on the DMD sits in one of them. A new scene goes into the other
' slot, the slots move, and the old one is emptied at the end:
'
'     FlexDMD.Stage
'      +- dmdtx_root
'      |   +- dmdtx_slot0      clips to the DMD; this is what moves
'      |   |   +- dmdtx_inner0  moves only for a wipe
'      |   |       +- dmdtx_backing0   black, so every scene is opaque
'      |   |       +- <the scene>
'      |   +- dmdtx_slot1      (the same)
'      |   +- flash, black, shades, curtain doors - hidden at rest
'      +- whatever DMDBigText added - always above all of this
'
' The scene group itself is never moved, resized or stripped of its
' actions - only the slot carrying it is - so a scene built at 0,2 stays
' at 0,2 and its own animations keep running through a transition.
'
' Nothing here calls Stage.RemoveAll, so anything else on the Stage (the
' DMDBigText group) is left alone.
'
' CONTRACT
'
'   DmdTx_Init           once, after FlexDMD.Run, before anything else is
'                        added to the Stage. Flex_Init does this.
'   DmdTx_Start s, t     put scene s on the DMD with transition t (a
'                        DmdTransition, or Nothing for a cut). Render
'                        thread must be UNLOCKED - this takes the lock.
'   DmdTx_Tick           every DMD frame, INSIDE the render lock, before
'                        the tickers. DMDTimer_Timer does this.
'   DmdTx_Finish         snap a running transition to its end. Unlocked.
'
' A change that comes less than DmdTx_MinGapMs after the last transition
' started is a cut, so a burst of slide changes does not stutter through
' half-transitions. A change while one is running snaps that one to its
' end first.

Const DmdTx_EndMarginMs = 25    ' let FlexDMD's own tweens land before the snap
Const DmdTx_MinGapMs = 250      ' a change closer than this to the last one is a cut

' The "DMD Transitions" table option (ZOPT). False makes every change a cut.
Dim DmdTx_Enabled : DmdTx_Enabled = True

' Table-wide defaults, Nothing until SetDmdDefaultTransition sets them.
' DmdTx_DefaultOut is Nothing when the departure default is "the same".
Dim DmdTx_DefaultIn : Set DmdTx_DefaultIn = Nothing
Dim DmdTx_DefaultOut : Set DmdTx_DefaultOut = Nothing

Dim DmdTx_Root
Dim DmdTx_Slot(1), DmdTx_Inner(1), DmdTx_Shown(1)
Dim DmdTx_Cur : DmdTx_Cur = 0          ' the slot holding the scene on the DMD
Dim DmdTx_Old : DmdTx_Old = -1         ' the slot being emptied, while a transition runs
Dim DmdTx_Active : DmdTx_Active = False
Dim DmdTx_EndTime : DmdTx_EndTime = 0
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
' The words go in any order, and anything left out keeps its default:
' direction "left", and the duration and easing listed in
' DmdTx_DefaultDuration / DmdTx_DefaultEase for the type.
'
'   .TransitionType   none, push, move_in, move_out, wipe, fade, flash,
'                     curtain. ("Type" is reserved in VBScript - this is
'                     the same name GLF's segment player uses.)
'   .Direction        left, right, up, down - the way the content
'                     TRAVELS, so "left" brings the new scene in from
'                     the right. Ignored by fade, flash and curtain.
'   .Duration         seconds; 0 means the type's default
'   .Easing           an MPF easing name (linear, out_cubic, in_out_sine,
'                     out_back, out_bounce...); "" means the default.
'                     Ignored by fade and flash.

Class DmdTransition
    Public TransitionType
    Public Direction
    Public Duration
    Public Easing

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

' The table-wide default, called from display_config.vbs. inSpec is used
' whenever an entry has nothing to say about a change; outSpec is used
' for a departure (the scene on the DMD left the stack) and "" means the
' same as inSpec. Never calling this, or calling it with "none", makes
' transitions opt-in per entry.
Sub SetDmdDefaultTransition(inSpec, outSpec)
    Set DmdTx_DefaultIn = DmdTx_FromSpec(inSpec)
    If Trim(outSpec) = "" Then
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

' MPF (Kivy) easing name -> FlexDMD Interpolation value, or -1 for a name
' it does not know.
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

' Durations are tuned for 128x32. A vertical move covers 32 pixels, not
' 128, so it gets a shorter one or it feels sluggish.
Function DmdTx_DefaultDuration(kind, vertical)
    Dim across, upDown
    Select Case kind
        Case "push"     : across = 0.4  : upDown = 0.2
        Case "move_in"  : across = 0.4  : upDown = 0.25
        Case "move_out" : across = 0.35 : upDown = 0.2
        Case "wipe"     : across = 0.4  : upDown = 0.2
        Case "fade"     : across = 0.5  : upDown = 0.5
        Case "flash"    : across = 0.08 : upDown = 0.08
        Case "curtain"  : across = 0.7  : upDown = 0.7
        Case Else       : across = 0    : upDown = 0
    End Select
    If vertical Then
        DmdTx_DefaultDuration = upDown
    Else
        DmdTx_DefaultDuration = across
    End If
End Function

Function DmdTx_DefaultEase(kind)
    Select Case kind
        Case "move_in"  : DmdTx_DefaultEase = 29   ' out_back - a small overshoot
        Case "move_out" : DmdTx_DefaultEase = 7    ' in_cubic - accelerating away
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
    ' draws outside its own bounds (the welcome logo starts at x = -100)
    ' cannot bleed over the other slot. The black backing under the scene
    ' makes every scene opaque, which a cover or a reveal needs. It is a
    ' Frame rather than ClearBackground on purpose: a Group fills its
    ' ClearBackground at twice its own offset once it moves.
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

    ' The fade's 25/50/75% steps are PNGs in the DMD project folder
    ' (dmdtx_black25.png and so on), because FlexDMD has no alpha on an
    ' actor. If one cannot be loaded, solid black stands in for it, so the
    ' fade still works - it just goes to black sooner.
    For i = 0 To 2
        Set DmdTx_Shade(i) = Nothing
        On Error Resume Next
        Set DmdTx_Shade(i) = FlexDMD.NewImage("dmdtx_shade" & i, "dmdtx_black" & ((i + 1) * 25) & ".png")
        On Error GoTo 0
        If DmdTx_Shade(i) Is Nothing Then
            Set DmdTx_Shade(i) = DmdTx_SolidFrame("dmdtx_shade" & i, W, H, RGB(0, 0, 0))
        End If
    Next

    FlexDMD.LockRenderThread
    DmdTx_ParkOverlays
    DmdTx_Arrange 0, -1
    FlexDMD.Stage.AddActor DmdTx_Root
    FlexDMD.UnlockRenderThread
End Sub

' Rebuild dmdtx_root's draw order: the bottom slot, the top slot (-1 for
' none), then the overlays. FlexDMD draws a group's children in the order
' they were added, and this is the only way to change that from script.
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

' Every overlay hidden and still.
Sub DmdTx_ParkOverlays()
    Dim i
    For i = 0 To 2
        DmdTx_Shade(i).ClearActions
        DmdTx_Shade(i).Visible = False
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

' Put a scene into a slot. Remove comes first because FlexDMD's AddActor
' does not take an actor away from a previous parent - without it the
' scene could end up listed in two groups.
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
' wait. Either actor may be Nothing, and wait may be 0. The actions are
' built from each actor's own factory, so they act on that actor even
' though the sequence runs on dmdtx_root.
Sub DmdTx_Step(seq, showMe, hideMe, wait)
    If Not showMe Is Nothing Then seq.Add showMe.ActionFactory.Show(True)
    If Not hideMe Is Nothing Then seq.Add hideMe.ActionFactory.Show(False)
    If wait > 0 Then seq.Add DmdTx_Root.ActionFactory.Wait(wait)
End Sub

Sub DmdTx_Start(newScene, tx)
    Dim kind, dur, ease, W, H, dx, dy, nu, old, s, stepTime, half, tClose, tHold

    FlexDMD.LockRenderThread
    If DmdTx_Active Then DmdTx_FinishLocked

    ' Already on the DMD - nothing to change.
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
            ' Both move together; the old leaves as the new arrives.
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).SetPosition -dx * W, -dy * H
            DmdTx_Slot(nu).AddAction DmdTx_Move(DmdTx_Slot(nu), 0, 0, dur, ease)
            DmdTx_Slot(old).AddAction DmdTx_Move(DmdTx_Slot(old), dx * W, dy * H, dur, ease)

        Case "move_in"
            ' The new one slides in over the old, which stays put.
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).SetPosition -dx * W, -dy * H
            DmdTx_Slot(nu).AddAction DmdTx_Move(DmdTx_Slot(nu), 0, 0, dur, ease)

        Case "move_out"
            ' The old one slides away, uncovering the new one underneath.
            DmdTx_Arrange nu, old
            DmdTx_Slot(old).AddAction DmdTx_Move(DmdTx_Slot(old), dx * W, dy * H, dur, ease)

        Case "wipe"
            ' The slot's clip window sweeps in while the inner group moves
            ' the other way by the same amount, so the scene itself stays
            ' still on screen and is uncovered in place.
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).SetPosition -dx * W, -dy * H
            DmdTx_Inner(nu).SetPosition dx * W, dy * H
            DmdTx_Slot(nu).AddAction DmdTx_Move(DmdTx_Slot(nu), 0, 0, dur, ease)
            DmdTx_Inner(nu).AddAction DmdTx_Move(DmdTx_Inner(nu), 0, 0, dur, ease)

        Case "fade"
            ' Seven equal steps: 25, 50, 75, black (and swap), 75, 50, 25.
            ' On a 16-shade DMD that reads as smooth.
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
            ' The new scene straight away, under a moment of solid white.
            DmdTx_Arrange nu, -1
            DmdTx_Flash.Visible = True
            Set s = DmdTx_Root.ActionFactory.Sequence()
            DmdTx_Step s, Nothing, Nothing, dur
            DmdTx_Step s, Nothing, DmdTx_Flash, 0
            DmdTx_Root.AddAction s

        Case "curtain"
            ' Two black doors close for 40%, hold for 20% and open for 40%;
            ' the scenes swap behind them halfway through the hold.
            half = W \ 2
            tClose = dur * 0.4 : tHold = dur * 0.2
            DmdTx_Arrange old, nu
            DmdTx_Slot(nu).Visible = False
            DmdTx_DoorL.SetPosition -half, 0
            DmdTx_DoorL.Visible = True
            DmdTx_DoorR.SetPosition W, 0
            DmdTx_DoorR.Visible = True

            Set s = DmdTx_DoorL.ActionFactory.Sequence()
            s.Add DmdTx_Move(DmdTx_DoorL, 0, 0, tClose, 7)          ' in_cubic
            s.Add DmdTx_DoorL.ActionFactory.Wait(tHold)
            s.Add DmdTx_Move(DmdTx_DoorL, -half, 0, tClose, 8)      ' out_cubic
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
' FlexDMD's tweens run on their own clock and should have landed by now;
' this puts the end state in place whether they have or not.
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

Function DmdTx_IsActive() : DmdTx_IsActive = DmdTx_Active : End Function
