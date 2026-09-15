'*******************************************
'  DMD scenes - the ones that are real code
'*******************************************
'
' Everything the DMD can show is listed in display_config.vbs. Most
' entries are a GIF or a line of text and need nothing more than that
' one line. The two below are not: they build a stage full of labels and
' then push live data into it every frame, so they name a Builder and a
' Ticker from the config and the actual code lives here.
'
' A Builder runs once, from Flex_Init, and hands its scene back through
' the entry:
'
'     Sub DmdBuild_Thing(entry)
'         Dim g : Set g = FlexDMD.NewGroup("Thing")
'         ' ...
'         entry.SetScene g
'     End Sub
'
' A Ticker runs on every DMD frame (17ms) while its entry is the one on
' screen, from inside FlexDMD's render lock - DMDTimer_Timer takes the
' lock, calls FlexDmd_Tick, and releases it. So a ticker must not lock
' the render thread itself, and must not do anything slow.
'
' Both take a single argument, matching the GetRef(name)(args) callback
' convention GLF uses everywhere.


'*******************************************
'  score - the scoreboard
'*******************************************
' Four player scores down the left, a scrolling title and the current
' player's score in a clipped panel on the right, ball number along the
' bottom. This is also the only scene that draws DMDBigText, which is
' what makes widgets an overlay on the scoreboard and nothing else.

Sub DmdBuild_Score(entry)
    Dim i, label

    Set FontScoreActive = FlexDMD.NewFont("TeenyTinyPixls5.fnt", vbWhite, vbWhite, 0)
    Set FontScoreInactive = FlexDMD.NewFont("TeenyTinyPixls5.fnt", RGB(100, 100, 100), vbWhite, 0)
    Set FontBig1 = FlexDMD.NewFont("sys80.fnt", vbWhite, vbBlack, 0)
    Set FontBig2 = FlexDMD.NewFont("sys80_1.fnt", vbWhite, vbBlack, 0)
    Set FontBig3 = FlexDMD.NewFont("sys80.fnt", RGB ( 10,10,10) ,vbBlack, 0)

    Dim g : Set g = FlexDMD.NewGroup("Score")
    With g
        For i = 1 To 4
            Set label = FlexDMD.NewLabel("Score_" & i, FontScoreInactive, "0")
            label.SetAlignedPosition 45, 1 + (i - 1) * 6, FlexDMD_Align_TopRight
            .AddActor label
        Next
        .AddActor FlexDMD.NewFrame("VSeparator")
        .GetFrame("VSeparator").Thickness = 1
        .GetFrame("VSeparator").SetBounds 45, 0, 1, 32
        .AddActor FlexDMD.NewGroup("Content")
        .GetGroup("Content").Clip = True
        .GetGroup("Content").SetBounds 47, 0, 81, 32
    End With

    Dim title
    Set title = FlexDMD.NewLabel("TitleScroller", FontScoreActive, ">>> Stars Hollow Showdown <<<")
    Dim af
    Set af = title.ActionFactory
    Dim list
    Set list = af.Sequence()
    list.Add af.MoveTo(128, 2, 0)
    list.Add af.Wait(0.5)
    list.Add af.MoveTo( - 128, 2, 5.0)
    list.Add af.Wait(3.0)
    title.AddAction af.Repeat(list, - 1)
    g.GetGroup("Content").AddActor title

    Set title = FlexDMD.NewLabel("Title2", FontBig3, " ")
    title.SetAlignedPosition 42, 16, FlexDMD_Align_Center
    g.GetGroup("Content").AddActor title

    Set title = FlexDMD.NewLabel("Title", FontBig1, " ")
    title.SetAlignedPosition 42, 16, FlexDMD_Align_Center
    g.GetGroup("Content").AddActor title

    g.GetGroup("Content").AddActor FlexDMD.NewLabel("Ball", FontScoreActive, "Ball 1")
    g.GetGroup("Content").AddActor FlexDMD.NewLabel("Credit", FontScoreActive, "Credit 5")

    entry.SetScene g
End Sub


