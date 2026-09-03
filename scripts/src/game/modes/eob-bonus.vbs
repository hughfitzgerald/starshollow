
' Bonus Mode.

Const BonusShows = 6
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
            .Add "play_bonus_show6{current_player.bonus_total         > 0 && current_player.bonus_skip == 0}", Array("bonus_light6_show","do_sfx_bonus", "show_bonus_total")
            .Add "play_bonus_show6{current_player.bonus_total        == 0 && current_player.bonus_skip == 0}", Array("play_bonus_show7")

            .Add "play_bonus_show7", Array("bonus_finished")

            ' Bonus x8 (or whatever the current multiplier is) and the score below it... it should be multiplier * 1000 * number of switches hit, but for now just show the multiplier and a static score.
            ' A card for each of the "special" shots (coffee, diners, grandparents)
            ' A card for each mode and however many points you got from each mode (those have already been added but we just summarize them here)
            ' A card showing the total bonus

            ' SLIDES/WIDGETS THAT I NEED TO ADD:
            ' 1. the first bonus card and the total bonus cards can be the exact same layout, different label text
            ' 2. the mode bonus cards have the exact same layout as each other (name of mode, points earned, and some kind of fancy border)
            ' 3. each special shot card has the exact same layout as each other (name of shot, points earned, and some kind of icon for the shot)
            ' EACH ONE has text describing the bonus category and a score that should be read from the game state
            ' SHOT BONUS also has the # of shots made
            ' MULTIPLIER BONUS also has the multiplier value
            '
            ' COFFEE COFFEE COFFEE: 25 CUPS
            ' FAST TALKING: 750 QUIPS
            ' GRANDPARENTS: 10 VISITS
            ' LUKE'S DINER: 5 MEALS
        End With

        With .ShowPlayer()
            For x = 1 To BonusShows
                With .EventName("bonus_light"&x&"_show")
                    .Key = "key_bonus_light"&x&"_show"
                    .Show = "flash_color"
                    .Speed = 20
                    .Loops = 20
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