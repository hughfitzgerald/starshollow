


' Basement Mode
'
' This mode runs all the time. Some tasks need to be handled outside of normal gameplay.


Sub CreateBasementMode()
    Dim x

    With CreateGlfMode("basement", 100)
        .StartEvents = Array("reset_complete")

        With .EventPlayer()
            'Some table init stuff
            .Add "mode_basement_started", Array("close_ramp_diverter","backglass_on", "dt2_enable_keepup", "bells_down", "check_start_button", "enable_scoop_hold")
            .Add "mode_basement_stopped", Array("backglass_off")

            'Backglass stuff
            .Add "backglass_on", Array("backglass_logo_on")
            .Add "backglass_off", Array("backglass_logo_off")

            'Handle tilt
            .Add "tilt", Array("kill_flippers","backglass_off")

            'Start button DOF (E102) - is the start button going to do anything?
            ' Re-check whenever credits, players, ball or game state change.
            ' GLF queues posted events, so check_start_button is evaluated after
            ' the VariablePlayer below has applied the change that triggered it.
            .Add "credits_added", Array("check_start_button")
            .Add "enabling_free_play", Array("check_start_button")
            .Add "enabling_credit_play", Array("check_start_button")
            .Add "player_added", Array("check_start_button")
            .Add "game_started", Array("check_start_button")
            .Add "ball_started", Array("check_start_button")
            .Add "game_ended", Array("check_start_button")
            ' game.num_players is 0 when no game is running (GLF clears the players
            ' before it posts game_ended).
            ' Mirrors GLF: no game -> needs a credit (or free play). In a game -> needs
            ' that, room for another player, and the current player still on ball 1.
            ' The credits and the player limit are GLF's own (credits mode, game settings).
            .Add "check_start_button{(machine.credits_whole_num >= 1 or machine.free_play == 1) and (game.num_players == 0 or (game.num_players < game.max_players and current_player.ball == 1))}", Array("start_button_available")
            .Add "check_start_button{(machine.credits_whole_num < 1 and machine.free_play == 0) or (game.num_players > 0 and (game.num_players >= game.max_players or current_player.ball > 1))}", Array("start_button_unavailable")

            .Add "balldevice_lock1_ball_entered", Array("ball_locked")
            .Add "balldevice_lock2_ball_entered", Array("ball_locked")

            .Add "balldevice_lock1_ball_exiting", Array("ball_unlocked")
            .Add "balldevice_lock2_ball_exiting", Array("ball_unlocked")

            .Add "bonus_start", Array("clear_multiball_locks")
            ' The bonus isn't counted on a tilted ball, so clear the locks here too -
            ' otherwise the next player inherits balls they never locked.
            .Add "ball_ending{game.tilted == True}", Array("clear_multiball_locks")
            .Add "timer_clear_multiball_locks_complete", Array("multiball_locks_cleared")
            
            .Add "return_captive_from_drain", Array("disable_captive_ramp_kicker_hold")
            .Add "logan_ball_captured", Array("capture_captive_ball","disable_captive_ramp_kicker_hold")

            .Add "s_captive_ball_active{machine.captive_ball_captive == 0}", Array("captive_ball_is_home")
            .Add "captive_ball_is_home", Array("dt2_enable_keepup", "disable_captive_ramp_upper_kicker")

            ' A captive ball held in the captive ramp kicker is released at the end of the
            ' ball (ll_multiball_qualify, on mode_base_stopping) and goes back up to the
            ' captive spot. The next ball waits (QueueRelayPlayer below) until it has landed
            ' and stopped bouncing: captive_return_settle restarts on every captive switch
            ' hit, and the failsafe ends the wait if the ball never gets there.
            .Add "s_captive_ball_active{machine.captive_returning == 1}", Array("captive_return_bounce")
            .Add "timer_captive_return_settle_complete", Array("captive_return_done")
            .Add "timer_captive_return_failsafe_complete", Array("captive_return_done")
            .Add "ball_drain{machine.captive_ball_captive == 0 and current_player.llmb_shoot_again_active == 0}", Array("return_captive_from_drain")

            ' Nothing releases the scoop hold when no ball is being played (game over, a
            ' cancelled game, between balls), so a ball that lands there is sent straight out.
            .Add "balldevice_scoop_ball_entered{modes.base.active == False}", Array("scoop_safety_release")
        End With

        With .QueueRelayPlayer()
            With .EventName("ball_starting{machine.captive_returning == 1}")
                .Post    = "waiting_for_captive_return"
                .WaitFor = "captive_return_done"
            End With
        End With

        With .Timers("captive_return_settle")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 3
            .EndValue = 0
            .TickInterval = 500      ' 1.5s with no captive switch hit
            With .ControlEvents()
                .EventName = "captive_return_bounce"
                .Action = "restart"
            End With
            With .ControlEvents()
                .EventName = "captive_return_done"
                .Action = "stop"
            End With
        End With

        With .Timers("captive_return_failsafe")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 8
            .EndValue = 0
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "release_captive_ramp_kicker_hold"
                .Action = "restart"
            End With
            With .ControlEvents()
                .EventName = "captive_return_done"
                .Action = "stop"
            End With
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
            With .EventName("release_captive_ramp_kicker_hold")
                With .Variable("captive_returning")
                    .Action = "set_machine"
                    .Int = 1
                End With
            End With
            With .EventName("captive_return_done")
                With .Variable("captive_returning")
                    .Action = "set_machine"
                    .Int = 0
                End With
            End With
            With .EventName("captive_ball_is_home")
                With .Variable("captive_ball_captive")
                    .Action = "set_machine"
                    .Int = 1
                End With
                With .Variable("captive_capture_pending")
                    .Action = "set_machine"
                    .Int = 0
                End With
            End With
        End With

        With .BallHolds("scoop_hold")
            .BallsToHold = 1
            .HoldDevices = Array("scoop")
            .EnableEvents = Array("enable_scoop_hold") 
            .DisableEvents = Array("disable_scoop_hold") 
            .ReleaseAllEvents = Array("scoop_eject_show_complete", "scoop_safety_release")
        End With

        With .Timers("clear_multiball_locks")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = 1
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            ' "restart", not "start": basement never stops, so nothing else sets the timer
            ' back to its start value. With "start" it would complete at once on every
            ' clear after the first and close the subway diverter early.
            With .ControlEvents
                .EventName = "clear_multiball_locks"
                .Action = "restart"
            End With
        End With

        With .BallHolds("captive_ramp_kicker_hold")
            .BallsToHold = 1
            .HoldDevices = Array("captive_ramp_kicker")
            .EnableEvents = Array("enable_captive_ramp_kicker_hold") 
            .DisableEvents = Array("disable_captive_ramp_kicker_hold") 
            .ReleaseAllEvents = Array("release_captive_ramp_kicker_hold")
        End With

        With .VariablePlayer()
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

        With .DOFPlayer()
            With .EventName("start_button_available")
                .Action = "DOF_ON"
                .DOFEvent = 102
            End With
            With .EventName("start_button_unavailable")
                .Action = "DOF_OFF"
                .DOFEvent = 102
            End With
        End With

        ' ' Pome sound effects (outside of normal ball play time)
        With .SoundPlayer()

            ' Player 2-4 joined (player 1 is added by the game start itself)
            With .EventName("player_added{kwargs.num > 1}")
                .Key = "key_sfx_player_added"
                .Sound = "sfx_dinerdoor"
            End With

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


        With .WidgetPlayer()
            For x = 2 To 4
                With .EventName("player_added{kwargs.num == " & x & "}")
                    .Widget = "player_" & x & "_added"
                    .Action = "play"
                    .Expire = 1.5
                End With
            Next
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

            ' ' Backglass light shows
            With .EventName("backglass_logo_on")
                .Key = "key_backglass_logo_on_show"
                .Show = "backglass_logo_on_show" 
                .Speed = 1
                .Loops = 0
                .Priority = 1000
            End With
            With .EventName("backglass_logo_off")
                .Key = "key_backglass_logo_off_show"
                .Show = "backglass_logo_off_show" 
                .Speed = 1
                .Loops = 0
                .Priority = 1000
            End With

            With .EventName("backglass_flash1")
                .Key = "key_backglass_flash1_show"
                .Show = "backglass_flash1_show" 
                .Speed = 1
                .Loops = 0
                .Priority = 1000
            End With
            With .EventName("backglass_flash2")
                .Key = "key_backglass_flash2_show"
                .Show = "backglass_flash2_show" 
                .Speed = 1
                .Loops = 0
                .Priority = 1000
            End With
            With .EventName("backglass_flash3")
                .Key = "key_backglass_flash3_show"
                .Show = "backglass_flash3_show" 
                .Speed = 1
                .Loops = 0
                .Priority = 1000
            End With
            With .EventName("backglass_flash4")
                .Key = "key_backglass_flash4_show"
                .Show = "backglass_flash4_show" 
                .Speed = 1
                .Loops = 0
                .Priority = 1000
            End With

        End With


        ' Backglass lights (for B2S backglass)
        ' With .DOFPlayer()
        '     .
        '     'Logo backglass light
        '     With .EventName("backglass_logo_on")
        '         .Action = "DOF_ON"
        '         .DOFEvent = 1
        '     End With
        '     With .EventName("backglass_logo_off")
        '         .Action = "DOF_OFF"
        '         .DOFEvent = 1
        '     End With

        '     'Flash1 backglass light
        '     With .EventName("backglass_flash1_on")
        '         .Action = "DOF_ON"
        '         .DOFEvent = 2
        '     End With
        '     With .EventName("backglass_flash1_off")
        '         .Action = "DOF_OFF"
        '         .DOFEvent = 2
        '     End With

        '     'Flash2 backglass light
        '     With .EventName("backglass_flash2_on")
        '         .Action = "DOF_ON"
        '         .DOFEvent = 3
        '     End With
        '     With .EventName("backglass_flash2_off")
        '         .Action = "DOF_OFF"
        '         .DOFEvent = 3
        '     End With

        '     'Flash3 backglass light
        '     With .EventName("backglass_flash3_on")
        '         .Action = "DOF_ON"
        '         .DOFEvent = 4
        '     End With
        '     With .EventName("backglass_flash3_off")
        '         .Action = "DOF_OFF"
        '         .DOFEvent = 4
        '     End With

        '     'Flash4 backglass light
        '     With .EventName("backglass_flash4_on")
        '         .Action = "DOF_ON"
        '         .DOFEvent = 5
        '     End With
        '     With .EventName("backglass_flash4_off")
        '         .Action = "DOF_OFF"
        '         .DOFEvent = 5
        '     End With

        ' End With



    End With

End Sub
