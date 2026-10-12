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
'	 DMDBigText "LAUNCH","",77,1  : display text instead of score : "text",image,frames(x17ms),effect  0=solid 1=blink
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

Dim hugeFont, biggerFont, bigFont, largeFont, smallFont, mediumFont, tinyFont, hugeFontDim, biggerFontDim, bigFontDim, largeFontDim, smallFontDim, mediumFontDim, tinyFontDim

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

    Set hugeFont = FlexDMD.NewFont("FlexDMD.Resources.udmd-f14by26.fnt", vbWhite, vbWhite, 0)
    Set biggerFont = FlexDMD.NewFont("FlexDMD.Resources.udmd-f12by24.fnt", vbWhite, vbWhite, 0)
    Set bigFont = FlexDMD.NewFont("FlexDMD.Resources.udmd-f7by13.fnt", vbWhite, vbWhite, 0)
    Set largeFont = FlexDMD.NewFont("FlexDMD.Resources.udmd-f6by12.fnt", vbWhite, vbWhite, 0)
    Set mediumFont = FlexDMD.NewFont("FlexDMD.Resources.udmd-f5by7.fnt", vbWhite, vbWhite, 0)
    Set smallFont = FlexDMD.NewFont("FlexDMD.Resources.udmd-f4by5.fnt", vbWhite, vbWhite, 0)
    Set tinyFont = FlexDMD.NewFont("FlexDMD.Resources.teeny_tiny_pixls-5.fnt", vbWhite, vbWhite, 0)

    Set hugeFontDim = FlexDMD.NewFont("FlexDMD.Resources.udmd-f14by26.fnt", RGB(120, 120, 120), vbWhite, 0)
    Set biggerFontDim = FlexDMD.NewFont("FlexDMD.Resources.udmd-f12by24.fnt", RGB(120, 120, 120), vbWhite, 0)
	Set bigFontDim = FlexDMD.NewFont("FlexDMD.Resources.udmd-f7by13.fnt", RGB(120, 120, 120), vbWhite, 0)
    Set largeFontDim = FlexDMD.NewFont("FlexDMD.Resources.udmd-f6by12.fnt", RGB(120, 120, 120), vbWhite, 0)
    Set mediumFontDim = FlexDMD.NewFont("FlexDMD.Resources.udmd-f5by7.fnt", RGB(120, 120, 120), vbWhite, 0)
    Set smallFontDim = FlexDMD.NewFont("FlexDMD.Resources.udmd-f4by5.fnt", RGB(120, 120, 120), vbWhite, 0)
    Set tinyFontDim = FlexDMD.NewFont("FlexDMD.Resources.teeny_tiny_pixls-5.fnt", RGB(120, 120, 120), vbWhite, 0)
	
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

' Word-wraps text so no line is longer than maxChars, joining the lines
' with vbLf. A single word longer than maxChars gets a line to itself
' and overflows it - DMDBigTextFit treats that as "does not fit".
Function DMDWrapText(text, maxChars)
	Dim words, w, line, out
	words = Split(Trim(text), " ")
	line = ""
	out = ""
	For Each w In words
		If w <> "" Then
			If line = "" Then
				line = w
			ElseIf Len(line) + 1 + Len(w) <= maxChars Then
				line = line & " " & w
			Else
				If out = "" Then out = line Else out = out & vbLf & line
				line = w
			End If
		End If
	Next
	If out = "" Then out = line Else out = out & vbLf & line
	DMDWrapText = out
End Function

' True when every line of wrapped text is at most maxChars long and
' there are at most maxLines of them.
Function DMDTextFits(wrapped, maxChars, maxLines)
	Dim lines, l
	lines = Split(wrapped, vbLf)
	DMDTextFits = False
	If UBound(lines) + 1 > maxLines Then Exit Function
	For Each l In lines
		If Len(l) > maxChars Then Exit Function
	Next
	DMDTextFits = True
End Function

