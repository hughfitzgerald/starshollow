
'*******************************************
'   ZBMP: Bumpers
'*******************************************
' Bumpers 1, 3, 5 only - Bumper2 and Bumper4 do not exist on this table.
' Scoring removed; award points from an EventPlayer on s_BumperN_active.
' Threshold pairs are how GLF switches a bumper off - there is no other way.

Sub Bumper1Action(args)
	Dim enabled : enabled = args(0)
	If enabled Then
		ToggleGI 0
		RandomSoundBumperTop s_Bumper1
		FlBumperFadeTarget(1) = 1
		s_Bumper1.timerenabled = True
		DOF 105, DOFPulse
	End If
End Sub
Sub Bumper1Disabled(args) : s_Bumper1.Threshold = 100 : End Sub
Sub Bumper1Enabled(args)  : s_Bumper1.Threshold = 1.5 : End Sub
Sub s_Bumper1_Timer
	FlBumperFadeTarget(1) = 0
End Sub

' Sub Bumper3Action(args)
' 	Dim enabled : enabled = args(0)
' 	If enabled Then
' 		RandomSoundBumperBottom s_Bumper3
' 		FlBumperFadeTarget(3) = 1
' 		s_Bumper3.timerenabled = True
' 		DOF 106, DOFPulse
' 	End If
' End Sub
' Sub Bumper3Disabled(args) : s_Bumper3.Threshold = 100 : End Sub
' Sub Bumper3Enabled(args)  : s_Bumper3.Threshold = 1.5 : End Sub
' Sub s_Bumper3_Timer
' 	FlBumperFadeTarget(3) = 0
' End Sub

Sub Bumper5Action(args)
	Dim enabled : enabled = args(0)
	If enabled Then
		RandomSoundBumperMiddle s_Bumper5
		FlBumperFadeTarget(5) = 1
		s_Bumper5.timerenabled = True
		DOF 107, DOFPulse
	End If
End Sub
Sub Bumper5Disabled(args) : s_Bumper5.Threshold = 100 : End Sub
Sub Bumper5Enabled(args)  : s_Bumper5.Threshold = 1.5 : End Sub
Sub s_Bumper5_Timer
	FlBumperFadeTarget(5) = 0
End Sub
