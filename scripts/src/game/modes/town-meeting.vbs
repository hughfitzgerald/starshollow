
' Town Meeting Mode

Const TownMeetingTime = 60   'seconds
Const TownMeetingShotScore = 20000

Sub CreateTownMeetingMode()
    Dim tm_shots, shot

    tm_shots = Array( _
        NewShot("tm_left_orbit", "s_left_orbit", "l51", "tm_orbits"), _
        NewShot("tm_right_orbit", "s_right_orbit", "l52", "tm_orbits") _
    )

    With CreateGlfMode("town_meeting", 680)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_town_meeting")
        .StopEvents = Array("timer_tm_mode_complete", "mode_base_stopping", "mode_eob_bonus_started")

        With .EventPlayer()
            .Add "mode_town_meeting_started", Array("base_music_stop", "release_scoop_hold", "tm_start_shots")
            .Add "mode_town_meeting_stopping", Array("tm_shots_off")
            .Add "timer_tm_mode_complete", Array("base_music_start")

            .Add "release_scoop_hold", Array("disable_scoop_hold")

            For Each shot In tm_shots
                .Add shot.Name & "_lit_hit", Array("tm_shot_hit")
            Next

            .Add "tm_reset_shots", Array("tm_shots_off","tm_start_shots")
        End With

        With .SoundPlayer()
            With .EventName("mode_town_meeting_started")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
            End With
            With .EventName("mode_town_meeting_stopping")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
                .Action = "stop"
            End With
            ' With .EventName("tm_voc_1")
            '     .Key = "key_voc_dancingfun"
            '     .Sound = "voc_dancingfun"
            ' End With
            ' With .EventName("tm_voc_2")
            '     .Key = "key_voc_flipallyouwant"
            '     .Sound = "voc_flipallyouwant"
            ' End With
            ' With .EventName("tm_voc_3")
            '     .Key = "key_voc_justkeepdancing"
            '     .Sound = "voc_justkeepdancing"
            ' End With
            ' With .EventName("tm_voc_4")
            '     .Key = "key_voc_letmeflipyou"
            '     .Sound = "voc_letmeflipyou"
            ' End With
            ' With .EventName("tm_voc_5")
            '     .Key = "key_voc_lookgreat"
            '     .Sound = "voc_lookgreat"
            ' End With
            ' With .EventName("tm_voc_6")
            '     .Key = "key_voc_neeson"
            '     .Sound = "voc_neeson"
            ' End With
            ' With .EventName("tm_voc_7")
            '     .Key = "key_voc_prostrate"
            '     .Sound = "voc_prostrate"
            ' End With
        End With

        With .SlidePlayer()
            With .EventName("mode_town_meeting_started")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_town_meeting_stopping")
                .Slide = "mode"
                .Action = "remove"
            End With
        End With

        With .VariablePlayer()
            With .EventName("mode_town_meeting_started")
                With .Variable("mode_display_text")
                    .Action = "set"
                    .String = """TOWN MEETING"""
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_tm_score}"
                End With
                With .Variable("mode_display_instructions")
                    .Action = "set"
                    .String = """HIT FLASHING SHOTS TO SCORE"""
                End With
            End With

            With .EventName("timer_tm_mode_tick")
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = "kwargs.ticks_remaining"
                End With
            End With

            With .EventName("tm_shot_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = TownMeetingShotScore
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = TownMeetingShotScore
                End With
                With .Variable("mode_tm_score")
                    .Action = "add"
                    .Int = TownMeetingShotScore
                End With
            End With
        End With

        With .Timers("tm_mode")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = TownMeetingTime
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "mode_town_meeting_started"
                .Action = "start"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("tm_shot_hit")
                .Add "tm_voc_1", 1
                .Add "tm_voc_2", 1
                .Add "tm_voc_3", 1
                .Add "tm_voc_4", 1
                .Add "tm_voc_5", 1
                .Add "tm_voc_6", 1
                .Add "tm_voc_7", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        For Each shot In tm_shots
            With .Shots(shot.Name)
                .Profile = "tm_profile"   'defined below
                .Switch = shot.Switch
                With .Tokens()
                    .Add "lights", shot.Light
                End With
                With .ControlEvents()
                    .Events = Array(shot.Name & "_lit_hit", "tm_shots_off")
                    .State = 0
                End With
                With .ControlEvents()
                    .Events = Array("tm_start_shots")
                    .State = 1
                End With
            End With
        Next

        With .ShotProfiles("tm_profile")
            .AdvanceOnHit = False
            With .States("unlit")
                .Key = "key_tm_unlit"
                .Show = "off"
            End With
            With .States("lit")
                .Key = "key_tm_lit"
                .Show = "flash_color"
                .Speed = 15
                .Priority = 1000
                With .Tokens()
                    .Add "color", "ff0000"
                End With
            End With
        End With
    End With
End Sub