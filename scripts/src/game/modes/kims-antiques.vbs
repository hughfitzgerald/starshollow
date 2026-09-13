' KimsAntiques Mode

Const KimsAntiquesTime = 60   'seconds
Const KimsAntiquesShotScore = 20000

Sub CreateKimsAntiquesMode()
    Dim kims_antiques_shots, shot
    kims_antiques_shots = Array( _
        NewShot("kims_antiques_orbit_left",  "s_left_orbit",  "l51", "kims_antiques_orbits"), _
        NewShot("kims_antiques_orbit_right", "s_right_orbit", "l52", "kims_antiques_orbits") _
    )
    With CreateGlfMode("kims_antiques", 710)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_kims_antiques")
        .StopEvents = Array("timer_kims_antiques_mode_complete", "mode_base_stopping", "mode_eob_bonus_started")

        With .EventPlayer()
            .Add "mode_kims_antiques_started", Array("base_music_stop", "release_scoop_hold")
            .Add "mode_kims_antiques_stopping", Array("kims_antiques_shots_off")
            .Add "timer_kims_antiques_mode_complete", Array("base_music_start")

            .Add "release_scoop_hold", Array("disable_scoop_hold")

            For Each shot In kims_antiques_shots
                .Add shot.Name & "_hit", Array("kims_antiques_shot_hit")
            Next
        End With

        With .SoundPlayer()
            With .EventName("mode_kims_antiques_started")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
            End With
            With .EventName("mode_kims_antiques_stopping")
                .Key = "key_mus_guitarmode"
                .Sound = "mus_guitarmode"
                .Action = "stop"
            End With
            ' With .EventName("kims_antiques_voc_1")
            '     .Key = "key_voc_dancingfun"
            '     .Sound = "voc_dancingfun"
            ' End With
            ' With .EventName("kims_antiques_voc_2")
            '     .Key = "key_voc_flipallyouwant"
            '     .Sound = "voc_flipallyouwant"
            ' End With
            ' With .EventName("kims_antiques_voc_3")
            '     .Key = "key_voc_justkeepdancing"
            '     .Sound = "voc_justkeepdancing"
            ' End With
            ' With .EventName("kims_antiques_voc_4")
            '     .Key = "key_voc_lekims_antiqueseflipyou"
            '     .Sound = "voc_lekims_antiqueseflipyou"
            ' End With
            ' With .EventName("kims_antiques_voc_5")
            '     .Key = "key_voc_lookgreat"
            '     .Sound = "voc_lookgreat"
            ' End With
            ' With .EventName("kims_antiques_voc_6")
            '     .Key = "key_voc_neeson"
            '     .Sound = "voc_neeson"
            ' End With
            ' With .EventName("kims_antiques_voc_7")
            '     .Key = "key_voc_prostrate"
            '     .Sound = "voc_prostrate"
            ' End With
        End With

        With .SlidePlayer()
            With .EventName("mode_kims_antiques_started")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("mode_kims_antiques_stopping")
                .Slide = "mode"
                .Action = "remove"
            End With
        End With

        With .VariablePlayer()
            With .EventName("mode_kims_antiques_started")
                With .Variable("mode_display_text")
                    .Action = "set"
                    .String = """KIM'S ANTIQUES"""
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_kims_antiques_score}"
                End With
                With .Variable("mode_display_instructions")
                    .Action = "set"
                    .String = """SHOOT ORBITS TO SCORE"""
                End With
            End With

            With .EventName("timer_kims_antiques_mode_tick")
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = "kwargs.ticks_remaining"
                End With
            End With

            With .EventName("kims_antiques_shot_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = KimsAntiquesShotScore
                End With
                With .Variable("mode_kims_antiques_score")
                    .Action = "add"
                    .Int = KimsAntiquesShotScore
                End With
                With .Variable("score")
                    .Action = "add"
                    .Int = KimsAntiquesShotScore
                End With
            End With
        End With

        With .Timers("kims_antiques_mode")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = KimsAntiquesTime
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "mode_kims_antiques_started"
                .Action = "start"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("kims_antiques_shot_hit")
                .Add "kims_antiques_voc_1", 1
                .Add "kims_antiques_voc_2", 1
                .Add "kims_antiques_voc_3", 1
                .Add "kims_antiques_voc_4", 1
                .Add "kims_antiques_voc_5", 1
                .Add "kims_antiques_voc_6", 1
                .Add "kims_antiques_voc_7", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
        End With

        For Each shot In kims_antiques_shots
            With .Shots(shot.Name)
                .Switch = shot.Switch
                .Profile = "mode_shot_flash"
                With .Tokens()
                    .Add "lights", shot.Light
                    .Add "color", "ffff00"
                End With
                With .ControlEvents()
                    .Events = Array("mode_kims_antiques_started")
                    .State = 1
                End With
                With .ControlEvents()
                    .Events = Array("mode_kims_antiques_stopping")
                    .State = 0
                End With
            End With
        Next
    End With
End Sub