
'*******************************************
'  Base Mode
'*******************************************
' Priority 110 - above attract (100), below any feature mode you add later
' (use 700+ for those) and below score (2000, when you write it).
'
' Runs for the whole of every ball. Owns anything that isn't specific to a
' feature mode: ball save, GI, the insert lights, tilt handling.
'
' No scoring anywhere in here yet - that's deliberate. When you add a score
' mode, the scoring goes on the SAME events already listed below, e.g.
'     .Add "s_ST11_active", Array("score_1000")
'
' NOTE on how the inserts reset: GlfLightPlayer.Deactivate() calls PlayOff
' for every event it registered, so when this mode stops on ball_ended the
' inserts it lit go dark automatically. You don't need an explicit reset.

Sub CreateBaseMode()

    Dim x, giName

    With CreateGlfMode("base", 110)

        .StartEvents = Array("ball_started")
        .StopEvents  = Array("ball_ended", "tilt")


        '--- Event routing -------------------------------------------------
        With .EventPlayer()

            ' Kill the attract mode as soon as a ball starts
            .Add "mode_base_started", Array("stop_attract_mode", "new_ball_started")

            ' The ball leaving the plunger lane for the first time is what
            ' actually starts play - this is what arms the ball save.
            .Add "s_Trigger1_inactive{current_player.ball_just_started == 1}", Array("new_ball_active")

            ' Once play is live, clear the just-started flag
            .Add "new_ball_active", Array("clear_ball_just_started")

            .Add "s_ST11_active", Array("lock_lit") ' TEMP: when you hit the J in "JESS" we get lock lit

            ' .Add "s_ST15_active", Array("start_multiball") ' TEMP: when you hit the D in "DEAN" we start multiball
            .Add "balldevice_lock3_ball_entered", Array("start_multiball")

            'Bumpers
            .Add "s_Bumper1_active", Array("score_5000")
            .Add "s_Bumper3_active", Array("score_5000")
            .Add "s_Bumper5_active", Array("score_5000")

            'Slingshots
            .Add "s_LeftSlingshot_active", Array("score_5000")
            .Add "s_RightSlingshot_active", Array("score_5000")

            'Spinners
            .Add "s_left_spinner_active", Array("score_3333")
            .Add "s_right_spinner_active", Array("score_3333")

        End With


        '--- Player variables ----------------------------------------------
        With .VariablePlayer()
            With .EventName("mode_base_started")
                With .Variable("ball_just_started")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("clear_ball_just_started")
                With .Variable("ball_just_started")
                    .Action = "set"
                    .Int = 0
                End With
            End With
        End With


        '--- Lights --------------------------------------------------------
        With .LightPlayer()

            ' GI full brightness for the duration of the ball.
            ' Addressed by name - see the note in _configuration.vbs.
            With .EventName("mode_base_started")
                For Each giName In GILightNames
                    With .Lights(giName)
                        .Color = GIColor2700k
                        .Fade  = 300
                    End With
                Next
            End With

            ' The eight standup targets each latch their own insert.
            ' s_ST11 -> l11, s_ST12 -> l12, ... s_ST18 -> l18
            For x = 11 To 18
                With .EventName("s_ST" & x & "_active")
                    With .Lights("l" & x)
                        .Color = StandupColor
                        .Fade  = 60
                    End With
                End With
            Next

            ' The two bonus-lane rollovers latch their inserts.
            ' s_sw8 (was sw8) -> l8, s_sw9 (was sw9) -> l9
            With .EventName("s_sw8_active")
                With .Lights("l8")
                    .Color = BonusLaneColor
                    .Fade  = 60
                End With
            End With
            With .EventName("s_sw9_active")
                With .Lights("l9")
                    .Color = BonusLaneColor
                    .Fade  = 60
                End With
            End With

        End With


        '--- Ball save -----------------------------------------------------
        ' AutoLaunch is False on purpose: this table has a mechanical
        ' plunger and no autoplunger coil. GLF will kick a fresh ball to the
        ' plunger lane and you plunge it yourself. Setting AutoLaunch = True
        ' would call glf_plunger.Eject on a MechanicalEject device, which
        ' has nothing to fire.
        With .BallSaves("new_ball")
            .ActiveTime   = 8000
            .HurryUpTime  = 3000
            .GracePeriod  = 2000
            .BallsToSave  = 1
            .AutoLaunch   = False
            .EnableEvents = Array("new_ball_active")
        End With


        '--- Hold start for 2s to abandon the game -------------------------
        With .TimedSwitches("cancel_game")
            .Switches         = Array("s_start")
            .Time             = 2000
            .EventsWhenActive = Array("glf_game_cancel")
        End With


        '--- Scoring -----------------------------------------------------
        ' With .VariablePlayer()
		' 	With .EventName("s_sw8_active")
		' 		With .Variable("score")
		' 			.Action = "add"
		' 			.Int = 10
		' 		End With
		' 	End With

		' 	With .EventName("s_sw9_active")
		' 		With .Variable("score")
		' 			.Action = "add"
		' 			.Int = 10
		' 		End With
		' 	End With

            ' ' Define events that will add points to the score
            ' With .EventName("add_score_1000")
            '     With .Variable("score")
            '         .Action = "add"
            '         .Int = 1000
            '     End With
            ' End With

            ' With .EventName("add_score_500")
            '     With .Variable("score")
            '         .Action = "add"
            '         .Int = 500
            '     End With
            ' End With

            ' With .EventName("add_score_250")
            '     With .Variable("score")
            '         .Action = "add"
            '         .Int = 250
            '     End With
            ' End With

            ' With .EventName("add_score_100")
            '     With .Variable("score")
            '         .Action = "add"
            '         .Int = 100
            '     End With
            ' End With

            ' With .EventName("add_score_10")
            '     With .Variable("score")
            '         .Action = "add"
            '         .Int = 10
            '     End With
            ' End With

        '     ' Define a bonus multiplier variable
        '     With .Variable("bonus_multiplier")
        '         .InitialValue = 1
        '     End With

        '     ' Event to increase the bonus multiplier
        '     With .EventName("increase_bonus")
        '         With .Variable("bonus_multiplier")
        '             .Action = "add"
        '             .Int = 1
        '         End With
        '     End With

        '     ' Event to add bonus points (multiplied by the current multiplier)
        '     With .EventName("add_bonus_points")
        '         With .Variable("score")
        '             .Action = "add"
        '             .Expression = "1000 * current_player.bonus_multiplier"
        '         End With
        '     End With
        ' End With

        With .MultiballLocks("multiball_lock")
            .LockDevices = Array("lock1", "lock2", "lock3")   ' Ball device that acts as the lock
            .BallsToLock = 2              ' Number of balls that can be locked
            .EnableEvents = Array("lock_lit")
            .DisableEvents = Array("lock_unlit")
            .Debug = True
        End With

        With .Multiballs("mb")
            .StartEvents = Array("start_multiball")
            .BallCount = 3
            .BallCountType = "total"
            .ShootAgain = 15000
            .HurryUp = 3000
            .GracePeriod = 2000
            .BallLocks = Array("lock1", "lock2", "lock3")
            .Debug = True
        End With

    End With

End Sub
