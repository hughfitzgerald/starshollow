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
Sub Vuk1EjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	If Not IsObject(ball) Then Exit Sub
	SoundSaucerKick 1, s_VUK1
	s_VUK1.Kick -19, 50
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

Sub EnableMultiballLockListener(ball)
	If Not s_Lock1.Enabled Then
		s_Lock1.Enabled = True
	ElseIf Not s_Lock2.Enabled Then
		s_Lock2.Enabled = True
	ElseIf Not s_Lock3.Enabled Then
		s_Lock3.Enabled = True
	End If
End Sub

Sub ClearMultiballLocksListener(ball)
	s_Lock1.Kick 0, 0
	s_Lock2.Kick 0, 0
	s_Lock3.Kick 0, 0
	s_Lock1.Enabled = False
	s_Lock2.Enabled = False
	s_Lock3.Enabled = False
End Sub

Sub Lock1EjectCallback(ball)
	Dim ang, vel
	ang = 251.5
	vel = 50
	' KickBall ball, ang, vel, 0, 0
	' ang = 0
	' vel = 0
	s_Lock1.Kick ang, vel
End Sub

Sub Lock2EjectCallback(ball)
	Dim ang, vel
	ang = 251.5
	vel = 50
	' KickBall ball, ang, vel, 0, 0
	' ang = 0
	' vel = 0
	s_Lock2.Kick ang, vel
End Sub

Sub Lock3EjectCallback(ball)
	Dim ang, vel
	ang = 251.5
	vel = 50
	' KickBall ball, ang, vel, 0, 0
	' ang = 0
	' vel = 0
	s_Lock3.Kick ang, vel
End Sub

Sub SubwayTroughEjectCallback(ball)
	Dim ang, vel
	ang = 128
	vel = 30
	' KickBall ball, ang, vel, 0, 0
	s_subway_trough_kicker.Kick ang, vel
End Sub