'*******************************************
'  DMD scenes - the ones that are real code
'*******************************************
'
' Everything the DMD can show is listed in display_config.vbs. Most
' entries are a GIF or a line of text and need nothing more than that
' one line. The ones below are not: they build a stage full of labels
' and then push live data into it every frame, so they name a Builder
' and a Ticker from the config and the actual code lives here.
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
' A Ticker runs on every DMD frame (17ms) while its scene is on the DMD,
' from inside FlexDMD's render lock - DMDTimer_Timer takes the lock,
' calls FlexDmd_Tick, and releases it. So a ticker must not lock the
' render thread itself, must not play or remove a slide (that would take
' the lock again), and must not do anything slow.
'
' Both take a single argument - the GlfDmdEntry they belong to, matching
' the GetRef(name)(args) callback convention GLF uses everywhere. Every
' ticker reaches its actors through entry.Scene(), never FlexDMD.Stage:
' during a transition two scenes are on the stage at once, and a Stage
' lookup can find the other one's label of the same name.
'
' Leave the scene group's own position alone once it is built (move the
' actors inside it instead). A transition carries the group in a parent
' of its own and puts it back where it was, so a builder may place it -
' Mystery sits at 0,2 - but a ticker moving the group itself would fight
' the transition.
'
' FULL-SCREEN SCENES AND LAYERS
'
' A scene with no .Over replaces what is on the DMD. A scene WITH an
' .Over is a layer: its group is added on top of the scene named there
' and removed again when it leaves the stack, so the backdrop keeps
' ticking underneath. The mechanism is in ZFBC - see the LAYERS note at
' the top of 28_ZFBC_FlexDMD_Bcp_Controller.vbs.


'*******************************************
'  score - the scoreboard
'*******************************************
' Four player scores down the left, a scrolling title and the current
' player's score in a clipped panel on the right, ball number along the
' bottom. This is also the only scene that draws DMDBigText, which is
' what makes widgets an overlay on the scoreboard and nothing else.

Sub DmdBuild_Score(entry)
    Dim scene
    Set scene = FlexDMD.NewGroup("Score")
    scene.SetSize 128, 32

    Dim frame
    Set frame = FlexDMD.NewFrame("Border")
    frame.SetBounds 0, 0, 128, 32
    frame.Thickness = 1
    frame.BorderColor = RGB(90, 90, 90)
    scene.AddActor frame

    Dim scoreDisplay
    Set scoreDisplay = FlexDMD.NewGroup("ScoreDisplay")
    scoreDisplay.SetBounds 1, 1, 127, 23
    scene.AddActor scoreDisplay

    Dim activeLeftScore
    Set activeLeftScore = FlexDMD.NewGroup("ActiveLeftScore")
    activeLeftScore.SetBounds 1, 1, 76, 23
    scene.AddActor activeLeftScore

    Dim inactiveLeftScore
    Set inactiveLeftScore = FlexDMD.NewGroup("InactiveLeftScore")
    inactiveLeftScore.SetBounds 1, 1, 54, 23
    scene.AddActor inactiveLeftScore

    Dim p1Score
    Set p1Score = FlexDMD.NewLabel("P1", mediumFont, "00")
    p1Score.AutoPack = False
    p1Score.FillParent = True
    p1Score.Alignment = FlexDMD_Align_TopRight
    inactiveLeftScore.AddActor p1Score

    Dim p2Score
    Set p2Score = FlexDMD.NewLabel("P2", mediumFont, "00")
    p2Score.AutoPack = False
    p2Score.FillParent = True
    p2Score.Alignment = FlexDMD_Align_TopRight
    scoreDisplay.AddActor p2Score

    Dim p3Score
    Set p3Score = FlexDMD.NewLabel("P3", mediumFont, "00")
    p3Score.AutoPack = False
    p3Score.FillParent = True
    p3Score.Alignment = FlexDMD_Align_BottomRight
    inactiveLeftScore.AddActor p3Score

    Dim p4Score
    Set p4Score = FlexDMD.NewLabel("P4", mediumFont, "00")
    p4Score.AutoPack = False
    p4Score.FillParent = True
    p4Score.Alignment = FlexDMD_Align_BottomRight
    scoreDisplay.AddActor p4Score

    Dim ball
    Set ball = FlexDMD.NewLabel("BallCredits", smallFont, "BALL 2   CREDITS 1")
    ball.SetAlignedPosition 64, 29, 4
    scene.AddActor ball

    entry.SetScene scene
End Sub

Sub DmdTick_Score(entry)
  Dim scene, scoreDisplay, activeLeftScore, inactiveLeftScore, scoreLabel, scoreValue
  Set scene = entry.Scene()
  Set scoreDisplay = scene.GetGroup("ScoreDisplay")
  Set activeLeftScore = scene.GetGroup("ActiveLeftScore")
  Set inactiveLeftScore = scene.GetGroup("InactiveLeftScore")

  scene.GetLabel("BallCredits").Text = "BALL " & GetPlayerState("ball") & "   CREDITS " & glf_machine_vars("credits").GetValue()
  
  scene.GetLabel("P1").Alignment = FlexDMD_Align_TopRight
  scene.GetLabel("P2").Visible = False
  scene.GetLabel("P3").Visible = False
  scene.GetLabel("P4").Visible = False
  Dim x
  For x = 1 To glf_playerState.Count
    scoreValue = GetPlayerStateForPlayer(x - 1, "score")
    Set scoreLabel = scene.GetLabel("P" & x)
    scoreLabel.Visible = True
    If scoreValue = 0 Then
      scoreLabel.Text = "00"
    Else
        scoreLabel.Text = FormatNumber(scoreValue, 0, -2, -2, -1)
    End If
    If glf_playerState.Count > 1 Then
      If Getglf_currentPlayerNumber() = x - 1 Then
        If x = 1 or x = 3 Then
          scene.RemoveActor scoreLabel
          activeLeftScore.addActor scoreLabel
        End If
        If scoreValue > 999999999 Then
          scoreLabel.Font = mediumFont
        ElseIf scoreValue > 99999999 Then
          scoreLabel.Font = largeFont
        Else
          scoreLabel.Font = bigFont
        End If
      Else
        If x = 1 or x = 3 Then
          scene.RemoveActor scoreLabel
          inactiveLeftScore.addActor scoreLabel
        End If
        If scoreValue > 9999999 Then
          scoreLabel.Font = smallFontDim
        Else
          scoreLabel.Font = mediumFontDim
        End If
      End If
    Else
      scoreDisplay.AddActor scoreLabel
      scoreLabel.Alignment = FlexDMD_Align_Center
      scoreLabel.Font = bigFont
    End If
  Next
End Sub

'*******************************************
'  welcome - the attract intro
'*******************************************
' The logo slides in and then blinks, all with FlexDMD actions built
' here - the ticker has nothing to do. FlexDMD runs an actor's actions
' only while it is on the stage, so the slide-in starts when the scene
' first goes on the DMD (at the start of its fade-in transition) and
' does not restart on a later replay.

Sub DmdBuild_Welcome(entry)
    ' Dim g : Set g = FlexDMD.NewGroup("Welcome")
    ' With g
    '     .AddActor FlexDMD.NewImage("logo","gilmore_girls_logo_128x32.png")
    '     .Getimage("logo").visible = False
    ' End With
    ' entry.SetScene g
    Dim scene, img, base, af, bf, seq, bseq, blink, mv, moveTime

    moveTime = 3                                     ' seconds for the slide

    Set scene = FlexDMD.NewGroup("TownScene")
    scene.SetSize FlexDMD.Width, FlexDMD.Height
    scene.ClearBackground = True

    ' Words-free version sits underneath at the final position, hidden until the move finishes
    Set base = FlexDMD.NewImage("TownBase", "stars_hollow_town_dark_long_logo_nowords.png")
    base.SetPosition -23, 0
    base.Visible = False
    scene.AddActor base

    ' Full logo (with words) on top: slides in, then blinks forever
    Set img = FlexDMD.NewImage("Town", "stars_hollow_town_dark_long_logo.png")   ' packs to 228x32
    img.SetPosition -100, 0
    scene.AddActor img

    ' Reveal the base image the moment the move completes
    Set bf = base.ActionFactory
    Set bseq = bf.Sequence()
    bseq.Add bf.Wait(moveTime)
    bseq.Add bf.Show(True)
    base.AddAction bseq

    Set af = img.ActionFactory
    Set seq = af.Sequence()

    Set mv = af.MoveTo(-23, 0, moveTime)             ' x, y, seconds
    mv.Ease = 16                                     ' SineIn; use 0 for Linear
    seq.Add mv

    ' After the move, toggle the top image on/off forever.
    ' Toggle first, then wait, so the first blink starts as soon as the move ends.
    Set blink = af.Sequence()
    blink.Add af.Show(False)                         ' reveals the no-words image
    blink.Add af.Wait(0.4)                           ' words hidden
    blink.Add af.Show(True)
    blink.Add af.Wait(0.5)                           ' words visible
    seq.Add af.Repeat(blink, -1)


    img.AddAction seq

    entry.SetScene scene
End Sub


Sub DmdTick_Welcome(entry)
End Sub

'*******************************************
'  luke_and_lorelei - a LAYER over the mode panel
'*******************************************
' Its config entry sets .Over = "mode", so this group is added on top of
' the mode scene rather than replacing it, and taken back off when the
' slide that played it leaves the stack. Two rules for a layer builder:
'
'   - build a group of your own and hand it back with entry.SetScene,
'     exactly like a full-screen scene. Do NOT reach into FlexDMD.Stage
'     here - at build time the stage is empty, and at run time the stage
'     belongs to whatever scene is underneath.
'   - leave ClearBackground alone (False). A layer that clears its
'     background paints over the scene it is supposed to sit on.
'
' The slide-in is an ActionFactory sequence rather than ticker code.
' FlexDMD advances an actor's actions only while it is on the stage, so
' the sequence starts when the layer is attached and pauses if it is
' detached - which is what you want, but it also means it does not
' restart on a replay. Animation that has to restart belongs in the
' ticker, keyed on entry.AttachedAtFrame; the bob below is an example.

Sub DmdBuild_LukeAndLorelei(entry)
    Dim g, lorelei, luke, af, seq

    Set g = FlexDMD.NewGroup("LukeAndLorelei")
    g.SetSize FlexDMD.Width, FlexDMD.Height

    ' Lorelei slides in from off the left edge...
    Set lorelei = FlexDMD.NewImage("Lorelei", "lorelei.png")           ' 32x32
    lorelei.SetPosition -32, 0
    g.AddActor lorelei

    Set af = lorelei.ActionFactory
    Set seq = af.Sequence()
    seq.Add af.MoveTo(0, 0, 0.35)
    lorelei.AddAction seq

    ' ...and Luke in from off the right. luke.png is a pre-flipped copy,
    ' so the two of them face each other across the panel.
    Set luke = FlexDMD.NewImage("Luke", "luke_flipped.png")                    ' 32x32
    luke.SetPosition FlexDMD.Width, 0
    g.AddActor luke

    Set af = luke.ActionFactory
    Set seq = af.Sequence()
    seq.Add af.MoveTo(FlexDMD.Width - 32, 0, 0.35)
    luke.AddAction seq

    entry.SetScene g
End Sub


' A layer's ticker is handed its own entry, not Null - so it reaches its
' actors through entry.Scene() rather than FlexDMD.Stage, which would
' search the scene underneath as well and can find an actor of the same
' name there.
'
' entry.AttachedAtFrame is the FlexFrame this layer went on, so an
' animation counts from zero however many times the layer is replayed.
Sub DmdTick_LukeAndLorelei(entry)
    Dim g, frames, bob
    Set g = entry.Scene()
    If g Is Nothing Then Exit Sub

    frames = FlexFrame - entry.AttachedAtFrame

    ' Once the slide-in has finished (0.35s ~ 21 frames), a slow
    ' one-pixel bob, the two of them out of phase.
    If frames > 21 Then
        bob = (frames \ 15) Mod 2
        g.GetImage("Lorelei").SetPosition 0, bob
        g.GetImage("Luke").SetPosition FlexDMD.Width - 32, 1 - bob
    End If
End Sub


Sub DmdBuild_HighScore(entry)
    Dim text, initials, time
    Dim g : Set g = FlexDMD.NewGroup("HighScore")
    With g
        ' one spot with the text "P1 INITIALS" or "P2 INITIALS" etc
        Set text = FlexDMD.NewLabel("high_score_text", bigFont, "P1 INITIALS")
        text.SetAlignedPosition 64, 8, FlexDMD_Align_Center
        .AddActor text

        ' one spot with the letters for the initials
        Set initials = FlexDMD.NewLabel("high_score_initials", bigFont, "")
        initials.SetAlignedPosition 32, 16, FlexDMD_Align_Center
        .AddActor initials
        
        ' ' one spot for the time left before timeout
        ' Set time = FlexDMD.NewLabel("high_score_time", bigFont, "")
        ' time.SetAlignedPosition 64, 24, FlexDMD_Align_Center
        ' .AddActor time
    End With
    entry.SetScene g
End Sub

Sub DmdTick_HighScore(entry)
    Dim text, initials, time, scene
    Set scene = entry.Scene()
    Set text = scene.GetLabel("high_score_text")
    text.Text = "P" & glf_machine_vars("high_score_player_num").GetValue() & " INITIALS"
    Set initials = scene.GetLabel("high_score_initials")
    initials.Text = glf_machine_vars("high_score_initials").GetValue() & AZLookup(glf_machine_vars("high_score_initials_index").GetValue())
    ' Set time = scene.GetLabel("high_score_time")
    ' time.Text = "00:00"
End Sub

Sub DmdBuild_Initials(entry)
  Dim scene
  Set scene = FlexDMD.NewGroup("Initials Entry")
  scene.SetSize 128, 32

  Dim letters
  Set letters = FlexDMD.NewGroup("Letters")
  letters.setPosition -1, 24
  Dim offset
  offset = 0
  Dim i, letter
  For i = 0 to 16
    Set letter = FlexDMD.NewLabel("letter" & i, smallFont, "")
    letter.SetPosition offset, 0
    offset = offset + 8
    letters.AddActor letter
  Next


  Dim initials
  Set initials = FlexDMD.NewLabel("Initials", bigFont, "")
  initials.SetAlignedPosition 64, 10, 4
  scene.AddActor initials

  Dim frame
  Set frame = FlexDMD.NewFrame("Border")
  frame.SetBounds 22, -2, 8, 9
  frame.Thickness = 1
  frame.BorderColor = RGB(90, 90, 90)
  letters.AddActor frame

  scene.AddActor letters

  entry.SetScene scene
End Sub

Sub DmdTick_Initials(entry)
  Dim scene
  Set scene = entry.Scene()

  Dim idx
  idx = glf_machine_vars("high_score_initials_index").GetValue()

  Dim InitialValues
  InitialValues = Array("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9","_")
  Dim Count : Count = UBound(InitialValues) + 1
  ' Calculate the starting index, handling negative and out-of-bounds numbers
  Dim Shift : Shift = ((idx Mod Count) + Count - 3) Mod Count
  Dim WrappedIndex : WrappedIndex = ((idx Mod Count) + Count) Mod Count

  Dim i, letter
  For i = 0 to 16
    Set letter = scene.GetLabel("letter" & i)
    letter.Text = InitialValues((i + Shift) Mod Count)
  Next

  Dim initials
  Set initials = scene.GetLabel("Initials")
  initials.Text = glf_machine_vars("high_score_initials").GetValue() & AZLookup(idx)
End Sub

Sub DmdBuild_Bonus(entry)
    Dim text, score
    Dim g : Set g = FlexDMD.NewGroup("Bonus")
    With g
        ' one spot with bonus text
        Set text = FlexDMD.NewLabel("bonus_text", tinyFontDim, "")
        .AddActor text

        ' one spot with bonus score
        Set score = FlexDMD.NewLabel("bonus_score", bigFont, "")
        .AddActor score
    End With
    entry.SetScene g
End Sub

Sub DmdTick_Bonus(entry)
    Dim text, score, scene
    Set scene = entry.Scene()
    Set text = scene.GetLabel("bonus_text")
    text.Text = GetPlayerState("bonus_display_text")
    text.SetBounds 0, 1, 128, 8
    text.Alignment = FlexDMD_Align_Center
    Set score = scene.GetLabel("bonus_score")
    score.Text = GetPlayerState("bonus_display_score")
    score.SetBounds 0, 12, 128, 16
    score.Alignment = FlexDMD_Align_Center
End Sub

Sub DmdBuild_Mode(entry)
    Dim text, score, instructions, timer
    Dim g : Set g = FlexDMD.NewGroup("Mode")
    With g
        ' one spot with mode text
        Set text = FlexDMD.NewLabel("mode_text", tinyFontDim, "")
        .AddActor text

        ' one spot with mode score
        Set score = FlexDMD.NewLabel("mode_score", bigFont, "")
        .AddActor score

        ' one spot with mode instructions
        Set instructions = FlexDMD.NewLabel("mode_instructions", tinyFontDim, "")
        .AddActor instructions

        ' one spot with mode timer
        Set timer = FlexDMD.NewLabel("mode_timer", tinyFontDim, "")
        .AddActor timer
    End With
    entry.SetScene g
End Sub

Sub DmdTick_Mode(entry)
    Dim text, score, instructions, timer, scene
    
    Set scene = entry.Scene()
    Set text = scene.GetLabel("mode_text")
    text.Text = GetPlayerState("mode_display_text")
    text.SetBounds 0, 1, 128, 8
    text.Alignment = FlexDMD_Align_Center

    Set score = scene.GetLabel("mode_score")
    score.Text = FormatNumber(GetPlayerState("mode_display_score"), 0)
    score.SetBounds 0, 9, 128, 14
    score.Alignment = FlexDMD_Align_Center

    Set instructions = scene.GetLabel("mode_instructions")
    instructions.Text = GetPlayerState("mode_display_instructions")
    instructions.SetBounds 0, 24, 128, 8
    instructions.Alignment = FlexDMD_Align_Center

    Set timer = scene.GetLabel("mode_timer")
    timer.Text = GetPlayerState("mode_display_timer")
    timer.SetBounds 0, 1, 128, 8
    timer.Alignment = FlexDMD_Align_Right
End Sub

'*******************************************
'  game_over - final scores
'*******************************************
' Reads the player1_score..player4_score machine vars, which GLF fills in
' Glf_EndGame just before game_ended (player state is gone by then).
' One player gets the big font; two or more share a 2x2 grid.

Sub DmdBuild_GameOver(entry)
    Dim i

    Dim g : Set g = FlexDMD.NewGroup("GameOver")
    With g
        .AddActor FlexDMD.NewLabel("go_title", tinyFontDim, "GAME OVER")
        .AddActor FlexDMD.NewLabel("go_big", bigFont, "")
        For i = 1 To 4
            .AddActor FlexDMD.NewLabel("go_p" & i, tinyFontDim, "")
        Next
    End With
    entry.SetScene g
End Sub

Sub DmdTick_GameOver(entry)
    Dim i, label, numPlayers, score, scene

    Set scene = entry.Scene()
    Set label = scene.GetLabel("go_title")
    label.SetBounds 0, 1, 128, 8
    label.Alignment = FlexDMD_Align_Center

    numPlayers = glf_machine_vars("num_players").GetValue()

    Set label = scene.GetLabel("go_big")
    If numPlayers <= 1 Then
        label.Text = FormatNumber(Score2Num(glf_machine_vars("player1_score").GetValue()), 0)
    Else
        label.Text = ""
    End If
    label.SetBounds 0, 9, 128, 14
    label.Alignment = FlexDMD_Align_Center

    For i = 1 To 4
        Set label = scene.GetLabel("go_p" & i)
        If numPlayers > 1 And i <= numPlayers Then
            score = Score2Num(glf_machine_vars("player" & i & "_score").GetValue())
            label.Text = "P" & i & " " & FormatNumber(score, 0)
        Else
            label.Text = ""
        End If
        label.SetBounds ((i - 1) Mod 2) * 64, 12 + ((i - 1) \ 2) * 10, 64, 8
        label.Alignment = FlexDMD_Align_Center
    Next
End Sub


Sub DmdBuild_MysteryShared(entry)
  Dim scene
  Set scene = FlexDMD.NewGroup("Mystery")
  scene.SetSize 128, 30
  scene.SetPosition 0, 2
  
  Dim woman
  Set woman = FlexDMD.NewLabel("woman", smallFont, "Woman of Mystery")
  woman.AutoPack = False
  woman.FillParent = True
  woman.Alignment = FlexDMD_Align_Top
  scene.AddActor woman
  
  Dim words
  words = Array("Lite Extra Ball", "Add-a-Ball", "Big Score", "Increase Bonus")
  
  Dim alignment
  alignment = Array(FlexDMD_Align_TopLeft, FlexDMD_Align_TopRight, FlexDMD_Align_BottomLeft, FlexDMD_Align_BottomRight)
  
  Dim wordGroup
  Set wordGroup = FlexDMD.NewGroup("wordGroup")
  wordGroup.SetBounds 10, 10, 108, 18
  scene.AddActor wordGroup
  
  Dim i, word
  For i = 0 to 3
    Set word = FlexDMD.NewLabel("dim_word" & i, tinyFontDim, words(i))
    word.AutoPack = False
    word.FillParent = True
    word.Alignment = alignment(i)
    wordGroup.AddActor(word)
    
    Set word = FlexDMD.NewLabel("word" & i, tinyFont, words(i))
    word.AutoPack = False
    word.FillParent = True
    word.Alignment = alignment(i)
    word.Visible = False
    wordGroup.AddActor(word)
  Next

  entry.SetScene scene
End Sub

Sub DmdBuild_Mystery(entry, choice)
  Dim scene
  Set scene = FlexDMD.NewGroup("Mystery" & choice)
  scene.SetSize 128, 30
  scene.SetPosition 0, 2
  
  Dim woman
  Set woman = FlexDMD.NewLabel("woman" & choice, smallFont, "Woman of Mystery")
  woman.AutoPack = False
  woman.FillParent = True
  woman.Alignment = FlexDMD_Align_Top
  scene.AddActor woman
  
  Dim words, i, groupNumber
  ' For i = 0 to Int(UBound(mysteryAwards) / 4)
  For i = 0 to 10
    If i * 4 + (choice Mod 4) = choice Then groupNumber = i
  Next
  words = Array(mysteryAwards(groupNumber * 4 + 0).Text, mysteryAwards(groupNumber * 4 + 1).Text, mysteryAwards(groupNumber * 4 + 2).Text, mysteryAwards(groupNumber * 4 + 3).Text)
  
  Dim alignment
  alignment = Array(FlexDMD_Align_TopLeft, FlexDMD_Align_TopRight, FlexDMD_Align_BottomLeft, FlexDMD_Align_BottomRight)
  
  Dim wordGroup
  Set wordGroup = FlexDMD.NewGroup("wordGroup" & choice)
  wordGroup.SetBounds 10, 10, 108, 18
  scene.AddActor wordGroup
  
  Dim word
  For i = 0 to 3
    Set word = FlexDMD.NewLabel("dim_word" & choice & i, tinyFontDim, words(i))
    word.AutoPack = False
    word.FillParent = True
    word.Alignment = alignment(i)
    wordGroup.AddActor(word)
    
    Set word = FlexDMD.NewLabel("word" & choice & i, tinyFont, words(i))
    word.AutoPack = False
    word.FillParent = True
    word.Alignment = alignment(i)
    word.Visible = False
    wordGroup.AddActor(word)
  Next

  Dim mysteryRandomStepSecs, steps, af, seq, idx, prev, mysteryDuration, mysteryShowDuration, mysterySelectedDuration, mysterySelectedBlinkSecs, mysterySelectedSteps
  mysteryDuration = 6.0
  mysteryRandomStepSecs = 0.10
  mysterySelectedBlinkSecs = 0.8

  mysteryShowDuration = mysteryDuration / 2.0
  mysterySelectedDuration = mysteryDuration / 2.0
  steps = mysteryShowDuration / mysteryRandomStepSecs
  prev = -1
  Set af = scene.ActionFactory
  Set seq = af.Sequence()
  For i = 1 To steps
    Do : idx = Int(Rnd * 4) : Loop While idx = prev
    seq.Add wordGroup.GetLabel("word" & choice & idx).ActionFactory.Show(True)
    seq.Add af.Wait(mysteryRandomStepSecs)
    seq.Add wordGroup.GetLabel("word" & choice & idx).ActionFactory.Show(False)
    prev = idx
  Next
  
  mysterySelectedSteps = mysterySelectedDuration / mysterySelectedBlinkSecs
  seq.Add wordGroup.GetLabel("word" & choice & (choice Mod 4)).ActionFactory.Blink(mysterySelectedBlinkSecs/2.0, mysterySelectedBlinkSecs/2.0, mysterySelectedSteps)

  scene.AddAction seq

  entry.SetScene scene
End Sub

Sub DmdBuild_Mystery_eb(entry)
  Dim i, choice
  For i = 0 to UBound(mysteryAwards)
    If mysteryAwards(i).Short = "eb" Then choice = i
  Next
  DmdBuild_Mystery entry, choice
End Sub

Sub DmdBuild_Mystery_ab(entry)
  Dim i, choice
  For i = 0 to UBound(mysteryAwards)
    If mysteryAwards(i).Short = "ab" Then choice = i
  Next
  DmdBuild_Mystery entry, choice
End Sub

Sub DmdBuild_Mystery_bs(entry)
  Dim i, choice
  For i = 0 to UBound(mysteryAwards)
    If mysteryAwards(i).Short = "bs" Then choice = i
  Next
  DmdBuild_Mystery entry, choice
End Sub

Sub DmdBuild_Mystery_ib(entry)
  Dim i, choice
  For i = 0 to UBound(mysteryAwards)
    If mysteryAwards(i).Short = "ib" Then choice = i
  Next
  DmdBuild_Mystery entry, choice
End Sub

Sub DmdBuild_Mystery_jd(entry)
  Dim i, choice
  For i = 0 to UBound(mysteryAwards)
    If mysteryAwards(i).Short = "jd" Then choice = i
  Next
  DmdBuild_Mystery entry, choice
End Sub

Sub DmdBuild_Mystery_ss(entry)
  Dim i, choice
  For i = 0 to UBound(mysteryAwards)
    If mysteryAwards(i).Short = "ss" Then choice = i
  Next
  DmdBuild_Mystery entry, choice
End Sub

Sub DmdBuild_Mystery_al(entry)
  Dim i, choice
  For i = 0 to UBound(mysteryAwards)
    If mysteryAwards(i).Short = "al" Then choice = i
  Next
  DmdBuild_Mystery entry, choice
End Sub

Sub DmdBuild_Mystery_ms(entry)
  Dim i, choice
  For i = 0 to UBound(mysteryAwards)
    If mysteryAwards(i).Short = "ms" Then choice = i
  Next
  DmdBuild_Mystery entry, choice
End Sub

Sub DmdTick_Mystery(entry)
End Sub