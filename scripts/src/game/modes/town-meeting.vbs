
' Town Meeting Mode

Const TownMeetingTime = 60   'seconds
Const TownMeetingShotScore = 20000
Const TownMeetingLukesShotScore = 100000
Const TownMeetingLukesTime = 20   'seconds

Sub CreateTownMeetingMode()
    Dim tm_shots, shot, shotNames

    tm_shots = Array( _
        NewShot("tm_left_ramp", "s_complete_left_ramp", "l53", "tm_ramps"), _
        NewShot("tm_right_ramp", "s_complete_right_ramp", "l55", "tm_ramps"), _
        NewShot("tm_captive", "s_captive_ball", "l57", "tm_captives"), _
        NewShot("tm_left_orbit", "s_left_orbit", "l51", "tm_orbits"), _
        NewShot("tm_right_orbit", "s_right_orbit", "l52", "tm_orbits") _
    )
    shotNames = Array("tm_left_ramp", "tm_right_ramp", "tm_captive", "tm_left_orbit", "tm_right_orbit")

    With CreateGlfMode("town_meeting", 680)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_town_meeting")
        .StopEvents = Array("mode_base_stopping", "mode_eob_bonus_started", "timer_town_meeting_post_mode_complete")

        With .EventPlayer()
            .Add "mode_town_meeting_started", Array("base_music_stop")
            .Add "mode_town_meeting_stopping", Array("tm_shots_off")
            .Add "timer_tm_mode_complete", Array("town_meeting_post_mode")

            .Add "town_meeting_post_mode", Array("stop_tm_sounds", "tm_shots_off", "stop_guitar_music", "play_town_meeting_post_mode")
            .Add "timer_town_meeting_post_mode_complete", Array("base_music_start")
            .Add "timer_town_meeting_intro_delay_complete", Array("release_scoop_hold","start_guitar_music", "tm_start_shots")

            .Add "release_scoop_hold", Array("disable_scoop_hold")

            .Add "tm_lukes_lit_hit", Array("tm_start_shots")

            ' .Add "tm_shot_group_unlit_complete", Array("light_lukes")
            .Add "timer_tm_lukes_complete", Array("stop_tm_sounds", "tm_shots_off", "light_lukes", "play_tm_coffee")

            For Each shot In tm_shots
                .Add shot.Name & "_lit_hit", Array("tm_shot_hit")
            Next

            .Add "tm_reset_shots", Array("tm_shots_off","tm_start_shots")
        End With

        With .Timers("tm_start_shots")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 0.5
            .EndValue = 0
            .TickInterval = 500
            With .ControlEvents()
                .EventName = "tm_start_shots"
                .Action = "start"
            End With
        End With

        With .Timers("play_tm_coffee")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 0.5
            .EndValue = 0
            .TickInterval = 500
            With .ControlEvents()
                .EventName = "play_tm_coffee"
                .Action = "start"
            End With
        End With

        With .Timers("play_town_meeting_post_mode")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 0.5
            .EndValue = 0
            .TickInterval = 500
            With .ControlEvents()
                .EventName = "play_town_meeting_post_mode"
                .Action = "start"
            End With
        End With

        With .Timers("town_meeting_post_mode")
            .StartRunning = False
            .Direction = "down"
            .StartValue = 6
            .EndValue = 0
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "town_meeting_post_mode"
                .Action = "start"
            End With
        End With

        With .Timers("town_meeting_intro_delay")
            .StartRunning = True
            .Direction = "down"
            .StartValue = 5
            .EndValue = 0
            .TickInterval = 1000    ' Tick every 1 second (1000 ms)
            With .ControlEvents()
                .EventName = "play_voc_tm_punctuality_dirty"
                .Action = "jump"
                .Value = 5
            End With
            With .ControlEvents()
                .EventName = "play_voc_tm_gavelx3"
                .Action = "jump"
                .Value = 8
            End With
        End With

        With .Timers("tm_lukes")
            .StartRunning = False
            .Direction = "down"
            .StartValue = TownMeetingLukesTime
            .EndValue = 0
            .TickInterval = 1000
            With .ControlEvents
                .EventName = "tm_start_shots"
                .Action = "restart"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("mode_town_meeting_started")
                .Add "play_voc_tm_punctuality_dirty", 1
                .Add "play_voc_tm_gavelx3", 1
            End With
        End With

        With .SoundPlayer()
            With .EventName("start_guitar_music")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
            End With
            With .EventName("stop_guitar_music")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
                .Action = "stop"
            End With
            With .EventName("play_voc_tm_punctuality_dirty")
                .Key = "key_voc_tm_punctuality_dirty"
                .Sound = "voc_tm_punctuality_dirty"
            End With
            With .EventName("play_voc_tm_gavelx3")
                .Key = "key_voc_tm_gavelx3"
                .Sound = "voc_tm_gavelx3"
            End With
            With .EventName("tm_start_shots")
                .Key = "key_sfx_tm_gavel"
                .Sound = "sfx_tm_gavel"
            End With
            With .EventName("timer_play_tm_coffee_complete")
                .Key = "key_voc_tm_coffee_in_an_iv"
                .Sound = "voc_tm_coffee_in_an_iv"
            End With
            With .EventName("timer_play_town_meeting_post_mode_complete")
                .Key = "key_voc_tm_meetingadjourned"
                .Sound = "voc_tm_meetingadjourned"
            End With
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
                    .Int = "{current_player.mode_town_meeting_score}"
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
                With .Variable("mode_town_meeting_score")
                    .Action = "add"
                    .Int = TownMeetingShotScore
                End With
            End With

            With .EventName("tm_lukes_lit_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = TownMeetingLukesShotScore
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = TownMeetingLukesShotScore
                End With
                With .Variable("mode_town_meeting_score")
                    .Action = "add"
                    .Int = TownMeetingLukesShotScore
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
                .EventName = "timer_town_meeting_intro_delay_complete"
                .Action = "start"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("timer_tm_start_shots_complete")
                .Add "town_meeting_deer_start", 1
                .Add "town_meeting_cartkiosk_start", 1
            End With
        End With

        With .Shots("tm_lukes")
            .Profile = "tm_profile"   'defined below
            .Switch = "s_DropTargetKicker"
            With .Tokens()
                .Add "lights", "l60"
            End With
            With .ControlEvents()
                .Events = Array("tm_lukes_lit_hit", "tm_shots_off")
                .State = 0
            End With
            With .ControlEvents()
                .Events = Array("light_lukes")
                .State = 1
            End With
        End With

        With .ShotGroups("tm_shot_group")
            .Shots = shotNames
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