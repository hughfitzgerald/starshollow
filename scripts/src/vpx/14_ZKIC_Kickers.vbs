'*******************************************
'   ZKIC: Kickers, Saucers
'*******************************************
' Kicker1 was deleted from this table long ago - its handlers are gone.
' s_VUK1's 1500ms VPX TimerInterval hold is replaced by the GLF ball device's
' EjectTimeout / eject_vuk1 event. Do not re-add a s_VUK1_Timer.

' GLF calls EjectCallback with a REAL ball on eject, but ALSO with Null
' from two other paths:
'   GlfBallDevice.EjectEnableComplete -> GetRef(m_eject_callback)(Null)
'   GlfBallDevice.BallSearch          -> can pass a Null m_balls(0)
' So every eject callback must tolerate Null or it throws "Object required"
' on a loop.
'
' Use the KICKER'S OWN .Kick(angle, force) method, exactly like the
' original working table did (VUK1.Kick -19, 50). This table's earlier
' migration used the generic KickBall() helper (manual ball.velx/vely
' assignment) instead, copied from the GLF example's ZSOL pattern for a
' plain Wall/Trigger-style device. For a real VPX Kicker object that is
' wrong: a Kicker can still consider the ball "captured" and override a
' manually-set velocity on the next physics tick, so the ball just sits
' there - no error, no kick, which matched exactly what was seen.
' The scoop kicks in two directions. GLF has one eject callback per device, so the
' callback picks the direction itself, from machine.captive_capture_pending. That
' variable is 1 from the moment a ball in the scoop is chosen to become the captive
' ball until a ball arrives at the captive spot (captive_ball_is_home), so a kick
' that has to be repeated still goes the right way.
Sub ScoopEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_VUK1
	If glf_machine_vars("captive_capture_pending").GetValue() = 1 Then
		s_VUK1.Kick 85, 100		' up to the captive ball spot
	Else
		s_VUK1.Kick -19, 50		' back into play
	End If
End Sub

Sub DropTargetKickerEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	dim angle
	angle = -110
	If glf_modes("fd_punch").GetValue("active") = True Then
		If GetPlayerState("fd_punch_left_redirect") = 1 Then
			angle = 180
		End If
	End If
	SoundSaucerKick 1, s_DropTargetKicker
	s_DropTargetKicker.Kick angle, 10
	' KickBall ball, -19, 50, 5, 25
End Sub

Sub HiddenUpperRightKickerEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_HiddenUpperRightKicker
	s_HiddenUpperRightKicker.Kick 134, 15
	' KickBall ball, -19, 50, 5, 25
End Sub

' Runs after GLF has counted the drain. One ball left in play means the ball now in
' the drain is the one that goes back to the captive spot.
Sub ReturnCaptiveFromDrain(ball)
	If glf_BIP = 1 Then KickDrainToCaptivity
	' If Drain.BallCntOver = 1 Then Drain.kick 93, 10
End Sub

Sub KickDrainToCaptivity()
	If Drain.BallCntOver = 1 Then glf_ball_audit_extra_balls = 0
	Drain.kick 93, 10
End Sub

' --- Captive ball recovery ---
' ReturnCaptiveFromDrain only acts on a drain that leaves one ball in play. A tilt or
' a cancelled game never produces one, so the captive spot would stay empty. Whenever
' no ball is in play and the captive ball is not home, this waits for every ball to
' come back: five in the trough and a sixth left in the drain. The sixth goes home.
Sub CaptiveRecoveryStart(args)
	SetDelay "captive_recovery", "CaptiveRecoveryCheck", Null, 300
End Sub

' reset_complete is a queue event. GLF expects a listener on a queue event to be a
' Function that hands back the event's arguments, so this cannot be a plain Sub.
Function CaptiveRecoveryOnReset(args)
	CaptiveRecoveryStart Null
	If IsObject(args(1)) Then
		Set CaptiveRecoveryOnReset = args(1)
	Else
		CaptiveRecoveryOnReset = args(1)
	End If
End Function

Sub CaptiveRecoveryCheck(args)
	If glf_machine_vars("captive_ball_captive").GetValue() <> 0 Then Exit Sub
	If glf_BIP > 0 Then Exit Sub
	' Switch events are not posted during a tilt, so the ball's arrival would go
	' unnoticed. CaptiveRecoveryAfterTilt handles that case once the tilt clears.
	If Not glf_gameTilted Then
		If Drain.BallCntOver = 1 And TroughIsFull() Then KickDrainToCaptivity
	End If
	SetDelay "captive_recovery", "CaptiveRecoveryCheck", Null, 300
