
' Dance Marathon Mode
'
'  - TODO: describe the mode

Const DanceMarathonShotTime = 15   'seconds
Const DanceMarathonModeNumShots = 4   'how long does the mode last in terms of numbers of shots, though it can be more if they make the shots quickly
Const DanceMarathonFirstShotScore = 20000
Const DanceMarathonSecondShotScore = 40000

Sub CreateDanceMarathonMode()
    Dim dm_shots, groupSeen, shot, g

    dm_shots = Array( _
        NewShot("dm_captive",  "s_captive_ball",                "l57", "dm_captive_spin"), _
        NewShot("dm_right_spinner", "s_right_spinner",          "l52", "dm_captive_spin"), _
        NewShot("dm_hidden_kicker", "s_HiddenUpperRightKicker", "l61", "dm_kickers"), _
        NewShot("dm_drop_target_kicker", "s_DropTargetKicker",  "l60", "dm_kickers"), _
        NewShot("dm_left_orbit",  "s_left_orbit",               "l51", "dm_orbits"), _
        NewShot("dm_right_orbit", "s_right_orbit",              "l52", "dm_orbits"), _
        NewShot("dm_right_ramp",  "s_complete_right_ramp",      "l55", "dm_ramps"), _
        NewShot("dm_left_ramp",   "s_complete_left_ramp",       "l53", "dm_ramps") _
    )

    Set groupSeen = CreateObject("Scripting.Dictionary")
    For Each shot In dm_shots
        If Not groupSeen.Exists(shot.Group) Then groupSeen.Add shot.Group, True
    Next

    With CreateGlfMode("dance_marathon", 670)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_dance_marathon")
        .StopEvents = Array("timer_dm_mode_complete", "mode_base_stopping", "mode_eob_bonus_started")

        With .EventPlayer()
            .Add "mode_dance_marathon_started", Array("base_music_stop")
            .Add "mode_dance_marathon_stopping", Array("dm_shots_off")
            .Add "timer_dm_mode_complete", Array("base_music_start")

            .Add "timer_intro_delay_complete", Array("release_scoop_hold", "dm_start_shots")
            .Add "release_scoop_hold", Array("disable_scoop_hold")

            .Add "timer_dm_shot_complete", Array("dm_reset_shots")
            .Add "dm_reset_shots", Array("dm_shots_off","dm_start_shots")

            For Each shot In dm_shots
                .Add shot.Name & "_lit_hit", Array("dm_shot_hit")
            Next
        End With

        With .SoundPlayer()
            With .EventName("mode_dance_marathon_started")
                .Key = "key_mus_dm"
                .Sound = "mus_dm"
            End With
            With .EventName("mode_dance_marathon_stopping")
                .Key = "key_mus_dm"
                .Sound = "mus_dm"
                .Action = "stop"
            End With
            With .EventName("dm_voc_1")
                .Key = "key_voc_dancingfun"
                .Sound = "voc_dancingfun"
            End With
            With .EventName("dm_voc_2")
                .Key = "key_voc_flipallyouwant"
                .Sound = "voc_flipallyouwant"
            End With
            With .EventName("dm_voc_3")
                .Key = "key_voc_justkeepdancing"
                .Sound = "voc_justkeepdancing"
            End With
            With .EventName("dm_voc_4")
                .Key = "key_voc_letmeflipyou"
                .Sound = "voc_letmeflipyou"
            End With
            With .EventName("dm_voc_5")
                .Key = "key_voc_lookgreat"
                .Sound = "voc_lookgreat"
            End With
            With .EventName("dm_voc_6")
                .Key = "key_voc_neeson"
                .Sound = "voc_neeson"
            End With
            With .EventName("dm_voc_7")
                .Key = "key_voc_prostrate"
                .Sound = "voc_prostrate"
            End With
        End With

        '--- DMD -----------------------------------------------------------
        ' Names map to FlexDMD scenes/overlays in FlexDmd_ShowSlide /
        ' FlexDmd_ShowWidget (ZFBC).
        ' With .WidgetPlayer()
        '     With .EventName("mode_dance_marathon_started")
        '         .Widget = "dance_marathon"
        '         .Action = "play"
        '         .Expire = 1.3
        '     End With
        '     ' _stopping, not _stopped: this mode's own devices are
        '     ' deactivated on _stopping at priority-1, and _stopped is only
        '     ' dispatched after that, so a widget player here would already
        '     ' be gone. The player's own listener sits at the mode's full
        '     ' priority, so it still fires on _stopping - the same event
        '     ' the SoundPlayer above uses to stop the music.
        '     With .EventName("mode_dance_marathon_stopping")
        '         .Widget = "dance_marathon_done"
        '         .Action = "play"
        '         .Expire = 1.3
        '     End With
        ' End With

        With .SlidePlayer()
            ' The countdown, replayed on every tick of the dm_mode timer
            ' below. A slide rather than a widget because the seconds left
            ' arrive in the tick event's kwargs, and only the slide player
            ' forwards those. It sits on the slide stack at this mode's
            ' priority, so it outranks the base scoreboard while the mode
            ' runs and is cleared automatically when the mode stops.
            ' With .EventName("timer_dm_mode_tick")
            '     .Slide  = "dance_marathon_timer"
            '     .Action = "play"
            ' End With

            With .EventName("mode_dance_marathon_started")
                .Slide = "kirk-dances"
                .Action = "play"
            End With


            With .EventName("dm_start_shots")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_dance_marathon_stopping")
                .Slide = "mode"
                .Action = "remove"
            End With
        End With

        With .VariablePlayer()
            With .EventName("mode_dance_marathon_started")
                With .Variable("mode_display_text")
                    .Action = "set"
                    .String = """DANCE MARATHON"""
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_dance_marathon_score}"
                End With
                With .Variable("mode_display_instructions")
                    .Action = "set"
                    .String = """HIT FLASHING SHOTS TO SCORE"""
                End With
            End With

            With .EventName("timer_dm_mode_tick")
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = "kwargs.ticks_remaining"
                End With
            End With

            With .EventName("dm_first_shot_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = DanceMarathonFirstShotScore
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = DanceMarathonFirstShotScore
                End With
            End With
            With .EventName("dm_second_shot_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = DanceMarathonSecondShotScore
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = DanceMarathonSecondShotScore
                End With
            End With
        End With


        With .Timers("intro_delay")
            .StartRunning = True
            .Direction = "down"
            .StartValue = 14        ' 14 seconds until the clip of Taylor is done and we can start the mode
            .EndValue = 0
            .TickInterval = 1000    ' Tick every 1 second (1000 ms)
        End With

        With .Timers("dm_mode")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = DanceMarathonShotTime * DanceMarathonModeNumShots
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "dm_start_shots"
                .Action = "start"
            End With
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

        With .RandomEventPlayer()
            With .EventName("dm_start_shots")
                For Each g In groupSeen.Keys()
                    .Add g, 1
                Next
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("dm_shot_hit")
                .Add "dm_voc_1", 1
                .Add "dm_voc_2", 1
                .Add "dm_voc_3", 1
                .Add "dm_voc_4", 1
                .Add "dm_voc_5", 1
                .Add "dm_voc_6", 1
                .Add "dm_voc_7", 1
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
                .Events = Array("dm_shots_off")
            End With
        End With

        
    End With
End Sub