'*******************************************
'  ZFBC: FlexDMD BCP Controller (local)
'*******************************************
'
' Lets the GLF slide player and widget player drive FlexDMD directly,
' with no Godot Media Controller and no socket.
'
' HOW IT WORKS
'
' Every place GLF plays a slide or a widget has the same shape:
'
'     If useBcp = True Then
'         bcpController.PlaySlide slide, mode, event, action, expire, priority, kwargs
'     End If
'
' There is no second branch and no event fired for "a slide was played" -
' if useBcp is False, or bcpController was never assigned, those calls do
' nothing at all. But bcpController is only a variable holding an object,
' and GLF never checks what class that object is. Give it an object with
' the same method names and GLF cannot tell the difference. That is all
' GlfFlexDmdBcpController below is.
'
' WHAT YOU EDIT
'
' Two Subs near the bottom of this file are the whole mapping:
'
'     FlexDmd_ShowSlide  slide name  -> a FlexDMD scene   (ShowScene)
'     FlexDmd_ShowWidget widget name -> a FlexDMD overlay (DMDBigText)
'
' Add a Case to those and the name is immediately usable from mode config:
'
'     With .SlidePlayer()
'         With .EventName("mode_base_started")
'             .Slide = "score"
'         End With
'     End With
'
'     With .WidgetPlayer()
'         With .EventName("ball_save_new_ball_saving_ball")
'             .Widget = "ball_save"
'             .Expire = 2
'         End With
'     End With
'
' ...and from a show step (.Slides("jackpot") / .Widgets("ball_save")).
' Everything past the Select Case is ordinary FlexDMD code.
'
' SLIDE STACKING
'
' The light stack and the segment display stack live inside GLF, so their
' priority layering is automatic. Nothing equivalent exists for slides -
' on a real setup that stacking is Godot's job. This file implements it:
' every played slide is kept in a priority-ordered stack (ties broken by
' most recent), the top entry is what is on the DMD, and removing the top
' re-renders whatever was underneath. Slides are tagged with the mode that
' played them, so ModeStop clears that mode's slides automatically.
'
' When the stack empties the last scene is deliberately LEFT on the DMD
' rather than blanked - that keeps the scoreboard up between balls, when
' base mode has stopped and nothing has played a slide yet. See
' FlexDmd_StackEmpty if you want a different fallback.
'
' WIDGETS
'
' A widget here is a DMDBigText overlay. DMDTimer_Timer only draws that
' text in FlexMode 1 (the scoreboard scene), which is the same rule a
' widget follows anyway: it overlays the current slide.
'
' THE COST OF useBcp = True
'
' Attaching a controller flips useBcp on, and that flag gates more than
' slides. GLF will also push every dispatched event, player add, ball
' start/end and variable change at bcpController.Send, and poll
' GetMessages every 300ms. Those are wire-protocol messages with nowhere
' to go here, so the controller drops them - but GLF still builds the
' strings, which is a small per-event cost you would also be paying with
' a real Godot controller attached.
'
' REVERTING TO REAL BCP
'
' Turn the "Glf Backbox Control Protocol" table option On. FlexBcp_Attach
' below stands down whenever that option is set, GLF connects to Godot
' the normal way, and every slide, widget and show entry keeps working
' unmodified - the only thing that changed is what sits behind
' bcpController.


' DMDTimer's interval, in ms - Expire is given in seconds, DMDBigText
' counts DMD frames. Keep in sync with the DMDTimer object in the table.
Const FlexDmdFrameMs = 17

' Expire used for a widget that did not set one.
Const FlexDmdDefaultWidgetExpire = 1.3

' Our controller instance, when one is attached. Null otherwise.
' bcpController points at the same object; this second reference is what
' the delay callback below uses, so it never has to care what GLF has
' since done with bcpController.
Dim glfFlexBcp : glfFlexBcp = Null


'*******************************************
'  Wiring
'*******************************************

