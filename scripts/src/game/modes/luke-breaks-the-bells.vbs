' Lbtb Mode

Const LbtbTime = 60   'seconds
Const LbtbShotScore = 20000

Sub CreateLbtbMode()
    Dim x
    With CreateGlfMode("lbtb", 720)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_lbtb")
        .StopEvents = Array("timer_lbtb_mode_complete", "mode_base_stopping", "mode_eob_bonus_started")

        With .EventPlayer()
            .Debug = True
            .Add "mode_lbtb_started", Array("base_music_stop", "reset_bells")
            .Add "mode_lbtb_stopping", Array("base_music_start", "lbtb_shots_off", "bells_down")

            .Add "timer_shuffle_bells_complete", Array("reset_bells")

            .Add "reset_bells", Array("bells_down", "choose_bell_one")
            .Add "choose_bell_one", Array("choose_bell", "choose_bell_two")
            .Add "choose_bell_two", Array("choose_bell", "choose_bell_three")
            .Add "choose_bell_three", Array("choose_bell")
            
            .Add "timer_lbtb_intro_delay_complete", Array("release_scoop_hold")
            .Add "release_scoop_hold", Array("disable_scoop_hold")

            For x = 3 To 8
                .Add "drop_target_drop" & x & "_down{current_player.bells_not_hit == 0}", Array("lbtb_shot_hit")
            Next
        End With

        With .Timers("lbtb_intro_delay")
            .StartRunning = True
            .Direction = "down"
            .StartValue = 3
            .EndValue = 0
            .TickInterval = 1000    ' Tick every 1 second (1000 ms)
        End With

        With .RandomEventPlayer()
            .Debug = True
            With .EventName("choose_bell")
                For x = 3 To 8
                    .Add "drop" & x & "_reset{device.drop_targets.drop" & x & ".state == 1}", 1
                Next
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        With .Timers("points_delay")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 1
            .EndValue = 0
            .TickInterval = 250
            With .ControlEvents()
                .EventName = "reset_bells"
                .Action = "restart"
            End With
        End With

        With .Timers("shuffle_bells")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 5
            .EndValue = 1
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "timer_lbtb_intro_delay_complete"
                .Action = "start"
            End With
            With .ControlEvents()
                .EventName = "timer_shuffle_bells_complete"
                .Action = "restart"
            End With
        End With

        With .SoundPlayer()
            With .EventName("mode_lbtb_started")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
            End With
            With .EventName("mode_lbtb_stopping")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
                .Action = "stop"
            End With
            ' With .EventName("lbtb_voc_1")
            '     .Key = "key_voc_dancingfun"
            '     .Sound = "voc_dancingfun"
            ' End With
            ' With .EventName("lbtb_voc_2")
            '     .Key = "key_voc_flipallyouwant"
            '     .Sound = "voc_flipallyouwant"
            ' End With
            ' With .EventName("lbtb_voc_3")
            '     .Key = "key_voc_justkeepdancing"
            '     .Sound = "voc_justkeepdancing"
            ' End With
            ' With .EventName("lbtb_voc_4")
            '     .Key = "key_voc_lelbtbeflipyou"
            '     .Sound = "voc_lelbtbeflipyou"
            ' End With
            ' With .EventName("lbtb_voc_5")
            '     .Key = "key_voc_lookgreat"
            '     .Sound = "voc_lookgreat"
            ' End With
            ' With .EventName("lbtb_voc_6")
            '     .Key = "key_voc_neeson"
            '     .Sound = "voc_neeson"
            ' End With
            ' With .EventName("lbtb_voc_7")
            '     .Key = "key_voc_prostrate"
            '     .Sound = "voc_prostrate"
            ' End With
        End With

        With .SlidePlayer()
            With .EventName("mode_lbtb_started")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_lbtb_stopping")
                .Slide = "mode"
                .Action = "remove"
            End With
        End With

        With .VariablePlayer()
            With .EventName("reset_bells")
                With .Variable("bells_not_hit")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("timer_points_delay_complete")
                With .Variable("bells_not_hit")
                    .Action = "set"
                    .Int = 0
                End With
            End With

            With .EventName("mode_lbtb_started")
                With .Variable("mode_display_text")
                    .Action = "set"
                    .String = """LUKE BREAKS THE BELLS!"""
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_lbtb_score}"
                End With
                With .Variable("mode_display_instructions")
                    .Action = "set"
                    .String = """SHOOT ORBITS TO SCORE"""
                End With
            End With

            With .EventName("timer_lbtb_mode_tick")
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = "kwargs.ticks_remaining"
                End With
            End With

            With .EventName("lbtb_shot_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = LbtbShotScore
                End With
                With .Variable("mode_lbtb_score")
                    .Action = "add"
                    .Int = LbtbShotScore
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = LbtbShotScore
                End With
            End With
        End With

        With .Timers("lbtb_mode")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = LbtbTime
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "timer_lbtb_intro_delay_complete"
                .Action = "start"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("lbtb_shot_hit")
                .Add "lbtb_voc_1", 1
                .Add "lbtb_voc_2", 1
                .Add "lbtb_voc_3", 1
                .Add "lbtb_voc_4", 1
                .Add "lbtb_voc_5", 1
                .Add "lbtb_voc_6", 1
                .Add "lbtb_voc_7", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With
    End With
End Sub