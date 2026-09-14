
Sub CreateLLMultiballQualifyMode()
    Dim x

    With CreateGlfMode("ll_multiball_qualify", 220)
        .Debug = True

        .StartEvents = Array("mode_base_started{machine.game_modes_enabled == 1}", "mode_ll_multiball_stopped", "mode_jd_multiball_stopped", "mode_dance_marathon_stopped", "mode_town_meeting_stopped", "mode_dinner_stopped", "mode_fd_punch_stopped", "mode_kims_antiques_stopped", "mode_lbtb_stopped")
        .StopEvents = Array("mode_base_stopping","mode_ll_multiball_started", "mode_jd_multiball_started", "mode_dance_marathon_started", "mode_town_meeting_started", "mode_dinner_started", "mode_fd_punch_started", "mode_kims_antiques_started", "mode_lbtb_started")

        With .EventPlayer()
            .Add "mode_ll_multiball_qualify_started", Array("enable_captive_ramp_kicker_hold")
            .Add "mode_base_stopping{device.ball_holds.captive_ramp_kicker_hold.balls_held == 1}", Array("release_captive_ramp_kicker_hold")
            .Add "logan_qualify_hit1_hit", Array("dt2_knockdown")
            .Add "logan_qualify_hit2_hit", Array("logan_qualify_complete")
        End With

        With .Shots("logan_light")
            .Profile = "logan_ball"
            With .Tokens()
                .Add "lights", "l72"
                .Add "color", LoganColor
            End With
            With .ControlEvents()
                .Events = Array("mode_ll_multiball_started", "mode_base_stopping")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("logan_qualify_complete")
                .State = 1
            End With
        End With

        With .VariablePlayer()
            With .EventName("timer_logan_cooldown_started")
                With .Variable("logan_cooldown_active")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("timer_logan_cooldown_complete")
                With .Variable("logan_cooldown_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
        End With

        With .Timers("logan_cooldown")
            .StartRunning = False
            .StartValue = 2
            .EndValue = 0
            .Direction = "down"
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "s_captive_ball_active"
                .Action = "restart"
            End With
        End With

        With .Shots("logan_qualify")
            .Persist = False
            .HitEvents = Array("s_captive_ball_active{current_player.logan_cooldown_active == 0}")
            .Profile = "logan_ball"
            With .Tokens()
                .Add "lights", "l57"
                .Add "color", LoganColor
            End With
        End With

        With .ShotProfiles("logan_ball")
            With .States("unlit")
                .Key = "key_logan_ball_unlit"
                .Show = "off"
            End With
            With .States("hit1")
                .Key = "key_logan_ball_hit1"
                .Show = "flash_color_with_fade"
                .Speed = 2
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
            With .States("hit2")
                .Key = "key_logan_ball_hit2"
                .Show = "flash_color_with_fade"
                .Speed = 7
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
            With .States("hit3")
                .Key = "key_logan_ball_hit3"
                .Show = "flicker_color_on"
            End With
        End With
    End With
End Sub