' Attach the local controller. Idempotent - safe to call as often as you
' like, which matters because Glf_Options tears bcpController down on
' every option event.
'
' Called from Table1_Init (after Flex_Init, so the scenes exist) and from
' Table1_OptionEvent (after Glf_Options, to put it back).
Sub FlexBcp_Attach()
    If UseFlexDMD = 0 Then Exit Sub

    ' The real Godot controller wins if the table option asks for it.
    ' Same Option() call Glf_Options makes, so this only reads the value.
    If Table1.Option("Glf Backbox Control Protocol", 0, 1, 1, 0, 0, Array("Off", "On")) = 1 Then
        Exit Sub
    End If

    If IsObject(bcpController) Then
        ' Identity comparison rather than TypeName - see the note on
        ' FlexDmd_Kwarg below. TypeName() segfaults VPX's macOS VBScript
        ' engine, so this file never calls it.
        Dim isOurs : isOurs = False
        If IsObject(glfFlexBcp) Then
            If bcpController Is glfFlexBcp Then isOurs = True
        End If

        If Not isOurs Then
            ' Somebody else's controller - leave it alone.
            Exit Sub
        End If
        If bcpController.Connected Then
            ' Already ours and live. Nothing to do but make sure GLF is
            ' still routing to it.
            useBcp = True
            Exit Sub
        End If
        ' Ours, but Disconnect has been through it - replace it below.
    End If

    Set glfFlexBcp = (new GlfFlexDmdBcpController)()
    Set bcpController = glfFlexBcp
    useBcp = True
End Sub


' Fired by SetDelay when a slide's Expire elapses.
Sub Glf_FlexDmdSlideExpired(args)
    If IsObject(glfFlexBcp) Then
        glfFlexBcp.RemoveSlide args
    End If
End Sub


'*******************************************
'  The controller
'*******************************************
' Implements every method GLF calls on bcpController. PlaySlide,
' PlayWidget, ModeStart, ModeStop, ModeList, SendPlayerVariable,
' SendMachineVariable, Send, GetMessages, Reset and Disconnect all have
' live call sites in GLF once useBcp is True - Send and GetMessages
' especially, which Glf_BcpSendEvent and Glf_BcpUpdate reach for on
' ordinary events, nowhere near a slide. RemoveSlide, PlaySound,
' StopSound and SlidesClear have none today; they are here so a later GLF
' version that starts calling them finds something to call.

