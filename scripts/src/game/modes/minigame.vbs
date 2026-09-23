

Sub CreateMiniGameMode
    Dim x, minigame

    ' build a string of the form: "current_player.shot_" & minigame.ModeName & "_minigame != 1 and"
    ' where you have a single string that includes all the conditions for checking if a minigame is not active.
    ' obviously it should not end with "and"
    Dim minigame_conditions
    minigame_conditions = ""
    For Each minigame In minigames
        minigame_conditions = minigame_conditions & "current_player.shot_" & minigame.ModeName & "_minigame != 1 and "
    Next
    ' remove the trailing " and "
    If Len(minigame_conditions) > 0 Then
        minigame_conditions = Left(minigame_conditions, Len(minigame_conditions) - 5)
    End If

    With CreateGlfMode("minigame", 500)
        .StartEvents = Array("mode_base_started{machine.game_modes_enabled == 1}")
        .StopEvents = Array("mode_base_stopping")
        .Debug = True

        With .EventPlayer()
            .Add "mode_eob_bonus_started", Array("clear_selected_minigame")
            .Add "mode_skillshots_stopped", Array("select_minigame")
            .Add "select_minigame", Array("clear_selected_minigame", "choose_new_minigame")

            .Add "check_minigame{current_player.shot_logan_light == 1}", Array("start_ll_multiball")

            .Add "check_minigame{" & minigame_conditions & "}", Array("release_scoop_hold")

            For Each minigame In minigames
                .Add "check_minigame{current_player.shot_" & minigame.ModeName & "_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", Array("start_" & minigame.ModeName)
                .Add minigame.ModeName & "_minigame_lit", Array("enable_scoop_hold")
                .Add "mode_" & minigame.ModeName & "_stopped", Array("select_minigame")
                .Add "clear_selected_minigame{current_player.shot_" & minigame.ModeName & "_minigame == 1}", Array(minigame.ModeName & "_minigame_unlit")
            Next
        End With

        'Skip the bonus tally animations
        With .ComboSwitches("intro_skip")
            .Switch1 = "s_left_flipper"
            .Switch2 = "s_right_flipper"
            .EventsWhenBoth = Array("skip_minigame_intro")
            '.HoldTime = 200
        End With

        With .RandomEventPlayer()
            With .EventName("choose_new_minigame{modes.eob_bonus.active == False}")
                For Each minigame In minigames
                    .Add minigame.ModeName & "_minigame_lit{current_player.shot_" & minigame.ModeName & "_minigame == 0}", 1
                Next
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        For Each minigame In minigames
            With .Shots(minigame.ModeName & "_minigame")
                .Persist = True
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
            .Persist = True
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