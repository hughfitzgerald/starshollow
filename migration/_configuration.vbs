'******************************************************
'   ZGCF: GLF Configurations - Stars Hollow Showdown
'******************************************************
'
' Devices only. No modes yet — get to the "milestone" state first:
' ball serves, flippers work, slings/bumpers/targets fire with sound + DOF.
'
' NOTE: switch and light names are CASE SENSITIVE and must match the
' VPX object names exactly.


'------------------------------------------------------
'  Colors
'------------------------------------------------------
Const GIColorWhite  = "ffffff"
Const GIColor2700k  = "ffA957"
Const StandupColor  = "0023cc"
Const BonusLaneColor= "fc7703"


'------------------------------------------------------
'  Light groups
'------------------------------------------------------
' GI: replaces the "For Each xx In GI : xx.state = 1" loop in Table1_Init.
' These must all be members of the glf_lights collection.
Dim GILightNames : GILightNames = Array( _
    "gi006","gi007","gi008","gi009","gi010","gi011","gi012","gi013","gi014", _
    "gi015","gi016","gi017","gi018","gi019","gi020","gi021","gi022","gi023", _
    "gi024","gi050")

' Standup target inserts, in switch order sw11..sw18
Dim StandupLightNames : StandupLightNames = Array("l11","l12","l13","l14","l15","l16","l17","l18")
Dim StandupSwitches   : StandupSwitches   = Array("s_ST11","s_ST12","s_ST13","s_ST14","s_ST15","s_ST16","s_ST17","s_ST18")

' Bonus lanes (sw8 / sw9 today). BonusX(0) and BonusX(1) have no switch
' in the current table — resolve that before wiring the other two.
Dim BonusLaneLightNames : BonusLaneLightNames = Array("l8","l9")

' Score values available to award
Dim ScoreArray : ScoreArray = Array(1000,3000,5000,10000,20000,50000,100000)


