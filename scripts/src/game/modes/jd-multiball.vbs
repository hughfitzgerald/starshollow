
Sub CreateJDMultiballMode()
    With CreateGlfMode("jd_multiball", 1020)
        .StartEvents = Array("start_jd_multiball")
        'A win (jess_wins / dean_wins) stops the mode like any other ending.
        'Every stop goes through the mode_jd_multiball_stopping relay, which
        'plays a callout picked by jd_winner and waits for it to finish.
        .StopEvents = Array("mode_base_stopping", "bonus_start", "multiball_jdmb_ended", _
                            "jd_multiball_stop_for_drain", "jess_wins", "dean_wins", "tilt")

        With .EventPlayer()
            .Add "mode_jd_multiball_started", Array("base_music_stop", ModeSlideEvent("play_jdmb_mode_slide", "JESS VS. DEAN: TO THE DEATH", "TEAM JESS: LEFT RAMP - TEAM LOGAN: RIGHT RAMP"))
            .Add "initiate_jd_multiball", Array("release_scoop_hold")
            .Add "jd_multiball_end_callout_done", Array("base_music_start")
            .Add "s_complete_left_ramp_active", Array("jess_ramp")
            .Add "s_complete_right_ramp_active", Array("dean_ramp")

            'Scoring. The first hit on each ramp is a jackpot, every hit after
            'that on the same ramp is a super jackpot, and the fourth wins.
            'Score events go out straight from the shot hits, ahead of
            'jess_wins / dean_wins, which stop this mode.
            .Add "jess_unlit_hit", Array(ScoreEvent(JDRampScore, NoMultiplier), "jd_jackpot")
            .Add "dean_unlit_hit", Array(ScoreEvent(JDRampScore, NoMultiplier), "jd_jackpot")
            .Add "jess_hit1_hit", Array(ScoreEvent(JDSuperJackpotScore, NoMultiplier), "jd_super_jackpot")
            .Add "dean_hit1_hit", Array(ScoreEvent(JDSuperJackpotScore, NoMultiplier), "jd_super_jackpot")
            .Add "jess_hit2_hit", Array(ScoreEvent(JDSuperJackpotScore, NoMultiplier), "jd_super_jackpot")
            .Add "dean_hit2_hit", Array(ScoreEvent(JDSuperJackpotScore, NoMultiplier), "jd_super_jackpot")
            .Add "jess_hit3_hit", Array(ScoreEvent(JDSuperJackpotScore, NoMultiplier), ScoreEvent(JDWinScore, NoMultiplier), "jd_super_jackpot", "jd_win_score", "jess_wins")
            .Add "dean_hit3_hit", Array(ScoreEvent(JDSuperJackpotScore, NoMultiplier), ScoreEvent(JDWinScore, NoMultiplier), "jd_super_jackpot", "jd_win_score", "dean_wins")

            .Add "balldevice_scoop_ball_entered", Array("release_scoop_hold")
        End With

        With .QueueRelayPlayer()
            With .EventName("mode_jd_multiball_stopping")
                .Post    = "jd_multiball_end_callout"
                .WaitFor = "jd_multiball_end_callout_done"
            End With
            With .EventName("ball_ending")
                .Post    = "jd_multiball_stop_for_drain"
                .WaitFor = "mode_jd_multiball_stopped"
            End With
        End With

        With .Multiballs("jdmb")
            .StartEvents = Array("initiate_jd_multiball")
            .BallCount = 3
            .BallCountType = "total"
            .ShootAgain = 15000
            .HurryUp = 3000
            .GracePeriod = 2000
            .BallLocks = Array("lock1", "lock2")
        End With

        With .RandomEventPlayer()
            With .EventName("dean_ramp")
                .Add "dean_ramp_callout1", 1
                .Add "dean_ramp_callout2", 1
                .Add "dean_ramp_callout3", 1
                .Add "dean_ramp_callout4", 1
                .Add "dean_ramp_callout5", 1
                .Add "dean_ramp_callout6", 1
                .Add "dean_ramp_callout7", 1
                .Add "dean_ramp_callout8", 1
                .Add "dean_ramp_callout9", 1
                .Add "dean_ramp_callout10", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("jess_ramp")
                .Add "jess_ramp_callout1", 1
                .Add "jess_ramp_callout2", 1
                .Add "jess_ramp_callout3", 1
                .Add "jess_ramp_callout4", 1
                .Add "jess_ramp_callout5", 1
                .Add "jess_ramp_callout6", 1
                .Add "jess_ramp_callout7", 1
                .Add "jess_ramp_callout8", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            'End callouts: jd_winner is 0 (no winner), 1 (Jess) or 2 (Dean).
            With .EventName("jd_multiball_end_callout{current_player.jd_winner == 1}")
                .Add "jess_wins_callout1", 1
                .Add "jess_wins_callout2", 1
                .Add "jess_wins_callout3", 1
                .Add "jess_wins_callout4", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("jd_multiball_end_callout{current_player.jd_winner == 2}")
                .Add "dean_wins_callout1", 1
                .Add "dean_wins_callout2", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("jd_multiball_end_callout{current_player.jd_winner == 0}")
                .Add "jd_multiball_end_callout1", 1
                .Add "jd_multiball_end_callout2", 1
                .Add "jd_multiball_end_callout3", 1
                .Add "jd_multiball_end_callout4", 1
                .Add "jd_multiball_end_callout5", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        With .SoundPlayer()
            With .EventName("mode_jd_multiball_started")
                .Key = "key_voc_rory_deanmeetjess"
                .Sound = "voc_rory_deanmeetjess"
                .EventsWhenStopped = Array("initiate_jd_multiball")
            End With
            With .EventName("dean_ramp_callout1")
                .Key = "key_voc_tall"
                .Sound = "voc_tall"
            End With
            With .EventName("dean_ramp_callout2")
                .Key = "key_voc_exboyfriend"
                .Sound = "voc_exboyfriend"
            End With
            With .EventName("dean_ramp_callout3")
                .Key = "key_voc_dean_yousaidboyfriend"
                .Sound = "voc_dean_yousaidboyfriend"
            End With
            With .EventName("dean_ramp_callout4")
                .Key = "key_voc_dean_imgoingwithyou"
                .Sound = "voc_dean_imgoingwithyou"
            End With
            With .EventName("dean_ramp_callout5")
                .Key = "key_voc_dean_sawyoustandinginline"
                .Sound = "voc_dean_sawyoustandinginline"
            End With
            With .EventName("dean_ramp_callout6")
                .Key = "key_voc_dean_necklace"
                .Sound = "voc_dean_necklace"
            End With
            With .EventName("dean_ramp_callout7")
                .Key = "key_voc_dean_pinkmoon"
                .Sound = "voc_dean_pinkmoon"
            End With
            With .EventName("dean_ramp_callout8")
                .Key = "key_voc_dean_notgoinganywhere"
                .Sound = "voc_dean_notgoinganywhere"
            End With
            With .EventName("dean_ramp_callout9")
                .Key = "key_voc_dean_ifyouhateme"
                .Sound = "voc_dean_ifyouhateme"
            End With
            With .EventName("dean_ramp_callout10")
                .Key = "key_voc_dean_dontyoudaremove"
                .Sound = "voc_dean_dontyoudaremove"
            End With
            With .EventName("initiate_jd_multiball")
                .Key = "key_mus_jdmb"
                .Sound = "mus_jdmb"
            End With
            With .EventName("jd_multiball_end_callout")
                .Key = "key_mus_jdmb"
                .Sound = "mus_jdmb"
                .Action = "stop"
            End With
            With .EventName("jess_ramp_callout1")
                .Key = "key_voc_jess_areyounervous"
                .Sound = "voc_jess_areyounervous"
            End With
            With .EventName("jess_ramp_callout2")
                .Key = "key_voc_jess_crazyprobably"
                .Sound = "voc_jess_crazyprobably"
            End With
            With .EventName("jess_ramp_callout3")
                .Key = "key_voc_jess_doesheknowbjork"
                .Sound = "voc_jess_doesheknowbjork"
            End With
            With .EventName("jess_ramp_callout4")
                .Key = "key_voc_jess_dropoutofyale"
                .Sound = "voc_jess_dropoutofyale"
            End With
            With .EventName("jess_ramp_callout5")
                .Key = "key_voc_jess_gladyourehere"
                .Sound = "voc_jess_gladyourehere"
            End With
            With .EventName("jess_ramp_callout6")
                .Key = "key_voc_jess_iknowyoubetterthananyone"
                .Sound = "voc_jess_iknowyoubetterthananyone"
            End With
            With .EventName("jess_ramp_callout7")
                .Key = "key_voc_jess_meanttobetogether"
                .Sound = "voc_jess_meanttobetogether"
            End With
            With .EventName("jess_ramp_callout8")
                .Key = "key_voc_jess_youherealone"
                .Sound = "voc_jess_youherealone"
            End With
            With .EventName("jess_wins_callout1")
                .Key = "key_voc_jess_andyouloveit"
                .Sound = "voc_jess_andyouloveit"
                .Priority = 1
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("jess_wins_callout2")
                .Key = "key_voc_jess_couldnthavedoneitwithoutyou"
                .Sound = "voc_jess_couldnthavedoneitwithoutyou"
                .Priority = 1
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("jess_wins_callout3")
                .Key = "key_voc_jess_drivingaround"
                .Sound = "voc_jess_drivingaround"
                .Priority = 1
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("jess_wins_callout4")
                .Key = "key_voc_jess_thisonewasnthalfbad"
                .Sound = "voc_jess_thisonewasnthalfbad"
                .Priority = 1
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("dean_wins_callout1")
                .Key = "key_voc_dean_iloveyourory"
                .Sound = "voc_dean_iloveyourory"
                .Priority = 1
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("dean_wins_callout2")
                .Key = "key_voc_dean_perfectmoment"
                .Sound = "voc_dean_perfectmoment"
                .Priority = 1
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("jd_multiball_end_callout1")
                .Key = "key_voc_jess_idontdeservethisrory"
                .Sound = "voc_jess_idontdeservethisrory"
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("jd_multiball_end_callout2")
                .Key = "key_voc_jess_lovehuh"
                .Sound = "voc_jess_lovehuh"
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("jd_multiball_end_callout3")
                .Key = "key_voc_jess_youkissedme"
                .Sound = "voc_jess_youkissedme"
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("jd_multiball_end_callout4")
                .Key = "key_voc_dean_gladyouenjoyedit"
                .Sound = "voc_dean_gladyouenjoyedit"
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
            With .EventName("jd_multiball_end_callout5")
                .Key = "key_voc_dean_goodbyelorelaigilmore"
                .Sound = "voc_dean_goodbyelorelaigilmore"
                .EventsWhenStopped = Array("jd_multiball_end_callout_done")
            End With
        End With

        With .VariablePlayer()
            With .EventName("mode_jd_multiball_started")
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_jdmb_score}"
                End With
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = """"""
                End With
                With .Variable("jd_winner")
                    .Action = "set"
                    .Int = 0
                End With
            End With
            With .EventName("jess_wins")
                With .Variable("jd_winner")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("dean_wins")
                With .Variable("jd_winner")
                    .Action = "set"
                    .Int = 2
                End With
            End With
            With .EventName("jd_jackpot")
                With .Variable("mode_jdmb_score")
                    .Action = "add"
                    .Int = JDRampScore
                End With
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = JDRampScore
                End With
            End With
            With .EventName("jd_super_jackpot")
                With .Variable("mode_jdmb_score")
                    .Action = "add"
                    .Int = JDSuperJackpotScore
                End With
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = JDSuperJackpotScore
                End With
            End With
            With .EventName("jd_win_score")
                With .Variable("mode_jdmb_score")
                    .Action = "add"
                    .Int = JDWinScore
                End With
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = JDWinScore
                End With
            End With
        End With

        With .SlidePlayer()
            With .EventName("multiball_jdmb_started")
                .Slide  = "multiball"
                .Action = "play"
                .Expire = 3
            End With
            With .EventName("play_jdmb_mode_slide")
                .Slide  = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_jd_multiball_ending")
                .Slide  = "mode"
                .Action = "remove"
            End With
        End With

        With .WidgetPlayer()
            With .EventName("jess_ramp")
                .Widget = "team_jess"
                .Action = "show"
                .Expire = 1.3
            End With
            With .EventName("dean_ramp")
                .Widget = "team_dean"
                .Action = "show"
                .Expire = 1.3
            End With
            With .EventName("jess_wins")
                .Widget = "jess_wins"
                .Action = "show"
                .Expire = 1.3
            End With
            With .EventName("dean_wins")
                .Widget = "dean_wins"
                .Action = "show"
                .Expire = 1.3
            End With
        End With

        'Define the muiltball shoot again light
        With .Shots("jd_mb_shoot_again")
            .Profile = "shoot_again"
            With .Tokens()
                .Add "color", MultiballColor
            End With
            With .ControlEvents()
                .Events = Array("multiball_jdmb_started")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("multiball_jdmb_hurry_up")
                .State = 2
            End With
            .RestartEvents = Array("multiball_jdmb_shoot_again_ended")
        End With

        With .Shots("jess")
            .Profile = "jd_ramp"
            .Switch = "s_complete_left_ramp"
            .DisableEvents = Array("mode_jd_multiball_stopping")
            With .Tokens()
                .Add "color", MultiballColor
                .Add "lights", "l53"
            End With
            With .ControlEvents()
                .Events = Array("multiball_jdmb_started")
                .State = 0
            End With
        End With

        With .Shots("dean")
            .Profile = "jd_ramp"
            .Switch = "s_complete_right_ramp"
            .DisableEvents = Array("mode_jd_multiball_stopping")
            
            With .Tokens()
                .Add "color", MultiballColor
                .Add "lights", "l55"
            End With
            With .ControlEvents()
                .Events = Array("multiball_jdmb_started")
                .State = 0
            End With
        End With

        With .ShotProfiles("jd_ramp")
            With .States("unlit")
                .Key = "key_jd_ramp_unlit"
                .Show = "off"
            End With
            With .States("hit1")
                .Key = "key_jd_ramp_hit1"
                .Show = "flash_color_with_fade"
                .Speed = 5
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
            With .States("hit2")
                .Key = "key_jd_ramp_hit2"
                .Show = "flash_color_with_fade"
                .Speed = 10
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
            With .States("hit3")
                .Key = "key_jd_ramp_hit3"
                .Show = "flash_color_with_fade"
                .Speed = 20
                With .Tokens()
                    .Add "fade", 500
                End With
            End With
        End With
    End With
End Sub