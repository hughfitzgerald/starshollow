' Founder's Day Punch Mode

Const FdPunchTime = 60   'seconds
Const FdPunchShotScore = 20000

Sub CreateFdPunchMode()
    Dim fd_punch_shots, shot
    fd_punch_shots = Array( _
        NewShot("fd_punch_orbit_left",  "s_left_orbit",  "l51", "fd_punch_orbits"), _
        NewShot("fd_punch_orbit_right", "s_right_orbit", "l52", "fd_punch_orbits") _
    )
    With CreateGlfMode("fd_punch", 700)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_fd_punch")
        .StopEvents = Array("timer_fd_punch_mode_complete", "mode_base_stopping", "mode_eob_bonus_started")

        With .EventPlayer()
            .Add "mode_fd_punch_started", Array("base_music_stop", "release_scoop_hold")
            .Add "mode_fd_punch_stopping", Array("base_music_start", "fd_punch_shots_off")

            .Add "release_scoop_hold", Array("disable_scoop_hold")

            For Each shot In fd_punch_shots
                .Add shot.Name & "_hit", Array("fd_punch_shot_hit")
            Next
        End With

        With .SoundPlayer()
            With .EventName("mode_fd_punch_started")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
            End With
            With .EventName("mode_fd_punch_stopping")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
                .Action = "stop"
            End With
            ' With .EventName("fd_punch_voc_1")
            '     .Key = "key_voc_dancingfun"
            '     .Sound = "voc_dancingfun"
            ' End With
            ' With .EventName("fd_punch_voc_2")
            '     .Key = "key_voc_flipallyouwant"
            '     .Sound = "voc_flipallyouwant"
            ' End With
            ' With .EventName("fd_punch_voc_3")
            '     .Key = "key_voc_justkeepdancing"
            '     .Sound = "voc_justkeepdancing"
            ' End With
            ' With .EventName("fd_punch_voc_4")
            '     .Key = "key_voc_lefd_puncheflipyou"
            '     .Sound = "voc_lefd_puncheflipyou"
            ' End With
            ' With .EventName("fd_punch_voc_5")
            '     .Key = "key_voc_lookgreat"
            '     .Sound = "voc_lookgreat"
            ' End With
            ' With .EventName("fd_punch_voc_6")
            '     .Key = "key_voc_neeson"
            '     .Sound = "voc_neeson"
            ' End With
            ' With .EventName("fd_punch_voc_7")
            '     .Key = "key_voc_prostrate"
            '     .Sound = "voc_prostrate"
            ' End With
        End With

        With .SlidePlayer()
            With .EventName("mode_fd_punch_started")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_fd_punch_stopping")
                .Slide = "mode"
                .Action = "stop"
            End With
        End With

        With .VariablePlayer()
            With .EventName("mode_fd_punch_started")
                With .Variable("mode_display_text")
                    .Action = "set"
                    .String = """FOUNDER'S DAY PUNCH"""
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_fd_punch_score}"
                End With
                With .Variable("mode_display_instructions")
                    .Action = "set"
                    .String = """SHOOT ORBITS TO SCORE"""
                End With
            End With

            With .EventName("timer_fd_punch_mode_tick")
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = "kwargs.ticks_remaining"
                End With
            End With

            With .EventName("fd_punch_shot_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = FdPunchShotScore
                End With
                With .Variable("mode_fd_punch_score")
                    .Action = "add"
                    .Int = FdPunchShotScore
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = FdPunchShotScore
                End With
            End With
        End With

        With .Timers("fd_punch_mode")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = FdPunchTime
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "mode_fd_punch_started"
                .Action = "start"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("fd_punch_shot_hit")
                .Add "fd_punch_voc_1", 1
                .Add "fd_punch_voc_2", 1
                .Add "fd_punch_voc_3", 1
                .Add "fd_punch_voc_4", 1
                .Add "fd_punch_voc_5", 1
                .Add "fd_punch_voc_6", 1
                .Add "fd_punch_voc_7", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        For Each shot In fd_punch_shots
            With .Shots(shot.Name)
                .Switch = shot.Switch
                .Profile = "mode_shot_flash"
                With .Tokens()
                    .Add "lights", shot.Light
                    .Add "color", "ffff00"
                End With
                With .ControlEvents()
                    .Events = Array("mode_fd_punch_started")
                    .State = 1
                End With
                With .ControlEvents()
                    .Events = Array("mode_fd_punch_stopping")
                    .State = 0
                End With
            End With
        Next
    End With
End Sub