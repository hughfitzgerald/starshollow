' Lbtb Mode

Const LbtbTime = 60   'seconds
Const LbtbShotScore = 20000
Const LbtbShuffleTime = 5

Sub CreateLbtbMode()
    Dim x
    With CreateGlfMode("lbtb", 720)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_lbtb")
        .StopEvents = Array("mode_base_stopping", "mode_eob_bonus_started", "timer_lbtb_post_mode_complete")

        With .EventPlayer()
            .Debug = True
            .Add "mode_lbtb_started", Array("base_music_stop", "reset_bells")
            .Add "mode_lbtb_stopping", Array("lbtb_shots_off", "bells_down", "stop_bells_loop", "stop_guitar_music")
            .Add "timer_lbtb_post_mode_complete", Array("base_music_start")

            .Add "timer_shuffle_bells_complete", Array("reset_bells")

            .Add "reset_bells", Array("bells_down", "choose_bell_one")
            .Add "choose_bell_one", Array("choose_bell", "choose_bell_two")
            .Add "choose_bell_two", Array("choose_bell", "choose_bell_three")
            .Add "choose_bell_three", Array("choose_bell")

            .Add "timer_lbtb_mode_complete", Array("lbtb_post_mode")
            .Add "lbtb_post_mode", Array("lbtb_shots_off", "bells_down", "stop_bells_loop", "stop_guitar_music", "play_lbtb_post_mode")
            
            .Add "timer_lbtb_intro_delay_complete", Array("release_scoop_hold", "start_bells_loop", "start_guitar_music")

            .Add "lbtb_shot_hit", Array("play_bells_sfx")
            

            For x = 3 To 8
                .Add "drop_target_drop" & x & "_down{current_player.bells_not_hit == 0}", Array("lbtb_shot_hit")
            Next
        End With

        With .Timers("lbtb_post_mode")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 7
            .EndValue = 0
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "lbtb_post_mode"
                .Action = "start"
            End With
        End With

        With .Timers("lbtb_intro_delay")
            .StartRunning = True
            .Direction = "down"
            .StartValue = 11.5
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
                .EventName = "bells_down"
                .Action = "restart"
            End With
        End With

        With .Timers("shuffle_bells")
            .StartRunning = False
            .Direction = "down"
            .StartValue = LbtbShuffleTime
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
            With .ControlEvents()
                .EventName = "lbtb_post_mode"
                .Action = "stop"
            End With
        End With

        With .SoundPlayer()
            With .EventName("mode_lbtb_started")
                .Key = "key_voc_bells_intro"
                .Sound = "voc_bells_intro"
                .Priority = 100
            End With
            With .EventName("start_bells_loop")
                .Key = "key_mus_bells_loop"
                .Sound = "mus_bells_loop"
            End With
            With .EventName("stop_bells_loop")
                .Key = "key_mus_bells_loop"
                .Sound = "mus_bells_loop"
                .Action = "stop"
            End With
            With .EventName("start_guitar_music")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
            End With
            With .EventName("stop_guitar_music")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
                .Action = "stop"
            End With
            With .EventName("play_lbtb_post_mode")
                .Key = "key_voc_bells_what_happened"
                .Sound = "voc_bells_what_happened"
                .Priority = 100
            End With
            With .EventName("lbtb_voc_1")
                .Key = "key_voc_bells_thankgod"
                .Sound = "voc_bells_thankgod"
            End With
            With .EventName("lbtb_voc_2")
                .Key = "key_voc_bells_hammer"
                .Sound = "voc_bells_hammer"
            End With
            With .EventName("lbtb_voc_3")
                .Key = "key_voc_bells_jamorwedge"
                .Sound = "voc_bells_jamorwedge"
            End With
            With .EventName("lbtb_voc_4")
                .Key = "key_voc_bells_clappers"
                .Sound = "voc_bells_clappers"
            End With
            ' With .EventName("lbtb_voc_5")
            '     .Key = "key_voc_bells_dont_have_to_break_every"
            '     .Sound = "voc_bells_dont_have_to_break_every"
            ' End With
            With .EventName("lbtb_voc_6")
                .Key = "key_voc_bells_ruintheset"
                .Sound = "voc_bells_ruintheset"
            End With
            With .EventName("lbtb_voc_7")
                .Key = "key_voc_bells_needapush"
                .Sound = "voc_bells_needapush"
            End With
            With .EventName("lbtb_voc_8")
                .Key = "key_voc_bells_hunchback"
                .Sound = "voc_bells_hunchback"
            End With
            With .EventName("lbtb_voc_9")
                .Key = "key_voc_bells_youre_welcome"
                .Sound = "voc_bells_youre_welcome"
            End With
            With .EventName("sfx_bells_break1")
                .Key = "key_sfx_bells_break1"
                .Sound = "sfx_bells_break1"
            End With
            With .EventName("sfx_bells_break2")
                .Key = "key_sfx_bells_break2"
                .Sound = "sfx_bells_break2"
            End With
            With .EventName("sfx_bells_break3")
                .Key = "key_sfx_bells_break3"
                .Sound = "sfx_bells_break3"
            End With
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
            With .EventName("bells_down")
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
                .Add "lbtb_voc_8", 1
                .Add "lbtb_voc_9", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("play_bells_sfx")
                .Add "sfx_bells_break1", 1
                .Add "sfx_bells_break2", 1
                .Add "sfx_bells_break3", 1
            End With
        End With
    End With
End Sub