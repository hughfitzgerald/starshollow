Const LoganBumperScore = 10000
Const LoganTotallyBashedScore = 10000000
Const LoganLockedAwayScore = 10000000
Const LoganScoreToWin = 1500000
Sub CreateLLMultiballMode()
    With CreateGlfMode("ll_multiball", 1005)
        .StartEvents = Array("start_ll_multiball")
        .StopEvents = Array("mode_base_stopping", "captive_ball_is_home", "mode_eob_bonus_started")
        .Debug = True

        With .EventPlayer()
            .Add "mode_ll_multiball_started", Array("release_scoop_hold", "clear_multiball_locks", "disable_captive_ball_kicker_hold", "open_captive_diverter", "play_multiball_slide")
            .Add "captive_ball_is_home", Array("close_captive_diverter")
            .Add "multiball_locks_cleared", Array("free_captive_ball")
            .Add "release_scoop_hold", Array("disable_scoop_hold")

            .Add "auto_fire_coil_bumper1_activate", Array("logan_bumper_hit")
            ' .Add "auto_fire_coil_bumper3_activate", Array("logan_bumper_hit")
            .Add "auto_fire_coil_bumper5_activate", Array("logan_bumper_hit")

            .Add "logan_bumper_hit{current_player.mode_llmb_score>=" & LoganScoreToWin & "}", Array("logan_totally_bashed")

            .Add "logan_totally_bashed", Array("enable_scoop_hold")
            .Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==0}", Array("disable_scoop_hold")
            .Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==1}", Array("logan_ball_captured")
        End With

        With .SoundPlayer()
            With .EventName("auto_fire_coil_bumper1_activate")
                .Key = "key_voc_logan_hit1"
                .Sound = "voc_logan_hit1"
            End With
            ' With .EventName("auto_fire_coil_bumper3_activate")
            '     .Key = "key_voc_logan_hit2"
            '     .Sound = "voc_logan_hit2"
            ' End With
            With .EventName("auto_fire_coil_bumper5_activate")
                .Key = "key_voc_logan_hit3"
                .Sound = "voc_logan_hit3"
            End With
        End With

        With .VariablePlayer()
            With .EventName("mode_ll_multiball_started")
                With .Variable("mode_display_text")
                    .Action = "set"
                    .String = """LOCK-AWAY LOGAN"""
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_llmb_score}"
                End With
                With .Variable("mode_display_instructions")
                    .Action = "set"
                    .String = """HIT BUMPERS TO BASH LOGAN"""
                End With
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = """"""
                End With
            End With
            With .EventName("logan_totally_bashed")
                With .Variable("mode_display_instructions")
                    .Action = "set"
                    .String = """LOCK-AWAY LOGAN IN THE SCOOP"""
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = LoganTotallyBashedScore
                End With
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
                With .Variable("score")
                    .Action = "add"
                    .Int = LoganLockedAwayScore
                End With
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
                With .Variable("score")
                    .Action = "add"
                    .Int = LoganBumperScore
                End With
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
            .StartEvents = Array("all_balls_returned")
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
            With .EventName("mode_ll_multiball_started")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_ll_multiball_stopping")
                .Slide = "mode"
                .Action = "stop"
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