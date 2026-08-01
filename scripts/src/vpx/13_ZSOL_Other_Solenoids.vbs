
'*******************************************
'   ZSOL: Other Solenoids
'*******************************************

' Knocker - requires a primitive named KnockerPosition
Sub SolKnocker(Enabled)
	If Enabled Then
		KnockerSolenoid
	End If
End Sub

Sub RampDiverterAction(Enabled)
	If Enabled Then
		RampDiverter.RotateToEnd
	Else
		RampDiverter.RotateToStart
	End If
End Sub

Sub SubwayDiverterAction(Enabled)
	If Enabled Then
		SubwayDiverter.RotateToEnd
	Else
		SubwayDiverter.RotateToStart
	End If
End Sub
