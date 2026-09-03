
' Bonus Mode.

Const BonusSlideTime = 2
Sub CreateBonusMode

    With CreateGlfMode("eob_bonus", 150)
        .StartEvents = Array("ball_ending{game.tilted == False}")
        .StopEvents = Array("bonus_finished")
        .UseWaitQueue = True
        .Debug = True

        With .EventPlayer()
            .Add "mode_eob_bonus_started", Array("run_bonus_started")

            .Add "run_bonus_started", Array("calculate_bonus_total")
            .Add "calculate_bonus_total", Array("add_bonus_total_to_score")

            .Add "timer_eob_bonus_complete", Array("bonus_finished")

            .Add "timer_eob_bonus_tick{device.timers.eob_bonus.ticks == 0}", Array("show_bonus_multiplier")
            .Add "timer_eob_bonus_tick{device.timers.eob_bonus.ticks == " & BonusSlideTime * 1 & "}", Array("show_bonus_coffee")
            .Add "timer_eob_bonus_tick{device.timers.eob_bonus.ticks == " & BonusSlideTime * 2 & "}", Array("show_bonus_diners")
            .Add "timer_eob_bonus_tick{device.timers.eob_bonus.ticks == " & BonusSlideTime * 3 & "}", Array("show_bonus_grandparents")
            .Add "timer_eob_bonus_tick{device.timers.eob_bonus.ticks == " & BonusSlideTime * 4 & "}", Array("show_bonus_talking")
            .Add "timer_eob_bonus_tick{device.timers.eob_bonus.ticks == " & BonusSlideTime * 5 & "}", Array("show_bonus_total")

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

        With .VariablePlayer()
            With .EventName("calculate_bonus_total")
                With .Variable("bonus_total")
                    .Action = "add"
                    .Int = "current_player.bonus_multiplier * " & BonusMultiplierFactor & " * current_player.total_switches_hit + current_player.bumper_count * " & BonusBumperFactor & " + current_player.diner_count * " & BonusDinerFactor & " + current_player.grandparents_count * " & BonusGrandparentsFactor & " + current_player.spinner_count * " & BonusSpinnerFactor
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

        With .Timers("eob_bonus")
            .TickInterval = 1000
            .StartValue = 0
            .EndValue = BonusSlideTime * 6
            With .ControlEvents()
                .EventName = "run_bonus_started"
                .Action = "start"
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