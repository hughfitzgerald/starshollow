
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

Dim ScoreArray : ScoreArray = Array(10, 250, 1000, 5000, 10000)

' Set by the plunger-lane listeners below; read by ZKEY for the plunger
' release sound. s_PlungerLane is a Trigger, so it has no BallCntOver.
Dim PlungerHasBall : PlungerHasBall = False

' GI lights, driven by a show instead of the old For-Each loop in ZINI.
' Every name here must be a member of glf_lights.
Dim GILightNames : GILightNames = Array( _
    "gi006","gi007","gi008","gi009","gi010","gi011","gi012","gi013","gi014", _
    "gi015","gi016","gi017","gi018","gi019","gi020","gi021","gi022","gi023", _
    "gi024","gi050")

Const GIColor2700k = "ffA957"


Sub ConfigureGlfDevices()

    Dim x

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
    AddPinEventListener "s_PlungerLane_active",   "plunger_ball_in",  "PlungerBallIn",  100, Null
    AddPinEventListener "s_PlungerLane_inactive", "plunger_ball_out", "PlungerBallOut", 100, Null


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


    '*********** PLAYER VARIABLES ***********

    Glf_SetInitialPlayerVar "ball_just_started", 1
    Glf_SetInitialPlayerVar "scoring_multiplier", 1
    Glf_SetInitialPlayerVar "bonus_multiplier", 1


    '*********** MODES ***********
    ' None yet. Your nine modes go here as CreateXxxMode() calls once
    ' written. Start with attract + base + score.


    '*********** DEVICES ***********

    ' --- Plunger lane (s_PlungerLane -> s_PlungerLane) ---
    ' MUST be a member of glf_switches.
    With CreateGlfBallDevice("plunger")
        .BallSwitches = Array("s_PlungerLane")
        .EjectTimeout = 2000
        .MechanicalEject = True
        .DefaultDevice = True
        .EjectCallback = "PlungerEjectCallback"
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
        .Switch = "s_LeftSlingshot"
        .ActionCallback = "LeftSlingshotAction"
        .DisabledCallback = "LeftSlingshotDisabled"
        .EnabledCallback = "LeftSlingshotEnabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents = Array("ball_started", "enable_flippers")
    End With

    With CreateGlfAutoFireDevice("right_sling")
        .Switch = "s_RightSlingshot"
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
        .EjectTimeout = 2000
        .MechanicalEject = False
        .EjectAllEvents = Array("eject_vuk1")
        .EjectCallback = "Vuk1EjectCallback"
    End With

    ' --- Diverter ---
    ' Was Diverter.RotateToEnd inline in Table1_KeyDown. GLF owns the
    ' flipper keys now, so bind to the virtual flipper switch events.
    With CreateGlfDiverter("diverter1")
        .EnableEvents = Array("ball_started", "reset_complete")
        .ActivateEvents = Array("s_left_flipper_active")
        .DeactivateEvents = Array("s_left_flipper_inactive", "ball_ended")
        .ActionCallback = "DiverterAction"
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
