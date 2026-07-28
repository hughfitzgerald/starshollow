
'*******************************************
'  ZKEY: Key Press Handling
'*******************************************
' GLF now owns: both flipper keys, staged flippers, magna-save, start
' button, add-credit, and NUDGE. The Nudge calls below are deliberately
' commented out - GLF applies the nudge itself; only the sound stays.
'
' Deleted vs. the original:
'   ScoreCard / CardTimer                        (ZCRD removed)
'   SolLFlipper/SolRFlipper calls                (GLF flipper devices)
'   Diverter.RotateToEnd/Start                   (GLF diverter device)
'   DMDBigText / ShowScene / FlexMode            (ZDMD removed)
'   BIP / BIPL / SolRelease multiball test       (GLF owns ball state)

Sub Table1_KeyDown(ByVal keycode)
	Glf_KeyDown(keycode)

	' Debug shot tester (ZTST): 2 = blocker posts, W/E/R/Y/U/I/P/A/S/F/G = shots
	DebugShotTableKeyDownCheck keycode

	' TEMPORARY - D dumps the GLF diagnostic. Remove with _diagnostics.vbs.
	If keycode = 32 Then MsgBox GlfDiag_Report()

	'Plunger
	If keycode = PlungerKey Then
		Plunger.Pullback
		SoundPlungerPull
	End If

	'Nudging - GLF applies the nudge, we only play the sound
	If keycode = LeftTiltKey Then
		'Nudge 90, 1     'This is set in GLF
		SoundNudgeLeft
	End If
	If keycode = RightTiltKey Then
		'Nudge 270, 1    'This is set in GLF
		SoundNudgeRight
	End If
	If keycode = CenterTiltKey Then
		'Nudge 0, 1      'This is set in GLF
		SoundNudgeCenter
	End If
	If keycode = MechanicalTilt Then
		SoundNudgeCenter()
	End If

	'Coin / start sounds
	If keycode = StartGameKey Then SoundStartButton
	If keycode = AddCreditKey Or keycode = AddCreditKey2 Then
		Select Case Int(Rnd * 3)
			Case 0 : PlaySound ("Coin_In_1"), 0, CoinSoundLevel, 0, 0.25
			Case 1 : PlaySound ("Coin_In_2"), 0, CoinSoundLevel, 0, 0.25
			Case 2 : PlaySound ("Coin_In_3"), 0, CoinSoundLevel, 0, 0.25
		End Select
	End If
End Sub


Sub Table1_KeyUp(ByVal keycode)
	Glf_KeyUp(keycode)

	DebugShotTableKeyUpCheck keycode

	If keycode = PlungerKey Then
		Plunger.Fire
		' PlungerHasBall is maintained by listeners in _configuration.vbs.
		' Do NOT use s_Trigger1.BallCntOver here - that is a Kicker
		' property and this table's plunger switch is a Trigger.
		If PlungerHasBall Then
			SoundPlungerReleaseBall()
		Else
			SoundPlungerReleaseNoBall()
		End If
	End If
End Sub
