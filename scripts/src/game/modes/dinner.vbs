' Dinner Mode

Const DinnerTime = 60   'seconds

Sub CreateDinnerMode()
    Dim dinner_shots, shot
    dinner_shots = Array( _
        NewShot("dinner_orbit_left",  "s_left_orbit",  "l51", "dinner_orbits"), _
        NewShot("dinner_orbit_right", "s_right_orbit", "l52", "dinner_orbits") _
    )
    With CreateGlfMode("dinner", 690)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_dinner")
        .StopEvents = Array("timer_dinner_post_mode_complete", "mode_base_stopping", "bonus_start")

        With .EventPlayer()
            'Scoring
            .Add "dinner_shot_hit", Array(ScoreEvent(DinnerShotScore, NoMultiplier))

            .add "s_HiddenUpperRightKicker_active", Array("dinner_jackpot_hit")
            .Add "dinner_jackpot_hit", Array(ScoreEvent(DinnerJackpotScore, NoMultiplier))

            .Add "mode_dinner_started", Array(ScoreEvent(ModeStartScore, NoMultiplier), "base_music_stop", ModeSlideEvent("play_dinner_mode_slide", "FRIDAY NIGHT DINNER", "SHOOT ORBITS TO SCORE"))
            'Lasted the full timer without draining
            .Add "timer_dinner_mode_complete", Array("dinner_post_mode", ScoreEvent(ModeCompleteScore, NoMultiplier))
            .Add "dinner_post_mode", Array("dinner_shots_off", "stop_dinner_music", "play_dinner_post_mode")
            .Add "timer_dinner_post_mode_complete", Array("base_music_start")

            .Add "timer_dinner_intro_delay_complete", Array("release_scoop_hold","start_dinner_music")

            For Each shot In dinner_shots
                .Add shot.Name & "_hit", Array("dinner_shot_hit")
            Next
        End With

        With .Timers("dinner_post_mode")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 6
            .EndValue = 0
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "dinner_post_mode"
                .Action = "start"
            End With
        End With

        With .Timers("dinner_intro_delay")
            .StartRunning = True
            .Direction = "down"
            .StartValue = 9
            .EndValue = 0
            .TickInterval = 1000    ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "skip_minigame_intro{device.timers.dinner_intro_delay.ticks > 0}"
                .Action = "jump"
                .Value = 0
            End With
        End With

        With .SoundPlayer()
            With .EventName("mode_dinner_started")
                .Key = "key_voc_dinner_lastchancetorun"
                .Sound = "voc_dinner_lastchancetorun"
                .Priority = 100
            End With
            With .EventName("start_dinner_music")
                .Key = "key_mus_dinner"
                .Sound = "mus_dinner"
            End With
            With .EventName("stop_dinner_music")
                .Key = "key_mus_dinner"
                .Sound = "mus_dinner"
                .Action = "stop"
            End With
            With .EventName("dinner_voc_1")
                .Key = "key_voc_dinner_menken"
                .Sound = "voc_dinner_menken"
            End With
            With .EventName("dinner_voc_2")
                .Key = "key_voc_dinner_reno"
                .Sound = "voc_dinner_reno"
            End With
            With .EventName("dinner_voc_3")
                .Key = "key_voc_dinner_ruthless"
                .Sound = "voc_dinner_ruthless"
            End With
            With .EventName("dinner_voc_4")
                .Key = "key_voc_dinner_sorbet"
                .Sound = "voc_dinner_sorbet"
            End With
            With .EventName("dinner_voc_5")
                .Key = "key_voc_dinner_spaghetti"
                .Sound = "voc_dinner_spaghetti"
            End With
            With .EventName("dinner_voc_6")
                .Key = "key_voc_dinner_uglymen"
                .Sound = "voc_dinner_uglymen"
            End With
            With .EventName("dinner_voc_7")
                .Key = "key_voc_dinner_cahoots"
                .Sound = "voc_dinner_cahoots"
            End With
            With .EventName("dinner_voc_8")
                .Key = "key_voc_dinner_deepdown"
                .Sound = "voc_dinner_deepdown"
            End With
            With .EventName("dinner_voc_9")
                .Key = "key_voc_dinner_dirtylibrarian"
                .Sound = "voc_dinner_dirtylibrarian"
            End With
            With .EventName("dinner_voc_10")
                .Key = "key_voc_dinner_heartfelt"
                .Sound = "voc_dinner_heartfelt"
            End With
            With .EventName("dinner_jackpot_voc_1")
                .Key = "key_voc_emily_spasareexploding"
                .Sound = "voc_emily_spasareexploding"
            End With
            With .EventName("dinner_jackpot_voc_2")
                .Key = "key_voc_trix_imnotabee"
                .Sound = "voc_trix_imnotabee"
            End With
            With .EventName("dinner_jackpot_voc_3")
                .Key = "key_voc_richard_twoglassesofwine"
                .Sound = "voc_richard_twoglassesofwine"
            End With
            With .EventName("play_dinner_post_mode")
                .Key = "key_voc_dinner_outro"
                .Sound = "voc_dinner_outro"
                .Priority = 100
            End With
        End With

        With .SlidePlayer()
            With .EventName("play_dinner_mode_slide")
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
            'Mode complete: this is also the event the mode stops on
            With .EventName("timer_dinner_mode_complete")
                With .Variable("mode_dinner_score")
                    .Action = "add"
                    .Int = ModeCompleteScore
                End With
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = ModeCompleteScore
                End With
            End With

            With .EventName("mode_dinner_started")
                'Start award, before mode_display_score is copied from it below
                With .Variable("mode_dinner_score")
                    .Action = "add"
                    .Int = ModeStartScore
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_dinner_score}"
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
            End With
        End With

        With .Timers("dinner_mode")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = DinnerTime
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "timer_dinner_intro_delay_complete"
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
                .Add "dinner_voc_8", 1
                .Add "dinner_voc_9", 1
                .Add "dinner_voc_10", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("dinner_jackpot_hit")
                .Add "dinner_jackpot_voc_1", 1
                .Add "dinner_jackpot_voc_2", 1
                .Add "dinner_jackpot_voc_3", 1
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