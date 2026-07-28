
'*******************************************
'   ZSOL: Other Solenoids
'*******************************************

' Knocker - requires a primitive named KnockerPosition
Sub SolKnocker(Enabled)
	If Enabled Then
		KnockerSolenoid
	End If
End Sub

' Diverter - was Diverter.RotateToEnd inline in Table1_KeyDown.
' GLF owns the flipper keys now, so this is driven by CreateGlfDiverter
' bound to s_left_flipper_active / s_left_flipper_inactive.
Sub DiverterAction(Enabled)
	If Enabled Then
		Diverter.RotateToEnd
	Else
		Diverter.RotateToStart
	End If
End Sub
