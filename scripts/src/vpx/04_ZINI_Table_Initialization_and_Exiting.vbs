
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
	Flex_Init()
	' FlexDmd_ShowSlide "welcome", Null
	LoadB2S()

	' GLF slide/widget player -> FlexDMD, in place of a Godot media
	' controller over BCP. Must come after Flex_Init (the scenes have to
	' exist before a slide can render) and after Glf_Init (Glf_Options
	' clears bcpController on its way through). See ZFBC.
	FlexBcp_Attach()

	' TEMPORARY diagnostics - delete this line and src/game/_diagnostics.vbs
	' once the table is starting games reliably.
	GlfDiag_Init()
End Sub


Sub Table1_Exit
	Glf_Exit()
	'Close flexDMD
	If UseFlexDMD = 0 Then Exit Sub
	If Not FlexDMD Is Nothing Or VRRoom = 0 Then
		FlexDMD.Show = False
		FlexDMD.Run = False
		FlexDMD = Null
	End If
    If Not B2SController Is Nothing Then
        B2SController.Stop
        Set B2SController = Nothing
    End If
End Sub

Sub Table1_Paused
End Sub

Sub Table1_UnPaused
End Sub
