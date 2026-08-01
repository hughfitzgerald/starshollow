'*******************************************
'  GLF Diagnostics  (TEMPORARY - delete when working)
'*******************************************
' Answers, in order: is the event pump running? is the start button
' reaching GLF? is the ball controller letting the game start?
'
' Press D at any time to dump the current state to a message box.
' Everything also goes to Debug.Print (visible in VPX's script debugger
' window) and, if "Glf Debug Log" is on in the F6 tweak menu, to
' glf_logs\<cGameName>_<timestamp>_debug_log.txt next to the table.
'
' To use: drop this file in src/game/ and call GlfDiag_Init() at the very
' end of Table1_Init (after Glf_Init).

Dim diag_events  : diag_events = ""
Dim diag_started : diag_started = False
Dim diag_switchNames, diag_switchHits

Sub GlfDiag_Init()
    diag_started = True

    ' Force the GLF file log on directly, bypassing Table1.Option entirely.
    ' That option is meant to be set via VPX's native "Table Options"
    ' overlay, and the correct keybind for it varies by VPX build/platform
    ' (F6 is not universal, particularly on the standalone BGFX build) -
    ' this is a guaranteed way to get the log while debugging, independent
    ' of whatever key that overlay happens to be bound to.
    glf_debugEnabled = True
    glf_debugLog.EnableLogs
    Debug.Print "GLFDIAG: GLF file log forced on (see glf_logs\ next to the table)"

    ' Watch the events that make up the start-of-game chain.
    AddPinEventListener "reset_complete", "diag_reset",   "GlfDiag_Note", 1, Array("reset_complete")
    AddPinEventListener "mode_attract_started", "diag_attract", "GlfDiag_Note", 1, Array("ATTRACT STARTED")
    AddPinEventListener "s_start_active",   "diag_startdn", "GlfDiag_Note", 1, Array("start button DOWN")
    AddPinEventListener "s_start_inactive", "diag_startup", "GlfDiag_Note", 1, Array("start button UP")
    AddPinEventListener "game_start",       "diag_gstart", "GlfDiag_Note", 1, Array("game_start")
    AddPinEventListener "game_started",     "diag_gstarted","GlfDiag_Note", 1, Array("GAME STARTED")
    AddPinEventListener "ball_started",     "diag_bstart", "GlfDiag_Note", 1, Array("ball_started")
    AddPinEventListener "ball_ended",     "diag_bend", "GlfDiag_Note", 1, Array("ball_ended")
    AddPinEventListener "mode_base_started","diag_base",   "GlfDiag_Note", 1, Array("BASE MODE STARTED")

    ' --- VUK chain, in the order it should happen ---
    ' s_VUK1_active -> (500ms EntranceCountDelay) -> ball_entered
    '   -> Vuk1Hold's 1500ms delay -> eject_vuk1 -> ejecting_ball
    ' If s_VUK1_inactive appears BEFORE ball_entered, GlfBallDevice.BallExiting
    ' has cancelled the pending enter (it calls RemoveDelay on it), m_balls(0)
    ' is never set, and no eject can ever happen.
    AddPinEventListener "s_VUK1_inactive", "diag_vuk_inact", "GlfDiag_Note", 1, Array("!! s_VUK1_INACTIVE (cancels pending enter)")
    AddPinEventListener "balldevice_vuk1_ball_entered", "diag_vuk_entered", "GlfDiag_Note", 1, Array("vuk1 ball_entered")
    AddPinEventListener "eject_vuk1", "diag_vuk_ejevt", "GlfDiag_Note", 1, Array("eject_vuk1 dispatched")
    AddPinEventListener "balldevice_vuk1_ejecting_ball", "diag_vuk_ejecting", "GlfDiag_Note", 1, Array("vuk1 ejecting_ball")
    AddPinEventListener "balldevice_vuk1_ball_exiting", "diag_vuk_exiting", "GlfDiag_Note", 1, Array("vuk1 ball_exiting")

    AddPinEventListener "balldevice_lock1_ball_entered", "diag_lock1_entered", "GlfDiag_Note", 1, Array("lock1 ball_entered")
    AddPinEventListener "balldevice_lock1_ejecting_ball", "diag_lock1_ejecting", "GlfDiag_Note", 1, Array("lock1 ejecting_ball")
    AddPinEventListener "balldevice_lock1_ball_exiting", "diag_lock1_exiting", "GlfDiag_Note", 1, Array("lock1 ball_exiting")

    AddPinEventListener "balldevice_lock2_ball_entered", "diag_lock2_entered", "GlfDiag_Note", 1, Array("lock2 ball_entered")
    AddPinEventListener "balldevice_lock2_ejecting_ball", "diag_lock2_ejecting", "GlfDiag_Note", 1, Array("lock2 ejecting_ball")
    AddPinEventListener "balldevice_lock2_ball_exiting", "diag_lock2_exiting", "GlfDiag_Note", 1, Array("lock2 ball_exiting")

    AddPinEventListener "balldevice_lock3_ball_entered", "diag_lock3_entered", "GlfDiag_Note", 1, Array("lock3 ball_entered")
    AddPinEventListener "balldevice_lock3_ejecting_ball", "diag_lock3_ejecting", "GlfDiag_Note", 1, Array("lock3 ejecting_ball")
    AddPinEventListener "balldevice_lock3_ball_exiting", "diag_lock3_exiting", "GlfDiag_Note", 1, Array("lock3 ball_exiting")

    AddPinEventListener "s_skillshot_active", "diag_skillshot_active", "GlfDiag_Note", 1, Array("s_skillshot switch active")

    AddPinEventListener "s_complete_right_ramp_active", "diag_complete_right_ramp", "GlfDiag_Note", 1, Array("s_complete_right_ramp switch active")
    AddPinEventListener "s_enter_right_ramp_active", "diag_enter_right_ramp", "GlfDiag_Note", 1, Array("s_enter_right_ramp switch active")

    ' Count every switch event the game actually depends on. A switch that
    ' never fires is almost always missing from the glf_switches collection:
    ' GLF only generates <name>_Hit / <name>_UnHit for members, and without
    ' the generated sub nothing ever dispatches <name>_active.
    ' Names must match the ACTUAL VPX objects.
    diag_switchNames = Array( _
        "s_sw8", "s_sw9", "s_VUK1", "s_Trigger1", _
        "s_LeftInlane", "s_RightInlane", _
        "s_Bumper1", "s_Bumper3", "s_Bumper5", _
        "s_LeftSlingshot", "s_RightSlingshot", "s_Lock1", "s_Lock2", "s_Lock3")
    ReDim diag_switchHits(UBound(diag_switchNames))
    Dim i
    For i = 0 To UBound(diag_switchNames)
        diag_switchHits(i) = 0
        AddPinEventListener diag_switchNames(i) & "_active", _
            "diag_sw_" & i, "GlfDiag_SwitchHit", 1, Array(i)
    Next

    Debug.Print "GLFDIAG: initialised"
