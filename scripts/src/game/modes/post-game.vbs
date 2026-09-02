
Sub CreatePostGameMode()
    Dim x

    With CreateGlfMode("post_game", 105)
        .StartEvents = Array("game_ended","test_post_game")
        .StopEvents = Array("stop_post_game_mode",GLF_BALL_STARTED)

        With .EventPlayer()
            .Add "mode_post_game_started", Array("play_mus_sad")

            .Add "mus_sad_stopped", Array("stop_post_game_mode")
            .Add "timer_post_game_complete", Array("stop_post_game_mode")

            .Add "stop_post_game_mode", Array("stop_mus_sad", "start_attract_mode")
        End With

        With .SoundPlayer()
            With .EventName("mode_post_game_started")
                .Key = "key_mus_sad"
                .Sound = "mus_sad"
            End With
            With .EventName("mode_post_game_stopped")
                .Key = "key_mus_sad"
                .Sound = "mus_sad"
                .Action = "stop"
            End With
        End With

        With .Timers("post_game")
            .StartRunning = True
            .TickInterval = 1000
            .StartValue = 0
            .EndValue = 10
        End With
    End With
End Sub