Class GlfFlexDmdBcpController

    Private m_slides     ' slide name -> GlfFlexDmdSlide
    Private m_current    ' slide name currently rendered ("" = none)
    Private m_seq        ' monotonic counter, breaks priority ties
    Private m_connected

    Public default Function Init()
        Set m_slides = CreateObject("Scripting.Dictionary")
        m_current = ""
        m_seq = 0
        m_connected = True
        Set Init = Me
    End Function

    ' The slide currently on the DMD, or "" - handy from the debugger.
    Public Property Get CurrentSlide() : CurrentSlide = m_current : End Property

    ' False once Disconnect has run. FlexBcp_Attach uses this to tell a
    ' live controller from a spent one.
    Public Property Get Connected() : Connected = m_connected : End Property


    '--- Slides --------------------------------------------------------

    Public Sub PlaySlide(slide, context, calling_context, action, expire, priority, kwargs)
        If m_connected = False Then Exit Sub
        If FlexBcp_Str(slide) = "" Then Exit Sub

        If LCase(FlexBcp_Str(action)) = "remove" Then
            RemoveSlide slide
            Exit Sub
        End If

        Dim entry
        If m_slides.Exists(slide) Then
            Set entry = m_slides(slide)
        Else
            Set entry = (new GlfFlexDmdSlide)()
            m_slides.Add slide, entry
        End If

        m_seq = m_seq + 1
        entry.Priority = FlexBcp_Num(priority)
        entry.Context = FlexBcp_StripMode(context)
        entry.Seq = m_seq
        entry.SetKwargs kwargs

        Log "PlaySlide " & slide & " (context=" & entry.Context & _
            ", priority=" & entry.Priority & ", expire=" & FlexBcp_Num(expire) & ")"

        RemoveDelay FlexBcp_ExpiryKey(slide)
        If FlexBcp_Num(expire) > 0 Then
            SetDelay FlexBcp_ExpiryKey(slide), "Glf_FlexDmdSlideExpired", slide, _
                     FlexBcp_Num(expire) * 1000
        End If

        ' Force a re-render if this slide is the top one, even when it
        ' already was - replaying a slide should restart its animation.
        Render slide
    End Sub

    Public Sub RemoveSlide(slide)
        If m_connected = False Then Exit Sub
        If m_slides.Exists(slide) Then
            Log "RemoveSlide " & slide
            m_slides.Remove slide
            RemoveDelay FlexBcp_ExpiryKey(slide)
        End If
        Render ""
    End Sub

    ' Drop every slide a given mode played. GLF has no internal caller for
    ' this, but ModeStop below does exactly what the real BCP controller
    ' does and calls it, so a mode's slides clean themselves up.
    Public Sub SlidesClear(context)
        If m_connected = False Then Exit Sub

        If m_slides.Count = 0 Then Exit Sub

        Dim ctx : ctx = FlexBcp_StripMode(context)
        Dim doomed() : ReDim doomed(m_slides.Count)
        Dim n : n = -1
        Dim slideName, entry
        For Each slideName In m_slides.Keys()
            Set entry = m_slides(slideName)
            If entry.Context = ctx Then
                n = n + 1
                doomed(n) = slideName
            End If
        Next

        If n = -1 Then Exit Sub

        Dim i
        For i = 0 To n
            Log "SlidesClear " & ctx & " -> removing " & doomed(i)
            m_slides.Remove doomed(i)
            RemoveDelay FlexBcp_ExpiryKey(doomed(i))
        Next
        Render ""
    End Sub


    '--- Widgets -------------------------------------------------------

    Public Sub PlayWidget(widget, context, calling_context, priority, expire)
        If m_connected = False Then Exit Sub
        If FlexBcp_Str(widget) = "" Then Exit Sub
        If Not IsObject(FlexDMD) Then Exit Sub

        Dim secs : secs = FlexBcp_Num(expire)
        If secs <= 0 Then secs = FlexDmdDefaultWidgetExpire

        Log "PlayWidget " & widget & " (context=" & FlexBcp_StripMode(context) & _
            ", priority=" & FlexBcp_Num(priority) & ", expire=" & secs & ")"

        FlexDmd_ShowWidget widget, secs, Null
    End Sub


    '--- Modes ---------------------------------------------------------

    Public Sub ModeStart(name, priority)
    End Sub

    Public Sub ModeStop(name)
        SlidesClear name
    End Sub

    Public Sub ModeList()
    End Sub


    '--- Sound ---------------------------------------------------------
    ' GLF's own SoundPlayer handles audio locally and never routes it
    ' through bcpController, so there is nothing to do here.

    Public Sub PlaySound(sound, context, calling_context, priority)
    End Sub

    Public Sub StopSound(sound)
    End Sub


    '--- Raw BCP surface -----------------------------------------------
    ' Once useBcp is True, GLF pushes every dispatched event, player add,
    ' ball start/end and variable change at these. They are wire-protocol
    ' messages for a process that does not exist here, so they are dropped
    ' - but they must exist, or those paths error out.

    ' Deliberately not logged: this one is hit on every dispatched event,
    ' and building the log string would cost more than the drop.
    Public Sub Send(commandMessage)
    End Sub

    ' Glf_BcpUpdate polls this every 300ms and returns early on Empty.
    Public Function GetMessages()
        GetMessages = Empty
    End Function

    Public Sub Reset()
    End Sub

    Public Sub SendPlayerVariable(name, value, prevValue)
    End Sub

    Public Sub SendMachineVariable(name, value, prevValue)
    End Sub

    Public Sub Disconnect()
        If m_connected Then
            Log "Disconnect"
            m_connected = False
            useBcp = False
            m_slides.RemoveAll
            m_current = ""
        End If
    End Sub


    '--- Internals -----------------------------------------------------

    ' Render the top of the stack. forceSlide re-renders even when that
    ' slide is already the one showing; pass "" for "only if it changed".
    Private Sub Render(forceSlide)
        Dim topSlideName : topSlideName = TopSlide()

        If topSlideName = "" Then
            ' Nothing left in the stack. Leave the last scene up, but
            ' forget it, so replaying it later renders again.
            m_current = ""
            FlexDmd_StackEmpty()
            Exit Sub
        End If

        If topSlideName <> m_current Or topSlideName = forceSlide Then
            ' Flex_Init has not run yet - leave m_current alone so the
            ' next Render still has this slide to draw.
            If Not IsObject(FlexDMD) Then Exit Sub

            Dim entry : Set entry = m_slides(topSlideName)
            Dim kw
            If entry.HasKwargs Then
                Set kw = entry.Kwargs()
            Else
                kw = Null
            End If

            FlexDmd_ShowSlide topSlideName, kw
            m_current = topSlideName
        End If
    End Sub

    ' Highest priority wins; most recently played breaks a tie.
    Private Function TopSlide()
        Dim bestName : bestName = ""
        Dim bestPri, bestSeq
        Dim slideName, entry
        For Each slideName In m_slides.Keys()
            Set entry = m_slides(slideName)
            If bestName = "" Or entry.Priority > bestPri Or _
               (entry.Priority = bestPri And entry.Seq > bestSeq) Then
                bestName = slideName
                bestPri = entry.Priority
                bestSeq = entry.Seq
            End If
        Next
        TopSlide = bestName
    End Function

    Private Sub Log(message)
        Glf_WriteDebugLog "flexdmd_bcp", message
    End Sub

End Class


