
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
            .Add "mode_eob_bonus_started", Array("run_bonus_started")

            .Add "run_bonus_started", Array("calculate_bonus_total", "play_bonus_show1")
            .Add "calculate_bonus_total", Array("add_bonus_total_to_score")

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
            .Add "play_bonus_show8{current_player.mode_dm_score       > 0 && current_player.bonus_skip == 0}", Array("bonus_light8_show","do_sfx_bonus", "show_bonus_dm")
            .Add "play_bonus_show8{current_player.mode_dm_score      == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show9")
            .Add "play_bonus_show9{current_player.mode_tm_score       > 0 && current_player.bonus_skip == 0}", Array("bonus_light9_show","do_sfx_bonus", "show_bonus_tm")
            .Add "play_bonus_show9{current_player.mode_tm_score      == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show10")
            .Add "play_bonus_show10{current_player.mode_lbtb_score     > 0 && current_player.bonus_skip == 0}", Array("bonus_light10_show","do_sfx_bonus", "show_bonus_lbtb")
            .Add "play_bonus_show10{current_player.mode_lbtb_score    == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show11")
            .Add "play_bonus_show11{current_player.mode_ka_score       > 0 && current_player.bonus_skip == 0}", Array("bonus_light11_show","do_sfx_bonus", "show_bonus_ka")
            .Add "play_bonus_show11{current_player.mode_ka_score      == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show12")
            .Add "play_bonus_show12{current_player.mode_dinner_score   > 0 && current_player.bonus_skip == 0}", Array("bonus_light12_show","do_sfx_bonus", "show_bonus_dinner")
            .Add "play_bonus_show12{current_player.mode_dinner_score  == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show13")
            .Add "play_bonus_show13{current_player.mode_punch_score    > 0 && current_player.bonus_skip == 0}", Array("bonus_light13_show","do_sfx_bonus", "show_bonus_punch")
            .Add "play_bonus_show13{current_player.mode_punch_score   == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show14")
            .Add "play_bonus_show14{current_player.bonus_total         > 0 && current_player.bonus_skip == 0}", Array("bonus_light14_show","do_sfx_bonus", "show_bonus_total")
            .Add "play_bonus_show14{current_player.bonus_total        == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show15")

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
            For x = 1 To BonusShows
                With .EventName("bonus_light"&x&"_show")
                    .Key = "key_bonus_light"&x&"_show"
                    .Show = "flash_color"
                    .Speed = 20
                    .Loops = 12
                    .Priority = 2000
                    'When the show ends, move to the next one
                    .EventsWhenCompleted = Array("play_bonus_show"&(x+1))
                    With .Tokens()
                        .Add "lights", "GI"
                        .Add "color", GIColorAttract
                    End With
                End With
            Next
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
                    .Int = "current_player.bonus_multiplier * " & BonusMultiplierFactor & _
                        " * current_player.total_switches_hit + current_player.bumper_count * " & BonusBumperFactor & _
                        " + current_player.diner_count * " & BonusDinerFactor & _
                        " + current_player.grandparents_count * " & BonusGrandparentsFactor & _
                        " + current_player.spinner_count * " & BonusSpinnerFactor
                End With
            End With
            With .EventName("add_bonus_total_to_score")
                With .Variable("score")
                    .Action = "add"
                    .Int = "current_player.bonus_total"
                End With
            End With
            With .EventName("show_bonus_multiplier")
                With .Variable("bonus_display_text")
                    .Action = "set"
                    .String = """BONUS "" & current_player.bonus_multiplier & ""x"""
                End With
                With .Variable("bonus_display_score")
                    .Action = "set"
                    .String = "current_player.bonus_multiplier * " & BonusMultiplierFactor & " * current_player.total_switches_hit"
                End With
            End With
            With .EventName("show_bonus_coffee")
                With .Variable("bonus_display_text")
                    .Action = "set"
                    .String = """COFFEE COFFEE COFFEE"""
                End With
                With .Variable("bonus_display_score")
                    .Action = "set"
                    .String = "current_player.bumper_count & "" CUPS x "" & BonusBumperFactor"
                End With
            End With
            With .EventName("show_bonus_diners")
                With .Variable("bonus_display_text")
                    .Action = "set"
                    .String = """LUKE'S DINER"""
                End With
                With .Variable("bonus_display_score")
                    .Action = "set"
                    .String = "current_player.diner_count & "" MEALS x "" & BonusDinerFactor"
                End With
            End With
            With .EventName("show_bonus_grandparents")
                With .Variable("bonus_display_text")
                    .Action = "set"
                    .String = """GRANDPARENTS"""
                End With
                With .Variable("bonus_display_score")
                    .Action = "set"
                    .String = "current_player.grandparents_count & "" VISITS x "" & BonusGrandparentsFactor"
                End With
            End With
            With .EventName("show_bonus_talking")
                With .Variable("bonus_display_text")
                    .Action = "set"
                    .String = """FAST TALKING"""
                End With
                With .Variable("bonus_display_score")
                    .Action = "set"
                    .String = "current_player.spinner_count & "" QUIPS x "" & BonusSpinnerFactor"
                End With
            End With
            With .EventName("show_bonus_llmb")
                With .Variable("bonus_display_text")
                    .Action = "set"
                    .String = """LOCK-AWAY LOGAN"""
                End With
                With .Variable("bonus_display_score")
                    .Action = "set"
                    .String = "current_player.mode_llmb_score"
                End With
            End With
            With .EventName("show_bonus_total")
                With .Variable("bonus_display_text")
                    .Action = "set"
                    .String = """TOTAL BONUS"""
                End With
                With .Variable("bonus_display_score")
                    .Action = "set"
                    .String = "current_player.bonus_total"
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
            With .EventName("run_bonus_started")
                .Slide = "eob_bonus"
                .Action = "play"
            End With
        End With
    End With
End Sub