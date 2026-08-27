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
Sub ScoopEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_VUK1
	s_VUK1.Kick -19, 50
	' KickBall ball, -19, 50, 5, 25
End Sub

Sub DropTargetKickerEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_DropTargetKicker
	s_DropTargetKicker.Kick -122, 20
	' KickBall ball, -19, 50, 5, 25
End Sub

Sub HiddenUpperRightKickerEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_HiddenUpperRightKicker
	s_HiddenUpperRightKicker.Kick 134, 10
	' KickBall ball, -19, 50, 5, 25
End Sub

Sub CaptiveRampKickerEjectCallback(ball)
	CaptiveDiverter.RotateToEnd
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_CaptiveRampKicker
	s_CaptiveRampKicker.Kick -90, 70
	' KickBall ball, -19, 50, 5, 25
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

Sub DisableMultiballLock(ball)
	s_Lock1.Enabled = False
	s_Lock2.Enabled = False
End Sub

Sub EnableInitialMultiballLock(ball)
	s_Lock1.Enabled = True
	s_Lock2.Enabled = False
End Sub

Sub EnableSecondMultiballLock(ball)
	s_Lock1.Enabled = True
	s_Lock2.Enabled = True
End Sub

Sub EnableThirdMultiballLock(ball)
	s_Lock1.Enabled = True
	s_Lock2.Enabled = True
End Sub

Sub ClearMultiballLocksListener(ball)
    glf_ball_devices("lock1").EjectCallback = "Lock1SubwayEjectCallback"
    glf_ball_devices("lock2").EjectCallback = "Lock2SubwayEjectCallback"

    glf_ball_devices("lock1").EjectAll()
    glf_ball_devices("lock2").EjectAll()

    glf_ball_devices("lock1").EjectCallback = "Lock1EjectCallback"
    glf_ball_devices("lock2").EjectCallback = "Lock2EjectCallback"
End Sub

Sub Lock1SubwayEjectCallback(ball)
    s_Lock1.Kick 162, 10
End Sub

Sub Lock2SubwayEjectCallback(ball)
    s_Lock2.Kick 162, 10
End Sub

Sub Lock1EjectCallback(ball)
	Dim ang, vel
	ang = 251.5
	vel = 50
	s_Lock1.Kick ang, vel
End Sub

Sub Lock2EjectCallback(ball)
	Dim ang, vel
	ang = 251.5
	vel = 50
	s_Lock2.Kick ang, vel
End Sub

Sub SubwayTroughEjectCallback(ball)
	Dim ang, vel
	ang = 128
	vel = 30
	' KickBall ball, ang, vel, 0, 0
	s_subway_trough_kicker.Kick ang, vel
End Sub