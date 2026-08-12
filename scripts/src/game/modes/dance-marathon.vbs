
' Dance Marathon Mode
'
'  - TODO: describe the mode

Const DanceMarathonShotTime = 20   'seconds
Const DanceMarathonModeNumShots = 6   'how long does the mode last in terms of numbers of shots, though it can be more if they make the shots quickly

' A single dance-marathon shot: which switch/light it uses, and which
' random-event group (e.g. "dm_orbits") lights it.
Class DmShotDef
    Public Name
    Public Switch
    Public Light
    Public Group
End Class

Function NewDmShot(name, switch, light, group)
    Dim s : Set s = New DmShotDef
    s.Name   = name
    s.Switch = switch
    s.Light  = light
    s.Group  = group
    Set NewDmShot = s
End Function

Sub CreateDanceMarathonMode()
    Dim dm_shots, groupSeen, shot, g

    dm_shots = Array( _
        NewDmShot("dm_captive",  "s_ST19",                        "l57", "dm_captive_spin"), _
        NewDmShot("dm_right_spinner", "s_right_spinner",          "l52", "dm_captive_spin"), _
        NewDmShot("dm_hidden_kicker", "s_HiddenUpperRightKicker", "l61", "dm_kickers"), _
        NewDmShot("dm_drop_target_kicker", "s_DropTargetKicker",  "l60", "dm_kickers"), _
        NewDmShot("dm_left_orbit",  "s_left_orbit",               "l51", "dm_orbits"), _
        NewDmShot("dm_right_orbit", "s_right_orbit",              "l52", "dm_orbits"), _
        NewDmShot("dm_right_ramp",  "s_complete_right_ramp",      "l55", "dm_ramps"), _
        NewDmShot("dm_left_ramp",   "s_complete_left_ramp",       "l53", "dm_ramps") _
    )

    Set groupSeen = CreateObject("Scripting.Dictionary")
    For Each shot In dm_shots
        If Not groupSeen.Exists(shot.Group) Then groupSeen.Add shot.Group, True
    Next

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

            For Each shot In dm_shots
                .Add shot.Name & "_lit_hit", Array("dm_shot_hit")
            Next
        End With

        With .RandomEventPlayer()
            With .EventName("dm_start_shots")
                For Each g In groupSeen.Keys()
                    .Add g, 1
                Next
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        For Each shot In dm_shots
            With .Shots(shot.Name)
                .Profile = "dm_profile"   'defined below
                .Switch = shot.Switch
                With .Tokens()
                    .Add "lights", shot.Light
                End With
                With .ControlEvents()
                    .Events = Array(shot.Name & "_lit_hit", "dm_shots_off")
                    .State = 0
                End With
                With .ControlEvents()
                    .Events = Array(shot.Group)
                    .State = 1
                End With
            End With
        Next

        With .ShotProfiles("dm_profile")
            .AdvanceOnHit = False
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