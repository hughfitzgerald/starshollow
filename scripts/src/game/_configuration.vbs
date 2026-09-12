'*******************************************
'  ZGCF: GLF Configurations
'*******************************************
' Wired to THIS table's devices only.
'
' This table has: 5-ball trough, mechanical plunger, 2 flippers, 2
' slingshots, bumpers 1/3/5, one VUK, one diverter, and 8 standup targets
' (s_ST11-s_ST18). It does NOT have: drop targets, a scoop, a kickback, a
' staged flipper, a magnet, or a spinner. Nothing for those appears here.
'
' No modes yet - that is the real remaining work. Add Create*Mode() calls
' in the MODES section once you write them.


'*********** GLOBALS ***********

Dim ScoreArray: ScoreArray = Array(1,10,100,333,500,1000,2000,3000,3333,5000,10000,20000,30000,33333,50000,100000,200000,500000,1000000)

' Set by the plunger-lane listeners below; read by ZKEY for the plunger
' release sound. s_Trigger1 is a Trigger, so it has no BallCntOver.
Dim PlungerHasBall : PlungerHasBall = False

Const GIColor3000k      = "ffdca3"
Const GIColor2700k      = "ffA957"   ' warm white, GI during play
Const GIColorAttract    = "ff8c3a"   ' attract, bright phase
Const GIColorAttractDim = "5a3010"   ' attract, dim phase
Const StandupColor      = "0023cc"   ' the 8 standup inserts l11..l18
Const BonusLaneColor    = "fc7703"   ' the 2 bonus lane inserts l8, l9
Const SkillshotColor    = "fc7703"   ' the 2 bonus lane inserts l8, l9
Const ShootAgainColor = "00ff00"
Const ExtraBallColor = "0000ff"
Const RampshotColor = "8800ff"
Const LoganColor = "8800ff"
Const MultiballColor = "1eff6b"
Const StarLightColor = "ffff00"   ' yellow for star lights

Const BonusMultiplierFactor = 1000
Const BonusSpinnerFactor = 1000
Const BonusBumperFactor = 2000
Const BonusDinerFactor = 3000
Const BonusGrandparentsFactor = 4000

Const BaseMusic1Duration = 245  ' go
Const BaseMusic2Duration = 51  ' happy
Const BaseMusic3Duration = 37  ' alternate
Const BaseMusic4Duration = 189  ' book
Const BaseMusic5Duration = 53  ' longer
Const BaseMusic6Duration = 235  ' maybe
Const BaseMusic7Duration = 333  ' popcorn


