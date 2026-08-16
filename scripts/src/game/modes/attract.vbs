
'*******************************************
'  Attract Mode
'*******************************************
' Priority 100 - lowest of everything. Runs whenever no game is in play.
'
' Deliberately minimal: it does NOT need to do anything to let you start a
' game. GLF handles that entirely on its own:
'
'   Glf_KeyUp(StartGameKey)
'     -> DispatchRelayPinEvent "request_to_start_game"
'        -> Glf_BallController  (verifies all 5 balls are in the trough)
'        -> Glf_StartGame       (adds player 1, dispatches game_start)
'        -> Glf_ReleaseBall     (kicks a ball to the plunger lane)
'
' So if the start button does nothing, the cause is almost always the ball
' controller check failing - GLF counts swTrough1..5 + Drain and refuses to
' start unless the count equals tnob. Turn on "Glf Debug Log" in the F6
' tweak menu to see it reject.
'
' All this mode does is pulse the GI so the table doesn't look dead, and
' get out of the way the moment a game starts.

Sub CreateAttractMode()

    Dim giName

    With CreateGlfMode("attract", 100)

        .StartEvents = Array("start_attract_mode","reset_complete")
        .StopEvents  = Array("game_started", "stop_attract_mode")



        With .ShowPlayer()
            With .EventName("mode_attract_started")
                .Key = "key_mode_attract_started"
                .Show = "new_animation"
                .Speed = 1
            End With
        End With

        ' Slow GI pulse so the table reads as "on" but idle.
        ' GI lights are addressed by name, not by tag - see the long note in
        ' _configuration.vbs for why .Lights("GI") would crash Glf_Init.
        With .LightPlayer()
            With .EventName("mode_attract_started")
                For Each giName In GILightNames
                    With .Lights(giName)
                        .Color = GIColorAttract
                        .Fade  = 1200
                    End With
                Next
            End With
            With .EventName("attract_gi_dim")
                For Each giName In GILightNames
                    With .Lights(giName)
                        .Color = GIColorAttractDim
                        .Fade  = 1200
                    End With
                Next
            End With
            With .EventName("attract_gi_bright")
                For Each giName In GILightNames
                    With .Lights(giName)
                        .Color = GIColorAttract
                        .Fade  = 1200
                    End With
                Next
            End With
        End With

        With .EventPlayer()
            .Add "mode_attract_started", Array("play_mus_married")
            .Add "mode_attract_stopping", Array("stop_mus_married")
            .Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 1}", Array("attract_gi_dim")
            .Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 3}", Array("attract_gi_bright")
        End With

        With .Timers("attract_pulse")
            .TickInterval = 1000
            .StartValue = 0
            .EndValue = 4
            With .ControlEvents()
                .EventName = "mode_attract_started"
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
            With .EventName("stop_mus_married")
                .Key = "key_mus_married"
                .Sound = "mus_married"
                .Action = "stop"
            End With
        End With

    End With

End Sub
