'*******************************************
'   ZTRI: Triggers
'*******************************************
' All _Hit subs deleted - GLF generates them for glf_switches members.
' The speed-limit helpers survive, wired via AddPinEventListener in
' _configuration.vbs - see the "GLF wiring" block at the bottom of this
' file for why and how.
'
' NOTE: the original had "Sub RighttInlane_Hit" (double t), so the right
' inlane speed limit has never actually run. Both are intact here.

' Inlane switch speedlimit code
'
' GLF change: these took no parameters and read the global ActiveBall
' directly. That is fine inside a real VPX _Hit sub (called synchronously
' at the moment of collision) but NOT once the trigger goes through GLF's
' event queue - a GLF switch event is dispatched, then only actually
' processed on the next Glf_GameTimer_Timer tick, and ActiveBall can have
' moved on to a different ball if anything else collided in between.
'
' GLF preserves the correct ball through the queue as part of the event's
' own arguments though, so taking it as a parameter instead of reading the
' global is both correct and just as simple. b replaces every activeball.

Sub leftInlaneSpeedLimit(b)
	'Wylte's implementation
'    debug.print "Spin in: "& b.AngMomZ
'    debug.print "Speed in: "& b.vely
	if b.vely < 0 then exit sub 							'don't affect upwards movement
    b.AngMomZ = -abs(b.AngMomZ) * RndNum(3,6)
    If abs(b.AngMomZ) > 60 Then b.AngMomZ = 0.8 * b.AngMomZ
    If abs(b.AngMomZ) > 80 Then b.AngMomZ = 0.8 * b.AngMomZ
    If b.AngMomZ > 100 Then b.AngMomZ = RndNum(80,100)
    If b.AngMomZ < -100 Then b.AngMomZ = RndNum(-80,-100)

    if abs(b.vely) > 5 then b.vely = 0.8 * b.vely
    if abs(b.vely) > 10 then b.vely = 0.8 * b.vely
    if abs(b.vely) > 15 then b.vely = 0.8 * b.vely
    if b.vely > 16 then b.vely = RndNum(14,16)
    if b.vely < -16 then b.vely = RndNum(-14,-16)
'    debug.print "Spin out: "& b.AngMomZ
'    debug.print "Speed out: "& b.vely
End Sub


Sub rightInlaneSpeedLimit(b)
	'Wylte's implementation
'    debug.print "Spin in: "& b.AngMomZ
'    debug.print "Speed in: "& b.vely
	if b.vely < 0 then exit sub 							'don't affect upwards movement
    b.AngMomZ = abs(b.AngMomZ) * RndNum(2,4)
    If abs(b.AngMomZ) > 60 Then b.AngMomZ = 0.8 * b.AngMomZ
    If abs(b.AngMomZ) > 80 Then b.AngMomZ = 0.8 * b.AngMomZ
    If b.AngMomZ > 100 Then b.AngMomZ = RndNum(80,100)
    If b.AngMomZ < -100 Then b.AngMomZ = RndNum(-80,-100)

	if abs(b.vely) > 5 then b.vely = 0.8 * b.vely
    if abs(b.vely) > 10 then b.vely = 0.8 * b.vely
    if abs(b.vely) > 15 then b.vely = 0.8 * b.vely
    if b.vely > 16 then b.vely = RndNum(14,16)
    if b.vely < -16 then b.vely = RndNum(-14,-16)
'    debug.print "Spin out: "& b.AngMomZ
'    debug.print "Speed out: "& b.vely
End Sub


'*******************************************
'  GLF wiring
'*******************************************
' AddPinEventListener callbacks always receive one array argument:
'   args(0) = whatever you pass as the listener's own args (Null here)
'   args(1) = the ball GLF captured at the moment of the real VPX hit -
'             the correct ball, preserved through the queue
'   args(2) = the event name

Function LeftInlaneSpeedLimitListener(args)
	If IsObject(args(1)) Then leftInlaneSpeedLimit args(1)
End Function

Function RightInlaneSpeedLimitListener(args)
	If IsObject(args(1)) Then rightInlaneSpeedLimit args(1)
End Function

'*******************************************