Sub ConfigureGlfDevices()

    Dim x

    '*********** INITALIZE SHOWS ***********

    ' Load up the shows
    CreateGeneralShows()

    ' Load shared shot profiles
    CreateSharedShotProfiles()

    '*********** SOUND BUSES ***********

    With CreateGlfSoundBus("mus")
        .SimultaneousSounds = 4
        .Volume = 0.2
    End With
    With CreateGlfSoundBus("sfx")
        .SimultaneousSounds = 8
        .Volume = 0.3
    End With
    With CreateGlfSoundBus("voc")
        .SimultaneousSounds = 2
        .Volume = 0.5
    End With

    CreateSounds()


    '*********** EVENT LISTENERS ***********

    AddPinEventListener "trough_eject", "on_trough_eject", "OnTroughEject", 2000, Null
    AddPinEventListener GLF_BALL_DRAIN, "ball_drain_sound", "BallDrainSound", 100, Null

    ' TODO: You probably don't want to use balldevice ball entered events to do this! because do they fire during the multiball relay?
    ' TODO: ALSO, do we want another callback for lock_unlit?
    AddPinEventListener "lock_unlit", "disable_multiball_lock", "DisableMultiballLock", 100, Null
    AddPinEventListener "lock_lit", "enable_initial_multiball_lock", "EnableInitialMultiballLock", 100, Null
    AddPinEventListener "balldevice_lock1_ball_entered", "enable_second_multiball_lock", "EnableSecondMultiballLock", 100, Null
    AddPinEventListener "balldevice_lock2_ball_entered", "enable_third_multiball_lock", "EnableThirdMultiballLock", 100, Null

    
    AddPinEventListener "clear_multiball_locks", "clear_multiball_locks_called", "ClearMultiballLocksListener", 100, Null
    AddPinEventListener "clear_multiball_locks", "enable_subway_return", "EnableSubwayReturn", 100, Null

    AddPinEventListener "free_captive_ball", "set_captive_ball_free", "SetCaptiveBallFreeListener", 100, Null
    AddPinEventListener "capture_captive_ball", "capture_captive_ball_called", "CaptureCaptiveBall", 100, Null
    AddPinEventListener "return_captive_from_drain", "return_captive_from_drain_called", "ReturnCaptiveFromDrain", 100, Null
    AddPinEventListener "disable_captive_ramp_upper_kicker", "disable_captive_ramp_upper_kicker_called", "DisableCaptiveRampUpperKicker", 100, Null

	AddPinEventListener "s_LeftInlane_active",  "left_inlane_speed_limit",  "LeftInlaneSpeedLimitListener",  100, Null
	AddPinEventListener "s_RightInlane_active", "right_inlane_speed_limit", "RightInlaneSpeedLimitListener", 100, Null

    AddPinEventListener "s_enter_left_ramp_active",     "enter_left_ramp_roll",     "EnterLeftRampListener",     100, Null
    AddPinEventListener "s_complete_left_ramp_active",  "complete_left_ramp_roll",  "CompleteLeftRampListener",  100, Null
    AddPinEventListener "s_enter_right_ramp_active",    "enter_right_ramp_roll",    "EnterRightRampListener",    100, Null
    AddPinEventListener "s_complete_right_ramp_active", "complete_right_ramp_roll", "CompleteRightRampListener", 100, Null

    AddPinEventListener "s_Trigger1_active",   "plunger_ball_in",  "PlungerBallIn",  100, Null
    AddPinEventListener "s_Trigger1_inactive", "plunger_ball_out", "PlungerBallOut", 100, Null


    '*********** HIGH SCORES ***********

    With EnableGlfHighScores()
        With .Categories()
            .Add "score", Array("GRAND CHAMPION", "HIGH SCORE 1", "HIGH SCORE 2", "HIGH SCORE 3")
        End With
        With .Defaults("score")
            .Add "LOR", 5000000
            .Add "ROR", 2000000
            .Add "LUK", 1000000
            .Add "SOO", 500000
        End With
    End With

    '*********** INITALIZE MACHINE VARIABLES ***********
    ' These variables are tracked for this machine. 
    ' Initial values are set first time the machine turns on. After that, values are read from the machines ini file.

    With CreateMachineVar("game_modes_enabled")         'tracks if game modes are enabled
        .InitialValue = 0
        .ValueType = "int"
        .Persist = False
    End With

    With CreateMachineVar("last_score")  'tracks the last score of the player
        .InitialValue = 0
        .ValueType = "int"
        .Persist = False
    End With
    
    With CreateMachineVar("high_score_initials")        'captures high score initials during high score mode
        .InitialValue = ""
        .ValueType = "string"
        .Persist = False
    End With
    With CreateMachineVar("high_score_initials_index")  'used to index through high score initials
        .InitialValue = 0
        .ValueType = "int"
        .Persist = False
    End With
    With CreateMachineVar("high_score_initials_chars")  'used to count current number of high score initials
        .InitialValue = 0
        .ValueType = "int"
        .Persist = False
    End With
    With CreateMachineVar("high_score_player_num")  'tracks which player is entering initials
        .InitialValue = 1
        .ValueType = "int"
        .Persist = False
    End With

    With CreateMachineVar("display_top_small_text")   'text to display at the top of the screen
        .InitialValue = ""
        .ValueType = "string"
        .Persist = False
    End With
    With CreateMachineVar("display_middle_large_text")   'text to display at the middle of the screen
        .InitialValue = ""
        .ValueType = "string"
        .Persist = False
    End With
    With CreateMachineVar("display_bottom_small_text")   'text to display at the bottom of the screen
        .InitialValue = ""
        .ValueType = "string"
        .Persist = False
    End With

    With CreateMachineVar("num_balls_locked")         'number of balls locked
        .InitialValue = 0                               'used to maintain state of locks across players
        .ValueType = "int"
        .Persist = False
    End With

    With CreateMachineVar("credits")
        .InitialValue = 0
        .ValueType = "int"
        .Persist = True
    End With

    With CreateMachineVar("captive_ball_captive")   'tracks if the captive ball is currently captured
        .InitialValue = 1
        .ValueType = "int"
        .Persist = False
    End With

    '*********** PLAYER VARIABLES ***********

    Glf_SetInitialPlayerVar "ball_just_started", 1
    Glf_SetInitialPlayerVar "scoring_multiplier", 1

    Glf_SetInitialPlayerVar "ss1_started", 0

    Glf_SetInitialPlayerVar "bonus_multiplier", 1
    Glf_SetInitialPlayerVar "total_switches_hit", 0
    Glf_SetInitialPlayerVar "bumper_count", 0
    Glf_SetInitialPlayerVar "spinner_count", 0
    Glf_SetInitialPlayerVar "diner_count", 0
    Glf_SetInitialPlayerVar "grandparents_count", 0
    Glf_SetInitialPlayerVar "bonus_total", 0

    Glf_SetInitialPlayerVar "bonus_display_text", "BONUS 1x"
    Glf_SetInitialPlayerVar "bonus_display_score", "0"

    Glf_SetInitialPlayerVar "mode_display_text", "MODE: NONE"
    Glf_SetInitialPlayerVar "mode_display_score", 0
    Glf_SetInitialPlayerVar "mode_display_instructions", "INSTRUCTIONS: NONE"
    Glf_SetInitialPlayerVar "mode_display_timer", ""

    Glf_SetInitialPlayerVar "mode_llmb_score", 0 ' Lock-Away Logan Multiball
    Glf_SetInitialPlayerVar "mode_jdmb_score", 0 ' Jess & Dean Multiball
    Glf_SetInitialPlayerVar "mode_dm_score", 0 ' Dance Marathon
    Glf_SetInitialPlayerVar "mode_tm_score", 0 ' Town Meeting
    Glf_SetInitialPlayerVar "mode_lbtb_score", 0 ' Luke Breaks the Bells
    Glf_SetInitialPlayerVar "mode_ka_score", 0 ' Kim's Antiques
    Glf_SetInitialPlayerVar "mode_dinner_score", 0 ' Friday Night Dinner
    Glf_SetInitialPlayerVar "mode_punch_score", 0 ' Founder's Day Punch

    Glf_SetInitialPlayerVar "is_lock_qualified", 0        'flag keeps track of when a player has qualified the locks
    Glf_SetInitialPlayerVar "hs_input_ready", 1         'flag to capture when high score mode is ready for player input
    Glf_SetInitialPlayerVar "llmb_shoot_again_active", 0
    Glf_SetInitialPlayerVar "logan_cooldown_active", 0


    '*********** MODES ***********
    ' Order here does not matter - each mode registers its own start/stop
    ' events and GLF sorts them by priority at dispatch time.
    CreateAttractMode()      ' priority 100
    CreateBasementMode()      ' priority 100
    CreatePostGameMode()    ' priority 105

    CreateBaseMode()         ' priority 110

    CreateHighScoreMode()    ' priority 120
    CreateBonusMode()        ' priority 150

    CreateJDMultiballQualifyMode()    ' priority 200
    CreateBonusLanesMode()  ' priority 210
    CreateLLMultiballQualifyMode() ' priority 220

    CreateSkillshotsMode()   ' priority 400
    CreateMinigameMode()      ' priority 500
    CreateExtraBallMode()    ' priority 510
    CreateMysteryMode()       ' priority 580
    CreateRampshotsMode()    ' priority 660

    CreateDanceMarathonMode() ' priority 670
    CreateTownMeetingMode()    ' priority 680

    CreateJDMultiballMode()    ' priority 1000
    CreateLLMultiballMode()    ' priority 1005

    CreateScoreMode()        ' priority 2000
    CreateTiltMode()         ' priority 10000


    '*********** DEVICES ***********

    ' --- Plunger lane (s_Trigger1 -> s_Trigger1) ---
    ' MUST be a member of glf_switches.
    With CreateGlfBallDevice("plunger")
        .BallSwitches = Array("s_Trigger1")
        .EjectTimeout = 2000
        .MechanicalEject = True
        .DefaultDevice = True
        .EjectCallback = "PlungerEjectCallback"
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("auto_launch_plunger")
    End With

    ' --- Flippers ---
    ' MUST NOT be in any collection.
    ' SolLFlipper/SolRFlipper already have GLF's exact (Enabled) signature,
    ' so they are pointed at directly - no wrapper, no rewrite.
    With CreateGlfFlipper("left")
        .Switch = "s_left_flipper"
        .ActionCallback = "SolLFlipper"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

    With CreateGlfFlipper("right")
        .Switch = "s_right_flipper"
        .ActionCallback = "SolRFlipper"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

    ' --- Slingshots ---
    ' MUST be members of glf_slingshots.
    With CreateGlfAutoFireDevice("left_sling")
        .Switch = "s_LeftSlingShot"
        .ActionCallback = "LeftSlingshotAction"
        .DisabledCallback = "LeftSlingshotDisabled"
        .EnabledCallback = "LeftSlingshotEnabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

    With CreateGlfAutoFireDevice("right_sling")
        .Switch = "s_RightSlingShot"
        .ActionCallback = "RightSlingshotAction"
        .DisabledCallback = "RightSlingshotDisabled"
        .EnabledCallback = "RightSlingshotEnabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

    With CreateGlfAutoFireDevice("top_sling")
        .Switch = "s_TopSlingShot"
        .ActionCallback = "TopSlingshotAction"
        .DisabledCallback = "TopSlingshotDisabled"
        .EnabledCallback = "TopSlingshotEnabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

    ' --- Bumpers (1, 3, 5 - there is no 2 or 4 on this table) ---
    ' MUST be members of glf_switches.
    With CreateGlfAutoFireDevice("bumper1")
        .Switch = "s_Bumper1"
        .ActionCallback = "Bumper1Action"
        .DisabledCallback = "Bumper1Disabled"
        .EnabledCallback = "Bumper1Enabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

    ' With CreateGlfAutoFireDevice("bumper3")
    '     .Switch = "s_Bumper3"
    '     .ActionCallback = "Bumper3Action"
    '     .DisabledCallback = "Bumper3Disabled"
    '     .EnabledCallback = "Bumper3Enabled"
    '     .DisableEvents = Array("kill_flippers")
    '     .EnableEvents = Array("ball_started", "enable_flippers")
    ' End With

    With CreateGlfAutoFireDevice("bumper5")
        .Switch = "s_Bumper5"
        .ActionCallback = "Bumper5Action"
        .DisabledCallback = "Bumper5Disabled"
        .EnabledCallback = "Bumper5Enabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

    ' --- VUK ---
    ' MUST be a member of glf_switches.
    With CreateGlfBallDevice("scoop")
        .Debug = True
        .BallSwitches = Array("s_VUK1")
        .EjectTimeout = 2000
        .MechanicalEject = True
        ' .Debug = True
        ' .AutoFireOnUnexpectedBall = False
        ' .EjectAllEvents = Array("eject_vuk")
        .EjectCallback = "ScoopEjectCallback"
    End With

    With CreateGlfBallDevice("drop_target_kicker")
        .BallSwitches = Array("s_DropTargetKicker")
        .Debug = True
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_DropTargetKicker_active")
        .EjectCallback = "DropTargetKickerEjectCallback"
		.MechanicalEject = True
    End With

    With CreateGlfBallDevice("hidden_upper_right_kicker")
        .BallSwitches = Array("s_HiddenUpperRightKicker")
        .Debug = True
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_HiddenUpperRightKicker_active")
        .EjectCallback = "HiddenUpperRightKickerEjectCallback"
		.MechanicalEject = True
    End With

    With CreateGlfBallDevice("lock1")
        .Debug = True
        .BallSwitches = Array("s_Lock1")
        .EjectTargets = Array("s_VUK1")
        .EjectCallback = "Lock1EjectCallback"
		.MechanicalEject = True
    End With

    With CreateGlfBallDevice("lock2")
        .Debug = True
        .BallSwitches = Array("s_Lock2")
        .EjectTargets = Array("s_Lock1")
        .EjectCallback = "Lock2EjectCallback"
		.MechanicalEject = True
    End With

    With CreateGlfBallDevice("subway_trough")
        .BallSwitches = Array("s_subway_trough_kicker")
        .EjectCallback = "SubwayTroughEjectCallback"
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_subway_trough_kicker_active")
		.MechanicalEject = True
    End With

    With CreateGlfBallDevice("captive_ramp_kicker")
        .BallSwitches = Array("s_CaptiveRampKicker")
        .Debug = True
        .AutoFireOnUnexpectedBall = True
        ' .EjectAllEvents = Array("s_CaptiveRampKicker_active")
        .EjectCallback = "CaptiveRampKickerEjectToCaptivity"
		.MechanicalEject = True
    End With

    With CreateGlfBallDevice("captive_ramp_upper_kicker")
        .BallSwitches = Array("s_CaptiveRampUpperKicker")
        .Debug = True
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_CaptiveRampUpperKicker_active")
        .EjectCallback = "CaptiveRampUpperKickerEjectCallback"
		.MechanicalEject = True
    End With

    With CreateGlfBallDevice("drain_subway_kicker")
        .BallSwitches = Array("s_DrainSubwayKicker")
        .Debug = True
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_DrainSubwayKicker_active")
        .EjectCallback = "DrainSubwayKickerEject"
		.MechanicalEject = True
    End With

    ' --- Diverter ---
    ' Was Diverter.RotateToEnd inline in Table1_KeyDown. GLF owns the
    ' flipper keys now, so bind to the virtual flipper switch events.
    With CreateGlfDiverter("ramp_diverter")
        .EnableEvents = Array("ball_started", "reset_complete")
        .ActivateEvents = Array("open_ramp_diverter")
        .DeactivateEvents = Array("close_ramp_diverter")
        .ActionCallback = "RampDiverterAction"
    End With

    With CreateGlfDiverter("subway_diverter")
        .EnableEvents = Array("ball_started")
        .ActivateEvents = Array("clear_multiball_locks")
        .DeactivateEvents = Array("multiball_locks_cleared")
        .ActionCallback = "SubwayDiverterAction"
    End With

    With CreateGlfDiverter("captive_diverter")
        .EnableEvents = Array("ball_started", "reset_complete")
        .ActivateEvents = Array("open_captive_diverter")
        .DeactivateEvents = Array("close_captive_diverter")
        .ActionCallback = "CaptiveDiverterAction"
    End With

    ' --- Standup targets s_ST11..s_ST18 ---
    ' MUST NOT be in any collection. RothSTSwitchID must match the 3rd
    ' argument of the Set STnn = (new StandupTarget)(...) lines in ZRST.
    For x = 11 To 18
        With CreateGlfStanduptarget("target" & x)
            .Switch = "s_ST" & x
            .UseRothStanduptarget = True
            .RothSTSwitchID = x
        End With
    Next

    For x = 1 To 4
        With CreateGlfStanduptarget("star_ramp" & x)
            .Switch = "s_slim_target_ramp" & x
            .UseRothStanduptarget = True
            .RothSTSwitchID = 65 + x
        End With
    Next

    For x = 1 To 2
        With CreateGlfStanduptarget("star_hidden" & x)
            .Switch = "s_slim_target_hidden" & x
            .UseRothStanduptarget = True
            .RothSTSwitchID = 69 + x
        End With
    Next

    'Drop Targets
    'NOTE: Drop targets SHOULD NOT be added to the glf_switches collection nor any other collection. 
    With CreateGlfDroptarget("drop1")
        .Switch = "s_DT1"
        .KnockdownEvents = Array("dt1_knockdown")
        .ResetEvents = Array("ball_started","reset_complete")
        .ActionCallback = "DT1Callback"
        .UseRothDroptarget = True
        .RothDTSwitchID = 1
    End With
    With CreateGlfDroptarget("drop2")
        .Switch = "s_DT2"
        .KnockdownEvents = Array("dt2_knockdown")
        .ResetEvents = Array("ball_started")
        .EnableKeepUpEvents = Array("dt2_enable_keepup", "reset_complete")
        .DisableKeepUpEvents = Array("dt2_disable_keepup")
        .ActionCallback = "DT2Callback"
        .UseRothDroptarget = True
        .RothDTSwitchID = 2
    End With

