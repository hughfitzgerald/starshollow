
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

            .Add "s_RightOutlane_active", Array("outlane_drain")
            .Add "s_LeftOutlane_active", Array("outlane_drain")

            ' The ball leaving the plunger lane for the first time is what
            ' actually starts play - this is what arms the ball save.
            .Add "s_Trigger1_inactive{current_player.ball_just_started == 1}", Array("new_ball_active")

            ' Once play is live, clear the just-started flag
            .Add "new_ball_active", Array("clear_ball_just_started")

            'Bumpers
            .Add "s_Bumper1_active", Array("score_5000", "play_bumper1_show")
            .Add "s_Bumper3_active", Array("score_5000", "play_bumper3_show")
            .Add "s_Bumper5_active", Array("score_5000", "play_bumper5_show")

            'Slingshots
            .Add "s_LeftSlingShot_active", Array("score_5000")
            .Add "s_RightSlingShot_active", Array("score_5000")

            'Spinners
            .Add "s_left_spinner_active", Array("score_3000", "play_spin1_show")
            .Add "s_right_spinner_active", Array("score_3000", "play_spin2_show")

            .Add "base_music_stop", Array("base_music_1_stop", "base_music_2_stop")
        End With


        '--- Player variables ----------------------------------------------
        With .VariablePlayer()
            With .EventName("mode_base_started")
                With .Variable("ball_just_started")
                    .Action = "set"
                    .Int = 1
                End With
            End With
            With .EventName("clear_ball_just_started")
                With .Variable("ball_just_started")
                    .Action = "set"
                    .Int = 0
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
            With .EventName("outlane_drain")
                .Key = "key_voc_poodles"
                .Sound = "voc_poodles"
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
            With .EventName("mode_base_started")
                .Key = "key_show_base"
                .Show = "flicker_color_on"
                .Speed = 15
                With .Tokens()
                    .Add "color", "ff0000"
                    .Add "lights", "slim_inserts"
                End With
            End With
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

    End With

End Sub
