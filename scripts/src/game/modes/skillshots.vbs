

' Skillshots Mode
'
'  - The kickback will save a ball falling down the left outlane by activating a cocked plunger in the outlane.
'  - To activate the kickback, all of the top rollover lane lights must be lit.
'  - The rollover lane lights rotate left and right with flipper button presses.
'  - Once the kickback is used, the lane lights and kicker light reset.



Sub CreateSkillshotsMode()
    Dim x

    With CreateGlfMode("skillshots", 400)

        'Define the events that start and stop this mode
        .StartEvents = Array("new_ball_started")
        .StopEvents = Array("mode_base_stopping","stop_skillshots")


        'The event player will respond to events during this mode
        With .EventPlayer()

            'Only start skillshots if starting a new ball
            .Add "mode_skillshots_started{current_player.ball_just_started == 1}", Array("init_ss")

            'Handle successful skillshots
            ' .Add "s_skillshot_active{current_player.shot_ss1 == 1}", Array("ss_achieved")
            .Add "s_skillshot_active", Array("ss_achieved")
            ' .Add "s_TopLane2_active{current_player.shot_ss2 == 1}", Array("ss_achieved")
            ' .Add "s_TopLane3_active{current_player.shot_ss3 == 1}", Array("ss_achieved")
            ' .Add "s_TopLane4_active{current_player.shot_ss4 == 1}", Array("ss_achieved")
            .Add "ss_achieved", Array("score_500000")

            'Stop skillshots if orbit lanes or rollovers are hit, or if timer runs out for some reason
            ' .Add "s_left_orbit_active", Array("stop_skillshots")
            ' .Add "s_right_orbit_active", Array("stop_skillshots")
            ' .Add "s_sw7_active", Array("stop_skillshots")
            ' .Add "s_sw8_active", Array("stop_skillshots")
            ' .Add "s_sw9_active", Array("stop_skillshots")
            .Add "timer_skillshots_complete", Array("stop_skillshots")
            .Add "balldevice_scoop_ball_exiting", Array("stop_skillshots")

            'Clear skill shot light if hit
            ' .Add "s_TopLane1_inactive", Array("clear_skillshots")
            ' .Add "s_TopLane2_inactive", Array("clear_skillshots")
            ' .Add "s_TopLane3_inactive", Array("clear_skillshots")
            ' .Add "s_TopLane4_inactive", Array("clear_skillshots")

        End With

        ' if the player goes past the initial skillshot, give them 5 seconds to hit one of the others
        With .Timers("skillshots")
            .StartRunning = False
            .TickInterval = 1000
            .StartValue = 0
            .EndValue = 3
            With .ControlEvents()
                .EventName = "Gate002_active"
                .Action = "start"
            End With
        End With


        '--- DMD ---------------------------------------------------------
        ' Name maps to a FlexDMD overlay in FlexDmd_ShowWidget (ZFBC).
        With .WidgetPlayer()
            With .EventName("ss_achieved")
                .Widget = "skillshot"
                .Action = "play"
                .Expire = 1.3
            End With
        End With


        'The random event player will dispatch an event at random (wieghted) from a list of possible events
        ' With .RandomEventPlayer()
        '     'Upon initialization, randomly choose one of the four top lane lights to flash for the skill shot
        '     With .EventName("init_ss")
        '         .Add "light_ss1", 1
        '         .Add "light_ss2", 1
        '         .Add "light_ss3", 1
        '         .Add "light_ss4", 1
        '         .ForceAll = False
        '         .ForceDifferent = False
        '     End With
        ' End With


        'Define the four possible skill shots
        ' For x = 1 to 4
        '     With .Shots("ss"&x)
        '         .Profile = "ss_ready"   'defined below
        '         With .Tokens()
        '             .Add "lights", SkillshotLightNames(x-1)
        '         End With
        '         With .ControlEvents()
        '             .Events = Array("stop_skillshots","clear_skillshots")
        '             .State = 0
        '         End With
        '         With .ControlEvents()
        '             .Events = Array("light_ss"&x)
        '             .State = 1
        '         End With
        '     End With
        ' Next


        'Define Skillshot ready shot profile with two states (0 = unlit, 1 = ready)
        'Skill shot is ready, two states
        ' With .ShotProfiles("ss_ready")
        '     With .States("unlit")
        '         .Key = "key_ss_not_ready"
        '         .Show = "off"
        '     End With
        '     With .States("ready")
        '         .Key = "key_ss_ready"
        '         .Show = "flash_color_with_fade"
        '         'Note the priority set below adds to this modes priority (which is set to 400). 
        '         ' This allows the other toplane lights from kickback mode (priority 500) show up under the unlit skillshot shots, 
        '         ' while putting the lit skillshot light on top of the toplane lights.
        '         .Priority = 1000   
        '         .Speed = 3
        '         With .Tokens()
        '             .Add "fade", 200
        '             .Add "color", SkillshotColor
        '         End With
        '     End With
        ' End With



        'Skillshot will time out after 5 seconds
        ' With .Timers("skillshots")
        '     .TickInterval = 1000
        '     .StartValue = 0
        '     .EndValue = 5
        '     With .ControlEvents()
        '         .EventName = "new_ball_active"
        '         .Action = "restart"
        '     End With
        ' End With

    End With

End Sub