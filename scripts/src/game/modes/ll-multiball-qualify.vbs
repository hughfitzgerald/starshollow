
Sub CreateLLMultiballQualifyMode()
    Dim x

    With CreateGlfMode("ll_multiball_qualify", 220)
        .StartEvents = Array("mode_base_started{machine.game_modes_enabled == 1}", "mode_ll_multiball_stopped", "mode_jd_multiball_stopped", "mode_dance_marathon_stopped", "mode_town_meeting_stopped", "mode_dinner_stopped", "mode_fd_punch_stopped", "mode_kims_antiques_stopped", "mode_lbtb_stopped")
        .StopEvents = Array("mode_base_stopping","mode_ll_multiball_started", "mode_jd_multiball_started", "mode_dance_marathon_started", "mode_town_meeting_started", "mode_dinner_started", "mode_fd_punch_started", "mode_kims_antiques_started", "mode_lbtb_started")

        With .EventPlayer()
            ' The captive ball on its way home from a drain (drain subway or captive recovery)
            ' passes through the captive ramp kicker too. That is not a Logan lock: only hold
            ' a ball there while the captive ball is home. Logan multiball ending on a double
            ' drain restarts this mode during ball_ending, while that ball may be on its way.
            .Add "mode_ll_multiball_qualify_started{machine.captive_ball_captive == 1}", Array("enable_captive_ramp_kicker_hold")
            .Add "mode_ll_multiball_qualify_started{machine.captive_ball_captive == 0}", Array("disable_captive_ramp_kicker_hold")
            .Add "captive_ball_is_home", Array("enable_captive_ramp_kicker_hold")
            .Add "mode_ll_multiball_qualify_started{current_player.shot_logan_qualify == 2}", Array("dt2_knockdown")
            .Add "mode_ll_multiball_qualify_started{current_player.shot_logan_qualify == 3 and device.ball_holds.captive_ramp_kicker_hold.balls_held == 0}", Array("dt2_knockdown","logan_back_to_2")
            ' A ball held in the captive ramp kicker only completes qualify when the mode
            ' restarts mid-ball (another mode ended). At the start of a new ball it is the
            ' captive ball on its way home after mode_base_stopping released it.
            .Add "mode_ll_multiball_qualify_started{device.ball_holds.captive_ramp_kicker_hold.balls_held == 1 and current_player.ball_just_started == 0}", Array("logan_qualify_complete")
            .Add "mode_base_stopping{device.ball_holds.captive_ramp_kicker_hold.balls_held == 1}", Array("release_captive_ramp_kicker_hold")
            .Add "logan_qualify_hit1_hit", Array("dt2_knockdown")
            .Add "advance_logan", Array("dt2_knockdown", "logan_back_to_2")
            .Add "s_CaptiveRampKicker_active{machine.captive_ball_captive == 1}", Array("logan_qualify_complete")

            ' Captive ball switch hits count for nothing until the player's ball has left
            ' the plunger lane (new_ball_active clears ball_just_started), nor while the
            ' captive ball is away or still settling after landing back home: the landing
            ' and its bounces are not shots (captive_ball_captive / captive_returning, basement).
            .Add "s_captive_ball_active{current_player.logan_cooldown_active == 0 and current_player.ball_just_started == 0 and machine.captive_ball_captive == 1 and machine.captive_returning == 0}", Array("logan_captive_ball_hit")
            .Add "logan_captive_ball_hit", Array(ScoreEvent(LoganCaptiveScore, WithMultiplier))
            ' Captive hits only advance the shot to hit2. hit3 (solid) means a ball is held
            ' in the captive ramp kicker, so only logan_qualify_complete sets it.
            .Add "logan_captive_ball_hit{current_player.shot_logan_qualify < 2}", Array("logan_qualify_advance")
        End With

        With .RandomEventPlayer()
            With .EventName("logan_captive_ball_hit{current_player.shot_logan_qualify == 0}")
                .Add "logan_captive_ball_first_callout1", 1
                .Add "logan_captive_ball_first_callout2", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("logan_captive_ball_hit{current_player.shot_logan_qualify == 1}")
                .Add "logan_captive_ball_callout1", 1
                .Add "logan_captive_ball_callout2", 1
                .Add "logan_captive_ball_callout3", 1
                .Add "logan_captive_ball_callout4", 1
                .Add "logan_captive_ball_callout5", 1
                .Add "logan_captive_ball_callout6", 1
                .Add "logan_captive_ball_callout7", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        With .SoundPlayer()
            With .EventName("logan_captive_ball_callout1")
                .Key = "key_logan_captive_ball_callout1"
                .Sound = "voc_logan_arrogant"
            End With
            With .EventName("logan_captive_ball_callout2")
                .Key = "key_logan_captive_ball_callout2"
                .Sound = "voc_logan_ass"
            End With
            With .EventName("logan_captive_ball_callout3")
                .Key = "key_logan_captive_ball_callout3"
                .Sound = "voc_logan_buttfacedmiscreant"
            End With
            With .EventName("logan_captive_ball_callout4")
                .Key = "key_logan_captive_ball_callout4"
                .Sound = "voc_logan_fratboylowlife"
            End With
            With .EventName("logan_captive_ball_callout5")
                .Key = "key_logan_captive_ball_callout5"
                .Sound = "voc_logan_inconsiderate"
            End With
            With .EventName("logan_captive_ball_callout6")
                .Key = "key_logan_captive_ball_callout6"
                .Sound = "voc_logan_jerk"
            End With
            With .EventName("logan_captive_ball_callout7")
                .Key = "key_logan_captive_ball_callout7"
                .Sound = "voc_logan_mindless"
            End With
            With .EventName("logan_captive_ball_first_callout1")
                .Key = "key_logan_captive_ball_first_callout1"
                .Sound = "voc_logan_heyloganheyace"
            End With
            With .EventName("logan_captive_ball_first_callout2")
                .Key = "key_logan_captive_ball_first_callout2"
                .Sound = "voc_logan_ladies"
            End With
            With .EventName("logan_qualify_complete")
                .Key = "key_logan_qualify_complete"
                .Sound = "voc_logan_60seconds"
                .Priority = 1
            End With
        End With

        With .Shots("logan_light")
            .Profile = "logan_ball"
            With .Tokens()
                .Add "lights", "l72"
                .Add "color", LoganColor
            End With
            With .ControlEvents()
                .Events = Array("mode_ll_multiball_started", "mode_base_stopping")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("logan_qualify_complete")
                .State = 1
            End With
        End With

        With .VariablePlayer()
            With .EventName("timer_logan_cooldown_started")
                With .Variable("logan_cooldown_active")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("timer_logan_cooldown_complete")
                With .Variable("logan_cooldown_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
        End With

        With .Timers("logan_cooldown")
            .StartRunning = False
            .StartValue = 2
            .EndValue = 0
            .Direction = "down"
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "s_captive_ball_active"
                .Action = "restart"
            End With
        End With

        With .Shots("logan_qualify")
            .Persist = True
            .HitEvents = Array("logan_qualify_advance")
            .Profile = "logan_ball"
            With .Tokens()
                .Add "lights", "l57"
                .Add "color", LoganColor
            End With
            With .ControlEvents()
                .Events = Array("mode_ll_multiball_started")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("logan_back_to_2")
                .State = 2
            End With
            With .ControlEvents()
                .Events = Array("logan_qualify_complete")
                .State = 3
            End With
        End With

        With .ShotProfiles("logan_ball")
            With .States("unlit")
                .Key = "key_logan_ball_unlit"
                .Show = "off"
            End With
            With .States("hit1")
                .Key = "key_logan_ball_hit1"
                .Show = "flash_color_with_fade"
                .Speed = 2
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
            With .States("hit2")
                .Key = "key_logan_ball_hit2"
                .Show = "flash_color_with_fade"
                .Speed = 7
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
            With .States("hit3")
                .Key = "key_logan_ball_hit3"
                .Show = "flicker_color_on"
            End With
        End With
    End With
End Sub