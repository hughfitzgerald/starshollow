' Score Mode.
'
' This mode manages scoring and score multipliers. It is the only place the
' "score" player variable is changed: everything else awards points with
' ScoreEvent / ScoreEventExpr (see _scores.vbs), which say whether the
' playfield multiplier (current_player.scoring_multiplier) applies.
'
'   score_<points>                     points x playfield multiplier
'   score_<points>_flat                points
'   score_dynamic:{points:<expr>}      expr x playfield multiplier
'   score_dynamic_flat:{points:<expr>} expr
'
' There are also playfield and bonus multiplier events defined below.



Sub CreateScoreMode()
    Dim x

    With CreateGlfMode("score", 2000)

        'Define the events that start and stop this mode
        .StartEvents = Array("game_start")
        .StopEvents = Array("game_ended")

        'The variable player will update machine and player varibles
        With .VariablePlayer()

            'One pair of events for every value defined with ScoreX()
            For each x in ScoreValues.Items
                With .EventName(ScoreEvent(x, WithMultiplier))
                    With .Variable("score")
                        .Action = "add"
                        .Int = x & " * current_player.scoring_multiplier"
                    End With
                End With
                With .EventName(ScoreEvent(x, NoMultiplier))
                    With .Variable("score")
                        .Action = "add"
                        .Int = x
                    End With
                End With
            Next

            'Amounts worked out when they are awarded
            With .EventName("score_dynamic")
                With .Variable("score")
                    .Action = "add"
                    .Int = "kwargs.points * current_player.scoring_multiplier"
                End With
            End With
            With .EventName("score_dynamic_flat")
                With .Variable("score")
                    .Action = "add"
                    .Int = "kwargs.points"
                End With
            End With

            With .EventName("2x_qualified")
                With .Variable("bonus_x")
                    .Action = "set"
                    .Int = 2
                End With
            End With
            With .EventName("3x_qualified")
                With .Variable("bonus_x")
                    .Action = "set"
                    .Int = 4
                End With
            End With
            With .EventName("4x_qualified")
                With .Variable("bonus_x")
                    .Action = "set"
                    .Int = 6
                End With
            End With
            With .EventName("5x_qualified")
                With .Variable("bonus_x")
                    .Action = "set"
                    .Int = 8
                End With
            End With

		End With

        
        'Replay (awarded by ReplayCheck in _configuration.vbs). Here rather than
        'in base, which has stopped by the time the end of ball bonus is added.
        'A text widget only draws over the scoreboard, though, so a replay
        'earned by the bonus itself won't show while the bonus slide is up.
        With .WidgetPlayer()
            With .EventName("replay_awarded")
                .Widget = "replay"
                .Action = "play"
                .Expire = 2
            End With
        End With

    End With

End Sub