End Sub


'======================================================
'  Callbacks
'======================================================

Function OnTroughEject(args)
    RandomSoundBallRelease swTrough1
End Function

Function BallDrainSound(args)
    RandomSoundDrain Drain
    BallDrainSound = args(1)      ' relay event - must return the value
End Function

Function PlungerBallIn(args)
    PlungerHasBall = True
End Function

Function PlungerBallOut(args)
    PlungerHasBall = False
End Function

Dim glf_subwayBallsReturning : glf_subwayBallsReturning = 0

Function SubwayReturnHandler(args)
    Dim ballsToSave : ballsToSave = args(1)
    If glf_subwayBallsReturning > 0 And ballsToSave > 0 Then
        glf_subwayBallsReturning = glf_subwayBallsReturning - 1
        ballsToSave = ballsToSave - 1
    End If
    SubwayReturnHandler = ballsToSave
    If glf_subwayBallsReturning = 0 Then
        RemovePinEventListener GLF_BALL_DRAIN, "subway_return_claim"
        DispatchPinEvent "all_balls_returned", 100
    End If
End Function

Function EnableSubwayReturn(args)
    glf_subwayBallsReturning = glf_machine_vars("num_balls_locked").GetValue()
    If glf_subwayBallsReturning > 0 Then
        AddPinEventListener GLF_BALL_DRAIN, "subway_return_claim", "SubwayReturnHandler", 500, Null
    Else
        DispatchPinEvent "all_balls_returned", 100
    End If
