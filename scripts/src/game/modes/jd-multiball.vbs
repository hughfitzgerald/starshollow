Sub CreateJDMultiballMode()
    With CreateGlfMode("jd_multiball", 1000)
        .StartEvents = Array("start_jd_multiball")
        .StopEvents = Array("mode_base_stopping", "multiball_jdmb_ended")

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

        With .SlidePlayer()
            With .EventName("multiball_jdmb_started")
                .Slide  = "multiball"
                .Action = "play"
                .Expire = 3
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
    End With
End Sub