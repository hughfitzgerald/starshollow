
' Multiball Mode
'
' To start the multiball:
'  - TODO: write this...
'
' TODO: Add state machine to handle locks, activating kickers, etc.


Sub CreateJDMultiballQualifyMode()
    Dim x

    With CreateGlfMode("jd_multiball_qualify", 200)
        .Debug = True
        
        'Define the events that start and stop this mode
        .StartEvents = Array("mode_skillshots_stopped{machine.game_modes_enabled == 1}", "mode_jd_multiball_stopped", "mode_ll_multiball_stopped", "mode_dance_marathon_stopped", "mode_town_meeting_stopped")
        .StopEvents = Array("mode_base_stopping", "mode_jd_multiball_started", "mode_ll_multiball_started", "mode_dance_marathon_started", "mode_town_meeting_started")


        'The event player will respond to events during this mode
        With .EventPlayer()
            .Debug = True

            .Add "s_ST11_active", Array("lock_qualified") ' TEMP: when you hit the J in "JESS" we get lock lit

            .Add "mode_jd_multiball_qualify_started{current_player.is_lock_qualified == 1}", Array("lock_lit")
            .Add "lock_qualified", Array("lock_lit")
            
            .Add "start_jd_multiball", Array("lock_unqualified")
            .Add "lock_unqualified", Array("lock_unlit")
            .Add "mode_jd_multiball_qualify_stopping", Array("lock_unlit")

            .Add "lock_lit", Array("open_ramp_diverter")
            .Add "lock_unlit", Array("close_ramp_diverter")

            .Add "s_lock3_trigger_active{current_player.multiball_lock_locked_balls == 2}", Array("start_jd_multiball")
        End With

        With .VariablePlayer()
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
            .LockDevices = Array("lock1", "lock2")   ' Ball device that acts as the lock
            .LockedBallCountingStrategy = "virtual_only"
            .BallsToLock = 2
            .BallsToReplace = 2
            .EnableEvents = Array("lock_lit")
            .DisableEvents = Array("lock_unlit")
            .Debug = True
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