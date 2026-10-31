
' Bonus Mode.

' The bonus tally, one row per line, in the order they are shown:
'     Array(name, count, title, score)
'   name   suffix of the show_bonus_<name> event posted when the line is shown
'   count  player variable; the line is skipped when it is 0
'   title  VBScript expression for the slide's text - wrap fixed text in EobBonusLiteral
'   score  VBScript expression for the slide's score, or "" for current_player.<count>
'          (numeric scores are comma-formatted by DmdTick_Bonus)
' Each line gets its own GI light show; the last line gets the up-and-down sweep.
Function EobBonusLines()
    EobBonusLines = Array( _
        Array("multiplier",     "total_switches_hit",        """BONUS "" & current_player.bonus_multiplier & ""x""", "current_player.bonus_multiplier * BonusMultiplierFactor * current_player.total_switches_hit"), _
        Array("coffee",         "bumper_count",              EobBonusLiteral("COFFEE COFFEE COFFEE"),  "current_player.bumper_count & "" CUPS x "" & BonusBumperFactor"), _
        Array("diners",         "diner_count",               EobBonusLiteral("LUKE'S DINER"),          "current_player.diner_count & "" MEALS x "" & BonusDinerFactor"), _
        Array("grandparents",   "grandparents_count",        EobBonusLiteral("GRANDPARENTS"),          "current_player.grandparents_count & "" VISITS x "" & BonusGrandparentsFactor"), _
        Array("talking",        "spinner_count",             EobBonusLiteral("FAST TALKING"),          "current_player.spinner_count & "" QUIPS x "" & BonusSpinnerFactor"), _
        Array("llmb",           "mode_llmb_score",           EobBonusLiteral("LOCK-AWAY LOGAN"),       ""), _
        Array("jdmb",           "mode_jdmb_score",           EobBonusLiteral("JESS & DEAN: TO THE DEATH"), ""), _
        Array("dm",             "mode_dance_marathon_score", EobBonusLiteral("DANCE MARATHON"),        ""), _
        Array("tm",             "mode_town_meeting_score",   EobBonusLiteral("TOWN MEETING"),          ""), _
        Array("lbtb",           "mode_lbtb_score",           EobBonusLiteral("LUKE BREAKS THE BELLS"), ""), _
        Array("kims_antiques",  "mode_kims_antiques_score",  EobBonusLiteral("KIM'S ANTIQUES"),        ""), _
        Array("dinner",         "mode_dinner_score",         EobBonusLiteral("FRIDAY NIGHT DINNER"),   ""), _
        Array("fd_punch",       "mode_fd_punch_score",       EobBonusLiteral("FOUNDER'S DAY PUNCH"),   ""), _
        Array("total",          "bonus_total",               EobBonusLiteral("TOTAL BONUS"),           "") _
    )
End Function

' Fixed text as a VBScript string expression that is safe to use as a kwarg.
' GLF splits an event's kwargs on "," and ":" without regard to quotes, so
' those two are spliced in with Chr() instead of appearing literally.
Function EobBonusLiteral(text)
    Dim expr : expr = Replace(text, """", """""")
    expr = Replace(expr, ":", """ & Chr(58) & """)
    expr = Replace(expr, ",", """ & Chr(44) & """)
    EobBonusLiteral = """" & expr & """"
End Function

Sub CreateBonusMode
    Dim x, row, score
    Dim bonusLines : bonusLines = EobBonusLines()
    Dim bonusShows : bonusShows = UBound(bonusLines) + 1
    With CreateGlfMode("eob_bonus", 150)
        .StartEvents = Array("ball_ending{game.tilted == False}")
        .StopEvents = Array("bonus_finished")
        .UseWaitQueue = True
        .Debug = True

        With .EventPlayer()
            .Debug = True
            .Add "mode_eob_bonus_started", Array("run_bonus_started", "gi_lights_off")

            .Add "run_bonus_started", Array("calculate_bonus_total", "play_bonus_show1")
            .Add "calculate_bonus_total", Array("add_bonus_total_to_score")
            'bonus_total is set by the variable player on calculate_bonus_total, so read it one event later
            .Add "add_bonus_total_to_score", Array(ScoreEventExpr("current_player.bonus_total", NoMultiplier))

            'Show each bonus line in turn, skipping those with nothing to show. Each one
            'plays the eob_bonus slide with its text and score as kwargs, and the light
            'show it starts moves on to the next line when it completes.
            For x = 1 To bonusShows
                row = bonusLines(x - 1)
                score = row(3)
                If score = "" Then score = "current_player." & row(1)
                .Add "play_bonus_show" & x & "{current_player." & row(1) & " > 0 && current_player.bonus_skip == 0}", Array("bonus_light" & x & "_show", "do_sfx_bonus", "show_bonus_" & row(0))
                .Add "play_bonus_show" & x & "{current_player." & row(1) & " == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show" & (x + 1))
                .Add "show_bonus_" & row(0), Array("show_bonus_slide:{text:" & row(2) & ",score:" & score & "}")
            Next
            .Add "play_bonus_show" & (bonusShows + 1), Array("bonus_finished")
            .Add "timer_bonus_skip_complete", Array("bonus_finished")

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
            End With
            With .EventName("calculate_bonus_total")
                With .Variable("bonus_total")
                    .Action = "add"
                    .Int = "{current_player.bonus_multiplier * " & BonusMultiplierFactor & _
                        " * current_player.total_switches_hit + current_player.bumper_count * " & BonusBumperFactor & _
                        " + current_player.diner_count * " & BonusDinerFactor & _
                        " + current_player.grandparents_count * " & BonusGrandparentsFactor & _
                        " + current_player.spinner_count * " & BonusSpinnerFactor & ":,}"
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
            With .EventName("mode_eob_bonus_started")
                .Key = "key_mus_shoo"
                .Sound = "mus_shoo"
            End With
            With .EventName("mode_eob_bonus_stopped")
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