Sub DmdTick_Score(args)
    Dim i, label

    ' GLF: was "If (FlexFrame Mod 64) = 0 Then CurrentPlayer = 1 + (CurrentPlayer Mod 4)"
    ' Turn advance is GLF's job now (Getglf_currentPlayerNumber tracks it);
    ' nothing to do here.
    If (FlexFrame Mod 16) = 0 Then
        For i = 1 To 4
            Set label = FlexDMD.Stage.GetLabel("Score_" & i)
            If i = (Getglf_currentPlayerNumber() + 1) Then    'GLF: was "If i = CurrentPlayer Then"
                label.Font = FontScoreActive
            Else
                label.Font = FontScoreInactive
            End If
            label.Text = FormatNumber(Score2Num(GetPlayerStateForPlayer(i - 1, "score")), 0)   'GLF: was "PlayerScore(i)"
            label.SetAlignedPosition 45, 1 + (i - 1) * 6, FlexDMD_Align_TopRight
        Next
    End If

    ' If DMDBGFlash > 0 Then
    ' 	DMDBGFlash = DMDBGFlash - 1
    ' 	FlexDMD.Stage.GetImage("bg2").visible = True
    ' Else
    ' 	FlexDMD.Stage.GetImage("bg2").visible = False
    ' End If

    If DMDfire > FLEXframe And (FlexFrame Mod 8) > 3 Then
        FlexDMD.Stage.GetLabel("Title").font = FontBig2
    Else
        FlexDMD.Stage.GetLabel("Title").font = FontBig1
    End If

    If DMDTextDisplayTime > FLEXframe Then
        If DMDTextEffect = 1 And (FLEXframe Mod 20) > 10 Then
            FlexDMD.Stage.GetLabel("Title").Text = " "
            FlexDMD.Stage.GetLabel("Title2").Text = " "
        Else
            FlexDMD.Stage.GetLabel("Title").Text = DMDTextOnScore
            FlexDMD.Stage.GetLabel("Title2").Text = DMDTextOnScore
        End If
    Else
        'GLF: was "PlayerScore(CurrentPlayer)" - GetPlayerState with no
        'index always reads the CURRENT player, so no index is needed.
        FlexDMD.Stage.GetLabel("Title").Text = FormatNumber(Score2Num(GetPlayerState("score")), 0)
        FlexDMD.Stage.GetLabel("Title2").Text = FormatNumber(Score2Num(GetPlayerState("score")), 0)
    End If

    FlexDMD.Stage.GetLabel("Title").SetAlignedPosition 42, 16, FlexDMD_Align_Center
    FlexDMD.Stage.GetLabel("Title2").SetAlignedPosition 43, 17, FlexDMD_Align_Center
    FlexDMD.Stage.GetLabel("Ball").SetAlignedPosition 0, 33, FlexDMD_Align_BottomLeft
    FlexDMD.Stage.GetLabel("Credit").SetAlignedPosition 81, 33, FlexDMD_Align_BottomRight
    FlexDMD.Stage.GetLabel("Ball").Text = "Ball " & GetPlayerState("ball")
    'Update with your own code for Credits
    FlexDMD.Stage.GetLabel("Credit").Text = "Credit " & glf_machine_vars("credits").GetValue()
End Sub


'*******************************************
'  welcome - the attract intro
'*******************************************
' The logo is hidden at build time and revealed by the ticker at an
' absolute frame number, so this scene only plays correctly from a reset
' frame counter - hence .ResetFrame = True on its config entry.

Sub DmdBuild_Welcome(entry)
    Dim g : Set g = FlexDMD.NewGroup("Welcome")
    With g
        .AddActor FlexDMD.NewImage("logo","gilmore_girls_logo_128x32.png")
        .Getimage("logo").visible = False
    End With
    entry.SetScene g
End Sub


Sub DmdTick_Welcome(args)
    If FlexFrame = 88 Then FlexDMD.Stage.Getimage("logo").visible = True

    If FlexFrame > 110 Then
        If (FlexFrame Mod 32) = 10 Then FlexDMD.Stage.Getimage("logo").visible = True
        If (FlexFrame Mod 32) = 1 Then FlexDMD.Stage.Getimage("logo").visible = False
    End If
