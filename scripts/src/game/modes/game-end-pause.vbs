' Game End Pause Mode
'
' After the last ball's bonus, hold the score slide on screen for a moment before
' high score initials entry (GLF high_scores, priority 1500) or match (priority 1000).
'
' game_ending is a queue event and this mode uses the wait queue at a higher priority
' than both, so they don't start until this mode stops. It stops when its timer
' completes, posting game_end_pause_done (the table's high_score mode starts on that).

Const GameEndPauseMs = 1500

Sub CreateGameEndPauseMode()
    With CreateGlfMode("game_end_pause", 1600)
        .StartEvents = Array("game_ending")
        .StopEvents = Array("game_end_pause_done")
        .GameMode = False
        .UseWaitQueue = True

        With .EventPlayer()
            .Add "timer_game_end_pause_complete", Array("game_end_pause_done")
        End With

        With .Timers("game_end_pause")
            .TickInterval = GameEndPauseMs
            .StartValue = 0
            .EndValue = 1
            .StartRunning = True
        End With
    End With
End Sub