End Sub

Function GlfDiag_SwitchHit(args)
    Dim idx : idx = args(0)(0)
    diag_switchHits(idx) = diag_switchHits(idx) + 1
    Debug.Print "GLFDIAG switch: " & diag_switchNames(idx) & "_active  (hit #" & diag_switchHits(idx) & ")"
    If Not IsNull(args) Then
        If IsObject(args(1)) Then
            Set GlfDiag_SwitchHit = args(1)
        Else
            GlfDiag_SwitchHit = args(1)
        End If
    Else
        GlfDiag_SwitchHit = Null
    End If
End Function

Function GlfDiag_Note(args)
    Dim label : label = args(0)(0)
    diag_events = diag_events & "  " & FormatNumber(gametime/1000, 2) & "s  " & label & vbNewLine
    Debug.Print "GLFDIAG event: " & label
    If Not IsNull(args) Then
        If IsObject(args(1)) Then
            Set GlfDiag_Note = args(1)
        Else
            GlfDiag_Note = args(1)
        End If
    Else
        GlfDiag_Note = Null
    End If
End Function


' Distinguish "the Timer object does not exist" from "it exists but VPX
' is not calling Glf_GameTimer_Timer". Different fixes.
Function GlfDiag_TimerProbe()
    Dim r, exists, isOn, iv
    exists = False
    On Error Resume Next
        Err.Clear
        isOn = Glf_GameTimer.Enabled
        If Err.Number = 0 Then
            exists = True
            iv = Glf_GameTimer.Interval
        End If
        Err.Clear
    On Error GoTo 0

    If Not exists Then
        r = "       -> No object named Glf_GameTimer found in the table." & vbNewLine
        r = r & "          Add one in the VPX editor: Timer object, Name" & vbNewLine
        r = r & "          Glf_GameTimer, Enabled ticked, Interval -1." & vbNewLine
    ElseIf isOn = False Then
        r = "       -> Glf_GameTimer EXISTS but Enabled = False." & vbNewLine
        r = r & "          Tick Enabled in its properties." & vbNewLine
    Else
        r = "       -> Glf_GameTimer exists, Enabled = True, Interval = " & iv & "," & vbNewLine
        r = r & "          but its _Timer sub is never called. VPX is not" & vbNewLine
        r = r & "          binding Glf_GameTimer_Timer from the ExecuteGlobal'd" & vbNewLine
        r = r & "          script. Use the fallback pump - see 03_ZTIM." & vbNewLine
    End If
    GlfDiag_TimerProbe = r
