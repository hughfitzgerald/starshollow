
' Dance Marathon Mode
'
'  - TODO: describe the mode

Const DanceMarathonShotTime = 5   'seconds
Const DanceMarathonModeNumShots = 3   'how long does the mode last in terms of numbers of shots

Sub CreateDanceMarathonMode()
    Dim x
    With CreateGlfMode("dance_marathon", 670)

        'Define the events that start and stop this mode
        .StartEvents = Array("s_VUK1_active")
        .StopEvents = Array("timer_dm_mode_complete", "mode_base_stopping")

        With .Timers("dm_mode")
            .StartRunning = True
            .Direction = "down"      ' Count down
            .StartValue = DanceMarathonShotTime * DanceMarathonModeNumShots
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
        End With

        With .Timers("dm_shot")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = DanceMarathonShotTime
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "dm_shots_off"
                .Action = "reset"
            End With
            With .ControlEvents
                .EventName = "dm_start_shots"
                .Action = "start"
            End With
        End With

        With .EventPlayer()
            .Add "mode_dance_marathon_started", Array("dm_start_shots")

            .Add "timer_dm_shot_complete", Array("dm_reset_shots")
            .Add "dm_reset_shots", Array("dm_shots_off","dm_start_shots")

            .Add "dm_left_orbit_lit_hit", Array("dm_shot_hit")
            .Add "dm_right_orbit_lit_hit", Array("dm_shot_hit")
            .Add "dm_left_ramp_lit_hit", Array("dm_shot_hit")
            .Add "dm_right_ramp_lit_hit", Array("dm_shot_hit")
        End With

        With .RandomEventPlayer()
            With .EventName("dm_start_shots")
                .Add "dm_orbits", 1
                .Add "dm_ramps", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        With .Shots("dm_left_orbit")
            .Profile = "dm_profile"   'defined below
            .Switch = "s_left_orbit"
            With .Tokens()
                .Add "lights", "l51"
            End With
            With .ControlEvents()
                .Events = Array("s_left_orbit_active","dm_shots_off")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("dm_orbits")
                .State = 1
            End With
        End With

        With .Shots("dm_right_orbit")
            .Profile = "dm_profile"   'defined below
            .Switch = "s_right_orbit"
            With .Tokens()
                .Add "lights", "l52"
            End With
            With .ControlEvents()
                .Events = Array("s_right_orbit_active","dm_shots_off")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("dm_orbits")
                .State = 1
            End With
        End With

        With .Shots("dm_right_ramp")
            .Profile = "dm_profile"   'defined below
            .Switch = "s_complete_right_ramp"
            With .Tokens()
                .Add "lights", "l55"
            End With
            With .ControlEvents()
                .Events = Array("s_complete_right_ramp_active","dm_shots_off")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("dm_ramps")
                .State = 1
            End With
        End With

        With .Shots("dm_left_ramp")
            .Profile = "dm_profile"   'defined below
            .Switch = "s_complete_left_ramp"
            With .Tokens()
                .Add "lights", "l53"
            End With
            With .ControlEvents()
                .Events = Array("s_complete_left_ramp_active","dm_shots_off")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("dm_ramps")
                .State = 1
            End With
        End With

        With .ShotProfiles("dm_profile")
            With .States("unlit")
                .Key = "key_dm_unlit"
                .Show = "off"
            End With
            With .States("lit")
                .Key = "key_dm_lit"
                .Show = "flash_color"
                .Speed = 15
                .Priority = 1000
                With .Tokens()
                    .Add "color", "ff0000"
                End With
            End With
        End With

        With .StateMachines("dm_state_machine")
            .StartingState = "dm_unlit"
            With .States("dm_unlit")
                .Label = "Unlit"
            End With
            With .States("dm_two_shots_lit")
                .Label = "Two Shots Lit"
            End With
            With .States("dm_one_shot_lit")
                .Label = "One Shot Lit"
            End With
            With .Transitions()
                .Source = Array("dm_unlit")
                .Target = "dm_two_shots_lit"
                .Events = Array("dm_start_shots")
            End With
            With .Transitions()
                .Source = Array("dm_two_shots_lit")
                .Target = "dm_one_shot_lit"
                .Events = Array("dm_shot_hit")
                .EventsWhenTransitioning = Array("dm_first_shot_hit")
            End With
            With .Transitions()
                .Source = Array("dm_one_shot_lit")
                .Target = "dm_two_shots_lit"
                .Events = Array("dm_shot_hit")
                .EventsWhenTransitioning = Array("dm_second_shot_hit","dm_reset_shots")
            End With
            With .Transitions()
                .Source = Array("dm_two_shots_lit","dm_one_shot_lit")
                .Target = "dm_unlit"
                .Events = Array("mode_dance_marathon_stopping")
            End With
        End With

        
    End With
End Sub