' Picks the biggest font that fits text, wrapping it onto as many lines
' as that font allows. rows is a list of Array(font, maxChars, maxLines),
' biggest font first; past the last row, text gets the last row's font
' wrapped to its width and is presumed to fit.
'
' Once a font fits, the wrap width is narrowed for as long as the line
' count holds, so two lines come out roughly even rather than one long
' line and a stub.
Sub DMDBigTextFit(ByRef text, ByRef font, rows)
	Dim row, wrapped, w, n
	For Each row In rows
		wrapped = DMDWrapText(text, row(1))
		If DMDTextFits(wrapped, row(1), row(2)) Then
			n = UBound(Split(wrapped, vbLf))
			w = row(1)
			Do While w > 1
				If UBound(Split(DMDWrapText(text, w - 1), vbLf)) <> n Then Exit Do
				If Not DMDTextFits(DMDWrapText(text, w - 1), w - 1, n + 1) Then Exit Do
				w = w - 1
			Loop
			text = DMDWrapText(text, w)
			Set font = row(0)
			Exit Sub
		End If
	Next
	row = rows(UBound(rows))
	text = DMDWrapText(text, row(1))
	Set font = row(0)
End Sub

' Font limits for the full 128x32 DMD.
Function DMDBigTextRowsFull()
	DMDBigTextRowsFull = Array( _
		Array(hugeFont, 8, 1), _
		Array(biggerFont, 9, 1), _
		Array(bigFont, 16, 2), _
		Array(mediumFont, 21, 3))
End Function

' Font limits for the 100x32 text frame beside an image.
Function DMDBigTextRowsBeside()
	DMDBigTextRowsBeside = Array( _
		Array(hugeFont, 6, 1), _
		Array(biggerFont, 7, 1), _
		Array(bigFont, 12, 2), _
		Array(largeFont, 14, 2), _
		Array(mediumFont, 17, 3), _
		Array(smallFont, 20, 5))
End Function

' Where the text frame starts when there is an image: the image sits at
' the left edge, and the frame overlaps its last few (blank) columns.
Const DMDBigTextImageInset = 28

Dim DMDTextOnScore
Dim DMDTextDisplayTime
Dim DMDTextEffect
' The group the last DMDBigText put on the stage, so the next call can
' replace it instead of stacking a second copy on top.
Dim DMDBigTextGroup
' image is a file in the DMD project folder, or "" for text alone. With
' an image, it sits at the left and the text is fitted into the 100
' pixels to its right; without one the text gets the whole DMD.
'
' Time is in frames (x17ms), as in the header; 0 or less means 2s.
Sub DMDBigText(text,image,Time,effect)
	' If UseFlexDMD = 0 Then Exit Sub
	' DMDTextOnScore = text
	' DMDTextDisplayTime = FLEXframe + Time
	
	' DMDTextEffect = effect
    Dim jp, af, seq
    Set jp = FlexDMD.NewGroup("Jackpot")
    jp.SetSize 128, 32
    jp.ClearBackground = True
    Dim lbl, font, shown, frame
    shown = text
    If image <> "" Then
        jp.AddActor FlexDMD.NewImage("Image", image)
        Set frame = FlexDMD.NewGroup("TextFrame")
        frame.SetBounds DMDBigTextImageInset, 0, 128 - DMDBigTextImageInset, 32
        jp.AddActor frame
        DMDBigTextFit shown, font, DMDBigTextRowsBeside()
    Else
        Set frame = jp
        DMDBigTextFit shown, font, DMDBigTextRowsFull()
    End If
    Set lbl = FlexDMD.NewLabel("Text", font, shown)
    lbl.AutoPack = False
    lbl.FillParent = True
    lbl.Alignment = FlexDMD_Align_Center
    frame.AddActor lbl
    If effect = 1 Then
        Set af = lbl.ActionFactory
        lbl.AddAction af.Blink(0.15, 0.1, 6)
    End If
    ' Show the scene on top of the stage, then remove it after Time
    Dim secs : secs = Time * 0.017
    If secs <= 0 Then secs = 2
    Set af = jp.ActionFactory
    Set seq = af.Sequence()
    seq.Add af.Wait(secs)
    seq.Add af.RemoveFromParent()
    jp.AddAction seq
    If IsObject(DMDBigTextGroup) Then FlexDMD.Stage.RemoveActor DMDBigTextGroup
    FlexDMD.Stage.AddActor jp
    Set DMDBigTextGroup = jp
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
