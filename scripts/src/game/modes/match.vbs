Sub CreateMatchMode()
    With EnableGlfMatch()
        .MatchPercentage = 15
        .DisplayTimeMs = 4000   'hold game_ending (and the match slide) before game_ended fires

        With .Mode.Timers("match")
            .StartValue = 0
            .EndValue = 2
            .StartRunning = True
        End With

        With .Mode.EventPlayer()
            .Add "timer_match_complete", Array("play_match_knocker")
        End With

        With .Mode.SlidePlayer()
            With .EventName("match_no_match")
                .Slide = "match"
                .Action = "play"
            End With
            With .EventName("match_has_match")
                .Slide = "match"
                .Action = "play"
            End With
        End With
    End With
End Sub