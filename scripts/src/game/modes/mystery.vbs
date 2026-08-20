

Sub CreateMysteryMode
    Dim x

    With CreateGlfMode("mystery", 580)
        .StartEvents = Array("new_ball_started")
        .StopEvents = Array("mode_base_stopping")

        With .EventPlayer()
            ' .Add "mode_mystery_started", Array("light_inlanes")
            .Add "qualify_multiplier_group_on_complete", Array("light_inlanes")

            .Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==0}", Array("check_minigame")
            .Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==1 and current_player.mb_active==0}", Array("select_random_mystery")
            .Add "balldevice_scoop_ball_entered{current_player.mb_active==1}", Array("disable_scoop_hold")

            .Add "select_random_mystery", Array("play_mystery_show")
            .Add "timer_mystery_show_complete", Array("restart_qualify_mystery")

            .Add "restart_qualify_mystery", Array("check_minigame")

            .Add "inlane_1_lit_hit", Array("mystery_is_ready")
            .Add "inlane_2_lit_hit", Array("mystery_is_ready")
            .Add "mystery_is_ready", Array("enable_scoop_hold")
        End With

        With .Timers("mystery_show")
            .StartRunning = False
            .Direction = "down"      ' Count down
            .StartValue = 5
            .EndValue = 0            ' End at 0
            .TickInterval = 1000     ' Tick every 1 second (1000 ms)
            With .ControlEvents
                .EventName = "play_mystery_show"
                .Action = "start"
            End With
        End With


        With .RandomEventPlayer()
            '.Debug = True
            With .EventName("select_random_mystery")
                ' .Add "mystery_full_health{current_player.shot_health9_light == 0}", 1
                ' .Add "mystery_full_protons{current_player.shot_proton_round6 == 0}", 0.7
                ' .Add "mystery_added_cluster{current_player.shot_cluster_bomb2 == 0}", 0.8
                ' .Add "mystery_added_saver{current_player.shot_ship_charge3 != 2}", 1
                ' .Add "mystery_added_shields{current_player.shot_shield_left == 0}", 1
                ' .Add "mystery_moon_ready{current_player.shot_moon_missile2 == 0 and device.state_machines.moon_mb.state!=""locking""}", 1
                ' '.Add "mystery_trainer_ready{current_player.shot_training_ready == 0 and current_player.training_total_achieved < 6}", 1
                ' .Add "mystery_double_scoring{current_player.scoring_multiplier == 1}", 0.5
                ' .Add "mystery_super_spinner{current_player.spin_multiplier == 1}", 0.5
                ' .Add "mystery_super_pops{current_player.pop_multiplier == 1}", 0.5 
                ' .Add "mystery_double_bonus{current_player.bonus_multiplier == 1}", 0.5  
                ' .Add "mystery_relaxed_combos{current_player.combos_relaxed == 0}", 0.5
                ' .Add "activate_nuke{current_player.nuke_acquired == 0}", 0.5
                '.Add "mystery_eb_is_lit{current_player.eb_ready == 0}", 0.1
                .ForceAll = False
                .ForceDifferent = False
            End With
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
            .Switches = Array("s_LeftInlane")
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
            .Switches = Array("s_RightInlane")
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
            .AdvanceOnHit = False
            With .States("unlit")
                .Key = "key_inlane_unlit"
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

        With .SoundPlayer()
            With .EventName("select_random_mystery")
                .Key = "key_voc_mystery"
                .Sound = "voc_mystery"
            End With
        End With
    End With
End Sub