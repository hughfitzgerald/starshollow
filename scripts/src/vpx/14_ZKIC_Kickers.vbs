
'*******************************************
'   ZKIC: Kickers, Saucers
'*******************************************
' Kicker1 was deleted from this table long ago - its handlers are gone.
' s_VUK1's 1500ms VPX TimerInterval hold is replaced by the GLF ball device's
' EjectTimeout / eject_vuk1 event. Do not re-add a s_VUK1_Timer.

'To include some randomness in the kick
Const KickerAngleTol = 2
Const KickerStrengthTol = 1

Sub Vuk1EjectCallback(ball)
	SoundSaucerKick 1, s_VUK1
	KickBall ball, -19 + RndNum(-KickerAngleTol, KickerAngleTol), _
	               50 + RndNum(-KickerStrengthTol, KickerStrengthTol), 0, 0
End Sub

Sub PlungerEjectCallback(ball)
	' Mechanical plunger only - nothing to do.
End Sub

' Generic helper used by the eject callbacks above.
Sub KickBall(kball, kangle, kvel, kvelz, kzlift)
	Dim rangle
	rangle = PI * (kangle - 90) / 180
	kball.z    = kball.z + kzlift
	kball.velz = kvelz
	kball.velx = Cos(rangle) * kvel
	kball.vely = Sin(rangle) * kvel
End Sub