End Sub

' The tilt has just cleared, so every ball has drained and the next ball is a second
' away. Check now, and keep checking in case the trough is still settling.
Sub CaptiveRecoveryAfterTilt(args)
	If glf_machine_vars("captive_ball_captive").GetValue() <> 0 Then Exit Sub
	If Drain.BallCntOver = 1 And TroughIsFull() Then KickDrainToCaptivity
	CaptiveRecoveryStart Null
End Sub

Function TroughIsFull()
	TroughIsFull = (swTrough1.BallCntOver + swTrough2.BallCntOver + swTrough3.BallCntOver + swTrough4.BallCntOver + swTrough5.BallCntOver = 5)
End Function

Sub DrainSubwayKickerEject(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_DrainSubwayKicker
	DrainSubwayTrackStart ball
	' Was 100: too hot, the ball sometimes skipped s_CaptiveRampKicker entirely.
	s_DrainSubwayKicker.Kick 8, 90
	' Catch-all: if the ball still skips s_CaptiveRampKicker it rolls down
	' CaptiveRampHigh anyway, so have the upper kicker ready to send it home.
	' captive_ball_is_home disables it again.
	s_CaptiveRampUpperKicker.Enabled = True
End Sub

' --- TEMPORARY: drain subway ball tracker (debugging lost returns to the captive spot) ---
' Logs the kicked ball's position and speed every 50ms for 3s after the drain subway
' kick, under "drain_subway_track" in the debug log. Tracks the ball GLF passes to the
' eject callback. The captive ball made at table init (LoganBall) is not in gBOT, so
' all balls come from GetBalls. Remove once the lost return is understood.
Const DrainSubwayTrackMs = 3000
Const DrainSubwayTrackStepMs = 50
Dim drainSubwayTrackBall : drainSubwayTrackBall = Empty
Dim drainSubwayTrackT0 : drainSubwayTrackT0 = 0

Function DrainSubwayInGBOT(ball)
	Dim b
	DrainSubwayInGBOT = False
	If Not IsArray(gBOT) Then Exit Function
	For Each b In gBOT
		If b Is ball Then DrainSubwayInGBOT = True : Exit Function
	Next
End Function

Sub DrainSubwayTrackStart(passedBall)
	Dim msg, b, allBalls
	drainSubwayTrackBall = Empty
	drainSubwayTrackT0 = gametime
	On Error Resume Next
	Set drainSubwayTrackBall = passedBall
	allBalls = GetBalls
	msg = "kick: BIP=" & glf_BIP & " balls on table=" & (UBound(allBalls) + 1) & " in gBOT=" & (UBound(gBOT) + 1)
	msg = msg & " | ball ID=" & passedBall.ID & " in gBOT=" & DrainSubwayInGBOT(passedBall) & " is LoganBall=" & (passedBall Is LoganBall)
	msg = msg & " x=" & Round(passedBall.x, 1) & " y=" & Round(passedBall.y, 1) & " z=" & Round(passedBall.z, 1)
	msg = msg & " | all:"
	For Each b In allBalls
		msg = msg & " [" & b.ID & " " & Round(b.x) & "," & Round(b.y) & "," & Round(b.z) & "]"
	Next
	Err.Clear
	On Error GoTo 0
	Glf_WriteDebugLog "drain_subway_track", msg
	SetDelay "drain_subway_track", "DrainSubwayTrackTick", Null, DrainSubwayTrackStepMs
End Sub

Sub DrainSubwayTrackTick(args)
	Dim b, t, msg
	t = gametime - drainSubwayTrackT0
	If Not IsObject(drainSubwayTrackBall) Then
		Glf_WriteDebugLog "drain_subway_track", "t=" & t & " no ball to track"
		Exit Sub
	End If
	On Error Resume Next
	Set b = drainSubwayTrackBall
	msg = "t=" & t & " ID=" & b.ID & " x=" & Round(b.x, 1) & " y=" & Round(b.y, 1) & " z=" & Round(b.z, 1) & _
		" vx=" & Round(b.velx, 2) & " vy=" & Round(b.vely, 2) & " vz=" & Round(b.velz, 2)
	If Err.Number <> 0 Then msg = "t=" & t & " ball gone (" & Err.Description & ")"
	Err.Clear
	On Error GoTo 0
	Glf_WriteDebugLog "drain_subway_track", msg
	If t < DrainSubwayTrackMs Then SetDelay "drain_subway_track", "DrainSubwayTrackTick", Null, DrainSubwayTrackStepMs
End Sub

' The ball in the scoop becomes the captive ball. It stops counting as in play when it
' is chosen, not when it arrives, so the ball can still end normally if the other
' balls drain while it is on its way. If the kick fails and the ball drops back into
' the scoop, the scoop device kicks it again by itself, in the same direction.
Sub CaptureCaptiveBall(ball)
	If Not glf_ball_devices("scoop").HasBall() Then Exit Sub
	If glf_machine_vars("captive_capture_pending").GetValue() = 0 Then
		glf_machine_vars("captive_capture_pending").Value = 1
		glf_BIP = glf_BIP - 1
		glf_ball_audit_extra_balls = 0
	End If
	glf_ball_holds("scoop_hold").ReleaseAll()
End Sub

' The captive ramp kicker also kicks in two directions: up to the captive ball spot
' (the default) or out to the left scoop, which puts the captive ball into play.
' captiveFreePending is True from the request to free the ball until GLF confirms
' the eject, so a kick that fails is repeated in the same direction.
Dim captiveFreePending : captiveFreePending = False
Dim captiveFreeTries : captiveFreeTries = 0
Const CaptiveFreeMaxTries = 3

Sub SetCaptiveBallFreeListener(ball)
	If Not glf_ball_devices("captive_ramp_kicker").HasBall() Then Exit Sub
	captiveFreePending = True
	captiveFreeTries = 1
	glf_BIP = glf_BIP + 1
	glf_ball_audit_extra_balls = 1
	glf_ball_holds("captive_ramp_kicker_hold").ReleaseAll()
End Sub

' GLF saw the ball leave and it did not come back.
Sub CaptiveFreeConfirmed(args)
	captiveFreePending = False
End Sub

' The ball dropped back into the kicker. The device kicks it again by itself half a
' second later, in whichever direction captiveFreePending says. After
' CaptiveFreeMaxTries that is back up to the captive spot, and the ball is taken out
' of play, which also ends the multiball mode. (ReleaseAll covers a ball the hold
' caught again because it came back after the eject had been confirmed.)
Sub CaptiveFreeFailed(args)
	If Not captiveFreePending Then Exit Sub
	captiveFreeTries = captiveFreeTries + 1
	If captiveFreeTries > CaptiveFreeMaxTries Then
		captiveFreePending = False
		glf_BIP = glf_BIP - 1
		glf_ball_audit_extra_balls = 0
	End If
	glf_ball_holds("captive_ramp_kicker_hold").ReleaseAll()
End Sub

Sub CaptiveRampKickerEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_CaptiveRampKicker
	If captiveFreePending Then
		s_CaptiveRampKicker.Kick -90, 70 ' Kick towards left scoop
	Else
		s_CaptiveRampKicker.Kick -167, 30 'Kick back up to captive ball area
		s_CaptiveRampUpperKicker.Enabled = True
	End If
End Sub

Sub CaptiveRampUpperKickerEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_CaptiveRampUpperKicker
	s_CaptiveRampUpperKicker.Kick -160, 45
	' s_CaptiveRampUpperKicker.Enabled = False ' Probably we want to put a trigger to know when the ball is back in captivity to disable it
End Sub

Sub DisableCaptiveRampUpperKicker(ball)
	s_CaptiveRampUpperKicker.Enabled = False
End Sub

Sub PlungerEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	KickBall ball, 0, 45, 0, 0
	SoundPlungerPull
	SoundPlungerReleaseBall()
End Sub

' Generic helper used by the eject callbacks above.
Sub KickBall(kball, kangle, kvel, kvelz, kzlift)
	If IsNull(kball) Then Exit Sub
	If Not IsObject(kball) Then Exit Sub
	Dim rangle
	rangle = PI * (kangle - 90) / 180
	kball.z    = kball.z + kzlift
	kball.velz = kvelz
	kball.velx = Cos(rangle) * kvel
	kball.vely = Sin(rangle) * kvel
End Sub

' A lock kicker is only switched off once it is empty. A kicker that is switched off
' while its ball is still leaving never reports the ball gone: the lock device then
' keeps counting a ball it no longer has, and num_balls_locked stays one too high.
' lock_unlit arrives in the same moment as the kick when Logan multiball clears the
' locks and when Jess/Dean multiball starts, so the switch-off waits for the ball.
Dim lockKickerDisablePending : lockKickerDisablePending = False

Sub DisableMultiballLock(ball)
	lockKickerDisablePending = True
	DisableEmptyLockKickers
End Sub

Sub DisableEmptyLockKickers()
	If Not lockKickerDisablePending Then Exit Sub
	If s_Lock1.BallCntOver = 0 Then s_Lock1.Enabled = False
	If s_Lock2.BallCntOver = 0 Then s_Lock2.Enabled = False
End Sub

' balldevice_lock1_ball_exiting / balldevice_lock2_ball_exiting
Sub LockKickerBallLeft(args)
	DisableEmptyLockKickers
End Sub

Sub EnableInitialMultiballLock(ball)
	lockKickerDisablePending = False
	s_Lock1.Enabled = True
	s_Lock2.Enabled = False
End Sub

Sub EnableSecondMultiballLock(ball)
	If lockKickerDisablePending Then Exit Sub
	s_Lock1.Enabled = True
	s_Lock2.Enabled = True
End Sub

Sub EnableThirdMultiballLock(ball)
	If lockKickerDisablePending Then Exit Sub
	s_Lock1.Enabled = True
	s_Lock2.Enabled = True
End Sub

' --- Clearing the locks ---
' The locks kick in two directions: toward the scoop (multiball start) or down the
' subway (clearing). lockClearPending is True from the moment clearing starts until
' every lock ball has come back through the drain, or LockClearTimeoutMs has passed.
' While it is True:
'   - both lock kickers kick down the subway, including any repeat kick
'   - the multiball lock is off, so a ball that drops back into a lock kicker is not
'     counted as a new lock. The lock device ejects it again by itself.
'   - a ball that drops back in reopens the subway diverter for the repeat kick
Dim lockClearPending : lockClearPending = False
Const LockClearTimeoutMs = 8000
Const LockClearRetryDiverterMs = 2000

Sub ClearMultiballLocksListener(ball)
	lockClearPending = True
	SetDelay "lock_clear_timeout", "LockClearDone", Null, LockClearTimeoutMs
	' lock_lit turns the multiball lock back on at the start of the next ball
	If glf_multiball_locks.Exists("multiball_lock") Then glf_multiball_locks("multiball_lock").Disable

    if glf_ball_devices("lock1").HasBall() Then
		glf_ball_devices("lock1").EjectAll()
    End If
    if glf_ball_devices("lock2").HasBall() Then
		glf_ball_devices("lock2").EjectAll()
    End If
End Sub

' all_balls_returned, the timeout, or a new game
Sub LockClearDone(args)
	lockClearPending = False
	RemoveDelay "lock_clear_timeout"
End Sub

' A ball is back in a lock kicker while the locks are being cleared
Sub LockClearRetry(args)
	If Not lockClearPending Then Exit Sub
	DispatchPinEvent "lock_clear_retry", Null
	SetDelay "lock_clear_retry_done", "LockClearRetryDone", Null, LockClearRetryDiverterMs
End Sub

Sub LockClearRetryDone(args)
	DispatchPinEvent "lock_clear_retry_done", Null
End Sub

Sub Lock1EjectCallback(ball)
	If lockClearPending Then
		s_Lock1.Kick 173, 10		' down the subway
	Else
		s_Lock1.Kick 262.5, 50		' toward the scoop
	End If
End Sub

Sub Lock2EjectCallback(ball)
	If lockClearPending Then
		s_Lock2.Kick 173, 10		' down the subway
	Else
		s_Lock2.Kick 262.5, 50		' toward lock 1 and the scoop
	End If
End Sub

Sub SubwayTroughEjectCallback(ball)
	Dim ang, vel
	ang = 128
	vel = 30
	' KickBall ball, ang, vel, 0, 0
	s_subway_trough_kicker.Kick ang, vel
End Sub