End Sub


Sub DmdBuild_HighScore(entry)
    Set FontBig1 = FlexDMD.NewFont("sys80.fnt", vbWhite, vbBlack, 0)

    Dim text, initials, time
    Dim g : Set g = FlexDMD.NewGroup("HighScore")
    With g
        ' one spot with the text "P1 INITIALS" or "P2 INITIALS" etc
        Set text = FlexDMD.NewLabel("high_score_text", FontBig1, "P1 INITIALS")
        text.SetAlignedPosition 64, 8, FlexDMD_Align_Center
        .AddActor text

        ' one spot with the letters for the initials
        Set initials = FlexDMD.NewLabel("high_score_initials", FontBig1, "")
        initials.SetAlignedPosition 32, 16, FlexDMD_Align_Center
        .AddActor initials
        
        ' ' one spot for the time left before timeout
        ' Set time = FlexDMD.NewLabel("high_score_time", FontBig1, "")
        ' time.SetAlignedPosition 64, 24, FlexDMD_Align_Center
        ' .AddActor time
    End With
    entry.SetScene g
End Sub

Sub DmdTick_HighScore(args)
    Dim text, initials, time
    Set text = FlexDMD.Stage.GetLabel("high_score_text")
    text.Text = "P" & glf_machine_vars("high_score_player_num").GetValue() & " INITIALS"
    Set initials = FlexDMD.Stage.GetLabel("high_score_initials")
    initials.Text = glf_machine_vars("high_score_initials").GetValue() & AZLookup(glf_machine_vars("high_score_initials_index").GetValue())
    ' Set time = FlexDMD.Stage.GetLabel("high_score_time")
    ' time.Text = "00:00"
End Sub

Sub DmdBuild_Bonus(entry)
    Set FontBig1 = FlexDMD.NewFont("sys80.fnt", vbWhite, vbBlack, 0)
    Set FontScoreActive = FlexDMD.NewFont("TeenyTinyPixls5.fnt", vbWhite, vbWhite, 0)

    Dim text, score
    Dim g : Set g = FlexDMD.NewGroup("Bonus")
    With g
        ' one spot with bonus text
        Set text = FlexDMD.NewLabel("bonus_text", FontScoreActive, "")
        .AddActor text

        ' one spot with bonus score
        Set score = FlexDMD.NewLabel("bonus_score", FontBig1, "")
        .AddActor score
    End With
    entry.SetScene g
End Sub

Sub DmdTick_Bonus(args)
    Dim text, score
    Set text = FlexDMD.Stage.GetLabel("bonus_text")
    text.Text = GetPlayerState("bonus_display_text")
    text.SetBounds 0, 1, 128, 8
    text.Alignment = FlexDMD_Align_Center
    Set score = FlexDMD.Stage.GetLabel("bonus_score")
    score.Text = GetPlayerState("bonus_display_score")
    score.SetBounds 0, 12, 128, 16
    score.Alignment = FlexDMD_Align_Center
End Sub

Sub DmdBuild_Mode(entry)
    Set FontBig1 = FlexDMD.NewFont("sys80.fnt", vbWhite, vbBlack, 0)
    Set FontScoreActive = FlexDMD.NewFont("TeenyTinyPixls5.fnt", vbWhite, vbWhite, 0)

    Dim text, score, instructions, timer
    Dim g : Set g = FlexDMD.NewGroup("Mode")
    With g
        ' one spot with mode text
        Set text = FlexDMD.NewLabel("mode_text", FontScoreActive, "")
        .AddActor text

        ' one spot with mode score
        Set score = FlexDMD.NewLabel("mode_score", FontBig1, "")
        .AddActor score

        ' one spot with mode instructions
        Set instructions = FlexDMD.NewLabel("mode_instructions", FontScoreActive, "")
        .AddActor instructions

        ' one spot with mode timer
        Set timer = FlexDMD.NewLabel("mode_timer", FontScoreActive, "")
        .AddActor timer
    End With
    entry.SetScene g
