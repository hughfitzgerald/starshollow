' KimsAntiques Mode

Const KimsAntiquesTime = 60   'seconds
Const KimsAntiquesShotScore = 20000
Const KimsAntiquesMoveTime = 5

Sub CreateKimsAntiquesMode()
    Dim kims_antiques_shots, shot
    kims_antiques_shots = Array( _
        NewShot("kims_antiques_left_ramp", "s_complete_left_ramp", "l53", "kims_antiques_ramps"), _
        NewShot("kims_antiques_right_ramp", "s_complete_right_ramp", "l55", "kims_antiques_ramps"), _
        NewShot("kims_antiques_captive", "s_captive_ball", "l57", "kims_antiques_captives"), _
        NewShot("kims_antiques_scoop", "s_VUK1", "l59", "kims_antiques_scoops"), _
        NewShot("kims_antiques_orbit_left",  "s_left_orbit",  "l51", "kims_antiques_orbits"), _
        NewShot("kims_antiques_orbit_right", "s_right_orbit", "l52", "kims_antiques_orbits") _
    )
    With CreateGlfMode("kims_antiques", 710)

        'Define the events that start and stop this mode
        .StartEvents = Array("start_kims_antiques")
        .StopEvents = Array("timer_kims_antiques_mode_complete", "mode_base_stopping", "mode_eob_bonus_started")

        With .EventPlayer()
            .Add "mode_kims_antiques_started", Array("base_music_stop", "release_scoop_hold", "move_miss_kim")
            .Add "mode_kims_antiques_stopping", Array("kims_antiques_shots_off")
            .Add "timer_kims_antiques_mode_complete", Array("base_music_start")

            .Add "release_scoop_hold", Array("disable_scoop_hold")

            .Add "timer_move_miss_kim_complete", Array("move_miss_kim")
            .Add "move_miss_kim", Array("kims_antiques_relight")
            .Add "kims_antiques_relight", Array("choose_new_miss_kim")

            For Each shot In kims_antiques_shots
                .Add shot.Name & "_ready_hit", Array("kims_antiques_shot_hit")
                .Add shot.Name & "_miss_kim_hit", Array("miss_kim_shot_hit")
            Next

            .Add "miss_kim_shot_hit", Array("timer_kims_antiques_mode_complete")
        End With

        With .Timers("move_miss_kim")
            .StartRunning = False
            .Direction = "down"
            .StartValue = KimsAntiquesMoveTime
            .EndValue = 0
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "move_miss_kim"
                .Action = "restart"
            End With
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

            With .EventName("choose_new_miss_kim")
                For Each shot in kims_antiques_shots
                    .Add "move_to_" & shot.Name, 1
                Next
            End With
        End With

        For Each shot In kims_antiques_shots
            With .Shots(shot.Name)
                .Switch = shot.Switch
                .Profile = "kims_antiques"
                With .Tokens()
                    .Add "lights", shot.Light
                    .Add "color", "ff0000"
                End With
                With .ControlEvents()
                    .Events = Array("move_to_" & shot.Name)
                    .State = 2
                End With
                With .ControlEvents()
                    .Events = Array("mode_kims_antiques_started","kims_antiques_relight")
                    .State = 1
                End With
                With .ControlEvents()
                    .Events = Array("mode_kims_antiques_stopping","move_miss_kim")
                    .State = 0
                End With
            End With
        Next

        With GlfShotProfiles("kims_antiques")
            .AdvanceOnHit = False
            With .States("unlit")
                .Show = "off"
                .Key = "key_unlit_ka"
            End With
            With .States("ready")
                .Show = "flash_color_with_fade"
                .Key = "key_ready_ka"
                .Speed = 5
                With .Tokens()
                    .Add "fade", 100
                End With
            End With
            With .States("miss_kim")
                .Show = "on_color"
                .Key = "key_miss_kim_ka"
                .Speed = 10
            End With
        End With
    End With
End Sub