'*******************************************
'  ZDMD: FlexDMD
'*******************************************
'
' DMDTimer @17ms
' StartFlex with the intro @ Table1_Init
' Startgame ( KeyDown : PlungerKey ) calls the Game DMD to start if intro is on
' Make a copy of VPWExampleTableDMD folder, rename and paste into Visual Pinball\Tables\"InsertTableNameDMD"
' Update .ProjectFolder = ".\VPWExampleTableDMD\" to DMD folder name from previous step
' Update DMDTimer_Timer Sub to allow DMD to update remaining balls and credit: find ("Ball") and ("Credit")
'
' Commands :
'	 DMDBigText "LAUNCH",77,1  : display text instead of score : "text",frames(x17ms),effect  0=solid 1=blink
'	DMDBGFlash=15 : will light up background with new image for xx frames
'	DMDFire=Flexframe+50  : will animate the font for 50 frames
'
' For another demo, see the following from the FlexDMD developer:
'   https://github.com/vbousquet/flexdmd/tree/master/FlexDemo
'
' --- CHANGES FOR GLF -------------------------------------------------
' 1. PlayerScore(i) / CurrentPlayer no longer exist - GLF owns player
'    state now. The scoreboard (DmdTick_Score, in display_scenes.vbs)
'    reads GetPlayerStateForPlayer(n, "score") / Getglf_currentPlayerNumber()
'    instead. See Score2Num() below for the False-until-first-set case.
' 2. Nothing in here listens for GLF events. ZFBC hands GLF a stand-in
'    bcpController, so the slide player and widget player drive the DMD
'    straight from mode config - .Slide = "score", .Widget = "ball_save".
'    See the note at the bottom.
' 3. No scenes are built here any more, and there is no FlexMode. What
'    the DMD can show is listed in src/game/dmd/display_config.vbs, and
'    the two scenes that are real code live in display_scenes.vbs. This
'    file is now the FlexDMD device setup and the render timer, nothing
'    else.
' 4. Everything else (ShowScene, DMDBigText, FlexFlasher) is untouched
'    from the VPW original, bar ShowScene losing its mode argument.


Dim FlexDMD	 'This is the FlexDMD object
Dim FlexFrame   'This is the current Frame count. It increments every time DMDTimer_Timer is run

Const FlexDMD_RenderMode_DMD_GRAY = 0, _
FlexDMD_RenderMode_DMD_GRAY_4 = 1, _
FlexDMD_RenderMode_DMD_RGB = 2, _
FlexDMD_RenderMode_SEG_2x16Alpha = 3, _
FlexDMD_RenderMode_SEG_2x20Alpha = 4, _
FlexDMD_RenderMode_SEG_2x7Alpha_2x7Num = 5, _
FlexDMD_RenderMode_SEG_2x7Alpha_2x7Num_4x1Num = 6, _
FlexDMD_RenderMode_SEG_2x7Num_2x7Num_4x1Num = 7, _
FlexDMD_RenderMode_SEG_2x7Num_2x7Num_10x1Num = 8, _
FlexDMD_RenderMode_SEG_2x7Num_2x7Num_4x1Num_gen7 = 9, _
FlexDMD_RenderMode_SEG_2x7Num10_2x7Num10_4x1Num = 10, _
FlexDMD_RenderMode_SEG_2x6Num_2x6Num_4x1Num = 11, _
FlexDMD_RenderMode_SEG_2x6Num10_2x6Num10_4x1Num = 12, _
FlexDMD_RenderMode_SEG_4x7Num10 = 13, _
FlexDMD_RenderMode_SEG_6x4Num_4x1Num = 14, _
FlexDMD_RenderMode_SEG_2x7Num_4x1Num_1x16Alpha = 15, _
FlexDMD_RenderMode_SEG_1x16Alpha_1x16Num_1x7Num = 16

Const FlexDMD_Align_TopLeft = 0, _
FlexDMD_Align_Top = 1, _
FlexDMD_Align_TopRight = 2, _
FlexDMD_Align_Left = 3, _
FlexDMD_Align_Center = 4, _
FlexDMD_Align_Right = 5, _
FlexDMD_Align_BottomLeft = 6, _
FlexDMD_Align_Bottom = 7, _
FlexDMD_Align_BottomRight = 8


Dim FontScoreInactive
Dim FontScoreActive
Dim FontBig1
Dim FontBig2
Dim FontBig3

Sub Flex_Init
	If UseFlexDMD = 0 Then Exit Sub
	Set FlexDMD = CreateObject("FlexDMD.FlexDMD")
	If FlexDMD Is Nothing Then
		MsgBox "No FlexDMD found. This table will Not run without it."
		Exit Sub
	End If
	SetLocale(1033)
	With FlexDMD
		.GameName = cGameName
		.TableFile = Table1.Filename & ".vpx"
		.Color = RGB(255, 88, 32)
		.RenderMode = FlexDMD_RenderMode_DMD_RGB
		.Width = 128
		.Height = 32
		.ProjectFolder = "./StarsHollowDMD/"
		.Clear = True
		.Run = True
	End With
	
	' Build everything the config asked for. CreateFlexDmdDisplay is the
	' list itself (src/game/dmd/display_config.vbs); FlexDmd_BuildScenes
	' (ZFBC) walks it and constructs a scene for every GIF, image and
	' Builder in it.
	CreateFlexDmdDisplay()
	FlexDmd_BuildScenes()
	
	' Nothing is hooked to a GLF event from here - the slide and widget
	' players do that from mode config now. See the note at the bottom of
	' this file.
	