End Sub

Sub DmdTick_Mode(args)
    Dim text, score, instructions, timer
    
    Set text = FlexDMD.Stage.GetLabel("mode_text")
    text.Text = GetPlayerState("mode_display_text")
    text.SetBounds 0, 1, 128, 8
    text.Alignment = FlexDMD_Align_Center

    Set score = FlexDMD.Stage.GetLabel("mode_score")
    score.Text = FormatNumber(GetPlayerState("mode_display_score"), 0)
    score.SetBounds 0, 9, 128, 14
    score.Alignment = FlexDMD_Align_Center

    Set instructions = FlexDMD.Stage.GetLabel("mode_instructions")
    instructions.Text = GetPlayerState("mode_display_instructions")
    instructions.SetBounds 0, 24, 128, 8
    instructions.Alignment = FlexDMD_Align_Center

    Set timer = FlexDMD.Stage.GetLabel("mode_timer")
    timer.Text = GetPlayerState("mode_display_timer")
    timer.SetBounds 0, 1, 128, 8
    timer.Alignment = FlexDMD_Align_Right
End Sub


Sub DmdBuild_ScoreCentralLayout(entry)
    Set FontBig1 = FlexDMD.NewFont("sys80.fnt", vbWhite, vbBlack, 0)
    Set FontScoreActive = FlexDMD.NewFont("TeenyTinyPixls5.fnt", vbWhite, vbWhite, 0)

    Dim text, score, instructions
    Dim g : Set g = FlexDMD.NewGroup("Mode")
    With g
        ' one spot with mode text
        Set text = FlexDMD.NewLabel("mode_text", FontScoreActive, "")
        .AddActor text

        ' one spot with mode score
        Set score = FlexDMD.NewLabel("mode_score", FontBig1, "")
        .AddActor score

        ' one spot with mode instructions
        Set instructions = FlexDMD.NewLabel("mode_instructions", FontScoreActive, "")
        .AddActor instructions
    End With
    entry.SetScene g
End Sub

Sub DmdTick_ScoreCentralLayout(args)
    Dim text, score, instructions
    
    Set text = FlexDMD.Stage.GetLabel("mode_text")
    text.Text = glf_machine_vars("display_top_small_text").GetValue()
    text.SetBounds 0, 1, 128, 8
    text.Alignment = FlexDMD_Align_Center

    Set score = FlexDMD.Stage.GetLabel("mode_score")
    score.Text = glf_machine_vars("display_middle_large_text").GetValue()
    score.SetBounds 0, 9, 128, 14
    score.Alignment = FlexDMD_Align_Center

    Set instructions = FlexDMD.Stage.GetLabel("mode_instructions")
    instructions.Text = glf_machine_vars("display_bottom_small_text").GetValue()
    instructions.SetBounds 0, 24, 128, 8
    instructions.Alignment = FlexDMD_Align_Center
End Sub


'*******************************************
'  mystery - grid random selector
'*******************************************
' Adapted from the FlexDMD grid-selector prototype in
' scripts/src/game/script.vbs. That version ran its own timer and
' rebuilt the whole scene from scratch every time it played. Here the
' scene is built once (DmdBuild_Mystery, at Flex_Init like every other
' Builder) and the animation is driven entirely by FlexFrame in the
' ticker, the same trick DmdTick_Welcome uses for its logo reveal.
' .ResetFrame = True on the config entry zeroes FlexFrame each time this
' slide is shown, so the jump sequence replays from the start on every
' play with no state of its own that needs resetting by hand.
'
' itemsArray, cols, rows, targetIdx, Z, W match script.vbs's
' StartGridSelection parameters:
'   itemsArray  strings to show, up to cols*rows of them
'   cols, rows  grid dimensions (fixed at 2x2 - see DmdBuild_Mystery)
'   targetIdx   the cell the box settles on (0-based, into itemsArray)
'   Z           number of random jumps before settling
'   W           DMD frames (17ms each) to hold each jump
' They're plain globals a real caller is expected to set before this
' slide is shown; test values are assigned in the Builder until that
' wiring exists.
'
' itemsArray is read fresh every tick (DmdTick_Mystery), not just once
' at build time - the pool of possible items is expected to be bigger
' than 4 and different on every play, so whatever sets these globals can
' hand over a brand new itemsArray/targetIdx right before showing this
' slide and the grid will pick it up immediately, no rebuild needed.
' Only cols/rows are actually fixed - the grid shape itself isn't meant
' to change play to play.
Dim itemsArray, cols, rows, targetIdx, Z, W

