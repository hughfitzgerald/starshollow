
'*******************************************
'  ZOPT: User Options
'*******************************************

'----- DMD Options -----
Const UseFlexDMD = 1				'0 = no FlexDMD, 1 = enable FlexDMD
Const FlexONPlayfield = False	   'False = off, True=DMD on playfield ( vrroom overrides this )

'----- VR Room -----
Const VRRoomChoice = 0			  ' 1 - Minimal Room, 2 - Ultra Minimal Room

' Set in Table1_OptionEvent below. Each option's default is the 5th argument
' of its Table1.Option(...) call and nowhere else; the player's saved value
' in <table>.ini wins over it. See docs/settings-and-defaults.md.
Dim LightLevel         ' Room lighting, 0 to 1 (from VPX's day/night slider)
Dim ColorLUT           ' Color desaturation LUT: 1 = normal ... 11 = black'n'white
Dim VolumeDial         ' Overall mechanical sound volume, 0 to 1
Dim BallRollVolume     ' Ball rolling volume, 0 to 1
Dim RampRollVolume     ' Ramp rolling volume, 0 to 1
Dim StagedFlippers     ' 0 = Disabled, 1 = Enabled

' Called when options are tweaked by the player. 
' - 0: game has started, good time to load options and adjust accordingly
' - 1: an option has changed
' - 2: options have been reseted
' - 3: player closed the tweak UI, good time to update staticly prerendered parts
' Table1.Option arguments are: 
' - option name, minimum value, maximum value, step between valid values, default value, unit (0=None, 1=Percent), an optional arry of literal strings
Dim dspTriggered : dspTriggered = False
Sub Table1_OptionEvent(ByVal eventId)
	If eventId = 1 And Not dspTriggered Then dspTriggered = True : DisableStaticPreRendering = True : End If

	' Color Saturation
    ColorLUT = Table1.Option("Color Saturation", 1, 11, 1, 1, 0, _
		Array("Normal", "Desaturated 10%", "Desaturated 20%", "Desaturated 30%", "Desaturated 40%", "Desaturated 50%", _
        "Desaturated 60%", "Desaturated 70%", "Desaturated 80%", "Desaturated 90%", "Black 'n White"))
	if ColorLUT = 1 Then Table1.ColorGradeImage = ""
	if ColorLUT = 2 Then Table1.ColorGradeImage = "colorgradelut256x16-10"
	if ColorLUT = 3 Then Table1.ColorGradeImage = "colorgradelut256x16-20"
	if ColorLUT = 4 Then Table1.ColorGradeImage = "colorgradelut256x16-30"
	if ColorLUT = 5 Then Table1.ColorGradeImage = "colorgradelut256x16-40"
	if ColorLUT = 6 Then Table1.ColorGradeImage = "colorgradelut256x16-50"
	if ColorLUT = 7 Then Table1.ColorGradeImage = "colorgradelut256x16-60"
	if ColorLUT = 8 Then Table1.ColorGradeImage = "colorgradelut256x16-70"
	if ColorLUT = 9 Then Table1.ColorGradeImage = "colorgradelut256x16-80"
	if ColorLUT = 10 Then Table1.ColorGradeImage = "colorgradelut256x16-90"
	if ColorLUT = 11 Then Table1.ColorGradeImage = "colorgradelut256x16-100"

    ' Sound volumes
    VolumeDial = Table1.Option("Mech Volume", 0, 1, 0.01, 0.8, 1)
    BallRollVolume = Table1.Option("Ball Roll Volume", 0, 1, 0.01, 0.5, 1)
	RampRollVolume = Table1.Option("Ramp Roll Volume", 0, 1, 0.01, 0.5, 1)

	' Room brightness
	LightLevel = NightDay/100
'	SetRoomBrightness LightLevel   'Uncomment this line for lightmapped tables.

    ' Staged Flippers
    StagedFlippers = Table1.Option("Staged Flippers", 0, 1, 1, 0, 0, Array("Disabled", "Enabled"))
	glf_machine_vars("game_modes_enabled").Value = Table1.Option("Game Modes Enabled", 0, 1, 1, 1, 0, Array("Disabled", "Enabled"))

	' DMD scene transitions (push, fade...). Off makes every change a
	' straight cut, for players who find the motion distracting. See ZDTX.
	DmdTx_Enabled = (Table1.Option("DMD Transitions", 0, 1, 1, 1, 0, Array("Off", "On")) = 1)


	' GLF's own options: Debug Log, Debug Log Level, Backbox Control
	' Protocol, Virtual Segment DMD, production mode. You will use the
	' first two constantly.
	Glf_Options(eventId)

	' Glf_Options tears bcpController down every time it runs, so the
	' local FlexDMD controller has to be put back afterwards. No-op when
	' the BCP option is On - then GLF connects to Godot instead. See ZFBC.
	FlexBcp_Attach()

	' Rebuild the VR room when options change
	InitVR()

	If eventId = 3 And dspTriggered Then dspTriggered = False : DisableStaticPreRendering = False : End If
End Sub