End Function


' GLF hardcodes a small set of VPX object and collection names. Missing
' ones fail in different ways: some crash, some (like Glf_GameTimer) go
' silently dead. Check them all in one place.
Function GlfDiag_RequiredObjects()
    Dim r, missing
    missing = ""
    missing = missing & GlfDiag_NeedObj("Glf_GameTimer",     "Timer, Enabled, Interval -1 - the event pump")
    missing = missing & GlfDiag_NeedObj("UpdateTroughTimer", "Timer, Interval 100, starts DISABLED")
    missing = missing & GlfDiag_NeedObj("FrameTimer",        "Timer, Interval -1 - VPW animations")
    missing = missing & GlfDiag_NeedObj("CorTimer",          "Timer, Interval 10 - Cor physics")
    missing = missing & GlfDiag_NeedObj("Drain",             "Kicker - GLF trough")
    missing = missing & GlfDiag_NeedObj("swTrough1",         "Kicker - GLF trough")
    missing = missing & GlfDiag_NeedObj("swTrough5",         "Kicker - GLF trough (tnob = 5)")
    missing = missing & GlfDiag_NeedColl("glf_lights",     "lights GLF drives")
    missing = missing & GlfDiag_NeedColl("glf_switches",   "switches GLF generates _Hit for")
    missing = missing & GlfDiag_NeedColl("glf_slingshots", "slingshots")
    missing = missing & GlfDiag_NeedColl("glf_spinners",   "must exist even if EMPTY")

    If missing = "" Then
        r = "[ ok ] All hardcoded GLF objects and collections present" & vbNewLine
    Else
        r = "[FAIL] Missing GLF requirements:" & vbNewLine & missing
    End If
    GlfDiag_RequiredObjects = r
End Function

Function GlfDiag_NeedObj(nm, why)
    Dim ok : ok = True
    On Error Resume Next
        Err.Clear
        Dim junk : junk = Eval(nm & ".Name")
        If Err.Number <> 0 Then ok = False
        Err.Clear
    On Error GoTo 0
    If ok Then
        GlfDiag_NeedObj = ""
    Else
        GlfDiag_NeedObj = "         " & nm & "  (" & why & ")" & vbNewLine
    End If
End Function

Function GlfDiag_NeedColl(nm, why)
    Dim ok : ok = True
    Dim n : n = 0
    On Error Resume Next
        Err.Clear
        Dim o
        For Each o In Eval(nm)
            n = n + 1
        Next
        If Err.Number <> 0 Then ok = False
        Err.Clear
    On Error GoTo 0
    If ok Then
        GlfDiag_NeedColl = ""
    Else
        GlfDiag_NeedColl = "         " & nm & "  (collection - " & why & ")" & vbNewLine
    End If
End Function


' For each light a mode drives: is it registered with GLF, and what
' colour does GLF currently have it at? A light that is NOT registered
' is never blanked, which is the usual cause of "stuck on".
Function GlfDiag_LightReport()
    Dim names, n, r, reg
    names = Array("l8","l9","l11","l12","l13","l14","l15","l16","l17","l18")
    r = "--- driven lights ---" & vbNewLine
    For Each n In names
        If glf_lightNames.Exists(n) Then
            reg = "registered, color=" & Hex(glf_lightNames(n).Color) & _
                  ", state=" & glf_lightNames(n).State
        Else
            reg = "NOT IN glf_lights  <-- will never be blanked by GLF"
        End If
        r = r & "  " & n & ": " & reg & vbNewLine
    Next
    GlfDiag_LightReport = r
End Function


' Cross-reference: is each switch IN glf_switches, and has its _active
' event ever actually fired? Those two answers together localise almost
' every "hitting X does nothing" problem.
Function GlfDiag_SwitchReport()
    Dim r, i, o, inColl, members, slings, nm, want
    members = "|" : slings = "|"
    On Error Resume Next
        For Each o In glf_switches
            members = members & o.Name & "|"
        Next
        Err.Clear
        For Each o In glf_slingshots
            slings = slings & o.Name & "|"
        Next
        Err.Clear
    On Error GoTo 0

    r = "--- switches / times fired ---" & vbNewLine
    For i = 0 To UBound(diag_switchNames)
        nm = diag_switchNames(i)
        ' Slingshots live in glf_slingshots, everything else in glf_switches.
        If InStr(1, nm, "Slingshot", 1) > 0 Then
            want = "glf_slingshots"
            If InStr(1, slings, "|" & nm & "|", 1) > 0 Then
                inColl = "in glf_slingshots"
            Else
                inColl = "NOT IN glf_slingshots  <-- no _Slingshot generated"
            End If
        Else
            want = "glf_switches"
            If InStr(1, members, "|" & nm & "|", 1) > 0 Then
                inColl = "in glf_switches"
            Else
                inColl = "NOT IN glf_switches  <-- no _Hit generated, never fires"
            End If
        End If
        r = r & "  " & nm & ": " & diag_switchHits(i) & " hits, " & inColl & vbNewLine
    Next
    r = r & "  raw glf_switches:   " & Replace(Mid(members,2), "|", " ") & vbNewLine
    r = r & "  raw glf_slingshots: " & Replace(Mid(slings,2), "|", " ") & vbNewLine
    r = r & "  NOTE: hit counts only move during a game - press D mid-ball," & vbNewLine
    r = r & "        not during attract, or everything reads 0." & vbNewLine
    GlfDiag_SwitchReport = r