' Reserved at the top of the DMD for the "MYSTERY" title, above the grid.
Const MysteryGridTop = 8

' Font the currently-highlighted item uses vs. every other item. There is
' no .Tint property on a Label - a label's color is baked into the Font
' it was built with (see NewFont's tint args) - so telling the picked
' item apart means swapping which pre-built Font it uses, the same way
' DmdTick_Score swaps FontScoreActive/FontScoreInactive.
Dim FontMysteryDim, FontMysteryHighlight

' The box actor itself, held onto from Build. Every other ticker in this
' file re-fetches its actors by name every frame (FlexDMD.Stage.GetLabel
' etc.), which works fine for labels/images - but GetFrame is never
' called that way anywhere in this codebase, only as
' newlyCreatedGroup.GetFrame(name) immediately after adding it (see
' VSeparator above). Rather than assume FlexDMD.Stage.GetFrame behaves
' the same way, just keep the reference script.vbs itself used
' (selectorBox, a module-level variable) and skip the lookup entirely.
Dim MysteryBoxFrame

Sub DmdBuild_Mystery(entry)
    ' TODO: replace with whatever mode code decides the award. cols/rows
    ' only matter at build time - the grid itself is a fixed 2x2 (one
    ' quadrant per slot), giving each item a full 64x12px cell, plenty of
    ' room to spell things out instead of the 4-column abbreviations this
    ' needed before. itemsArray/targetIdx/Z/W are read fresh every tick
    ' instead (see the comment above), so swapping in a new list is just
    ' assigning itemsArray before this slide is shown.
    itemsArray = Array("10,000", "EXTRA BALL", "50,000", "JACKPOT")
    cols = 2
    rows = 2
    targetIdx = 2
    Z = 20
    W = 6

    Dim font : Set font = FlexDMD.NewFont("TeenyTinyPixls5.fnt", vbWhite, vbWhite, 0)
    Set FontMysteryDim = FlexDMD.NewFont("TeenyTinyPixls5.fnt", RGB(100, 100, 100), RGB(100, 100, 100), 0)
    Set FontMysteryHighlight = FlexDMD.NewFont("TeenyTinyPixls5.fnt", vbWhite, vbWhite, 0)

    Dim cellWidth : cellWidth = 128 / cols
    Dim cellHeight : cellHeight = (32 - MysteryGridTop) / rows

    Dim g : Set g = FlexDMD.NewGroup("Mystery")
    With g
        Dim title : Set title = FlexDMD.NewLabel("mystery_title", font, "MYSTERY")
        title.SetAlignedPosition 64, 0, FlexDMD_Align_Top
        .AddActor title

        ' Item labels start blank - DmdTick_Mystery stamps in whatever
        ' itemsArray currently holds on the very first frame, so a
        ' rebuild is never needed just to show a different list.
        '
        ' SetBounds + .Alignment (DmdTick_Bonus/DmdTick_Mode's approach)
        ' rather than SetAlignedPosition (DmdBuild_Score/HighScore's) -
        ' at a 12px-tall cell, SetAlignedPosition's Center consistently
        ' sat the text near the bottom of its cell instead of centered,
        ' visible enough at this scale that it looked misaligned with
        ' the box around it. Giving the label the same rectangle the box
        ' insets from, and letting .Alignment center within it, keeps
        ' the two from being able to disagree.
        Dim i, col, row, label
        For i = 0 To (cols * rows) - 1
            col = i Mod cols
            row = i \ cols
            Set label = FlexDMD.NewLabel("mystery_item_" & i, FontMysteryDim, "")
            label.SetBounds col * cellWidth, MysteryGridTop + row * cellHeight, cellWidth, cellHeight
            label.Alignment = FlexDMD_Align_Center
            .AddActor label
        Next

        ' The "box" - an actual rectangle outline rather than the bracket
        ' label script.vbs used, which would now collide with the
        ' full-length item text sitting where it used to draw "[ ]".
        ' Thin while jumping, thick once it settles - the same
        ' NewFrame/.Thickness/.SetBounds API DmdBuild_Score already uses
        ' for its score/title separator, so no new/unverified property.
        Set MysteryBoxFrame = FlexDMD.NewFrame("mystery_box")
        MysteryBoxFrame.Thickness = 1
        .AddActor MysteryBoxFrame
    End With

    entry.SetScene g
