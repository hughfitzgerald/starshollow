

Sub CreateMysteryMode
    Dim x

    With CreateGlfMode("mystery", 580)
        .StartEvents = Array("new_ball_started", "stop_dance_marathon")
        .StopEvents = Array("mode_base_stopping", "start_dance_marathon")

        With .EventPlayer()
            .Add "qualify_multiplier_group_on_complete", Array("light_inlanes")

            .Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==0}", Array("check_minigame")

            .Add "inlane_1_lit_hit", Array("mystery_is_ready")
            .Add "inlane_2_lit_hit", Array("mystery_is_ready")
            .Add "mystery_is_ready", Array("enable_scoop_hold")
        End With

        With .Shots("mystery_ready")
            .Profile = "qualified_shot"
            With .Tokens()
                .Add "lights", "l58"
                .Add "color", "ffff00"
            End With
            With .ControlEvents()
                .Events = Array("mystery_is_ready")
                .State = 1
            End With
            .RestartEvents = Array("restart_qualify_mystery")
        End With

        With .Shots("inlane_1")
            .Profile = "inlane"
            .RestartEvents = Array("mystery_is_ready")
            With .Tokens()
                .Add "lights", "l63"
            End With
            With .ControlEvents()
                .Events = Array("light_inlanes")
                .State = 1
            End With
        End With

        With .Shots("inlane_2")
            .Profile = "inlane"
            .RestartEvents = Array("mystery_is_ready")
            With .Tokens()
                .Add "lights", "l64"
            End With
            With .ControlEvents()
                .Events = Array("light_inlanes")
                .State = 1
            End With
        End With

        With .ShotProfiles("inlane")
            With .States("unlit")
                .Show = "off"
            End With
            With .States("lit")
                .Show = "flicker_color_on"
                .Speed = 4
                With .Tokens()
                    .Add "color", "ffff00"
                End With
            End With
        End With
    End With
End Sub