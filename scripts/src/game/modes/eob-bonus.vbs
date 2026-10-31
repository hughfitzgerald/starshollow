
' Bonus Mode.

Const BonusShows = 14
Sub CreateBonusMode
    Dim x
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

            .Add "play_bonus_show1{current_player.total_switches_hit  > 0 && current_player.bonus_skip == 0}", Array("bonus_light1_show","do_sfx_bonus", "show_bonus_multiplier")
            .Add "play_bonus_show1{current_player.total_switches_hit == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show2")
            .Add "play_bonus_show2{current_player.bumper_count        > 0 && current_player.bonus_skip == 0}", Array("bonus_light2_show","do_sfx_bonus", "show_bonus_coffee")
            .Add "play_bonus_show2{current_player.bumper_count       == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show3")
            .Add "play_bonus_show3{current_player.diner_count         > 0 && current_player.bonus_skip == 0}", Array("bonus_light3_show","do_sfx_bonus", "show_bonus_diners")
            .Add "play_bonus_show3{current_player.diner_count        == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show4")
            .Add "play_bonus_show4{current_player.grandparents_count  > 0 && current_player.bonus_skip == 0}", Array("bonus_light4_show","do_sfx_bonus", "show_bonus_grandparents")
            .Add "play_bonus_show4{current_player.grandparents_count == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show5")
            .Add "play_bonus_show5{current_player.spinner_count       > 0 && current_player.bonus_skip == 0}", Array("bonus_light5_show","do_sfx_bonus", "show_bonus_talking")
            .Add "play_bonus_show5{current_player.spinner_count      == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show6")
            .Add "play_bonus_show6{current_player.mode_llmb_score     > 0 && current_player.bonus_skip == 0}", Array("bonus_light6_show","do_sfx_bonus", "show_bonus_llmb")
            .Add "play_bonus_show6{current_player.mode_llmb_score    == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show7")
            .Add "play_bonus_show7{current_player.mode_jdmb_score     > 0 && current_player.bonus_skip == 0}", Array("bonus_light7_show","do_sfx_bonus", "show_bonus_jdmb")
            .Add "play_bonus_show7{current_player.mode_jdmb_score    == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show8")
            .Add "play_bonus_show8{current_player.mode_dance_marathon_score       > 0 && current_player.bonus_skip == 0}", Array("bonus_light8_show","do_sfx_bonus", "show_bonus_dm")
            .Add "play_bonus_show8{current_player.mode_dance_marathon_score      == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show9")
            .Add "play_bonus_show9{current_player.mode_town_meeting_score       > 0 && current_player.bonus_skip == 0}", Array("bonus_light9_show","do_sfx_bonus", "show_bonus_tm")
            .Add "play_bonus_show9{current_player.mode_town_meeting_score      == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show10")
            .Add "play_bonus_show10{current_player.mode_lbtb_score     > 0 && current_player.bonus_skip == 0}", Array("bonus_light10_show","do_sfx_bonus", "show_bonus_lbtb")
            .Add "play_bonus_show10{current_player.mode_lbtb_score    == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show11")
            .Add "play_bonus_show11{current_player.mode_kims_antiques_score       > 0 && current_player.bonus_skip == 0}", Array("bonus_light11_show","do_sfx_bonus", "show_bonus_kims_antiques")
            .Add "play_bonus_show11{current_player.mode_kims_antiques_score      == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show12")
            .Add "play_bonus_show12{current_player.mode_dinner_score   > 0 && current_player.bonus_skip == 0}", Array("bonus_light12_show","do_sfx_bonus", "show_bonus_dinner")
            .Add "play_bonus_show12{current_player.mode_dinner_score  == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show13")
            .Add "play_bonus_show13{current_player.mode_fd_punch_score    > 0 && current_player.bonus_skip == 0}", Array("bonus_light13_show","do_sfx_bonus", "show_bonus_fd_punch")
            .Add "play_bonus_show13{current_player.mode_fd_punch_score   == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show14")
            .Add "play_bonus_show14{current_player.bonus_total         > 0 && current_player.bonus_skip == 0}", Array("bonus_light14_show","do_sfx_bonus", "show_bonus_total")
            .Add "play_bonus_show14{current_player.bonus_total        == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show15")

            'Each bonus line plays the eob_bonus slide with its text and score as kwargs.
            'The kwargs parser splits on "," and ":", so neither may appear inside a value
            '(hence Chr(58) below); numeric scores are comma-formatted by DmdTick_Bonus.
            .Add "show_bonus_multiplier", Array("show_bonus_slide:{text:""BONUS "" & current_player.bonus_multiplier & ""x"",score:current_player.bonus_multiplier * BonusMultiplierFactor * current_player.total_switches_hit}")
            .Add "show_bonus_coffee", Array("show_bonus_slide:{text:""COFFEE COFFEE COFFEE"",score:current_player.bumper_count & "" CUPS x "" & BonusBumperFactor}")
            .Add "show_bonus_diners", Array("show_bonus_slide:{text:""LUKE'S DINER"",score:current_player.diner_count & "" MEALS x "" & BonusDinerFactor}")
            .Add "show_bonus_grandparents", Array("show_bonus_slide:{text:""GRANDPARENTS"",score:current_player.grandparents_count & "" VISITS x "" & BonusGrandparentsFactor}")
            .Add "show_bonus_talking", Array("show_bonus_slide:{text:""FAST TALKING"",score:current_player.spinner_count & "" QUIPS x "" & BonusSpinnerFactor}")
            .Add "show_bonus_llmb", Array("show_bonus_slide:{text:""LOCK-AWAY LOGAN"",score:current_player.mode_llmb_score}")
            .Add "show_bonus_jdmb", Array("show_bonus_slide:{text:""JESS & DEAN"" & Chr(58) & "" TO THE DEATH"",score:current_player.mode_jdmb_score}")
            .Add "show_bonus_dm", Array("show_bonus_slide:{text:""DANCE MARATHON"",score:current_player.mode_dance_marathon_score}")
            .Add "show_bonus_tm", Array("show_bonus_slide:{text:""TOWN MEETING"",score:current_player.mode_town_meeting_score}")
            .Add "show_bonus_lbtb", Array("show_bonus_slide:{text:""LUKE BREAKS THE BELLS"",score:current_player.mode_lbtb_score}")
            .Add "show_bonus_kims_antiques", Array("show_bonus_slide:{text:""KIM'S ANTIQUES"",score:current_player.mode_kims_antiques_score}")
            .Add "show_bonus_dinner", Array("show_bonus_slide:{text:""FRIDAY NIGHT DINNER"",score:current_player.mode_dinner_score}")
            .Add "show_bonus_fd_punch", Array("show_bonus_slide:{text:""FOUNDER'S DAY PUNCH"",score:current_player.mode_fd_punch_score}")
            .Add "show_bonus_total", Array("show_bonus_slide:{text:""TOTAL BONUS"",score:current_player.bonus_total}")

            .Add "play_bonus_show15", Array("bonus_finished")
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
            For x = 1 To BonusShows - 1
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
            With .EventName("bonus_light"&BonusShows&"_show")
                .Key = "key_bonus_light"&BonusShows&"_show"
                .Show = "psc_eob_sweep_up_and_down"
                .Loops = 0
                .Priority = 2000
                .EventsWhenCompleted = Array("play_bonus_show"&(BonusShows+1))
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