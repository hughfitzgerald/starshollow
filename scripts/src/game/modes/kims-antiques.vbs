' KimsAntiques Mode
'
'  - Miss Kim (solid red) roams the six shots. Hitting her ends the mode.
'    The shot she is about to move to flashes for KimsAntiquesWarningTime
'    first; until she arrives it is still a safe shot.
'  - The right ramp is a jackpot (KimsAntiquesJackpotScore) while the Dean
'    sign is chasing. Collecting it unlights it; any other shot that isn't
'    Miss Kim scores KimsAntiquesShotScore and relights it.
'  - Playfield scoring is multiplied by KimsAntiquesPlayfieldX for the mode.
'  - Lasting the full timer without hitting her scores KimsAntiquesCompleteScore

Const KimsAntiquesTime = 60   'seconds
Const KimsAntiquesMoveTime = 5          'seconds Miss Kim stays on a shot, including the warning
Const KimsAntiquesWarningTime = 1       'seconds the next shot flashes before she moves there

Sub CreateKimsAntiquesMode()
    Dim kims_antiques_shots, shot, pauseEvent
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
        .StopEvents = Array("timer_kims_antiques_mode_complete", "miss_kim_shot_hit", "mode_base_stopping", "bonus_start")

        With .EventPlayer()
            'Scoring
            .Add "kims_antiques_shot_hit", Array(ScoreEvent(KimsAntiquesShotScore, NoMultiplier), "kims_jackpot_relight")
            .Add "kims_jackpot_hit", Array(ScoreEvent(KimsAntiquesJackpotScore, NoMultiplier))

            .Add "mode_kims_antiques_started", Array(ScoreEvent(ModeStartScore, NoMultiplier), "base_music_stop", ModeSlideEvent("play_kims_antiques_mode_slide", "KIM'S ANTIQUES", KimsAntiquesPlayfieldX & "X SCORING - RIGHT RAMP JACKPOT - AVOID MISS KIM"))
            .Add "mode_kims_antiques_stopping", Array("kims_antiques_shots_off")
            'Survived the full timer without hitting Miss Kim
            .Add "timer_kims_antiques_mode_complete", Array("base_music_start", ScoreEvent(KimsAntiquesCompleteScore, NoMultiplier))

            'Shots go live. The move timer is jumped straight to its warning second,
            'so the first shot flashes and Miss Kim arrives there a second later.
            .Add "timer_kims_antiques_intro_delay_complete", Array("release_scoop_hold", "start_kims_antiques_music", "prime_move_miss_kim", "start_move_miss_kim", "play_voc_ka_kimsantiques")

            'Miss Kim moves: flash the next shot at KimsAntiquesWarningTime left, then move
            'her there when the timer runs out. A paused timer re-sends its current tick
            'when it resumes, so kims_warning_active stops that picking a second shot.
            'clear_miss_kim and set_miss_kim are separate events so that the shot she
            'leaves is cleared before the warned shot becomes her.
            .Add "timer_move_miss_kim_tick{kwargs.ticks == " & KimsAntiquesWarningTime & " && current_player.kims_warning_active == 0}", Array("choose_next_miss_kim")
            .Add "timer_move_miss_kim_complete", Array("clear_miss_kim", "set_miss_kim")

            For Each shot In kims_antiques_shots
                If shot.Name = "kims_antiques_right_ramp" Then
                    'The jackpot shot: scores the jackpot only while it is lit (Dean sign
                    'chasing). Otherwise the ramp just gets its normal playfield score.
                    .Add shot.Name & "_unlit_hit{current_player.shot_kims_jackpot == 1}", Array("kims_jackpot_hit")
                    .Add shot.Name & "_warning_hit{current_player.shot_kims_jackpot == 1}", Array("kims_jackpot_hit")
                Else
                    .Add shot.Name & "_unlit_hit", Array("kims_antiques_shot_hit")
                    .Add shot.Name & "_warning_hit", Array("kims_antiques_shot_hit")
                End If
                .Add shot.Name & "_miss_kim_hit", Array("miss_kim_shot_hit")
            Next

            'Caught by Miss Kim: the mode ends with no completion award
            .Add "miss_kim_shot_hit", Array("base_music_start")
        End With

        With .Timers("kims_antiques_intro_delay")
            .StartRunning = True
            .Direction = "down"
            .StartValue = 7
            .EndValue = 0
            .TickInterval = 1000    ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "skip_minigame_intro{device.timers.kims_antiques_intro_delay.ticks > 0}"
                .Action = "jump"
                .Value = 0
            End With
        End With

        'Miss Kim's cycle: she stays on a shot for KimsAntiquesMoveTime seconds, the
        'last KimsAntiquesWarningTime of which the next shot is flashing.
        With .Timers("move_miss_kim")
            .StartRunning = False
            .Direction = "down"
            .StartValue = KimsAntiquesMoveTime
            .EndValue = 0
            .TickInterval = 1000
            With .ControlEvents()
                .EventName = "prime_move_miss_kim"
                .Action = "jump"
                .Value = KimsAntiquesWarningTime
            End With
            With .ControlEvents()
                .EventName = "start_move_miss_kim"
                .Action = "start"
            End With
            With .ControlEvents()
                .EventName = "timer_move_miss_kim_complete"
                .Action = "restart"
            End With
            For Each pauseEvent In Array("balldevice_scoop_ball_entered", "start_hurryup_timer")
                With .ControlEvents
                    .EventName = pauseEvent
                    .Action = "pause"
                End With
            Next
            For Each pauseEvent In Array("scoop_eject_show_complete", "hurryup_is_over")
                With .ControlEvents
                    .EventName = pauseEvent
                    .Action = "start"
                End With
            Next
        End With

        With .SoundPlayer()
            With .EventName("mode_kims_antiques_started")
                .Key = "key_voc_ka_mothercanhear"
                .Sound = "voc_ka_mothercanhear"
            End With
            With .EventName("play_voc_ka_kimsantiques")
                .Key = "key_voc_ka_kimsantiques"
                .Sound = "voc_ka_kimsantiques"
                .Priority = 100
            End With
            With .EventName("start_kims_antiques_music")
                .Key = "key_mus_ka"
                .Sound = "mus_ka"
            End With
            With .EventName("mode_kims_antiques_stopping")
                .Key = "key_mus_ka"
                .Sound = "mus_ka"
                .Action = "stop"
            End With
            With .EventName("kims_antiques_voc_1")
                .Key = "key_voc_ka_belleandsebastian"
                .Sound = "voc_ka_belleandsebastian"
            End With
            With .EventName("kims_antiques_voc_2")
                .Key = "key_voc_ka_cage"
                .Sound = "voc_ka_cage"
            End With
            With .EventName("kims_antiques_voc_3")
                .Key = "key_voc_ka_cautionarytale"
                .Sound = "voc_ka_cautionarytale"
            End With
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
            With .EventName("play_kims_antiques_mode_slide")
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
                With .Variable("kims_warning_active")
                    .Action = "set"
                    .Int = 0
                End With
                'Start award, before mode_display_score is copied from it below
                With .Variable("mode_kims_antiques_score")
                    .Action = "add"
                    .Int = ModeStartScore
                End With
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = "{current_player.mode_kims_antiques_score}"
                End With
            End With

            With .EventName("timer_kims_antiques_mode_tick")
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = "kwargs.ticks_remaining"
                End With
            End With

            'Same event the mode stops on, so add to the recap here rather than on a follow-on event
            With .EventName("timer_kims_antiques_mode_complete")
                With .Variable("mode_kims_antiques_score")
                    .Action = "add"
                    .Int = KimsAntiquesCompleteScore
                End With
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = KimsAntiquesCompleteScore
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
            End With

            With .EventName("kims_jackpot_hit")
                With .Variable("mode_display_score")
                    .Action = "add"
                    .Int = KimsAntiquesJackpotScore
                End With
                With .Variable("mode_kims_antiques_score")
                    .Action = "add"
                    .Int = KimsAntiquesJackpotScore
                End With
            End With

            'One warning at a time (see the move_miss_kim tick above)
            With .EventName("choose_next_miss_kim")
                With .Variable("kims_warning_active")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("set_miss_kim")
                With .Variable("kims_warning_active")
                    .Action = "set"
                    .Int = 0
                End With
            End With

            'Playfield multiplier while the shots are live. The mode's own awards
            'above use NoMultiplier, so this only affects playfield scoring.
            With .EventName("timer_kims_antiques_intro_delay_complete")
                With .Variable("scoring_multiplier")
                    .Action = "set"
                    .Int = KimsAntiquesPlayfieldX
                End With
            End With
            With .EventName("mode_kims_antiques_stopping")
                With .Variable("scoring_multiplier")
                    .Action = "set"
                    .Int = 1
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
                .EventName = "timer_kims_antiques_intro_delay_complete"
                .Action = "start"
            End With
            With .ControlEvents
                .EventName = "balldevice_scoop_ball_entered"
                .Action = "pause"
            End With
            With .ControlEvents
                .EventName = "scoop_eject_show_complete"
                .Action = "start"
            End With
            With .ControlEvents
                .EventName = "start_hurryup_timer"
                .Action = "pause"
            End With
            With .ControlEvents
                .EventName = "hurryup_is_over"
                .Action = "start"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("kims_antiques_shot_hit")
                .Add "kims_antiques_voc_1", 1
                .Add "kims_antiques_voc_2", 1
                .Add "kims_antiques_voc_3", 1
                ' .Add "kims_antiques_voc_4", 1
                ' .Add "kims_antiques_voc_5", 1
                ' .Add "kims_antiques_voc_6", 1
                ' .Add "kims_antiques_voc_7", 1
                .ForceAll = True
                .ForceDifferent = True
            End With

            With .EventName("choose_next_miss_kim")
                For Each shot in kims_antiques_shots
                    .Add "warn_" & shot.Name & "{current_player.shot_" & shot.Name & " != 2}", 1
                Next
                .ForceAll = False
                .ForceDifferent = False
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
                    .Events = Array("warn_" & shot.Name)
                    .State = 1
                End With
                With .ControlEvents()
                    .Events = Array("set_miss_kim{current_player.shot_" & shot.Name & " == 1}")
                    .State = 2
                End With
                With .ControlEvents()
                    .Events = Array("clear_miss_kim{current_player.shot_" & shot.Name & " == 2}", "mode_kims_antiques_started", "mode_kims_antiques_stopping")
                    .State = 0
                End With
            End With
        Next

        'Jackpot light: chases the Dean sign on the right ramp while the jackpot is lit
        With .Shots("kims_jackpot")
            .Profile = "kims_jackpot"
            With .Tokens()
                .Add "color", "00ff00"
            End With
            With .ControlEvents()
                .Events = Array("timer_kims_antiques_intro_delay_complete", "kims_jackpot_relight")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("kims_jackpot_hit", "mode_kims_antiques_started", "mode_kims_antiques_stopping")
                .State = 0
            End With
        End With

        With GlfShotProfiles("kims_jackpot")
            .AdvanceOnHit = False
            'No show: when the chase stops the Dean lights go back to whatever is under it
            With .States("unlit")
                .Key = "key_kims_jackpot_unlit"
            End With
            With .States("lit")
                .Show = "dean_sign_chase"    'defined in CreateGeneralShows()
                .Key = "key_kims_jackpot_lit"
            End With
        End With

        With GlfShotProfiles("kims_antiques")
            .AdvanceOnHit = False
            With .States("unlit")
                .Show = "off"
                .Key = "key_unlit_ka"
            End With
            'The shot Miss Kim is about to move to. Still safe to hit.
            With .States("warning")
                .Show = "flash_color_with_fade"
                .Key = "key_warning_ka"
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