End Sub

'--------------------------------------------
' Easy wrapper to play a FlexDMD scene
'
' flexScene: FlexDMD.Group to play
' render: The render mode to use
'
' VPW's version took a third "mode" argument and assigned it to a global
' FlexMode, which DMDTimer_Timer switched on to pick a per-frame updater.
' A scene's updater is now a property of the scene itself - the .Ticker
' on its config entry - so there is no mode number to pass. Go through
' FlexDmd_Present (ZFBC) rather than calling this directly: it is what
' keeps "what is on screen" and "whose ticker runs" the same answer.
'--------------------------------------------
Sub ShowScene(flexScene, render) 'Easy wrapper to play a FlexDMD scene
	If UseFlexDMD = 0 Then Exit Sub

	FlexDMD.LockRenderThread
	FlexDMD.RenderMode = render
	FlexDMD.Stage.RemoveAll
	FlexDMD.Stage.AddActor flexScene
	If VRroom > 0 Or FlexONPlayfield Then FlexDMD.Show = False Else FlexDMD.Show = True
	FlexDMD.UnlockRenderThread
End Sub

Dim DMDTextOnScore
Dim DMDTextDisplayTime
Dim DMDTextEffect
Sub DMDBigText(text,Time,effect)
	If UseFlexDMD = 0 Then Exit Sub
	DMDTextOnScore = text
	DMDTextDisplayTime = FLEXframe + Time
	
	DMDTextEffect = effect
End Sub

Sub FlexFlasher 'Flex on vrroom and playfield runs this one
	Dim DMDp
	DMDp = FlexDMD.DMDColoredPixels
	If Not IsEmpty(DMDp) Then
		DMDWidth = FlexDMD.Width
		DMDHeight = FlexDMD.Height
		DMDColoredPixels = DMDp
	End If
End Sub

' GLF: GetPlayerStateForPlayer / GetPlayerState return False (not 0)
' until something has actually set the key - which won't happen until
' you have a score mode. Score2Num keeps the DMD showing "0" instead of
' erroring or printing "False" in the meantime.
Function Score2Num(v)
	If v = False Then
		Score2Num = 0
	Else
		Score2Num = v
	End If
End Function

Dim DMDFire
' Dim DMDBGFlash
Sub DMDTimer_Timer 'Main FlexDMD Timer
	If UseFlexDMD = 0 Then Exit Sub
	If VRroom > 0 Or FlexONPlayfield Then FlexFlasher
	
	FlexFrame = FlexFrame + 1
	FlexDMD.LockRenderThread
	
	' Whatever scene is on the DMD gets its per-frame update here, if it
	' asked for one - the scoreboard refreshing scores and drawing widget
	' text, the intro revealing its logo - and then so does every layer
	' attached on top of it. VPW switched on a FlexMode number; the
	' scene's config entry names its own .Ticker instead, so adding a
	' scene never means adding a Case here.
	FlexDmd_Tick()
	
	FlexDMD.UnlockRenderThread
End Sub


'*******************************************
'  Triggering the DMD from GLF
'*******************************************
' Nothing here listens for GLF events. Every slide and widget is listed
' in src/game/dmd/display_config.vbs and reached through the slide player
' and widget player, with the events chosen in mode config:
'
'   base            score slide, launch + ball saved widgets
'   multiball       multiball slide, ball 1/2 locked widgets
'   skillshots      skillshot widget
'   extra_ball      extra ball lit + extra ball widgets
'   dance_marathon  dance marathon + complete widgets, countdown slide
'
' A slide or widget player only listens while its mode is running, which
' is the one thing to watch when adding more: put the entry in a mode
' that is actually up when the event fires. Two cases worth knowing:
'
'   - Devices deactivate on mode_X_stopping at the mode's priority minus
'     one, and mode_X_stopped is not dispatched until after that. So a
'     mode cannot react to its own _stopped event; use _stopping, which
'     the player still hears (it registers at the mode's own priority),
'     or put the entry in a mode that outlives it.
'   - Only the slide player forwards the triggering event's kwargs. A
'     widget carrying live data is not possible; the dance marathon
'     countdown is a slide for exactly that reason.
'
' If you ever do need a scene on an event no running mode can see, the
' hand-wired route still works:
'
'     AddPinEventListener "some_event", "dmd_key", "SomeCallback", 100, Null
'
' registered at the end of Flex_Init (it needs Glf_Init to have run), with
' a matching Function SomeCallback(args). Prefer mode config.