'------------------------------------------------------
'  Main entry point, called from Table1_Init
'------------------------------------------------------
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


    '*********** TROUGH SOUNDS ***********
    ' Replaces the RandomSoundBallRelease / RandomSoundDrain calls that
    ' lived in the old ZDRN section.

    AddPinEventListener "trough_eject", "on_trough_eject", "OnTroughEject", 2000, Null
    AddPinEventListener GLF_BALL_DRAIN, "ball_drain_sound", "BallDrainSound", 100, Null


    '*********** HIGH SCORES ***********

    With EnableGlfHighScores()
        With .Categories()
            .Add "score", Array("GRAND CHAMPION", "HIGH SCORE 1", "HIGH SCORE 2", "HIGH SCORE 3")
        End With
        With .Defaults("score")
            .Add "LOR", 5000000
            .Add "ROR", 2000000
            .Add "LUK", 1000000
            .Add "SUK", 500000
        End With
    End With


    '*********** PLAYER VARIABLES ***********
    ' These replace the global BIP / BIPL / BonusX() / PlayerScore() arrays.

    Glf_SetInitialPlayerVar "ball_just_started", 1
    Glf_SetInitialPlayerVar "bonus_lanes_lit",   0    ' was BonusX()
    Glf_SetInitialPlayerVar "bonus_multiplier",  1
    Glf_SetInitialPlayerVar "scoring_multiplier",1


    '*********** DEVICE CONFIGS ***********

    ' --- Plunger lane -------------------------------------------------
    ' Trigger1, renamed s_PlungerLane. Mechanical only (no autoplunger on
    ' this table), so the eject callback is just sound.
    ' MUST be a member of glf_switches.
    With CreateGlfBallDevice("plunger")
        .BallSwitches = Array("s_PlungerLane")
        .EjectTimeout = 2000
        .MechanicalEject = True
        .DefaultDevice = True
        .EjectCallback = "PlungerEjectCallback"
    End With


    ' --- Flippers -----------------------------------------------------
    ' MUST NOT be in any collection.
    ' Bodies of these callbacks are your existing SolLFlipper / SolRFlipper.
    With CreateGlfFlipper("left")
        .Switch = "s_left_flipper"
        .ActionCallback = "LeftFlipperAction"
        .DisableEvents  = Array("kill_flippers")
        .EnableEvents   = Array("ball_started","enable_flippers")
    End With

    With CreateGlfFlipper("right")
        .Switch = "s_right_flipper"
        .ActionCallback = "RightFlipperAction"
        .DisableEvents  = Array("kill_flippers")
        .EnableEvents   = Array("ball_started","enable_flippers")
    End With


    ' --- Slingshots ---------------------------------------------------
    ' MUST be members of glf_slingshots.
    With CreateGlfAutoFireDevice("left_sling")
        .Switch = "s_LeftSlingshot"
        .ActionCallback   = "LeftSlingshotAction"
        .DisabledCallback = "LeftSlingshotDisabled"
        .EnabledCallback  = "LeftSlingshotEnabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents  = Array("ball_started","enable_flippers")
    End With

    With CreateGlfAutoFireDevice("right_sling")
        .Switch = "s_RightSlingshot"
        .ActionCallback   = "RightSlingshotAction"
        .DisabledCallback = "RightSlingshotDisabled"
        .EnabledCallback  = "RightSlingshotEnabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents  = Array("ball_started","enable_flippers")
    End With


    ' --- Bumpers ------------------------------------------------------
    ' MUST be members of glf_switches.
    ' Note the odd numbering (1,3,5) — Bumper2/Bumper4 no longer exist.
    With CreateGlfAutoFireDevice("bumper1")
        .Switch = "s_Bumper1"
        .ActionCallback   = "Bumper1Action"
        .DisabledCallback = "Bumper1Disabled"
        .EnabledCallback  = "Bumper1Enabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents  = Array("ball_started","enable_flippers")
    End With

    With CreateGlfAutoFireDevice("bumper3")
        .Switch = "s_Bumper3"
        .ActionCallback   = "Bumper3Action"
        .DisabledCallback = "Bumper3Disabled"
        .EnabledCallback  = "Bumper3Enabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents  = Array("ball_started","enable_flippers")
    End With

    With CreateGlfAutoFireDevice("bumper5")
        .Switch = "s_Bumper5"
        .ActionCallback   = "Bumper5Action"
        .DisabledCallback = "Bumper5Disabled"
        .EnabledCallback  = "Bumper5Enabled"
        .DisableEvents = Array("kill_flippers")
        .EnableEvents  = Array("ball_started","enable_flippers")
    End With


    ' --- VUK ----------------------------------------------------------
    ' Was VUK1_Hit / VUK1_Timer with a 1500ms TimerInterval hold.
    ' MUST be a member of glf_switches.
    With CreateGlfBallDevice("vuk1")
        .BallSwitches = Array("s_VUK1")
        .EjectTimeout = 2000
        .MechanicalEject = False
        .EjectAllEvents = Array("eject_vuk1")
        .EjectCallback  = "Vuk1EjectCallback"
    End With


    ' --- Diverter -----------------------------------------------------
    ' Was: Diverter.RotateToEnd inside Table1_KeyDown on LeftFlipperKey.
    ' GLF owns the flipper keys now, so bind to the virtual switch event.
    With CreateGlfDiverter("diverter1")
        .EnableEvents     = Array("ball_started","reset_complete")
        .ActivateEvents   = Array("s_left_flipper_active")
        .DeactivateEvents = Array("s_left_flipper_inactive","ball_ended")
        .ActionCallback   = "DiverterAction"
    End With


    ' --- Standup targets ----------------------------------------------
    ' MUST NOT be in any collection.
    ' RothSTSwitchID must match the 3rd arg of your existing
    '   Set STnn = (new StandupTarget)(s_STnn, pswnn, nn, 0)
    For x = 11 To 18
        With CreateGlfStanduptarget("target" & x)
            .Switch = "s_ST" & x
            .UseRothStanduptarget = True
            .RothSTSwitchID = x
        End With
    Next


    ' --- Drop targets -------------------------------------------------
    ' None currently. If the bank comes back, add CreateGlfDroptarget
    ' entries here with .UseRothDroptarget = True and restore the ZRDT
    ' section plus DoDTAnim in FrameTimer_Timer.


    '*********** MODES ***********
    ' Add as you build them. Sounds and shows must be created first.
    '
    ' CreateAttractMode()
    ' CreateBaseMode()
    ' CreateScoreMode()

End Sub



'======================================================
'  Device callbacks
'======================================================

' --- Trough -------------------------------------------------------
Function OnTroughEject(args)
    RandomSoundBallRelease swTrough1
    ' DOF 110, DOFPulse
End Function

Function BallDrainSound(args)
    RandomSoundDrain Drain
    BallDrainSound = args(1)     ' relay event: must return the value
End Function


' --- Plunger ------------------------------------------------------
Sub PlungerEjectCallback(ball)
    ' Mechanical only — the physical plunger does the work.
    ' Add a sound here if you want one on successful eject.
End Sub


' --- VUK ----------------------------------------------------------
Sub Vuk1EjectCallback(ball)
    SoundSaucerKick 1, s_VUK1
    KickBall ball, -19, 50, 0, 0
End Sub


' --- Diverter -----------------------------------------------------
Sub DiverterAction(Enabled)
    If Enabled Then
        Diverter.RotateToEnd
    Else
        Diverter.RotateToStart
    End If
End Sub


' --- Kicker helper (from the GLF example's ZSOL) -------------------
Sub KickBall(kball, kangle, kvel, kvelz, kzlift)
    Dim rangle
    rangle = PI * (kangle - 90) / 180
    kball.z    = kball.z + kzlift
    kball.velz = kvelz
    kball.velx = Cos(rangle) * kvel
    kball.vely = Sin(rangle) * kvel
End Sub