' One entry in the slide stack.
Class GlfFlexDmdSlide

    Private m_priority, m_context, m_seq, m_kwargs

    Public Property Get Priority() : Priority = m_priority : End Property
    Public Property Let Priority(input) : m_priority = input : End Property

    Public Property Get Context() : Context = m_context : End Property
    Public Property Let Context(input) : m_context = input : End Property

    Public Property Get Seq() : Seq = m_seq : End Property
    Public Property Let Seq(input) : m_seq = input : End Property

    Public default Function Init()
        m_priority = 0
        m_context = ""
        m_seq = 0
        m_kwargs = Null
        Set Init = Me
    End Function

    ' kwargs is whatever the event carried - a Scripting.Dictionary, or
    ' Null from a show step. Property Let cannot take an object, hence
    ' the pair of methods.
    Public Sub SetKwargs(input)
        If IsObject(input) Then
            Set m_kwargs = input
        Else
            m_kwargs = Null
        End If
    End Sub

    Public Property Get HasKwargs()
        HasKwargs = IsObject(m_kwargs)
    End Property

    Public Function Kwargs()
        If IsObject(m_kwargs) Then
            Set Kwargs = m_kwargs
        Else
            Kwargs = Null
        End If
    End Function

End Class


'*******************************************
'  Slide and widget mapping - edit these
'*******************************************

' slide name -> FlexDMD scene. The names are what you put in
' .Slide = "..." in mode config, or .Slides("...") in a show step.
'
' kwargs is the kwargs of the event that played the slide (a
' Scripting.Dictionary), or Null. Read it with FlexDmd_Kwarg.
Sub FlexDmd_ShowSlide(slide, kwargs)
    Select Case LCase(slide)

        Case "score", "base"
            ' The scoreboard. FlexMode 1 is the one DMDTimer_Timer keeps
            ' updating with live scores, ball number and DMDBigText, so
            ' any slide that wants widgets over it wants mode 1.
            ShowScene FlexScenes(0), FlexDMD_RenderMode_DMD_GRAY, 1

        Case "welcome", "attract"
            ' FlexMode 2's animation is keyed to absolute frame numbers
            ' (88, 110), so it only plays from a reset counter.
            FlexFrame = 0
            ShowScene FlexScenes(1), FlexDMD_RenderMode_DMD_GRAY, 2

        Case "bonus_x"
            ShowScene FlexScenes(2), FlexDMD_RenderMode_DMD_GRAY, 0

        Case "multiball"
            ShowScene FlexScenes(3), FlexDMD_RenderMode_DMD_GRAY, 4

        Case "jackpot"
            ShowScene FlexScenes(4), FlexDMD_RenderMode_DMD_GRAY, 0

        Case "dance_marathon_timer"
            ' Text over the scoreboard rather than a scene of its own. It
            ' is a slide and not a widget because only the slide player
            ' passes the triggering event's kwargs through, and the count
            ' lives in there - GLF's timer puts "ticks_remaining" in the
            ' kwargs of every timer_X_tick.
            '
            ' The ShowScene guard is what makes a text-only slide safe. A
            ' slide that renders no scene leaves whatever scene is already
            ' up, so if this one took the top of the stack back from, say,
            ' an expiring multiball animation, the DMD would still be
            ' showing multiball. Claiming the scoreboard when it is not
            ' already up fixes that, and skipping it when it is avoids
            ' rebuilding the stage - and restarting the scrolling title -
            ' once a second. Any other text-only slide wants the same two
            ' lines.
            '
            ' Held slightly longer than the 1s tick interval so the text
            ' does not blink out between ticks, and solid rather than
            ' flashing because it is continuous, not a notification.
            If FlexMode <> 1 Then
                ShowScene FlexScenes(0), FlexDMD_RenderMode_DMD_GRAY, 1
            End If
            DMDBigText FlexDmd_Kwarg(kwargs, "ticks_remaining", 0) & " SEC", _
                       FlexDmd_Frames(1.2), 0

        Case "no_bonus"
            ShowScene FlexScenes(5), FlexDMD_RenderMode_DMD_GRAY, 0

        Case "bonus_1"
            ShowScene FlexScenes(6), FlexDMD_RenderMode_DMD_GRAY, 0

        Case "bonus_2"
            ShowScene FlexScenes(7), FlexDMD_RenderMode_DMD_GRAY, 0

        Case "bonus_3"
            ShowScene FlexScenes(8), FlexDMD_RenderMode_DMD_GRAY, 0
        
        Case "kirk-dances"
            ShowScene FlexScenes(9), FlexDMD_RenderMode_DMD_GRAY, 0

        Case Else
            Glf_WriteDebugLog "flexdmd_bcp", "No FlexDMD scene mapped for slide '" & slide & "'"

    End Select