End Sub


Sub DmdTick_Mystery(args)
    Dim slots : slots = cols * rows
    Dim itemCount : itemCount = UBound(itemsArray) + 1
    Dim visibleCount : visibleCount = itemCount
    If visibleCount > slots Then visibleCount = slots

    Dim cellWidth : cellWidth = 128 / cols
    Dim cellHeight : cellHeight = (32 - MysteryGridTop) / rows
    Dim jumpsElapsed : jumpsElapsed = FlexFrame \ W
    Dim settled : settled = (jumpsElapsed >= Z)

    Dim idx
    If settled Then
        idx = targetIdx
    Else
        idx = Mystery_IndexForJump(jumpsElapsed, visibleCount)
    End If
    ' Guard against a caller's targetIdx (or an empty itemsArray) landing
    ' outside the visible slots - VBScript's Mod can return negative for
    ' a negative idx, hence the extra +visibleCount Mod visibleCount.
    If visibleCount > 0 Then idx = ((idx Mod visibleCount) + visibleCount) Mod visibleCount

    Dim i, label
    For i = 0 To slots - 1
        Set label = FlexDMD.Stage.GetLabel("mystery_item_" & i)
        If i < visibleCount Then
            label.Text = itemsArray(i)
        Else
            label.Text = ""
        End If

        If i = idx Then
            label.Font = FontMysteryHighlight
        Else
            label.Font = FontMysteryDim
        End If
    Next

    Dim col, row
    col = idx Mod cols
    row = idx \ cols
    If settled Then MysteryBoxFrame.Thickness = 3 Else MysteryBoxFrame.Thickness = 1
    MysteryBoxFrame.SetBounds col * cellWidth + 2, MysteryGridTop + row * cellHeight + 2, cellWidth - 4, cellHeight - 4
End Sub


' A deterministic stand-in for script.vbs's Int(Rnd * ...) jump picker.
' The ticker runs every DMD frame (17ms) but a jump only lasts W of
' them, so this has to give back the same answer every time it's asked
' about the same jump number - it's called far more often than the jump
' actually changes. Using the table's real Rnd/Randomize for that would
' mean reseeding the shared random generator on every tick this slide is
' on screen, which would quietly make any other code's "real" random
' draws predictable for as long as that lasted - so this is a small
' hand-rolled scramble instead, not real randomness.
Function Mystery_SeededIndex(jumpNum, itemCount)
    If itemCount <= 0 Then
        Mystery_SeededIndex = 0
    Else
        ' jumpNum Mod 97 keeps the multiply well inside Long range no
        ' matter how long the slide has been on screen.
        Mystery_SeededIndex = (((jumpNum Mod 97) * 41) + 17) Mod itemCount
    End If
End Function

' Same as script.vbs's Do/Loop guard: never land on the same cell twice
' in a row.
Function Mystery_IndexForJump(jumpNum, itemCount)
    Dim idx : idx = Mystery_SeededIndex(jumpNum, itemCount)
    If jumpNum > 0 And itemCount > 1 Then
        If idx = Mystery_SeededIndex(jumpNum - 1, itemCount) Then
            idx = (idx + 1) Mod itemCount
        End If
    End If
    Mystery_IndexForJump = idx
End Function

