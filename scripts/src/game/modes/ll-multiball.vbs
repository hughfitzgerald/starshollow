Sub CreateLLMultiballMode()
    With CreateGlfMode("ll_multiball", 1005)
        .StartEvents = Array("start_ll_multiball")
        .StopEvents = Array("mode_base_stopping", "captive_ball_is_home")
        .Debug = True

        With .EventPlayer()
            .Add "mode_ll_multiball_started", Array("release_scoop_hold", "clear_multiball_locks", "disable_captive_ball_kicker_hold")
            .Add "multiball_locks_cleared", Array("free_captive_ball")
            .Add "release_scoop_hold", Array("disable_scoop_hold")

            .Add "timer_llmb_complete", Array("enable_scoop_hold")
            .Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==0}", Array("disable_scoop_hold")
            .Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==1}", Array("logan_ball_captured")
        End With

        ' With .QueueRelayPlayer()
        '     With .EventName("mode_ll_multiball_ending{machine.captive_ball_captive == 0}")
        '         .Post = "disable_captive_ball_kicker_hold"
        '         .WaitFor = "captive_ball_is_home"
        '     End With
        ' End With

        With .VariablePlayer()
            With .EventName("multiball_llmb_shoot_again")
                With .Variable("llmb_shoot_again_active")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("multiball_llmb_shoot_again_ended")
                With .Variable("llmb_shoot_again_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
            With .EventName("multiball_llmb_reset_event")
                With .Variable("llmb_shoot_again_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
            With .EventName("multiball_llmb_ended")
                With .Variable("llmb_shoot_again_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
        End With

        With .Multiballs("llmb")
            .StartEvents = Array("all_balls_returned")
            .BallCount = 1
            .BallCountType = "add"
            .ShootAgain = 15000
            .HurryUp = 3000
            .GracePeriod = 2000
        End With

        With .Timers("llmb")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = 5
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "multiball_llmb_started"
                .Action = "start"
            End With
        End With

        With .SlidePlayer()
            With .EventName("mode_ll_multiball_started")
                .Slide  = "multiball"
                .Action = "play"
                .Expire = 3
            End With
        End With



        With .Shots("win_logan_light")
            .Persist = True
            .Profile = "llmb"
            With .Tokens()
                .Add "lights", "l72"
                .Add "color", LoganColor
            End With
            With .ControlEvents()
                .Events = Array("mode_ll_multiball_started", "mode_base_stopping")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("timer_llmb_complete")
                .State = 1
            End With
        End With

        With .ShotProfiles("llmb")
            With .States("unlit")
                .Key = "key_llmb_unlit"
                .Show = "off"
            End With
            With .States("lit")
                .Key = "key_llmb_lit"
                .Show = "flash_color_with_fade"
                .Speed = 7
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
        End With

        'Define the muiltball shoot again light
        With .Shots("ll_mb_shoot_again")
            .Profile = "shoot_again"
            With .Tokens()
                .Add "color", MultiballColor
            End With
            With .ControlEvents()
                .Events = Array("multiball_llmb_started")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("multiball_llmb_hurry_up")
                .State = 2
            End With
            .RestartEvents = Array("multiball_llmb_shoot_again_ended")
        End With
    End With
End Sub