End Sub


' widget name -> a transient overlay on the current slide.
'
' expireSeconds is the .Expire from config (or FlexDmdDefaultWidgetExpire
' when none was set). DMDBigText's second argument counts DMD frames, so
' it goes through FlexDmd_Frames.
'
' The widget player does not pass event kwargs today, so kwargs is Null
' from that path; a show step's .Widgets(...) is the same. The parameter
' is here so the "text" case works if that ever changes.
Sub FlexDmd_ShowWidget(widget, expireSeconds, kwargs)
    Dim frames : frames = FlexDmd_Frames(expireSeconds)

    Select Case LCase(widget)

        Case "ball_save"
            DMDBigText "BALL SAVED", frames, 1

        Case "launch"
            DMDBigText "LAUNCH", frames, 1

        Case "ball_1_locked"
            DMDBigText "BALL 1 LOCKED", frames, 1

        Case "ball_2_locked"
            DMDBigText "BALL 2 LOCKED", frames, 1

        Case "skillshot"
            DMDBigText "SKILLSHOT HIT", frames, 1

        Case "extra_ball_lit"
            DMDBigText "EXTRA BALL LIT", frames, 1

        Case "extra_ball"
            DMDBigText "EXTRA BALL", frames, 1

        Case "dance_marathon"
            DMDBigText "DANCE MARATHON", frames, 1

        Case "dance_marathon_done"
            DMDBigText "DANCE MARATHON COMPLETE", frames, 1

        Case "text"
            ' Generic: whatever the event carried under "text".
            Dim message : message = FlexDmd_Kwarg(kwargs, "text", "")
            If message <> "" Then DMDBigText message, frames, 1

        Case Else
            Glf_WriteDebugLog "flexdmd_bcp", "No FlexDMD overlay mapped for widget '" & widget & "'"

    End Select
End Sub


' Called when the last slide leaves the stack. Deliberately does nothing:
' the scene that was up stays up, which is what keeps the scoreboard on
' screen after base mode stops at the end of a ball.
'
' To blank the DMD instead:
'     FlexDMD.LockRenderThread : FlexDMD.Stage.RemoveAll : FlexDMD.UnlockRenderThread
'     FlexMode = 0
Sub FlexDmd_StackEmpty()
End Sub


'*******************************************
'  Helpers
'*******************************************

Function FlexDmd_Frames(seconds)
    FlexDmd_Frames = Int(seconds * 1000 / FlexDmdFrameMs)
End Function

' Read one key out of an event's kwargs, with a fallback.
'
' NEVER call TypeName() on kwargs to check that it is a Dictionary. VPX's
' macOS VBScript engine (libwinevbs) segfaults on TypeName(<Scripting.
' Dictionary>) - Global_TypeName -> get_typeinfo dereferences a bad
' pointer and takes the whole process down with SIGSEGV, no script error.
' It is a real crash in the engine, not something this table did wrong,
' and it does not reproduce on Windows' vbscript.dll.
'
' IsObject plus On Error is the safe equivalent. Everything GLF puts in
' kwargs comes from GlfKwargs(), which is always a Scripting.Dictionary,
' so the only job left is to survive a caller passing something else.
Function FlexDmd_Kwarg(kwargs, key, fallback)
    FlexDmd_Kwarg = fallback
    If Not IsObject(kwargs) Then Exit Function

    On Error Resume Next
    If kwargs.Exists(key) Then FlexDmd_Kwarg = kwargs(key)
    On Error GoTo 0
End Function

Function FlexBcp_Num(value)
    If IsObject(value) Then
        FlexBcp_Num = 0
    ElseIf IsEmpty(value) Or IsNull(value) Then
        FlexBcp_Num = 0
    ElseIf IsNumeric(value) Then
        FlexBcp_Num = CDbl(value)
    Else
        FlexBcp_Num = 0
    End If
End Function

Function FlexBcp_Str(value)
    If IsObject(value) Then
        FlexBcp_Str = ""
    ElseIf IsEmpty(value) Or IsNull(value) Then
        FlexBcp_Str = ""
    Else
        FlexBcp_Str = CStr(value)
    End If
End Function

' The slide player passes the mode name unprefixed already; a show step
' can pass it with the "mode_" still on. Normalise, the way the real BCP
' controller does, so ModeStop's clear matches what PlaySlide stored.
Function FlexBcp_StripMode(value)
    FlexBcp_StripMode = Replace(FlexBcp_Str(value), "mode_", "")
End Function

Function FlexBcp_ExpiryKey(slide)
    FlexBcp_ExpiryKey = "flexdmd_slide_expire_" & slide
End Function
