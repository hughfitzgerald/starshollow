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
            .Add "mode_lbtb_started", Array("base_music_stop", "release_scoop_hold", "reset_bells")
            .Add "mode_lbtb_stopping", Array("base_music_start", "lbtb_shots_off", "bells_down")

            .Add "release_scoop_hold", Array("disable_scoop_hold")

            For x = 3 To 8
                .Add "drop_target_drop" & x & "_down", Array("lbtb_shot_hit")
            Next
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
                .EventName = "mode_lbtb_started"
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