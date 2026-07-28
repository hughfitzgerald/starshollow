'*******************************************
'   ZKIC: Kickers, Saucers
'*******************************************
' Kicker1 was deleted from this table long ago - its handlers are gone.
' s_VUK1's 1500ms VPX TimerInterval hold is replaced by the GLF ball device's
' EjectTimeout / eject_vuk1 event. Do not re-add a s_VUK1_Timer.

'To include some randomness in the kick
Const KickerAngleTol = 2
Const KickerStrengthTol = 1

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
	s_VUK1.Kick -19 + RndNum(-KickerAngleTol, KickerAngleTol), _
	            50 + RndNum(-KickerStrengthTol, KickerStrengthTol)
End Sub

Sub PlungerEjectCallback(ball)
	If IsNull(ball) Then Exit Sub
	' Mechanical plunger only - nothing else to do.
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