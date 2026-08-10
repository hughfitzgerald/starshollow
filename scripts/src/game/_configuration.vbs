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

' GI lights.
'
' The modes iterate this array and address each light BY NAME.
'
' Deliberately NOT using GLF's light-tag feature. GLF can group lights by
' tag, but it builds those tags from each light's BlinkPattern field:
'     For Each light In Glf_Lights
'         tags = Split(light.BlinkPattern, ",")   ' -> tag "T_" & value
' VPX defaults BlinkPattern to "10", so every untouched light lands under
' the tag "T_10" and a lookup for "T_GI" returns Nothing. GlfLightPlayer
' then does glf_lightTags("T_GI").Keys() and throws "Object required" at
' Glf_Init - which is fatal and gives no hint about the real cause.
'
' Addressing lights by name avoids the whole mechanism. If you later want
' tags, set BlinkPattern to GI on each of these in the VPX editor first.
'
' Every name here must be a member of the glf_lights collection.
Dim GILightNames : GILightNames = Array( _
    "gi006","gi007","gi008","gi009","gi010","gi011","gi012","gi013","gi014", _
    "gi015","gi016","gi017","gi018","gi019","gi020","gi021","gi022","gi023", _
    "gi024","gi050")

Const GIColor2700k      = "ffA957"   ' warm white, GI during play
Const GIColorAttract    = "ff8c3a"   ' attract, bright phase
Const GIColorAttractDim = "5a3010"   ' attract, dim phase
Const StandupColor      = "0023cc"   ' the 8 standup inserts l11..l18
Const BonusLaneColor    = "fc7703"   ' the 2 bonus lane inserts l8, l9
Const ShootAgainColor = "00ff00"
Const ExtraBallColor = "0000ff"
Const RampshotColor = "8800ff"
Const MultiballColor = "1eff6b"


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
        .Volume = 1
    End With
    With CreateGlfSoundBus("sfx")
        .SimultaneousSounds = 8
        .Volume = 0.5
    End With
    With CreateGlfSoundBus("voc")
        .SimultaneousSounds = 2
        .Volume = 1
    End With

    CreateSounds()


    '*********** EVENT LISTENERS ***********

    AddPinEventListener "trough_eject", "on_trough_eject", "OnTroughEject", 2000, Null
    AddPinEventListener GLF_BALL_DRAIN, "ball_drain_sound", "BallDrainSound", 100, Null

    ' Track ball-in-plunger-lane for the ZKEY release sound.
    ' VUK hold: wait 1.5s after the ball is captured, then eject. This
    ' replaces the original VUK1.TimerInterval = 1500.
    ' AddPinEventListener "s_VUK1_active", "vuk1_hold", "Vuk1Hold", 100, Null

    AddPinEventListener "lock_lit", "enable_initial_multiball_lock", "EnableMultiballLockListener", 100, Null
    AddPinEventListener "balldevice_lock1_ball_entered", "enable_additional_multiball_lock", "EnableMultiballLockListener", 100, Null
    AddPinEventListener "balldevice_lock2_ball_entered", "enable_additional_multiball_lock", "EnableMultiballLockListener", 100, Null

    ' For some reason, this is getting called when multiball starts... but no ball_ended event is getting fired??? super weird
    ' TODO: is there a different event we can use to determine when to clear the multiball locks without firing them out of the scoop?
    ' AddPinEventListener "ball_ended", "clear_multiball_locks", "ClearMultiballLocksListener", 100, Null

    AddPinEventListener "ball_ended", "enable_subway_return", "EnableSubwayReturn", 100, Null

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

    With CreateMachineVar("num_balls_locked")         'number of balls locked
        .InitialValue = 0                               'used to maintain state of locks across players
        .ValueType = "int"
        .Persist = False
    End With

    '*********** PLAYER VARIABLES ***********

    Glf_SetInitialPlayerVar "ball_just_started", 1
    Glf_SetInitialPlayerVar "ss_running", 0             '0 when skillshots are not active, 1 when active
    Glf_SetInitialPlayerVar "target_hit_count", 0       'used in targetbank mode
    Glf_SetInitialPlayerVar "scoring_multiplier", 1
    Glf_SetInitialPlayerVar "bonus_multiplier", 1
    Glf_SetInitialPlayerVar "locks_qualfiied", 0        'flag keeps track of when a player has qualified the locks
    Glf_SetInitialPlayerVar "bonus_total", 0            'total bonus score, calculated in bonus mode
    Glf_SetInitialPlayerVar "bonus_count", 0            'number of bonus lights achieved, calculated in bonus mode
    Glf_SetInitialPlayerVar "bonus_skip", 0             'flag to capture if player wants to skip the bonus tally shows in bonus mode
    Glf_SetInitialPlayerVar "hs_input_ready", 1         'flag to capture when high score mode is ready for player input


    '*********** MODES ***********
    ' Order here does not matter - each mode registers its own start/stop
    ' events and GLF sorts them by priority at dispatch time.
    CreateAttractMode()      ' priority 100
    CreateBaseMode()         ' priority 110
    CreateTiltMode()         ' priority 10000
    CreateScoreMode()        ' priority 2000
    CreateSkillshotsMode()   ' priority 400
    CreateExtraBallMode()    ' priority 510
    CreateRampshotsMode()    ' priority 660
    CreateMultiballMode()    ' priority 1000

    ' Your nine feature modes go here later, at priority 700+.


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

    With CreateGlfAutoFireDevice("bumper3")
        .Switch = "s_Bumper3"
        .ActionCallback = "Bumper3Action"
        .DisabledCallback = "Bumper3Disabled"
        .EnabledCallback = "Bumper3Enabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

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
    With CreateGlfBallDevice("vuk1")
        .BallSwitches = Array("s_VUK1")
        .Debug = True
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_VUK1_active") ' TODO: Change this to the event that means we're done with mystery or whatever...
        .EjectCallback = "Vuk1EjectCallback"
    End With

    With CreateGlfBallDevice("drop_target_kicker")
        .BallSwitches = Array("s_DropTargetKicker")
        .Debug = True
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_DropTargetKicker_active")
        .EjectCallback = "DropTargetKickerEjectCallback"
    End With

    With CreateGlfBallDevice("hidden_upper_right_kicker")
        .BallSwitches = Array("s_HiddenUpperRightKicker")
        .Debug = True
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_HiddenUpperRightKicker_active")
        .EjectCallback = "HiddenUpperRightKickerEjectCallback"
    End With

    With CreateGlfBallDevice("lock1")
        .BallSwitches = Array("s_Lock1")
        .EjectTargets = Array("s_VUK1")
        .EjectCallback = "Lock1EjectCallback"
    End With

    With CreateGlfBallDevice("lock2")
        .BallSwitches = Array("s_Lock2")
        .EjectTargets = Array("s_Lock1")
        .EjectCallback = "Lock2EjectCallback"
    End With

    With CreateGlfBallDevice("lock3")
        .BallSwitches = Array("s_Lock3")
        .EjectTargets = Array("s_Lock2")
        .EjectCallback = "Lock3EjectCallback"
    End With

    With CreateGlfBallDevice("subway_trough")
        .BallSwitches = Array("s_subway_trough_kicker")
        .EjectCallback = "SubwayTroughEjectCallback"
        .AutoFireOnUnexpectedBall = False
        .EjectAllEvents = Array("s_subway_trough_kicker_active")
    End With

    ' --- Diverter ---
    ' Was Diverter.RotateToEnd inline in Table1_KeyDown. GLF owns the
    ' flipper keys now, so bind to the virtual flipper switch events.
    With CreateGlfDiverter("ramp_diverter")
        .EnableEvents = Array("ball_started", "reset_complete")
        .ActivateEvents = Array("lock_lit")
        .DeactivateEvents = Array("lock_unlit", "ball_ended")
        .ActionCallback = "RampDiverterAction"
    End With

    With CreateGlfDiverter("subway_diverter")
        .EnableEvents = Array("ball_started")
        .ActivateEvents = Array("ball_ended")
        .DeactivateEvents = Array("ball_started", "reset_complete")
        .ActionCallback = "SubwayDiverterAction"
    End With

    ' --- Standup targets s_ST11..s_ST18 ---
    ' MUST NOT be in any collection. RothSTSwitchID must match the 3rd
    ' argument of the Set STnn = (new StandupTarget)(...) lines in ZRST.
    For x = 11 To 19
        With CreateGlfStanduptarget("target" & x)
            .Switch = "s_ST" & x
            .UseRothStanduptarget = True
            .RothSTSwitchID = x
        End With
    Next

    'Drop Targets
    'NOTE: Drop targets SHOULD NOT be added to the glf_switches collection nor any other collection. 
    With CreateGlfDroptarget("drop1")
        .Switch = "s_DT1"
        .KnockdownEvents = Array("DT1_knockdown")
        .ResetEvents = Array("ball_started","reset_complete")
        .ActionCallback = "DT1Callback"
        .UseRothDroptarget = True
        .RothDTSwitchID = 1
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

' Function Vuk1Hold(args)
'     Debug.Print "GLFDIAG: Vuk1Hold fired - scheduling eject in 1500ms"
'     SetDelay "vuk1_eject_delay", "Vuk1DoEject", Null, 1500
' End Function

' Function Vuk1DoEject(args)
'     Debug.Print "GLFDIAG: Vuk1DoEject - dispatching eject_vuk1"
'     DispatchPinEvent "eject_vuk1", Null
' End Function

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
    End If
End Function

Function EnableSubwayReturn(args)
    glf_subwayBallsReturning = GetPlayerState("multiball_lock_locked_balls")
    If glf_subwayBallsReturning > 0 Then
        AddPinEventListener GLF_BALL_DRAIN, "subway_return_claim", "SubwayReturnHandler", 500, Null
    End If
End Function

'======================================================
'  Sounds - empty until you have real assets.
'  The three helper subs are generic; keep them.
'======================================================

Sub CreateSounds()
    ' AddMusic       "mus_name", <seconds>, -1
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


End Sub