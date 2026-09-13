

Sub CreateMiniGameMode
    Dim x, minigame

    With CreateGlfMode("minigame", 500)
        .StartEvents = Array("mode_skillshots_stopped{machine.game_modes_enabled == 1}")
        .StopEvents = Array("mode_base_stopping")

        With .EventPlayer()
            .Add "mode_minigame_started", Array("select_minigame")
            
            ' TODO: Maybe add minigame state machine?
            '           That way we won't start one if one is already running
            '           Maybe it can handle the post-minigame cleanup too, like lighting the completed minigame shot, etc.

            .Add "dance_marathon_lit", Array("enable_scoop_hold")

            .Add "check_minigame{current_player.shot_logan_light == 1}", Array("start_ll_multiball")

            For Each minigame In minigames
                .Add "check_minigame{current_player.shot_" & minigame.ModeName & "_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", Array("start_" & minigame.ModeName)
            Next
        End With

        With .RandomEventPlayer()
            With .EventName("select_minigame")
                For Each minigame In minigames
                    .Add minigame.ModeName & "_minigame_lit{current_player.shot_" & minigame.ModeName & "_minigame == 0}", 1
                Next
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        For Each minigame In minigames
            With .Shots(minigame.ModeName & "_minigame")
                .Profile = "minigame"
                With .Tokens()
                    .Add "lights", minigame.Light
                End With
                With .ControlEvents()
                    .Events = Array(minigame.ModeName & "_minigame_unlit")
                    .State = 0
                End With
                With .ControlEvents()
                    .Events = Array(minigame.ModeName & "_minigame_lit")
                    .State = 1
                End With
                With .ControlEvents()
                    .Events = Array("start_" & minigame.ModeName)
                    .State = 2
                End With
            End With
        Next

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

        With .Shots("llmb_minigame")
            .Profile = "minigame"
            With .Tokens()
                .Add "lights", "l22"
            End With
            With .ControlEvents()
                .Events = Array("logan_qualify_complete")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("start_ll_multiball","llmb_minigame_complete")
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