End Function

'======================================================
'  Sounds - empty until you have real assets.
'  The three helper subs are generic; keep them.
'======================================================

Sub CreateSounds()
    AddMusic       "mus_happy",  BaseMusic2Duration, 0
    AddMusic       "mus_married",  217, -1
    AddMusic       "mus_go",  BaseMusic1Duration, 0
    AddMusic       "mus_sad",  93, 0
    AddMusic       "mus_alternate",  BaseMusic3Duration, 0
    AddMusic       "mus_book",  BaseMusic4Duration, 0
    AddMusic       "mus_longer",  BaseMusic5Duration, 0
    AddMusic       "mus_maybe",  BaseMusic6Duration, 0
    AddMusic       "mus_popcorn",  BaseMusic7Duration, 0
    AddMusic       "mus_shoo",  48, 0
    AddMusic       "mus_guitarmode", 33.882, -1

    AddCallout     "voc_poodles1",  2
    AddCallout     "voc_poodles2",  2
    AddCallout     "voc_poodles3",  2
    AddCallout     "voc_mystery", 3
    AddCallout     "voc_coffeecoffeecoffee", 1
    AddCallout     "voc_truman", 2
    AddCallout     "voc_stars", 1
    AddCallout     "voc_hollow", 1
    AddCallout     "voc_tall", 2
    AddCallout     "voc_exboyfriend", 3
    AddCallout     "voc_wereclosed", 1
    AddCallout     "voc_copperboom1", 1
    AddCallout     "voc_copperboom2", 1
    AddCallout     "voc_richardtheyrehere", 2

    AddSoundEffect "sfx_dinerdoor", 5
    AddSoundEffect "sfx_bumper1", 1
    AddSoundEffect "sfx_bumper2", 1
    AddSoundEffect "sfx_bumper3", 1
    AddSoundEffect "sfx_eob_bonus", 2

    ' Logan Multiball
    AddCallout     "voc_logan_hit1", 2
    AddCallout     "voc_logan_hit2", 2
    AddCallout     "voc_logan_hit3", 1
    AddCallout     "voc_buttfacedmiscreant_full", 7

    ' Dance Marathon
    AddMusic       "mus_dm",  305, -1
    AddCallout     "voc_dancingfun", 2
    AddCallout     "voc_flipallyouwant", 2
    AddCallout     "voc_justkeepdancing", 1
    AddCallout     "voc_letmeflipyou", 3
    AddCallout     "voc_lookgreat", 2
    AddCallout     "voc_neeson", 2
    AddCallout     "voc_prostrate", 6
    
    ' AddSoundEffect "sfx_name", <seconds>
    ' AddCallout     "voc_name", <seconds>
    ' Durations must be exact - GLF sequences on them.
