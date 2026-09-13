' Dinner Mode

Const DinnerTime = 60   'seconds
Const DinnerShotScore = 20000

Sub CreateDinnerMode()
    Dim dinner_shots, shot
    dinner_shots = Array( _
        NewShot("dinner_orbit_left",  "s_left_orbit",  "l51", "dinner_orbits"), _
        NewShot("dinner_orbit_right", "s_right_orbit", "l52", "dinner_orbits") _
    )
    With CreateGlfMode("dinner", 690)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_dinner")
        .StopEvents = Array("timer_dinner_mode_complete", "mode_base_stopping", "mode_eob_bonus_started")

        With .EventPlayer()
            .Add "mode_dinner_started", Array("base_music_stop", "release_scoop_hold")
            .Add "mode_dinner_stopping", Array("dinner_shots_off")
            .Add "timer_dinner_mode_complete", Array("base_music_start")

            .Add "release_scoop_hold", Array("disable_scoop_hold")

            For Each shot In dinner_shots
                .Add shot.Name & "_hit", Array("dinner_shot_hit")
            Next
        End With

        With .SoundPlayer()
            With .EventName("mode_dinner_started")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
            End With
            With .EventName("mode_dinner_stopping")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
                .Action = "stop"
            End With
            ' With .EventName("dinner_voc_1")
            '     .Key = "key_voc_dancingfun"
            '     .Sound = "voc_dancingfun"
            ' End With
            ' With .EventName("dinner_voc_2")
            '     .Key = "key_voc_flipallyouwant"
            '     .Sound = "voc_flipallyouwant"
            ' End With
            ' With .EventName("dinner_voc_3")
            '     .Key = "key_voc_justkeepdancing"
            '     .Sound = "voc_justkeepdancing"
            ' End With
            ' With .EventName("dinner_voc_4")
            '     .Key = "key_voc_ledinnereflipyou"
            '     .Sound = "voc_ledinnereflipyou"
            ' End With
            ' With .EventName("dinner_voc_5")
            '     .Key = "key_voc_lookgreat"
            '     .Sound = "voc_lookgreat"
            ' End With
            ' With .EventName("dinner_voc_6")
            '     .Key = "key_voc_neeson"
            '     .Sound = "voc_neeson"
            ' End With
            ' With .EventName("dinner_voc_7")
            '     .Key = "key_voc_prostrate"
            '     .Sound = "voc_prostrate"
            ' End With
        End With

        With .SlidePlayer()
            With .EventName("mode_dinner_started")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_dinner_stopping")
                .Slide = "mode"
                .Action = "remove"
            End With
        End With

        With .VariablePlayer()
            With .EventName("mode_dinner_started")
                With .Variable("mode_display_text")
                    .Action = "set"
                    .String = """FRIDAY NIGHT DINNER"""
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_dinner_score}"
                End With
                With .Variable("mode_display_instructions")
                    .Action = "set"
                    .String = """SHOOT ORBITS TO SCORE"""
                End With
            End With

            With .EventName("timer_dinner_mode_tick")
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = "kwargs.ticks_remaining"
                End With
            End With

            With .EventName("dinner_shot_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = DinnerShotScore
                End With
                With .Variable("mode_dinner_score")
                    .Action = "add"
                    .Int = DinnerShotScore
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = DinnerShotScore
                End With
            End With
        End With

        With .Timers("dinner_mode")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = DinnerTime
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "mode_dinner_started"
                .Action = "start"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("dinner_shot_hit")
                .Add "dinner_voc_1", 1
                .Add "dinner_voc_2", 1
                .Add "dinner_voc_3", 1
                .Add "dinner_voc_4", 1
                .Add "dinner_voc_5", 1
                .Add "dinner_voc_6", 1
                .Add "dinner_voc_7", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        For Each shot In dinner_shots
            With .Shots(shot.Name)
                .Switch = shot.Switch
                .Profile = "mode_shot_flash"
                With .Tokens()
                    .Add "lights", shot.Light
                    .Add "color", "ffff00"
                End With
                With .ControlEvents()
                    .Events = Array("mode_dinner_started")
                    .State = 1
                End With
                With .ControlEvents()
                    .Events = Array("mode_dinner_stopping")
                    .State = 0
                End With
            End With
        Next
    End With
End Sub