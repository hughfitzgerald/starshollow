Sub CreateLLMultiballMode()
    With CreateGlfMode("ll_multiball", 1005)
        .StartEvents = Array("start_ll_multiball")
        .StopEvents = Array("mode_base_stopping", "multiball_llmb_ended")

        With .EventPlayer()
            .Add "mode_ll_multiball_started", Array("release_scoop_hold")
            .Add "release_scoop_hold", Array("disable_scoop_hold")
        End With

        With .Multiballs("llmb")
            .StartEvents = Array("mode_ll_multiball_started")
            .BallCount = 3
            .BallCountType = "total"
            .ShootAgain = 15000
            .HurryUp = 3000
            .GracePeriod = 2000
        End With

        ' With .SlidePlayer()
        '     With .EventName("multiball_llmb_started")
        '         .Slide  = "multiball"
        '         .Action = "play"
        '         .Expire = 3
        '     End With
        ' End With

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