End Sub

Sub AddMusic(Name, Duration, Loops)
    With CreateGlfSound(Name)
        .File = Name
        .Bus = "mus"
        .Loops = Loops
        .Duration = Duration * 1000
        .EventsWhenStopped = Array(Name & "_stopped")
    End With
End Sub

Sub AddSoundEffect(Name, Duration)
    With CreateGlfSound(Name)
        .File = Name
        .Bus = "sfx"
        .Duration = Duration * 1000
        .EventsWhenStopped = Array(Name & "_stopped")
    End With
End Sub

Sub AddCallout(Name, Duration)
    With CreateGlfSound(Name)
        .File = Name
        .Bus = "voc"
        .Duration = Duration * 1000
        .EventsWhenStopped = Array(Name & "_stopped")
    End With
End Sub



' Shared shot profile examples. These profiles can be used by shots in any mode.
Public Sub CreateSharedShotProfiles()


    'This shot profile is used turn on a light. 
    'The "lights" and "color" tokens must be defined in Shot.
    ' States:
    '  0 - unlit
    '  1 - on
    With GlfShotProfiles("off_on_color")
        With .States("unlit")
            .Show = "off"                   'defined in glf
            .Key = "key_off_on_color_unlit"
        End With
        With .States("on")
            .Show = "led_color"             'defined in glf
            .Key = "key_off_on_color_on"
        End With
    End With


    'This shot profile is used turn on a light with a flickering effect. 
    'The "lights" and "color" tokens must be defined in Shot.
    ' States:
    '  0 - unlit
    '  1 - on
    With GlfShotProfiles("flicker_on")
        With .States("unlit")
            .Show = "off"                   'defined in glf
            .Key = "key_flicker_on_unlit"
        End With
        With .States("on")
            .Show = "flicker_color_on"      'defined in CreateGeneralShows()
            .Key = "key_flicker_on_on"
            .Speed = 4
        End With
    End With


    'This shot profile turns a light on initially with a flickering effect then turns off with a flickering effect. 
    'The "lights" and "color" tokens must be defined in Shot.
    ' States:
    '  0 - lit
    '  1 - unlit
    With GlfShotProfiles("flicker_on_flicker_off")
        With .States("lit")
            .Show = "flicker_color_on"      'defined in CreateGeneralShows()
            .Key = "key_flicker_on_flicker_off_lit"
            .Speed = 3
        End With
        With .States("unlit")
            .Show = "flicker_color_off"     'defined in CreateGeneralShows()
            .Speed = 3
            .Key = "key_flicker_on_flicker_off_unlit"
        End With
    End With


    'This shot profile is used to indicate when a ball save is active. Light l1 is always used.
    'The "color" token must be defined in shot.
    ' States:
    '  0 - unlit
    '  1 - flashing
    '  2 - hurry
    With GlfShotProfiles("shoot_again")
      With .States("unlit")
          .Show = "off"                     'defined in glf
          .Key = "key_shoot_again_unlit"
          With .Tokens()
              .Add "lights", "l1"
          End With
      End With
      With .States("flashing")
          .Show = "flash_color_with_fade"   'defined in CreateGeneralShows()
          .Key = "key_shoot_again_flashing"
          .Speed = 2
          .Priority = 5000
          With .Tokens()
              .Add "lights", "l1"
              .Add "fade", 500
          End With
      End With
      With .States("hurry")
          .Show = "flash_color"             'defined in glf
          .Key = "key_shoot_again_hurry"
          .Speed = 7
          .Priority = 5000
          With .Tokens()
              .Add "lights", "l1"
          End With
      End With
    End With

    With GlfShotProfiles("qualified_shot")
        With .States("unlit")
            .Show = "off"
            .Key = "key_off_d"
        End With
        With .States("ready")
            .Show = "flash_color_with_fade"
            .Key = "key_on_d"
            .Speed = 2
            With .Tokens()
                .Add "fade", 100
            End With
        End With
    End With


End Sub

' A single mode shot: which switch/light it uses, and which
' random-event group (e.g. "dm_orbits") lights it.
Class ShotDef
    Public Name
    Public Switch
    Public Light
    Public Group
End Class

Function NewShot(name, switch, light, group)
    Dim s : Set s = New ShotDef
    s.Name   = name
    s.Switch = switch
    s.Light  = light
    s.Group  = group
    Set NewShot = s
End Function