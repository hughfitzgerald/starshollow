Sub CreateJDMultiballMode()
    With CreateGlfMode("jd_multiball", 1000)
        .StartEvents = Array("start_jd_multiball")
        .StopEvents = Array("mode_base_stopping", "mode_eob_bonus_started", "multiball_jdmb_ended", "jess_wins", "dean_wins")

        With .EventPlayer()
            .Add "s_complete_left_ramp_active", Array("jess_ramp")
            .Add "s_complete_right_ramp_active", Array("dean_ramp")
            .Add "jess_hit3_hit", Array("jess_wins")
            .Add "dean_hit3_hit", Array("dean_wins")
        End With

        With .Multiballs("jdmb")
            .StartEvents = Array("mode_jd_multiball_started")
            .BallCount = 3
            .BallCountType = "total"
            .ShootAgain = 15000
            .HurryUp = 3000
            .GracePeriod = 2000
            .BallLocks = Array("lock1", "lock2")
            .Debug = True
        End With

        With .RandomEventPlayer()
            With .EventName("dean_ramp")
                .Add "tall_callout", 1
                .Add "exboyfriend_callout", 1
            End With
        End With

        With .SoundPlayer()
            With .EventName("tall_callout")
                .Key = "key_voc_tall"
                .Sound = "voc_tall"
            End With
            With .EventName("exboyfriend_callout")
                .Key = "key_voc_exboyfriend"
                .Sound = "voc_exboyfriend"
            End With
        End With

        With .SlidePlayer()
            With .EventName("multiball_jdmb_started")
                .Slide  = "multiball"
                .Action = "play"
                .Expire = 3
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
            With .Tokens()
                .Add "color", MultiballColor
                .Add "lights", "l53"
            End With
        End With

        With .Shots("dean")
            .Profile = "jd_ramp"
            .Switch = "s_complete_right_ramp"
            With .Tokens()
                .Add "color", MultiballColor
                .Add "lights", "l55"
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