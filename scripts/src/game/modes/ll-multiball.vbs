Sub CreateLLMultiballMode()
    With CreateGlfMode("ll_multiball", 1005)
        .StartEvents = Array("start_ll_multiball")
        .StopEvents = Array("mode_base_stopping", "captive_ball_is_home", "bonus_start")
        With .EventPlayer()
            .Add "mode_ll_multiball_started", Array("base_music_stop", "play_multiball_slide", ModeSlideEvent("play_llmb_mode_slide", "LOCK-AWAY LOGAN", "HIT BUMPERS TO BASH LOGAN"))
            .Add "mode_ll_multiball_stopping", Array("base_music_start", "open_orbit_gate2")

            .Add "initiate_ll_multiball", Array("close_orbit_gate2", "release_scoop_hold", "clear_multiball_locks", "open_captive_diverter")
            
            'Scoring
            .Add "logan_bumper_hit", Array(ScoreEvent(LoganBumperScore, NoMultiplier))
            .Add "logan_totally_bashed", Array(ScoreEvent(LoganTotallyBashedScore, NoMultiplier), ModeSlideEvent("play_llmb_mode_slide", "LOCK-AWAY LOGAN", "LOCK-AWAY LOGAN IN THE SCOOP"), "logan_totally_bashed_callouts")
            .Add "logan_ball_captured", Array(ScoreEvent(LoganLockedAwayScore, NoMultiplier), "logan_totally_bashed_callouts")

            
            .Add "captive_ball_is_home", Array("close_captive_diverter")
            .Add "multiball_locks_cleared", Array("free_captive_ball")
            

            ' Once Logan is totally bashed (win light lit), bumpers stop feeding the mode; only the scoop lock scores from here.
            .Add "auto_fire_coil_bumper1_activate{current_player.shot_win_logan_light==0}", Array("logan_bumper_hit")
            .Add "auto_fire_coil_bumper5_activate{current_player.shot_win_logan_light==0}", Array("logan_bumper_hit")

            .Add "logan_bumper_hit{current_player.mode_llmb_score>=" & LoganScoreToWin & "}", Array("logan_totally_bashed")

            .Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==0}", Array("release_scoop_hold")
            .Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==1 and machine.captive_capture_pending==0}", Array("logan_ball_captured")
            ' The kick to the captive spot failed and the ball is back in the scoop: kick again, no second award.
            .Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==1 and machine.captive_capture_pending==1}", Array("capture_captive_ball")
        End With
        
        With .Counters("logan_bash_progress")
            .CountEvents = Array("logan_bumper_hit")
            .CountCompleteValue = 10
            .EventsWhenComplete = Array("logan_bash_progress")
            .RestartEvents = Array("logan_bash_progress")
        End With

        With .RandomEventPlayer()
            With .EventName("logan_bumper_hit")
                .Add "logan_bumper_callout1", 1
                .Add "logan_bumper_callout2", 1
                .Add "logan_bumper_callout3", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("logan_bash_progress")
                .Add "logan_bash_progress_callout1", 1
                .Add "logan_bash_progress_callout2", 1
                .Add "logan_bash_progress_callout3", 1
                .Add "logan_bash_progress_callout4", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("logan_totally_bashed_callouts")
                .Add "logan_totally_bashed_callout1", 1
                .Add "logan_totally_bashed_callout2", 1
                .Add "logan_totally_bashed_callout3", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("ll_multiball_lost")
                .Add "ll_multiball_lost_callout1", 1
                .Add "ll_multiball_lost_callout2", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        With .SoundPlayer()
            With .EventName("ll_multiball_lost_callout1")
                .Key = "key_voc_ll_multiball_lost_callout1"
                .Sound = "voc_logan_cmonroryletsforget"
                .Priority = 2
            End With
            With .EventName("ll_multiball_lost_callout2")
                .Key = "key_voc_ll_multiball_lost_callout2"
                .Sound = "voc_logan_seeyaace"
                .Priority = 2
            End With
            With .EventName("logan_bumper_callout1")
                .Key = "key_voc_logan_hit1"
                .Sound = "voc_logan_hit1"
            End With
            With .EventName("logan_bumper_callout2")
                .Key = "key_voc_logan_hit2"
                .Sound = "voc_logan_hit2"
            End With
            With .EventName("logan_bumper_callout3")
                .Key = "key_voc_logan_hit3"
                .Sound = "voc_logan_hit3"
            End With
            With .EventName("logan_bash_progress_callout1")
                .Key = "key_voc_logan_bash_progress_callout1"
                .Sound = "voc_logan_notsurehowwell"
                .Priority = 1
            End With
            With .EventName("logan_bash_progress_callout2")
                .Key = "key_voc_logan_bash_progress_callout2"
                .Sound = "voc_logan_inmymind"
                .Priority = 1
            End With
            With .EventName("logan_bash_progress_callout3")
                .Key = "key_voc_logan_bash_progress_callout3"
                .Sound = "voc_logan_roryiloveyou"
                .Priority = 1
            End With
            With .EventName("logan_bash_progress_callout4")
                .Key = "key_voc_logan_bash_progress_callout4"
                .Sound = "voc_logan_ivebeenfaithful"
                .Priority = 1
            End With
            With .EventName("logan_totally_bashed_callout1")
                .Key = "key_voc_logan_totally_bashed_callout1"
                .Sound = "voc_logan_onedoor"
                .Priority = 2
            End With
            With .EventName("logan_totally_bashed_callout2")
                .Key = "key_voc_logan_totally_bashed_callout2"
                .Sound = "voc_logan_porschedealer"
                .Priority = 2
            End With
            With .EventName("logan_totally_bashed_callout3")
                .Key = "key_voc_logan_totally_bashed_callout3"
                .Sound = "voc_logan_wasteofatrustfund"
                .Priority = 2
            End With
            With .EventName("mode_ll_multiball_started")
                .Key = "key_voc_logan_multiballintro"
                .Sound = "voc_logan_multiballintro"
                .EventsWhenStopped = Array("initiate_ll_multiball")
            End With
            With .EventName("initiate_ll_multiball")
                .Key = "key_mus_llmb"
                .Sound = "mus_llmb"
            End With
            With .EventName("mode_ll_multiball_stopping")
                .Key = "key_mus_llmb"
                .Sound = "mus_llmb"
                .Action = "stop"
            End With
        End With

        With .VariablePlayer()
            With .EventName("mode_ll_multiball_started")
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_llmb_score}"
                End With
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = """"""
                End With
            End With
            With .EventName("logan_totally_bashed")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = LoganTotallyBashedScore
                End With
                With .Variable("mode_llmb_score")
                    .Action = "add"
                    .Int = LoganTotallyBashedScore
                End With
            End With
            With .EventName("logan_ball_captured")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = LoganLockedAwayScore
                End With
                With .Variable("mode_llmb_score")
                    .Action = "add"
                    .Int = LoganLockedAwayScore
                End With
            End With
            With .EventName("logan_bumper_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = LoganBumperScore
                End With
                With .Variable("mode_llmb_score")
                    .Action = "add"
                    .Int = LoganBumperScore
                End With
            End With


            With .EventName("multiball_llmb_shoot_again")
                With .Variable("llmb_shoot_again_active")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("multiball_llmb_shoot_again_ended")
                With .Variable("llmb_shoot_again_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
            With .EventName("multiball_llmb_reset_event")
                With .Variable("llmb_shoot_again_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
            With .EventName("multiball_llmb_ended")
                With .Variable("llmb_shoot_again_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
        End With

        With .Multiballs("llmb")
            ' llmb_ready is posted from _configuration.vbs once the lock balls are back
            ' and the captive ball has been freed, so this always counts three balls.
            .StartEvents = Array("llmb_ready")
            .BallCount = 1
            .BallCountType = "add"
            .ShootAgain = 15000
            .HurryUp = 3000
            .GracePeriod = 2000
        End With

        With .SlidePlayer()
            With .EventName("logan_bumper_hit")
                .Slide = "logan-hit"
                .Action = "play"
                .Expire = 1
                .Priority = 1010
            End With
            With .EventName("play_multiball_slide")
                .Slide  = "multiball"
                .Action = "play"
                .Expire = 3
                .Priority = 1010
            End With
            With .EventName("play_llmb_mode_slide")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_ll_multiball_stopping")
                .Slide = "mode"
                .Action = "remove"
            End With
        End With



        With .Shots("win_logan_light")
            .Persist = True
            .Profile = "llmb"
            With .Tokens()
                .Add "lights", "l72"
                .Add "color", LoganColor
            End With
            With .ControlEvents()
                .Events = Array("mode_ll_multiball_started", "mode_base_stopping")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("logan_totally_bashed")
                .State = 1
            End With
        End With

        With .ShotProfiles("llmb")
            With .States("unlit")
                .Key = "key_llmb_unlit"
                .Show = "off"
            End With
            With .States("lit")
                .Key = "key_llmb_lit"
                .Show = "flash_color_with_fade"
                .Speed = 7
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
        End With

        'Define the muiltball shoot again light
        With .Shots("ll_mb_shoot_again")
            .Profile = "shoot_again"
            With .Tokens()
                .Add "color", MultiballColor
            End With
            With .ControlEvents()
                .Events = Array("multiball_llmb_started")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("multiball_llmb_hurry_up")
                .State = 2
            End With
            .RestartEvents = Array("multiball_llmb_shoot_again_ended")
        End With
    End With
End Sub