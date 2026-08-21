

Sub CreateMiniGameMode
    Dim x

    With CreateGlfMode("minigame", 500)
        .StartEvents = Array("new_ball_started")
        .StopEvents = Array("mode_base_stopping")

        With .EventPlayer()
            .Add "mode_minigame_started", Array("select_minigame")

            .Add "dm_minigame_lit", Array("minigame_is_ready")
            
            ' TODO: Maybe add minigame state machine?
            '           That way we won't start one if one is already running
            '           Maybe it can handle the post-minigame cleanup too, like lighting the completed minigame shot, etc.

            .Add "minigame_is_ready", Array("enable_scoop_hold")

            .Add "check_minigame{current_player.shot_dm_minigame == 1 and modes.jd_multiball.active == False}", Array("start_dance_marathon")
            .Add "mode_dance_marathon_stopped", Array("dm_minigame_complete")
        End With

        With .RandomEventPlayer()
            With .EventName("select_minigame")
                .Add "dm_minigame_lit", 1
                .Add "th_minigame_lit", 0
                ' .ForceAll = True
                ' .ForceDifferent = True
            End With
        End With

        With .Shots("dm_minigame")
            .Profile = "minigame"
            With .Tokens()
                .Add "lights", "l24"
            End With
            With .ControlEvents()
                .Events = Array("dm_minigame_unlit")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("dm_minigame_lit")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("start_dance_marathon","dm_minigame_complete")
                .State = 2
            End With
        End With

        With .Shots("th_minigame")
            .Profile = "minigame"
            With .Tokens()
                .Add "lights", "l25"
            End With
            With .ControlEvents()
                .Events = Array("th_minigame_unlit")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("th_minigame_lit")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("start_townhall","th_minigame_complete")
                .State = 2
            End With
        End With

        With .Shots("jdmb_minigame")
            .Profile = "minigame"
            With .Tokens()
                .Add "lights", "l23"
            End With
            With .ControlEvents()
                .Events = Array("mode_jd_multiball_started")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("mode_jd_multiball_stopped")
                .State = 2
            End With
        End With

        With .ShotProfiles("minigame")
            With .States("unlit")
                .Show = "off"
            End With
            With .States("lit")
                .Show = "fade_color_on_off_on"
                .Speed = 4
                With .Tokens()
                    .Add "color", "ffff00"
                End With
            End With
            With .States("complete")
                .Show = "flicker_color_on"
                .Speed = 4
                With .Tokens()
                    .Add "color", "ffff00"
                End With
            End With
        End With
    End With
End Sub