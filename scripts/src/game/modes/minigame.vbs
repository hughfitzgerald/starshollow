

Sub CreateMiniGameMode
    Dim x

    With CreateGlfMode("minigame", 500)
        .StartEvents = Array("new_ball_started")
        .StopEvents = Array("mode_base_stopping")

        With .EventPlayer()
            .Add "mode_minigame_started", Array("minigame_is_ready")
            .Add "check_minigame", Array("start_dance_marathon")

            .Add "minigame_is_ready", Array("enable_scoop_hold")

            ' ADD LOGIC: that looks for the next minigame, lights it, dispatches "minigame_is_ready" event
            '               this should happen at the beginning of the ball, and after each minigame is completed. Other times?
            '               WHAT ABOUT when you complete them all? Wizard mode???
        End With
    End With
End Sub