End Function


Function GlfDiag_Report()
    Dim s, i, n, ok

    s = "=== GLF DIAGNOSTIC ===" & vbNewLine & vbNewLine

    '--- 1. event pump -----------------------------------------------
    ' Glf_GameTimer_Timer is GLF's entire event pump: DispatchPinEvent
    ' only QUEUES, and SetDelay only schedules. Nothing executes until
    ' the pump ticks. It sets glf_lastEventExecutionTime on every pass,
    ' so that value is a direct liveness probe - no hook needed.
    If glf_lastEventExecutionTime = 0 Then
        s = s & "[FAIL] Event pump has NEVER run." & vbNewLine
        s = s & "       You are missing a VPX Timer object named exactly" & vbNewLine
        s = s & "       Glf_GameTimer, Enabled = True, Interval = -1." & vbNewLine
        s = s & "       Without it NOTHING in GLF works: no attract mode," & vbNewLine
        s = s & "       no start button, no ball release. This is almost" & vbNewLine
        s = s & "       certainly your problem." & vbNewLine
        s = s & GlfDiag_TimerProbe()
    ElseIf (gametime - glf_lastEventExecutionTime) > 500 Then
        s = s & "[FAIL] Event pump has STALLED (last ran " & _
                FormatNumber((gametime - glf_lastEventExecutionTime)/1000, 2) & _
                "s ago)." & vbNewLine
        s = s & "       Glf_GameTimer exists but has been disabled, or a" & vbNewLine
        s = s & "       script error killed it." & vbNewLine
    Else
        s = s & "[ ok ] Event pump alive (last tick " & _
                (gametime - glf_lastEventExecutionTime) & "ms ago)" & vbNewLine
    End If

    '--- 2. trough / ball controller ---
    n = 0
    If swTrough1.BallCntOver = 1 Then n = n + 1
    If swTrough2.BallCntOver = 1 Then n = n + 1
    If swTrough3.BallCntOver = 1 Then n = n + 1
    If swTrough4.BallCntOver = 1 Then n = n + 1
    If swTrough5.BallCntOver = 1 Then n = n + 1
    If n = tnob Then
        s = s & "[ ok ] Trough: " & n & " of " & tnob & " balls detected" & vbNewLine
    Else
        s = s & "[FAIL] Trough: only " & n & " of " & tnob & " balls detected." & vbNewLine
        s = s & "       Glf_BallController refuses to start a game unless" & vbNewLine
        s = s & "       every swTrough kicker reports BallCntOver = 1." & vbNewLine
        s = s & "       Check the balls actually land ON the kickers." & vbNewLine
    End If

    '--- 2b. every other object/collection GLF hardcodes ---
    s = s & GlfDiag_RequiredObjects()

    '--- 3. lights ---
    s = s & "[info] glf_lights registered: " & glf_lightNames.Count & vbNewLine

    '--- 3b. the lights the modes actually drive ---
    s = s & GlfDiag_LightReport()

    '--- 3c. switches ---
    s = s & GlfDiag_SwitchReport()

    '--- 4. game state ---
    s = s & "[info] glf_gameStarted = " & glf_gameStarted & vbNewLine
    s = s & "[info] glf_troughSize  = " & glf_troughSize & "  (tnob = " & tnob & ")" & vbNewLine
    s = s & "[info] BallsPerGame    = " & GlfGameSettings().BallsPerGame & vbNewLine

    '--- 5. event log ---
    s = s & vbNewLine & "--- events seen so far ---" & vbNewLine
    If diag_events = "" Then
        s = s & "  (none - consistent with a dead event pump)" & vbNewLine
    Else
        s = s & diag_events
    End If

    s = s & vbNewLine & "Expected order on a healthy table:" & vbNewLine
    s = s & "  reset_complete -> ATTRACT STARTED" & vbNewLine
    s = s & "  (press start) start button DOWN -> UP" & vbNewLine
    s = s & "  -> game_start -> GAME STARTED -> ball_started -> BASE MODE STARTED"

    GlfDiag_Report = s
End Function