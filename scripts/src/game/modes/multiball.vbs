
' Multiball Mode
'
' To start the multiball:
'  - TODO: write this...
'
' TODO: Add state machine to handle locks, activating kickers, etc.


Sub CreateMultiballMode()
    Dim x

    With CreateGlfMode("multiball", 1000)
        .Debug = True
        
        'Define the events that start and stop this mode
        .StartEvents = Array("ball_started")
        .StopEvents = Array("mode_base_stopping")


        'The event player will respond to events during this mode
        With .EventPlayer()
            .Debug = True

            .Add "s_ST11_active", Array("lock_lit") ' TEMP: when you hit the J in "JESS" we get lock lit
        End With

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


        'SHOTS

        'Define the muiltball shoot again light
        With .Shots("mb_shoot_again")
            .Profile = "shoot_again"
            With .Tokens()
                .Add "color", MultiballColor
            End With
            With .ControlEvents()
                .Events = Array("start_multiball")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("multiball_mb_hurry_up")
                .State = 2
            End With
            .RestartEvents = Array("multiball_mb_shoot_again_ended")
        End With

        With .Shots("ramp_lock_light")
            .Debug = True

            .Profile = "lock"   'defined below
            With .ControlEvents()
                .Events = Array("lock_lit")
                .State = 1
            End With
            .RestartEvents = Array("start_multiball","lock_unlit")
        End With

        'Define shot profile with two states (0 = unlit, 1 = ready)
        With .ShotProfiles("lock")
            With .States("unlit")
                .Key = "key_lock_unlit"
                .Show = "off"
                With .Tokens()
                    .Add "lights", "l54"
                End With
            End With
            With .States("ready")
                .Key = "key_lock_ready"
                .Show = "flash_color_with_fade"    'defined in CreateGeneralShows()
                .Speed = 5
                With .Tokens()
                    .Add "fade", 200
                    .Add "color", MultiballColor
                    .Add "lights", "l54"
                End With
            End With
        End With

    End With
End Sub