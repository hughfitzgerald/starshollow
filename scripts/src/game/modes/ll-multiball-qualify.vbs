
Sub CreateLLMultiballQualifyMode()
    Dim x

    With CreateGlfMode("ll_multiball_qualify", 220)
        .Debug = True

        .StartEvents = Array("mode_base_started", "mode_ll_multiball_stopped")
        .StopEvents = Array("mode_base_stopping","mode_ll_multiball_started")

        With .EventPlayer()
            .Add "logan_qualify_hit1_hit", Array("logan_drop_target")
            .Add "logan_qualify_hit2_hit", Array("logan_qualify_complete")
        End With

        With .Shots("logan_light")
            .Persist = False
            .Profile = "logan_ball"
            With .Tokens()
                .Add "lights", "l72"
                .Add "color", LoganColor
            End With
            With .ControlEvents()
                .Events = Array("logan_qualify_complete")
                .State = 1
            End With
        End With

        Glf_SetInitialPlayerVar "logan_cooldown_active", 0

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