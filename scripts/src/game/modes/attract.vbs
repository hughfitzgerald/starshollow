
'*******************************************
'  Attract Mode
'*******************************************
' GLF's built-in attract mode (EnableGlfAttract): priority 10, lowest of
' everything, not a game mode. GLF starts it on reset_complete and game_ended
' and stops it on game_start. This file only adds the table's presentation.
'
' The mode is running again as soon as a game ends, but the post-game mode
' has the stage first, so the presentation waits for attract_intro: posted
' at once when there is no post-game (table start), otherwise when the
' post-game mode is done.
'
' Deliberately minimal: it does NOT need to do anything to let you start a
' game. GLF handles that entirely on its own:
'
'   Glf_KeyUp(StartGameKey)
'     -> DispatchRelayPinEvent "request_to_start_game"
'        -> Glf_BallController  (verifies all 5 balls are in the trough)
'        -> GLF credits mode     (needs >= 1 credit, see _configuration.vbs)
'        -> Glf_StartGame       (adds player 1, dispatches game_start)
'        -> Glf_ReleaseBall     (kicks a ball to the plunger lane)
'
' So if the start button does nothing, the cause is almost always the ball
' controller check failing - GLF counts swTrough1..5 + Drain and refuses to
' start unless the count equals tnob - or there are no credits (the DMD shows
' the count; the add-credit key adds one). Turn on "Glf Debug Log" in the F6
' tweak menu to see which one rejected.
'
' All this mode does is pulse the GI so the table doesn't look dead, and
' get out of the way the moment a game starts.

Sub CreateAttractMode()

    Dim giName

    With EnableGlfAttract()

        With .EventPlayer()
            .Add "mode_attract_started{modes.post_game.active == False}", Array("attract_intro")
            .Add "stop_post_game_mode", Array("attract_intro")
            .Add "attract_intro", Array("play_mus_married")

            .Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 1}", Array("attract_gi_dim")
            .Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 3}", Array("attract_gi_bright")
            
            .Add "credits_added{device.timers.attract_insert_coins.ticks == 4}", Array("show_insert_coins")
            .Add "not_enough_credits{device.timers.attract_insert_coins.ticks == 4}", Array("show_insert_coins")
            .Add "s_right_flipper_active{device.timers.attract_insert_coins.ticks == 4}", Array("manual_advance_attract_slide")
        End With

        With .ShowPlayer()
            With .EventName("attract_intro")
                .Key = "key_mode_attract_started"
                .Show = "psc_attract"
                ' .Show = "generated_flash"
                ' .Speed = 1
            End With
        End With

        With .Carousel()
            .SelectableItems = Array("score", "title1", "insert_coins", "grand_champion", "high_scores_1", "high_scores_2", "replay", "game_over")
            .NextItemEvents = Array("timer_attract_screens_complete", "manual_advance_attract_slide")
            .PreviousItemEvents = Array("s_left_flipper_active")
        End With

        With .Timers("attract_screens")
            .StartValue = 0
            .EndValue = 6
            .RestartOnComplete = True
            .StartRunning = True
            With .ControlEvents
                .EventName = "mode_attract_started"
                .Action = "jump"
                .value = 3
            End With
            With .ControlEvents
                .EventName = "manual_advance_attract_slide"
                .Action = "restart"
            End With
            With .ControlEvents
                .EventName = "show_insert_coins"
                .Action = "pause"
            End With
            With .ControlEvents
                .EventName = "timer_attract_insert_coins_complete"
                .Action = "start"
            End With
        End With

        With .Timers("attract_insert_coins")
            .StartValue = 4
            .EndValue = 0
            .StartRunning = False
            .Direction = "down"
            With .ControlEvents
                .EventName = "show_insert_coins"
                .Action = "restart"
            End With
            With .ControlEvents
                .EventName = "mode_attract_started"
                .Action = "jump"
                .Value = 0
            End With
            With .ControlEvents
                .EventName = "timer_attract_insert_coins_complete"
                .Action = "reset"
            End With
        End With

        With .SlidePlayer()
            With .EventName("attract_score_highlighted")
                .Slide  = "score"
                .Action = "play"
            End With
            With .EventName("attract_insert_coins_highlighted")
                .Slide  = "insert_coins"
                .Action = "play"
            End With
            With .EventName("attract_title1_highlighted")
                .Slide  = "title1"
                .Action = "play"
            End With
            With .EventName("attract_game_over_highlighted")
                .Slide  = "game_over_attract"
                .Action = "play"
            End With
            With .EventName("attract_grand_champion_highlighted")
                .Slide  = "grand_champion"
                .Action = "play"
            End With
            With .EventName("attract_high_scores_1_highlighted")
                .Slide  = "high_scores_1"
                .Action = "play"
            End With
            With .EventName("attract_high_scores_2_highlighted")
                .Slide  = "high_scores_2"
                .Action = "play"
            End With
            With .EventName("attract_replay_highlighted")
                .Slide  = "replay_attract"
                .Action = "play"
            End With
            With .EventName("show_insert_coins")
                .Slide = "insert_coins"
                .Action = "play"
            End With
            With .EventName("timer_attract_insert_coins_complete")
                .Slide = "insert_coins"
                .Action = "remove"
            End With
            With .EventName("player_will_add")
                .Slide = "insert_coins"
                .Action = "remove"
            End With
        End With

        With .LightPlayer()
            With .EventName("attract_intro")
                With .Lights("GI")
                    .Color = GIColorAttract
                    .Fade  = 1200
                End With
            End With
            With .EventName("attract_gi_dim")
                With .Lights("GI")
                    .Color = GIColorAttractDim
                    .Fade  = 1200
                End With
            End With
            With .EventName("attract_gi_bright")
                With .Lights("GI")
                    .Color = GIColorAttract
                    .Fade  = 1200
                End With
            End With
        End With

        With .Timers("attract_pulse")
            .TickInterval = 1000
            .StartValue = 0
            .EndValue = 4
            With .ControlEvents()
                .EventName = "attract_intro"
                .Action = "start"
            End With
            With .ControlEvents()
                .EventName = "timer_attract_pulse_complete"
                .Action = "restart"
            End With
        End With

        ' Plays sounds during this mode
        With .SoundPlayer()

            'Music

            With .EventName("play_mus_married")
                .Key = "key_mus_married"
                .Sound = "mus_married"
            End With
            With .EventName("mode_attract_stopped")
                .Key = "key_mus_married"
                .Sound = "mus_married"
                .Action = "stop"
            End With
        End With

    End With

End Sub
