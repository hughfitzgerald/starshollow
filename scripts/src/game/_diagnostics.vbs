
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

Sub GlfDiag_Init()
    diag_started = True

    ' Watch the events that make up the start-of-game chain.
    AddPinEventListener "reset_complete", "diag_reset",   "GlfDiag_Note", 1, Array("reset_complete")
    AddPinEventListener "mode_attract_started", "diag_attract", "GlfDiag_Note", 1, Array("ATTRACT STARTED")
    AddPinEventListener "s_start_active",   "diag_startdn", "GlfDiag_Note", 1, Array("start button DOWN")
    AddPinEventListener "s_start_inactive", "diag_startup", "GlfDiag_Note", 1, Array("start button UP")
    AddPinEventListener "game_start",       "diag_gstart", "GlfDiag_Note", 1, Array("game_start")
    AddPinEventListener "game_started",     "diag_gstarted","GlfDiag_Note", 1, Array("GAME STARTED")
    AddPinEventListener "ball_started",     "diag_bstart", "GlfDiag_Note", 1, Array("ball_started")
    AddPinEventListener "mode_base_started","diag_base",   "GlfDiag_Note", 1, Array("BASE MODE STARTED")

    Debug.Print "GLFDIAG: initialised"
End Sub

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

    '--- 3. lights ---
    s = s & "[info] glf_lights registered: " & glf_lightNames.Count & vbNewLine

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
