
'*******************************************
'  Base Mode
'*******************************************
' Priority 110 - above attract (100), below any feature mode you add later
' (use 700+ for those) and below score (2000, when you write it).
'
' Runs for the whole of every ball. Owns anything that isn't specific to a
' feature mode: ball save, GI, the insert lights, tilt handling.
'
' No scoring anywhere in here yet - that's deliberate. When you add a score
' mode, the scoring goes on the SAME events already listed below, e.g.
'     .Add "s_ST11_active", Array("score_1000")
'
' NOTE on how the inserts reset: GlfLightPlayer.Deactivate() calls PlayOff
' for every event it registered, so when this mode stops on ball_ended the
' inserts it lit go dark automatically. You don't need an explicit reset.

Sub CreateBaseMode()

    Dim x, giName

    With CreateGlfMode("base", 110)

        .StartEvents = Array("ball_started")
        .StopEvents  = Array("ball_ended", "tilt")


        '--- Event routing -------------------------------------------------
        With .EventPlayer()

            ' Kill the attract mode as soon as a ball starts
            .Add "mode_base_started", Array("stop_attract_mode", "new_ball_started", "base_music_start")
            .Add "mode_base_stopped", Array("base_music_stop")

            .Add "s_RightOutlane_active", Array("outlane_drain", "total_switches_hit_increment")
            .Add "s_LeftOutlane_active", Array("outlane_drain", "total_switches_hit_increment")

            ' The ball leaving the plunger lane for the first time is what
            ' actually starts play - this is what arms the ball save.
            .Add "s_Trigger1_inactive{current_player.ball_just_started == 1}", Array("new_ball_active")

            ' Once play is live, clear the just-started flag
            .Add "new_ball_active", Array("clear_ball_just_started", "coffee_callout")

            'Kickers
            .Add "s_DropTargetKicker_active", Array("diner_callout", "diner_count_increment", "total_switches_hit_increment")
            .Add "s_HiddenUpperRightKicker_active", Array("grandparents_callout", "grandparents_count_increment", "total_switches_hit_increment")

            'Bumpers
            .Add "s_Bumper1_active", Array("score_5000", "play_bumper1_show", "bumper_count_increment", "total_switches_hit_increment")
            .Add "s_Bumper3_active", Array("score_5000", "play_bumper3_show", "bumper_count_increment", "total_switches_hit_increment")
            .Add "s_Bumper5_active", Array("score_5000", "play_bumper5_show", "bumper_count_increment", "total_switches_hit_increment")

            'Slingshots
            .Add "s_LeftSlingShot_active", Array("score_5000", "total_switches_hit_increment")
            .Add "s_RightSlingShot_active", Array("score_5000", "total_switches_hit_increment")

            'Spinners
            .Add "s_left_spinner_active", Array("score_3000", "play_spin1_show", "spinner_count_increment", "total_switches_hit_increment")
            .Add "s_right_spinner_active", Array("score_3000", "play_spin2_show", "spinner_count_increment", "total_switches_hit_increment")
            ' .Add "s_left_spinner_active{device.timers.left_spinner.ticks == 0}", Array("coffee_callout")

            'Star Targets
            .Add "s_slim_target_ramp1_active", Array("star_target_hit", "total_switches_hit_increment")
            .Add "s_slim_target_ramp2_active", Array("star_target_hit", "total_switches_hit_increment")
            .Add "s_slim_target_ramp3_active", Array("star_target_hit", "total_switches_hit_increment")
            .Add "s_slim_target_ramp4_active", Array("star_target_hit", "total_switches_hit_increment")
            .Add "s_slim_target_hidden1_active", Array("star_target_hit", "total_switches_hit_increment")
            .Add "s_slim_target_hidden2_active", Array("star_target_hit", "total_switches_hit_increment")

            'TODO: Add JESS and DEAN hit targets, ramp rollovers, inlanes, bonus lanes, captive ball, ANY OTHERS?

            .Add "base_music_stop", Array("base_music_1_stop", "base_music_2_stop")
        End With

        ' With .Timers("left_spinner")
        '     .StartRunning = True
        '     .TickInterval = 1000
        '     .StartValue = 2
        '     .EndValue = 0
        '     .Direction = "down"
        '     With .ControlEvents()
        '         .EventName = "coffee_callout"
        '         .Action = "restart"
        '     End With
        ' End With


        '--- Player variables ----------------------------------------------
        With .VariablePlayer()
            With .EventName("mode_base_started")
                With .Variable("ball_just_started")
                    .Action = "set"
                    .Int = 1
                End With
                With .Variable("total_switches_hit")
                    .Action = "set"
                    .Int = 0
                End With
                With .Variable("bumper_count")
                    .Action = "set"
                    .Int = 0
                End With
                With .Variable("spinner_count")
                    .Action = "set"
                    .Int = 0
                End With
                With .Variable("diner_count")
                    .Action = "set"
                    .Int = 0
                End With
                With .Variable("grandparents_count")
                    .Action = "set"
                    .Int = 0
                End With
                With .Variable("bonus_total")
                    .Action = "set"
                    .Int = 0
                End With
            End With
            With .EventName("clear_ball_just_started")
                With .Variable("ball_just_started")
                    .Action = "set"
                    .Int = 0
                End With
            End With
            With .EventName("total_switches_hit_increment")
                With .Variable("total_switches_hit")
                    .Action = "add"
                    .Int = 1
                End With
            End With
            With .EventName("bumper_count_increment")
                With .Variable("bumper_count")
                    .Action = "add"
                    .Int = 1
                End With
            End With
            With .EventName("spinner_count_increment")
                With .Variable("spinner_count")
                    .Action = "add"
                    .Int = 1
                End With
            End With
            With .EventName("diner_count_increment")
                With .Variable("diner_count")
                    .Action = "add"
                    .Int = 1
                End With
            End With
            With .EventName("grandparents_count_increment")
                With .Variable("grandparents_count")
                    .Action = "add"
                    .Int = 1
                End With
            End With
        End With

        '--- Sound ---------------------------------------------------------
        With .RandomEventPlayer()
            With .EventName("base_music_start")
                .Add "base_music_1_start", 1
                .Add "base_music_2_start", 1
                .ForceAll = True
                .ForceDifferent = True
            End With
            With .EventName("outlane_drain")
                .Add "poodles1_callout", 1
                .Add "poodles2_callout", 1
                .Add "poodles3_callout", 1
            End With
        End With

        With .SoundPlayer()
            With .EventName("base_music_1_start")
                .Key = "key_mus_go"
                .Sound = "mus_go"
            End With
            With .EventName("base_music_1_stop")
                .Key = "key_mus_go"
                .Sound = "mus_go"
                .Action = "stop"
            End With
            With .EventName("base_music_2_start")
                .Key = "key_mus_happy"
                .Sound = "mus_happy"
            End With
            With .EventName("base_music_2_stop")
                .Key = "key_mus_happy"
                .Sound = "mus_happy"
                .Action = "stop"
            End With
            With .EventName("poodles1_callout")
                .Key = "key_voc_poodles1"
                .Sound = "voc_poodles1"
            End With
            With .EventName("poodles2_callout")
                .Key = "key_voc_poodles2"
                .Sound = "voc_poodles2"
            End With
            With .EventName("poodles3_callout")
                .Key = "key_voc_poodles3"
                .Sound = "voc_poodles3"
            End With
            With .EventName("coffee_callout")
                .Key = "key_voc_coffeecoffeecoffee"
                .Sound = "voc_coffeecoffeecoffee"
            End With
            With .EventName("stars_callout")
                .Key = "key_voc_stars"
                .Sound = "voc_stars"
            End With
            With .EventName("hollow_callout")
                .Key = "key_voc_hollow"
                .Sound = "voc_hollow"
            End With
            With .EventName("drop_target_drop1_down")
                .Key = "key_voc_hollow"
                .Sound = "voc_wereclosed"
            End With
            With .EventName("auto_fire_coil_bumper1_activate")
                .Key = "key_sfx_bumper1"
                .Sound = "sfx_bumper1"
            End With
            With .EventName("auto_fire_coil_bumper3_activate")
                .Key = "key_sfx_bumper2"
                .Sound = "sfx_bumper2"
            End With
            With .EventName("auto_fire_coil_bumper5_activate")
                .Key = "key_sfx_bumper3"
                .Sound = "sfx_bumper3"
            End With
            With .EventName("auto_fire_coil_left_sling_activate")
                .Key = "key_voc_copperboom1"
                .Sound = "voc_copperboom1"
            End With
            With .EventName("auto_fire_coil_right_sling_activate")
                .Key = "key_voc_copperboom2"
                .Sound = "voc_copperboom2"
            End With
            With .EventName("diner_callout")
                .Key = "key_sfx_dinerdoor"
                .Sound = "sfx_dinerdoor"
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("star_target_hit")
                .Add "stars_callout", 1.1
                .Add "hollow_callout", 1
            End With
        End With


        '--- Lights --------------------------------------------------------
        With .LightPlayer()

            ' GI full brightness for the duration of the ball.
            ' Addressed by name - see the note in _configuration.vbs.
            With .EventName("mode_base_started")
                For Each giName In GILightNames
                    With .Lights(giName)
                        .Color = GIColor2700k
                        .Fade  = 300
                    End With
                Next
                ' With .Lights("slim_inserts")
                '     .Color = GIColor2700k
                ' End With
            End With

            ' The eight standup targets each latch their own insert.
            ' s_ST11 -> l11, s_ST12 -> l12, ... s_ST18 -> l18
            For x = 11 To 18
                With .EventName("s_ST" & x & "_active")
                    With .Lights("l" & x)
                        .Color = StandupColor
                        .Fade  = 60
                    End With
                End With
            Next
        End With

        With .ShowPlayer()
            ' With .EventName("mode_base_started")
            '     .Key = "key_show_base"
            '     .Show = "flicker_color_on"
            '     .Speed = 15
            '     With .Tokens()
            '         .Add "color", "ff0000"
            '         .Add "lights", "slim_inserts"
            '     End With
            ' End With
            With .EventName("play_spin1_show") 
                .Key = "key_spin1_show"
                .Show = "flash_color_with_fade"    'defined in CreateGeneralShows()
                .Speed = 10
                .Loops = 0
                With .Tokens()
                    .Add "lights", "FL1"
                    .Add "fade", 500
                    .Add "color", "ff0000"
                End With
            End With
            With .EventName("play_spin2_show") 
                .Key = "key_spin2_show"
                .Show = "flash_color_with_fade"    'defined in CreateGeneralShows()
                .Speed = 10
                .Loops = 0
                With .Tokens()
                    .Add "lights", "FL2"
                    .Add "fade", 500
                    .Add "color", "00ff00"
                End With
            End With
            With .EventName("play_bumper1_show") 
                .Key = "key_bumper1_show"
                .Show = "flash_color_with_fade"    'defined in CreateGeneralShows()
                .Speed = 10
                .Loops = 0
                With .Tokens()
                    .Add "lights", "FL2"
                    .Add "fade", 500
                    .Add "color", "ff0000"
                End With
            End With
            With .EventName("play_bumper3_show") 
                .Key = "key_bumper3_show"
                .Show = "flash_color_with_fade"    'defined in CreateGeneralShows()
                .Speed = 10
                .Loops = 0
                With .Tokens()
                    .Add "lights", "FL3"
                    .Add "fade", 500
                    .Add "color", "0000ff"
                End With
            End With
            With .EventName("play_bumper5_show") 
                .Key = "key_bumper5_show"
                .Show = "flash_color_with_fade"    'defined in CreateGeneralShows()
                .Speed = 10
                .Loops = 0
                With .Tokens()
                    .Add "lights", "FL4"
                    .Add "fade", 500
                    .Add "color", "FFA500"
                End With
            End With
        End With

        '--- DMD -----------------------------------------------------------
        ' These go through the slide/widget player exactly as they would
        ' with a Godot media controller. What is behind them here is
        ' GlfFlexDmdBcpController (ZFBC), which turns the names below into
        ' FlexDMD calls locally. Slide and widget names are mapped in
        ' FlexDmd_ShowSlide / FlexDmd_ShowWidget.
        With .SlidePlayer()
            ' The scoreboard, for the whole ball. Cleared from the slide
            ' stack when base mode stops - the scene itself stays up.
            With .EventName("mode_base_started")
                .Slide  = "score"
                .Action = "play"
            End With
        End With

        With .WidgetPlayer()
            With .EventName("balldevice_plunger_ball_exiting")
                .Widget = "launch"
                .Action = "play"
                .Expire = 1.3
            End With
            With .EventName("ball_save_new_ball_saving_ball")
                .Widget = "ball_save"
                .Action = "play"
                .Expire = 1.3
            End With
        End With

        With .BallHolds("scoop_hold")
            .BallsToHold = 1
            .HoldDevices = Array("scoop")
            .EnableEvents = Array("enable_scoop_hold") 
            .DisableEvents = Array("disable_scoop_hold") 
            .ReleaseAllEvents = Array("release_scoop_hold")
        End With


        '--- Ball save -----------------------------------------------------
        ' AutoLaunch is False on purpose: this table has a mechanical
        ' plunger and no autoplunger coil. GLF will kick a fresh ball to the
        ' plunger lane and you plunge it yourself. Setting AutoLaunch = True
        ' would call glf_plunger.Eject on a MechanicalEject device, which
        ' has nothing to fire.
        With .BallSaves("new_ball")
            .ActiveTime   = 15000
            .HurryUpTime  = 5000
            .GracePeriod  = 3000
            .BallsToSave  = 1
            .AutoLaunch   = True
            .EnableEvents = Array("new_ball_active")
            .TimerStartEvents = Array("balldevice_plunger_ball_eject_success")
        End With

        'Shot created for the ball save light. 
        With .Shots("base_shoot_again")
            .Profile = "shoot_again"  'This is a shared shot profile created in CreateSharedShotProfiles()
            With .Tokens()
                .Add "color", ShootAgainColor
            End With
            With .ControlEvents()
                .Events = Array("ball_save_new_ball_enabled")
                .State = 1
            End With
            With .ControlEvents()
                .Events = Array("ball_save_new_ball_hurry_up")
                .State = 2
            End With
            .RestartEvents = Array("ball_save_new_ball_grace_period","ball_save_new_ball_saving_ball")
        End With


        '--- Hold start for 2s to abandon the game -------------------------
        With .TimedSwitches("cancel_game")
            .Switches         = Array("s_start")
            .Time             = 2000
            .EventsWhenActive = Array("glf_game_cancel")
        End With

        For x = 66 To 69
            With .Shots("star_light_" & x)
                .Profile = "star_lights"
                .Switch = "s_slim_target_ramp" & (x - 65)
                With .Tokens()
                    .Add "color", StarLightColor
                    .Add "lights", "l" & x
                End With
                With .ControlEvents()
                    .Events = Array("s_slim_target_ramp" & (x - 65) & "_active")
                    .State = 1
                End With
            End With
        Next

        For x = 70 To 71
            With .Shots("star_light_" & x)
                .Profile = "star_lights"
                .Switch = "s_slim_target_hidden" & (x - 69)
                With .Tokens()
                    .Add "color", StarLightColor
                    .Add "lights", "l" & x
                End With
                With .ControlEvents()
                    .Events = Array("s_slim_target_hidden" & (x - 69) & "_active")
                    .State = 1
                End With
            End With
        Next
        
        With .ShotProfiles("star_lights")
            With .States("unlit")
                .Show = "off"
            End With
            With .States("on")
                .Show = "flicker_color_on"
                .Speed = 4
                .Priority = 100
                With .Tokens()
                    .Add "color", BonusLaneColor
                End With
            End With
        End With

    End With

End Sub
