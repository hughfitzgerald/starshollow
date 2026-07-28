
'*******************************************
'  ZINI: Table Initialization and Exiting
'*******************************************
' Deleted vs. the original:
'   ETBall1..5 creation  - Glf_Init calls DestroyBall and makes its own
'   vpmMapLights AllLamps - ROM lamp mapping, meaningless with no ROM
'   For Each xx In GI     - GI is now a glf_lights show
'   PlayerScore/BonusX    - GLF player vars
'   Flex_Init / ShowScene - FlexDMD removed
'   queue.QueueEmpty      - ZQUE removed
'   ShadowDT loop         - no drop targets on this table

LoadCoreFiles
Sub LoadCoreFiles
	On Error Resume Next
	ExecuteGlobal GetTextFile("core.vbs")   'still needed for vpmTimer, DOF consts, cvpmMagnet
	If Err Then MsgBox "Can\'t open core.vbs"
	On Error GoTo 0
End Sub


Sub Table1_Init
	' GLF - ConfigureGlfDevices must run first; Glf_Init consumes it
	ConfigureGlfDevices()
	Glf_Init(Table1)

	' Turn off the Flupper bumper lights
	FlBumperFadeTarget(1) = 0
	FlBumperFadeTarget(2) = 0
	FlBumperFadeTarget(3) = 0
	FlBumperFadeTarget(4) = 0
	FlBumperFadeTarget(5) = 0

	' VPW physics init - unchanged
	InitRolling()
	InitPolarity()
	InitSlingCorrection()

	InitVR()
End Sub


Sub Table1_Exit
	Glf_Exit()
End Sub

Sub Table1_Paused
End Sub

Sub Table1_UnPaused
End Sub
