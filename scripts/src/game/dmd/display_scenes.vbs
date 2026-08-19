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
    Dim i

    Set FontScoreActive = FlexDMD.NewFont("TeenyTinyPixls5.fnt", vbWhite, vbWhite, 0)
    Set FontScoreInactive = FlexDMD.NewFont("TeenyTinyPixls5.fnt", RGB(100, 100, 100), vbWhite, 0)
    Set FontBig1 = FlexDMD.NewFont("sys80.fnt", vbWhite, vbBlack, 0)
    Set FontBig2 = FlexDMD.NewFont("sys80_1.fnt", vbWhite, vbBlack, 0)
    Set FontBig3 = FlexDMD.NewFont("sys80.fnt", RGB ( 10,10,10) ,vbBlack, 0)

    Dim g : Set g = FlexDMD.NewGroup("Score")
    With g
        ' .AddActor FlexDMD.NewImage("bg","bgdarker.png")
        ' .Getimage("bg").visible = True ' False
        ' .AddActor FlexDMD.NewImage("bg2","bg.png")
        ' .Getimage("bg2").visible = False
        For i = 1 To 4
            .AddActor FlexDMD.NewLabel("Score_" & i, FontScoreInactive, "0")
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
    '   FlexDMD.Stage.GetLabel("Credit").Text = "Credit " & (Credits(CurrentPlayer)) - 1
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
        ' .AddActor FlexDMD.Newvideo ("test","spinner.gif")
        ' .Getvideo("test").visible = True
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
