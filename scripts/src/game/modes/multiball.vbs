
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

            .Add "s_ST11_active", Array("lock_qualified") ' TEMP: when you hit the J in "JESS" we get lock lit

            .Add "mode_multiball_started{current_player.is_lock_qualified == 1}", Array("lock_lit")
            .Add "lock_qualified", Array("lock_lit")
            
            .Add "multiball_mb_started", Array("lock_unqualified")
            .Add "lock_unqualified", Array("lock_unlit")
            .Add "mode_multiball_stopping", Array("lock_unlit")

            .Add "lock_lit", Array("open_ramp_diverter")
            .Add "lock_unlit", Array("close_ramp_diverter")

            .Add "multiball_lock_multiball_lock_full", Array("start_multiball")
        End With

        With .VariablePlayer()
            With .EventName("multiball_mb_started")
                With .Variable("mb_active")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("multiball_mb_ended")
                With .Variable("mb_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With
            With .EventName("lock_qualified")
                With .Variable("is_lock_qualified")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("lock_unqualified")
                With .Variable("is_lock_qualified")
                    .Action = "set"
                    .Int = 0
                End With
            End With
        End With

        With .MultiballLocks("multiball_lock")
            .LockDevices = Array("lock1", "lock2", "lock3")   ' Ball device that acts as the lock
            .LockedBallCountingStrategy = "virtual_only"
            .BallsToLock = 3
            .BallsToReplace = 2
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


        '--- DMD ---------------------------------------------------------
        ' Names map to FlexDMD scenes in FlexDmd_ShowSlide /
        ' FlexDmd_ShowWidget (ZFBC).
        With .SlidePlayer()
            ' Expire matters here. Without it the multiball animation
            ' would hold the top of the slide stack until this mode stops
            ' at the end of the ball, hiding the scoreboard for the whole
            ' multiball. Three seconds, then the score comes back.
            With .EventName("multiball_mb_started")
                .Slide  = "multiball"
                .Action = "play"
                .Expire = 3
            End With
        End With

        With .WidgetPlayer()
            With .EventName("multiball_lock_multiball_lock_locked_ball{kwargs.total_balls_locked == 1}")
                .Widget = "ball_1_locked"
                .Action = "play"
                .Expire = 1.3
            End With
            With .EventName("multiball_lock_multiball_lock_locked_ball{kwargs.total_balls_locked == 2}")
                .Widget = "ball_2_locked"
                .Action = "play"
                .Expire = 1.3
            End With
        End With


        'SHOTS

        'Define the muiltball shoot again light
        With .Shots("mb_shoot_again")
            .Profile = "shoot_again"
            With .Tokens()
                .Add "color", MultiballColor
            End With
            With .ControlEvents()
                .Events = Array("multiball_mb_started")
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
            .RestartEvents = Array("lock_unlit")
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