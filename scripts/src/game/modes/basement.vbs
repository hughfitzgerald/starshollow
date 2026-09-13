


' Basement Mode
'
' This mode runs all the time. Some tasks need to be handled outside of normal gameplay.


Sub CreateBasementMode()
    Dim x

    With CreateGlfMode("basement", 100)
        .Debug = True
        .StartEvents = Array("reset_complete")

        With .EventPlayer()

            'Some table init stuff
            .Add "mode_basement_started", Array("close_ramp_diverter","backglass_on", "dt2_enable_keepup", "bells_down")

            'Backglass stuff
            .Add "backglass_on", Array("backglass_logo_on","backglass_game_on","backglass_logic_on","backglass_framework_on")
            .Add "backglass_off", Array("backglass_logo_off","backglass_game_off","backglass_logic_off","backglass_framework_off")

            'Handle tilt
            .Add "tilt", Array("kill_flippers","backglass_off")

            .Add "s_add_credit_key_active", Array("add_credit")
            .Add "s_add_credit_key2_active", Array("add_credit")

            .Add "balldevice_lock1_ball_entered", Array("ball_locked")
            .Add "balldevice_lock2_ball_entered", Array("ball_locked")

            .Add "balldevice_lock1_ball_exiting", Array("ball_unlocked")
            .Add "balldevice_lock2_ball_exiting", Array("ball_unlocked")

            .Add "ball_ended", Array("clear_multiball_locks")
            .Add "timer_clear_multiball_locks_complete", Array("multiball_locks_cleared")
            
            .Add "return_captive_from_drain", Array("disable_captive_ramp_kicker_hold")
            .Add "logan_ball_captured", Array("capture_captive_ball","disable_captive_ramp_kicker_hold")

            .Add "s_captive_ball_active{machine.captive_ball_captive == 0}", Array("captive_ball_is_home")
            .Add "captive_ball_is_home", Array("dt2_enable_keepup", "disable_captive_ramp_upper_kicker")
            .Add "ball_drain{machine.captive_ball_captive == 0 and current_player.llmb_shoot_again_active == 0}", Array("return_captive_from_drain")
        End With

        ' With .QueueRelayPlayer()
        '     With .EventName("ball_drain{machine.captive_ball_captive == 0}")
        '         .Post = "return_captive_from_drain"
        '         .WaitFor = "captive_ball_is_home"
        '     End With
        ' End With

        With .VariablePlayer()
            With .EventName("free_captive_ball")
                With .Variable("captive_ball_captive")
                    .Action = "set_machine"
                    .Int = 0
                End With
            End With
            With .EventName("captive_ball_is_home")
                With .Variable("captive_ball_captive")
                    .Action = "set_machine"
                    .Int = 1
                End With
            End With
        End With

        With .BallHolds("scoop_hold")
            .BallsToHold = 1
            .HoldDevices = Array("scoop")
            .EnableEvents = Array("enable_scoop_hold") 
            .DisableEvents = Array("disable_scoop_hold") 
            .ReleaseAllEvents = Array("release_scoop_hold")
        End With

        With .Timers("clear_multiball_locks")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = 1
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "clear_multiball_locks"
                .Action = "start"
            End With
        End With

        With .BallHolds("captive_ramp_kicker_hold")
            .Debug = True
            .BallsToHold = 1
            .HoldDevices = Array("captive_ramp_kicker")
            .EnableEvents = Array("enable_captive_ramp_kicker_hold") 
            .DisableEvents = Array("disable_captive_ramp_kicker_hold") 
            .ReleaseAllEvents = Array("release_captive_ramp_kicker_hold")
        End With

        With .VariablePlayer()
            With .EventName("add_credit")
                With .Variable("credits")
                    .Action = "add_machine"
                    .Int = 1
                End With
            End With
            With .EventName("ball_locked")
                With .Variable("num_balls_locked")
                    .Action = "add_machine"
                    .Int = 1
                End With
            End With
            With .EventName("ball_unlocked")
                With .Variable("num_balls_locked")
                    .Action = "add_machine"
                    .Int = -1
                End With
            End With
        End With

        ' ' Pome sound effects (outside of normal ball play time)
        With .SoundPlayer() 

            ' 'When players get added
            ' With .EventName("player_added{kwargs.num==1}")
            '     .Key = "key_sfx_p1"
            '     .Sound = "sfx_button"
            ' End With
            ' With .EventName("player_added{kwargs.num==2}")
            '     .Key = "key_sfx_p2"
            '     .Sound = "sfx_button"
            ' End With
            ' With .EventName("player_added{kwargs.num==3}")
            '     .Key = "key_sfx_p3"
            '     .Sound = "sfx_button"
            ' End With
            ' With .EventName("player_added{kwargs.num==4}")
            '     .Key = "key_sfx_p4"
            '     .Sound = "sfx_button"
            ' End With

            ' 'When ball drains
            ' With .EventName("mode_bonus_started")
            '     .Key = "key_sfx_drain"
            '     .Sound = "sfx_drain"
            ' ' End With

            ' 'When tilting
            ' With .EventName("tilt_warning")
            '     .Key = "key_sfx_tilt_warning"
            '     .Sound = "sfx_tilt_warning"
            ' End With
            ' With .EventName("tilt")
            '     .Key = "key_sfx_tilt"
            '     .Sound = "sfx_tilt"
            ' End With
            
        End With


        With .SegmentDisplayPlayer()

            'Display the tilt warning
            ' With .EventName("tilt_warning")
            '     With .Display("player1")
            '         .Text = ""
            '         .Expire = 4000
            '         .Priority = 10000
            '     End With
            '     With .Display("player2")
            '         .Text = "WARNING"
            '         .Expire = 4000
            '         .Flashing = "all"
            '         .Priority = 10000
            '     End With
            '     With .Display("player3")
            '         .Text = "WARNING"
            '         .Expire = 4000
            '         .Flashing = "all"
            '         .Priority = 10000
            '     End With
            '     With .Display("player4")
            '         .Text = ""
            '         .Expire = 4000
            '         .Priority = 10000
            '     End With
            ' End With

            ' 'Display tilt
            ' With .EventName("tilt")
            '     With .Display("player1")
            '         .Text = ""
            '         .Expire = 4000
            '         .Priority = 10000
            '     End With
            '     With .Display("player2")
            '         .Text = "TILT"
            '         .Expire = 4000
            '         .Priority = 10000
            '     End With
            '     With .Display("player3")
            '         .Text = "TILT"
            '         .Expire = 4000
            '         .Priority = 10000
            '     End With
            '     With .Display("player4")
            '         .Text = ""
            '         .Expire = 4000
            '         .Priority = 10000
            '     End With
            ' End With

        End With


        With .ShowPlayer()

            'DEBUG to test show. To run test, uncomment and update section for given show. 
            ' With .EventName("test_show") 
            '     .Key = "key_test_show1"
            '     .Show = "ship_saver_acquired"
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 20000
            ' End With
            ' With .EventName("test_show") 
            '     .Key = "key_test_show1"
            '     .Show = "fade_color_on_off_on"   'defined in CreateGeneralShows()
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 20000
            '     With .Tokens()
            '         .Add "lights", "GI"
            '         .Add "color", "ff0000"
            '     End With
            ' End With


            ' 'Flicker off GI lights when tilted
            With .EventName("tilt") 
                .Key = "key_tilted_gi"
                .Show = "flicker_color_off" 
                .Speed = 3
                .Loops = 0
                .Priority = 10000
                With .Tokens()
                    .Add "lights", "GI"
                    .Add "color", GIColor3000k
                End With
            End With
            With .EventName("ball_started") 
                .Key = "key_tilted_gi"
                .Show = "flicker_color_off" 
                .Speed = 3
                .Loops = 0
                .Priority = 10000
                .Action = "stop"
                With .Tokens()
                    .Add "lights", "GI"
                    .Add "color", GIColor3000k
                End With
            End With

            ' 'Flash some warning lights
            ' With .EventName("tilt_warning") 
            '     .Key = "key_tilt_warning_gi"
            '     .Show = "flash_color" 
            '     .Speed = 9
            '     .Loops = 9
            '     .Priority = 10000
            '     With .Tokens()
            '         .Add "lights", "InlaneGI"
            '         .Add "color", GIColor3000k
            '     End With
            ' End With

            ' ' Backglass light shows (for VR backglass)
            ' With .EventName("backglass_logo_on")
            '     .Key = "key_backglass_logo_on_show"
            '     .Show = "backglass_logo_on_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With
            ' With .EventName("backglass_logo_off")
            '     .Key = "key_backglass_logo_off_show"
            '     .Show = "backglass_logo_off_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With

            ' With .EventName("backglass_game_on")
            '     .Key = "key_backglass_game_on_show"
            '     .Show = "backglass_game_on_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With
            ' With .EventName("backglass_game_off")
            '     .Key = "key_backglass_game_off_show"
            '     .Show = "backglass_game_off_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With

            ' With .EventName("backglass_logic_on")
            '     .Key = "key_backglass_logic_on_show"
            '     .Show = "backglass_logic_on_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With
            ' With .EventName("backglass_logic_off")
            '     .Key = "key_backglass_logic_off_show"
            '     .Show = "backglass_logic_off_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With

            ' With .EventName("backglass_framework_on")
            '     .Key = "key_backglass_framework_on_show"
            '     .Show = "backglass_framework_on_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With
            ' With .EventName("backglass_framework_off")
            '     .Key = "key_backglass_framework_off_show"
            '     .Show = "backglass_framework_off_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With

            ' With .EventName("backglass_flash1")
            '     .Key = "key_backglass_flash1_show"
            '     .Show = "backglass_flash1_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With
            ' With .EventName("backglass_flash2")
            '     .Key = "key_backglass_flash2_show"
            '     .Show = "backglass_flash2_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With
            ' With .EventName("backglass_flash3")
            '     .Key = "key_backglass_flash3_show"
            '     .Show = "backglass_flash3_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With
            ' With .EventName("backglass_flash4")
            '     .Key = "key_backglass_flash4_show"
            '     .Show = "backglass_flash4_show" 
            '     .Speed = 1
            '     .Loops = 0
            '     .Priority = 1000
            ' End With

        End With


        ' Backglass lights (for B2S backglass)
        With .DOFPlayer()

            'Logo backglass light
            With .EventName("backglass_logo_on")
                .Action = "DOF_ON"
                .DOFEvent = 1
            End With
            With .EventName("backglass_logo_off")
                .Action = "DOF_OFF"
                .DOFEvent = 1
            End With

            'GAME backglass light
            With .EventName("backglass_game_on")
                .Action = "DOF_ON"
                .DOFEvent = 2
            End With
            With .EventName("backglass_game_off")
                .Action = "DOF_OFF"
                .DOFEvent = 2
            End With

            'LOGIC backglass light
            With .EventName("backglass_logic_on")
                .Action = "DOF_ON"
                .DOFEvent = 3
            End With
            With .EventName("backglass_logic_off")
                .Action = "DOF_OFF"
                .DOFEvent = 3
            End With

            'FRAMEWORK backglass light
            With .EventName("backglass_framework_on")
                .Action = "DOF_ON"
                .DOFEvent = 4
            End With
            With .EventName("backglass_framework_off")
                .Action = "DOF_OFF"
                .DOFEvent = 4
            End With

            'Flash1 backglass light
            With .EventName("backglass_flash1_on")
                .Action = "DOF_ON"
                .DOFEvent = 5
            End With
            With .EventName("backglass_flash1_off")
                .Action = "DOF_OFF"
                .DOFEvent = 5
            End With

            'Flash2 backglass light
            With .EventName("backglass_flash2_on")
                .Action = "DOF_ON"
                .DOFEvent = 6
            End With
            With .EventName("backglass_flash2_off")
                .Action = "DOF_OFF"
                .DOFEvent = 6
            End With

            'Flash3 backglass light
            With .EventName("backglass_flash3_on")
                .Action = "DOF_ON"
                .DOFEvent = 7
            End With
            With .EventName("backglass_flash3_off")
                .Action = "DOF_OFF"
                .DOFEvent = 7
            End With

            'Flash4 backglass light
            With .EventName("backglass_flash4_on")
                .Action = "DOF_ON"
                .DOFEvent = 8
            End With
            With .EventName("backglass_flash4_off")
                .Action = "DOF_OFF"
                .DOFEvent = 8
            End With

        End With



    End With

End Sub
