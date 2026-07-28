
'******************************************************
'   ZTST: Debug Shot Tester v3.2
'******************************************************
'
' Restored from the VPW example table and adapted for GLF.
'
'  2         cycle the outlane / drain blocking posts (4 states:
'            none -> all -> outlanes only -> centre drain only)
'  W E R Y U I P A S F G
'            hold to capture the ball at the debug kicker, release to
'            fire it at that key's saved angle
'  L/R flipper while holding one of those keys
'            adjust that shot's angle live; released angles are saved to
'            <UserDirectory>\<cGameName>.txt and reloaded next run
'
' Set DebugShotMode = 0 below to disable the shot tester (the blocker
' posts on key 2 keep working either way).
'
' --- GLF notes -------------------------------------------------------
' The kicker object is s_debugKicker on this table (it got the blanket
' s_ prefix). The blocker walls/posts/rubbers were not renamed.
'
' This code drives s_debugKicker.Enabled / .Kick directly - it does NOT
' go through GLF events - so it works whether or not s_debugKicker is a
' member of glf_switches. It is currently in that collection; removing it
' is harmless and stops it dispatching pointless s_debugKicker_active
' events during play.
'
' Holding a shot key and tapping a flipper will also flip that flipper,
' because GLF owns the flipper keys now. Same as stock VPW - live with it
' or nudge the angle with the ball already captured.

Const DebugShotMode = 1        'Set to 0 to disable the shot tester
Const DebugBlockerKey = 3      'keycode 3 = the "2" key

Dim DebugKickerForce
DebugKickerForce = 55


'------------------------------------------------------
'  Outlane / drain blocking posts
'------------------------------------------------------
Dim DebugBLState

Sub DebugBlockersApply(w1, w2, w3)
    debug_BLW1.IsDropped = w1 : debug_BLP1.Visible = 1-w1 : debug_BLR1.Visible = 1-w1
    debug_BLW2.IsDropped = w2 : debug_BLP2.Visible = 1-w2 : debug_BLR2.Visible = 1-w2
    debug_BLW3.IsDropped = w3 : debug_BLP3.Visible = 1-w3 : debug_BLR3.Visible = 1-w3
End Sub

' Start with everything open (normal play)
DebugBLState = 0
DebugBlockersApply 1, 1, 1

Sub BlockerWalls
    DebugBLState = (DebugBLState + 1) Mod 4
    PlaySound ("Start_Button")

    Select Case DebugBLState
        Case 0                          'all posts down - normal play
            DebugBlockersApply 1, 1, 1
        Case 1                          'all posts up - nothing drains
            DebugBlockersApply 0, 0, 0
        Case 2                          'outlanes blocked, centre open
            DebugBlockersApply 0, 0, 1
        Case 3                          'centre blocked, outlanes open
            DebugBlockersApply 1, 1, 0
    End Select
End Sub


'------------------------------------------------------
'  Shot angles
'------------------------------------------------------
Dim TestKickerVar
Dim TestKickAngleW, TestKickAngleE, TestKickAngleR, TestKickAngleY
Dim TestKickAngleU, TestKickAngleI, TestKickAngleP, TestKickAngleA
Dim TestKickAngleS, TestKickAngleF, TestKickAngleG

Dim DebugShotKeys, DebugShotAngles
' keycodes: W=17 E=18 R=19 Y=21 U=22 I=23 P=25 A=30 S=31 F=33 G=34
' (D=32 is deliberately skipped - it is the GLF diagnostic key)
DebugShotKeys   = Array(17, 18, 19, 21, 22, 23, 25, 30, 31, 33, 34)
DebugShotAngles = Array(-27, -20, -14, -8, -3, 1, 5, 11, 17, 19, 5)   'defaults

Function DebugShotIndex(keycode)
    Dim i
    DebugShotIndex = -1
    For i = 0 To UBound(DebugShotKeys)
        If DebugShotKeys(i) = keycode Then
            DebugShotIndex = i
            Exit Function
        End If
    Next
End Function


Sub DebugShotTableKeyDownCheck(Keycode)
    'Cycle the outlane / drain blocking posts - works even with the shot
    'tester disabled, since that is the part you want during GLF debugging.
    If Keycode = DebugBlockerKey Then
        BlockerWalls
        Exit Sub
    End If

    If DebugShotMode <> 1 Then Exit Sub

    Dim idx : idx = DebugShotIndex(Keycode)
    If idx >= 0 Then
        s_debugKicker.Enabled = True
        TestKickerVar = DebugShotAngles(idx)
    End If

    'Use the flippers to adjust the angle while holding a shot key
    If s_debugKicker.Enabled = True Then
        If Keycode = LeftFlipperKey Then
            debugKickAim.Visible = True
            TestKickerVar = TestKickerVar - 1
            Debug.Print "Debug shot angle: " & TestKickerVar
        ElseIf Keycode = RightFlipperKey Then
            debugKickAim.Visible = True
            TestKickerVar = TestKickerVar + 1
            Debug.Print "Debug shot angle: " & TestKickerVar
        End If
        debugKickAim.ObjRotz = TestKickerVar
    End If
End Sub


Sub DebugShotTableKeyUpCheck(Keycode)
    If DebugShotMode = 1 Then
        Dim idx : idx = DebugShotIndex(Keycode)
        If idx >= 0 Then
            DebugShotAngles(idx) = TestKickerVar
            s_debugKicker.Kick TestKickerVar, DebugKickerForce
            s_debugKicker.Enabled = False
        End If
    End If

    'Save any angle changes once the key is released
    If (s_debugKicker.Enabled = False And debugKickAim.Visible = True) Then
        debugKickAim.Visible = False
        SaveTestKickAngles
    End If
End Sub


'------------------------------------------------------
'  Persistence - <UserDirectory>\<cGameName>.txt
'------------------------------------------------------
Sub SaveTestKickAngles
    Dim FileObj, OutFile, i
    Set FileObj = CreateObject("Scripting.FileSystemObject")
    If Not FileObj.FolderExists(UserDirectory) Then Exit Sub
    Set OutFile = FileObj.CreateTextFile(UserDirectory & cGameName & ".txt", True)
    For i = 0 To UBound(DebugShotAngles)
        OutFile.WriteLine DebugShotAngles(i)
    Next
    OutFile.Close
    Set OutFile = Nothing
    Set FileObj = Nothing
End Sub

Sub LoadTestKickAngles
    Dim FileObj, OutFile, TextStr, i
    Set FileObj = CreateObject("Scripting.FileSystemObject")
    If Not FileObj.FolderExists(UserDirectory) Then Exit Sub

    If FileObj.FileExists(UserDirectory & cGameName & ".txt") Then
        Set OutFile = FileObj.GetFile(UserDirectory & cGameName & ".txt")
        Set TextStr = OutFile.OpenAsTextStream(1, 0)
        For i = 0 To UBound(DebugShotAngles)
            If TextStr.AtEndOfStream = True Then Exit For
            DebugShotAngles(i) = CInt(TextStr.ReadLine)
        Next
        TextStr.Close
    Else
        SaveTestKickAngles      'first run - write the defaults out
    End If

    Set OutFile = Nothing
    Set FileObj = Nothing
End Sub

If DebugShotMode = 1 Then LoadTestKickAngles
