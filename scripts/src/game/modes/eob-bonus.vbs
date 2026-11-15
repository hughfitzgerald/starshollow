' Bonus Mode.
'
' GLF's built-in bonus mode (EnableGlfBonus) does the counting: it starts on
' ball_ending, holds the end of the ball, walks through the counted lines below,
' adds the total to the score and posts bonus_entry for every line it counts.
' This file gives it the lines and adds the table's presentation.
'
' The tally has two parts, shown in this order:
'
' 1. Counted lines - GLF bonus entries. Each is worth score x count:
'     Array(name, count, score, title, shown)
'   name   bonus entry name; show_bonus_<name> is posted when the line is counted
'   count  player variable with the number of hits; the line is skipped when it is 0
'   score  value of one hit - a number, or a GLF expression
'   title  VBScript expression for the slide's text - wrap fixed text in KwargText
'   shown  VBScript expression for what the slide shows as the score
'
' 2. Recap lines - shown only, not counted: what each mode scored this ball (already
'    in the score), then the bonus total. Same format as before:
'     Array(name, count, title, score)
'   score  "" for current_player.<count>
'
' Timing: GLF moves from one counted line to the next every DisplayDelayMs, set to
' the length of the sweep light show. On the total it hands over to the recap lines,
' where each line's light show starts the next one when it completes, and the last
' one posts bonus_finished, which ends the bonus.
'
' Both flippers skip: the counted lines are hurried through, the recap is dropped.
'
' Bonus X: the player variable is bonus_x, and it multiplies the switch line only.
' It is not called bonus_multiplier because GLF's bonus mode (like MPF's) multiplies
' the whole bonus by a variable of that name.
Function EobBonusCountedLines()
    EobBonusCountedLines = Array( _
        Array("switches",     "total_switches_hit", "current_player.bonus_x * " & BonusMultiplierFactor, """BONUS "" & current_player.bonus_x & ""x""", "current_player.bonus_x * BonusMultiplierFactor * current_player.total_switches_hit"), _
        Array("coffee",       "bumper_count",       BonusBumperFactor,       KwargText("COFFEE COFFEE COFFEE"), "current_player.bumper_count & "" CUPS x "" & BonusBumperFactor"), _
        Array("diners",       "diner_count",        BonusDinerFactor,        KwargText("LUKE'S DINER"),         "current_player.diner_count & "" MEALS x "" & BonusDinerFactor"), _
        Array("grandparents", "grandparents_count", BonusGrandparentsFactor, KwargText("GRANDPARENTS"),         "current_player.grandparents_count & "" VISITS x "" & BonusGrandparentsFactor"), _
        Array("talking",      "spinner_count",      BonusSpinnerFactor,      KwargText("FAST TALKING"),         "current_player.spinner_count & "" QUIPS x "" & BonusSpinnerFactor") _
    )
End Function

Function EobBonusRecapLines()
    EobBonusRecapLines = Array( _
        Array("llmb",           "mode_llmb_score",           KwargText("LOCK-AWAY LOGAN"),       ""), _
        Array("jdmb",           "mode_jdmb_score",           KwargText("JESS & DEAN: TO THE DEATH"), ""), _
        Array("dm",             "mode_dance_marathon_score", KwargText("DANCE MARATHON"),        ""), _
        Array("tm",             "mode_town_meeting_score",   KwargText("TOWN MEETING"),          ""), _
        Array("lbtb",           "mode_lbtb_score",           KwargText("LUKE BREAKS THE BELLS"), ""), _
        Array("kims_antiques",  "mode_kims_antiques_score",  KwargText("KIM'S ANTIQUES"),        ""), _
        Array("dinner",         "mode_dinner_score",         KwargText("FRIDAY NIGHT DINNER"),   ""), _
        Array("fd_punch",       "mode_fd_punch_score",       KwargText("FOUNDER'S DAY PUNCH"),   ""), _
        Array("total",          "bonus_total",               KwargText("TOTAL BONUS"),           "") _
    )
End Function

' Listener on bonus_entry (added in _configuration.vbs). GLF posts it for every line
' it counts, and at the end for the total.
'   a counted line -> show_bonus_<name>, which plays its slide, sound and light show
'   the total      -> the bonus is in the score now. Remember it for the TOTAL BONUS
'                     line and start the recap - or end the bonus if it was skipped.
Function EobBonusEntry(args)
    If Not IsObject(args(1)) Then Exit Function
    Dim entryName : entryName = args(1)("entry")
    Select Case entryName
        Case "subtotal", "multiplier"
            'Not used: bonus_multiplier stays at 1, so GLF goes straight to the total
        Case "total"
            SetPlayerState "bonus_total", args(1)("score")
            SetPlayerState "bonus_counted", 1
            If GetPlayerState("bonus_skip") = 1 Then
                DispatchPinEvent "bonus_finished", Null
            Else
                DispatchPinEvent "play_bonus_show1", Null
            End If
        Case Else
            DispatchPinEvent "show_bonus_" & entryName, Null
    End Select
End Function

Sub CreateBonusMode
    Dim x, row, score
    Dim countedLines : countedLines = EobBonusCountedLines()
    Dim bonusLines : bonusLines = EobBonusRecapLines()
    Dim bonusShows : bonusShows = UBound(bonusLines) + 1
    Dim bonus : Set bonus = EnableGlfBonus()

    With bonus
        .DisplayDelayMs = 1300                  'one psc_eob_sweep
        .HurryUpDelayMs = 150
        .HurryUpEvent = "skip_bonus_tally"
        .EndBonusEvent = "bonus_finished"       'posted by the last recap line, below
        For x = 0 To UBound(countedLines)
            row = countedLines(x)
            With .Entries(row(0))
                .Score = row(2)
                .PlayerScoreEntry = row(1)
            End With
        Next
    End With

    ' bonus_start is posted when the count really begins. The mode itself also starts,
    ' and stops at once, on a tilted ball - so nothing here hangs off mode_bonus_started.
    With bonus.Mode
        With .EventPlayer()
            .Add "bonus_start", Array("run_bonus_started", "gi_lights_off")

            'Counted lines: GLF sets the pace, EobBonusEntry posts show_bonus_<name>
            For x = 0 To UBound(countedLines)
                row = countedLines(x)
                .Add "show_bonus_" & row(0), Array("bonus_count" & (x + 1) & "_show", "do_sfx_bonus", "show_bonus_slide:{text:" & row(3) & ",score:" & row(4) & "}")
            Next

            'Recap lines, started by EobBonusEntry on the total. Show each in turn,
            'skipping those with nothing to show. Each one plays the eob_bonus slide
            'with its text and score as kwargs, and the light show it starts moves on
            'to the next line when it completes.
            For x = 1 To bonusShows
                row = bonusLines(x - 1)
                score = row(3)
                If score = "" Then score = "current_player." & row(1)
                .Add "play_bonus_show" & x & "{current_player." & row(1) & " > 0 && current_player.bonus_skip == 0}", Array("bonus_light" & x & "_show", "do_sfx_bonus", "show_bonus_" & row(0))
                .Add "play_bonus_show" & x & "{current_player." & row(1) & " == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show" & (x + 1))
                .Add "show_bonus_" & row(0), Array("show_bonus_slide:{text:" & row(2) & ",score:" & score & "}")
            Next
            .Add "play_bonus_show" & (bonusShows + 1), Array("bonus_finished")
            'A skip during the recap ends the bonus. During the count it only hurries
            'GLF along - ending before the total would lose the bonus - and
            'EobBonusEntry ends it when the total arrives.
            .Add "timer_bonus_skip_complete{current_player.bonus_counted == 1}", Array("bonus_finished")

            .Add "do_sfx_bonus", Array("stop_sfx_eob_bonus") 'first stop the sfx if it is already playing
            .Add "stop_sfx_eob_bonus", Array("play_sfx_eob_bonus") 'then play the sfx
        End With

        With .SoundPlayer()
            With .EventName("play_sfx_eob_bonus")
                .Key = "key_sfx_eob_bonus"
                .Sound = "sfx_eob_bonus"
            End With
            With .EventName("stop_sfx_eob_bonus")
                .Key = "key_sfx_eob_bonus"
                .Sound = "sfx_eob_bonus"
                .Action = "stop"
            End With
            With .EventName("show_bonus_total")
                .Key = "key_show_bonus_total"
                .Sound = "voc_isthatgood"
            End With
        End With

        'Skip the bonus tally animations
        With .ComboSwitches("bonus_skip")
            .Switch1 = "s_left_flipper"
            .Switch2 = "s_right_flipper"
            .EventsWhenBoth = Array("skip_bonus_tally")
            '.HoldTime = 200
        End With
        
        With .Timers("bonus_skip")
            .TickInterval = 1200
            .StartValue = 0
            .EndValue = 1
            With .ControlEvents()
                .EventName = "skip_bonus_tally"
                .Action = "restart"
            End With
        End With

        With .ShowPlayer()
            For x = 1 To UBound(countedLines) + 1
                With .EventName("bonus_count"&x&"_show")
                    .Key = "key_bonus_count"&x&"_show"
                    .Show = "psc_eob_sweep"
                    .Loops = 0
                    .Priority = 2000
                    With .Tokens()
                        .Add "lights", "GI"
                        .Add "color", GIColorAttract
                    End With
                End With
            Next
            For x = 1 To bonusShows - 1
                With .EventName("bonus_light"&x&"_show")
                    .Key = "key_bonus_light"&x&"_show"
                    .Show = "psc_eob_sweep"
                    .Loops = 0
                    .Priority = 2000
                    'When the show ends, move to the next one
                    .EventsWhenCompleted = Array("play_bonus_show"&(x+1))
                    With .Tokens()
                        .Add "lights", "GI"
                        .Add "color", GIColorAttract
                    End With
                End With
            Next
            With .EventName("bonus_light"&bonusShows&"_show")
                .Key = "key_bonus_light"&bonusShows&"_show"
                .Show = "psc_eob_sweep_up_and_down"
                .Loops = 0
                .Priority = 2000
                .EventsWhenCompleted = Array("play_bonus_show"&(bonusShows+1))
                With .Tokens()
                    .Add "lights", "GI"
                    .Add "color", GIColorAttract
                End With
            End With
        End With

        With .VariablePlayer()
            With .EventName("run_bonus_started")
				With .Variable("bonus_skip")
                    .Action = "set"
					.Int = 0
				End With
				With .Variable("bonus_counted")
                    .Action = "set"
					.Int = 0
				End With
            End With
            With .EventName("skip_bonus_tally")
                'Skip the bonus tally
				With .Variable("bonus_skip")
                    .Action = "set"
					.Int = 1
				End With
            End With
        End With

        With .SoundPlayer()
            With .EventName("bonus_start")
                .Key = "key_mus_shoo"
                .Sound = "mus_shoo"
            End With
            With .EventName("mode_bonus_stopped")
                .Key = "key_mus_shoo"
                .Sound = "mus_shoo"
                .Action = "stop"
            End With
        End With

        With .SlidePlayer()
            With .EventName("show_bonus_slide")
                .Slide = "eob_bonus"
                .Action = "play"
            End With
        End With
    End With
End Sub