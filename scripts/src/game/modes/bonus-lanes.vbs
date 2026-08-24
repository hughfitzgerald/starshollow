Sub CreateBonusLanesMode()
    Dim x
    With CreateGlfMode("bonus_lanes", 210)
        .StartEvents = Array("mode_base_started")
        .StopEvents = Array("mode_base_stopping")

        'Define our shots
        For x = 7 to 9
            With .Shots("bonus_lane_"&x)
                .Switch = "s_sw"&x
                .Profile = "qualify_multiplier"
                With .Tokens()
                    .Add "lights", "l"&x
                End With
                With .ControlEvents()
                    .Events = Array("complete_qualify_multiplier")
                    .State = 1
                End With
            End With
        Next

        'Define a shot profile with two states (off/on)
        ' NOTE: must be defined before the shot group below - ShotGroups.Shots
        ' resolves the group's RotationPattern immediately from the first
        ' shot's profile, so the profile has to already exist in
        ' Glf_ShotProfiles by then.
        With .ShotProfiles("qualify_multiplier")
            With .States("unlit")
                .Show = "off"
            End With
            With .States("on")
                .Show = "flicker_color_on"
                .Speed = 4
                .Priority = 100
                With .Tokens()
                    .Add "color", BonusLaneColor
                End With
            End With
        End With


        ' Bonus multiplier shot group
        With .ShotGroups("qualify_multiplier_group")
            .Shots = Array("bonus_lane_7", "bonus_lane_8", "bonus_lane_9")
            .RotateLeftEvents = Array("s_right_flipper_active")
            .RotateRightEvents = Array("s_left_flipper_active")
            .RestartEvents = Array("qualify_multiplier_group_on_complete")
        End With

        For x = 1 to 4
            With .Shots((x+1) & "x")
                .Profile = "qualify_multiplier"
                With .Tokens()
                    .Add "lights", "l3" & x
                End With
                With .ControlEvents()
                    .Events = Array((x+1) & "x_qualified")
                    .State = 1
                End With
            End With
        Next

        ' Bonus multiplier state machine
        With .StateMachines("bonus_multiplier_states")
            .StartingState = "1x"
            .PersistState = True
            With .States("1x")
                .Label = "1x"
            End With
            With .States("2x")
                .Label = "2x"
            End With
            With .States("3x")
                .Label = "3x"
            End With
            With .States("4x")
                .Label = "4x"
            End With
            With .States("5x")
                .Label = "5x"
            End With
            
            For x = 1 to 3
                With .Transitions() 
                    .Source = Array(x & "x")
                    .Target = (x+1) & "x"
                    .Events = Array("qualify_multiplier_group_on_complete")
                    .EventsWhenTransitioning = Array((x+1) & "x_qualified")
                End With
            Next
            With .Transitions() 
                .Source = Array("4x")
                .Target = "5x"
                .Events = Array("qualify_multiplier_group_on_complete")
                .EventsWhenTransitioning = Array("bonus_multiplier_maxed", "5x_qualified")
            End With
        End With
    End With
End Sub