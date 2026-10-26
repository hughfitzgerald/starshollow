'*******************************************
'  ZSCR: Score Values
'*******************************************
' Every score in the game is defined here, as a multiple of BaseScore.
' To rebalance the whole game, change BaseScore. To rebalance one feature,
' change its multiplier.
'
' Each value is named for what it scores (BumperScore, UnlitRampScore), not
' for its size (score10x), so that changing one feature's value doesn't touch
' any other feature that happens to share the same number today.
'
' Awarding points
'
' Every change to the player's score goes through the score mode
' (modes/score.vbs). Nothing else adds to the "score" player variable. Every
' award says explicitly whether the playfield multiplier
' (current_player.scoring_multiplier) applies, so turning that multiplier on
' later can't silently change an award that was never meant to be multiplied:
'
'     .Add "s_Bumper1_active", Array(ScoreEvent(BumperScore, WithMultiplier), ...)
'     .Add "dinner_shot_hit",  Array(ScoreEvent(DinnerShotScore, NoMultiplier))
'
' For an amount only known when it is awarded (a hurry-up value, the bonus
' total), pass an expression instead. It is evaluated when the event fires:
'
'     ScoreEventExpr("current_player.bonus_total", NoMultiplier)
'
' The current rule of thumb: playfield switches and shots, skill shots,
' mystery and lock awards use WithMultiplier; mode shots, multiball
' jackpots, hurry-up and the end-of-ball bonus use NoMultiplier.
'
' ScoreX() records every value it returns, and the score mode creates the
' score events for each one, so any value defined here can be used with
' ScoreEvent() without maintaining a separate list.
'
' Scoring tiers (multipliers of BaseScore), following the progression in
' Dark Chaos, Medieval Madness and Attack from Mars:
'   Tier 1   0.02 - 0.65x  switches, rollovers, unlit shots
'   Tier 2   2 - 5x        lit shots, mode shots, power-ups, easy skill shot
'   Tier 3   8 - 80x       hurry-up, mystery, jackpots, mode completion
'   Tier 4   100x and up   multiball wins, wizard mode
' Bumper, spinner, diner and grandparents are balanced on their total per hit:
' live value + item bonus factor + BonusMultiplierFactor (every switch hit
' counts toward the switch total, times bonus X). Totals below are at 1x bonus X.
'
' Values marked "NOT WIRED" don't have a feature on the table to score yet.

Const BaseScore = 50000

Dim ScoreValues : Set ScoreValues = CreateObject("Scripting.Dictionary")

' Returns BaseScore * multiplier, rounded to a whole number of points.
Function ScoreX(multiplier)
    Dim points : points = Round(BaseScore * multiplier)
    If Not ScoreValues.Exists(CStr(points)) Then ScoreValues.Add CStr(points), points
    ScoreX = points
End Function

' Second argument to ScoreEvent / ScoreEventExpr.
Const WithMultiplier = True
Const NoMultiplier = False

' Returns the score mode event that awards the given points.
Function ScoreEvent(points, applyMultiplier)
    If applyMultiplier Then
        ScoreEvent = "score_" & points
    Else
        ScoreEvent = "score_" & points & "_flat"
    End If
End Function

' Returns the score mode event that awards the result of a GLF expression,
' evaluated when the event fires, e.g. "current_player.bonus_total".
Function ScoreEventExpr(expression, applyMultiplier)
    If applyMultiplier Then
        ScoreEventExpr = "score_dynamic:{points:" & expression & "}"
    Else
        ScoreEventExpr = "score_dynamic_flat:{points:" & expression & "}"
    End If
End Function


'*********** PLAYFIELD (base mode) ***********
' Live value per hit. Totals in comments include the item bonus factor and the
' per-switch bonus at 1x bonus X (see END OF BALL BONUS).
Dim InlaneScore         : InlaneScore         = ScoreX(0.02)
Dim TopLaneScore        : TopLaneScore        = ScoreX(0.05)   ' each bonus lane rollover
Dim OutlaneScore        : OutlaneScore        = ScoreX(0.1)
Dim SlingScore          : SlingScore          = ScoreX(0.05)
Dim SpinnerScore        : SpinnerScore        = ScoreX(0.03)   ' total 0.07x: 0.03 live + 0.02 item bonus + 0.02 switch bonus
Dim BumperScore         : BumperScore         = ScoreX(0.1)    ' total 0.16x: 0.1 live + 0.04 item bonus + 0.02 switch bonus
Dim StarTargetScore     : StarTargetScore     = ScoreX(0.1)
Dim UnlitRampScore      : UnlitRampScore      = ScoreX(0.5)
Dim DinerDropTargetScore: DinerDropTargetScore= ScoreX(0.25)   ' drop target guarding Luke's kicker
Dim DinerKickerScore    : DinerKickerScore    = ScoreX(0.4)    ' Luke's kicker; total 0.52x: 0.4 + 0.1 + 0.02
Dim GrandparentsScore   : GrandparentsScore   = ScoreX(0.5)    ' crossfield shot; total 0.67x: 0.5 + 0.15 + 0.02
Dim LoganCaptiveScore   : LoganCaptiveScore   = ScoreX(0.5)    ' captive ball outside multiball

'*********** JESS / DEAN TARGETS ***********
' Separate from the Star targets.
Dim JessDeanTargetScore : JessDeanTargetScore = ScoreX(0.2)    ' each standup
Dim JessDeanBankScore   : JessDeanBankScore   = ScoreX(1)      ' all four of one bank

'*********** RAMP SHOT / EXTRA BALL / LOCK / COMBOS ***********
Dim LitRampScore        : LitRampScore        = ScoreX(3)
Dim ExtraBallScore      : ExtraBallScore      = ScoreX(2)
Dim BallLockScore       : BallLockScore       = ScoreX(5)      ' Jess/Dean ball locked
Dim ComboStepScore      : ComboStepScore      = ScoreX(2)      ' NOT WIRED, times combo length (no combo system yet)

'*********** SKILLSHOTS ***********
Dim Skillshot1Score     : Skillshot1Score     = ScoreX(15)     ' hardest
Dim Skillshot2Score     : Skillshot2Score     = ScoreX(4)      ' easiest
Dim Skillshot3Score     : Skillshot3Score     = ScoreX(8)

'*********** MYSTERY ***********
Dim MysterySmallScore   : MysterySmallScore   = ScoreX(5)
Dim MysteryMediumScore  : MysteryMediumScore  = ScoreX(20)
Dim MysteryBigScore     : MysteryBigScore     = ScoreX(50)

'*********** HURRY-UP ***********
' The hurry-up value counts up from start to end over the hurry-up duration.
Dim HurryUpStartScore   : HurryUpStartScore   = ScoreX(10)
Dim HurryUpEndScore     : HurryUpEndScore     = ScoreX(40)

'*********** MODES ***********
Dim ModeStartScore              : ModeStartScore              = ScoreX(2)    ' each timed mode, when it starts
Dim ModeCompleteScore           : ModeCompleteScore           = ScoreX(30)   ' Kim's Antiques: last the timer without hitting Miss Kim
Dim DinnerShotScore             : DinnerShotScore             = ScoreX(5)
Dim FdPunchShotScore            : FdPunchShotScore            = ScoreX(5)
Dim LbtbShotScore               : LbtbShotScore               = ScoreX(5)
Dim KimsAntiquesShotScore       : KimsAntiquesShotScore       = ScoreX(5)
Dim TownMeetingShotScore        : TownMeetingShotScore        = ScoreX(5)
Dim TownMeetingLukesShotScore   : TownMeetingLukesShotScore   = ScoreX(15)
Dim DanceMarathonFirstShotScore : DanceMarathonFirstShotScore = ScoreX(5)    ' jackpot
Dim DanceMarathonSecondShotScore: DanceMarathonSecondShotScore= ScoreX(25)   ' combo super jackpot

'*********** JESS / DEAN MULTIBALL ***********
Dim JDRampScore         : JDRampScore         = ScoreX(25)     ' jackpot, first hit on each ramp
Dim JDSuperJackpotScore : JDSuperJackpotScore = ScoreX(80)     ' second and later hits on the same ramp
Dim JDWinScore          : JDWinScore          = ScoreX(150)

'*********** LOGAN MULTIBALL ***********
Dim LoganBumperScore        : LoganBumperScore        = ScoreX(1)
Dim LoganTotallyBashedScore : LoganTotallyBashedScore = ScoreX(150)
Dim LoganLockedAwayScore    : LoganLockedAwayScore    = ScoreX(150)
' Mode score needed to totally bash Logan (a target, not an award).
' About 50 Logan bumper hits.
Dim LoganScoreToWin         : LoganScoreToWin         = ScoreX(50)

'*********** WIZARD MODE (not designed yet) ***********
Dim WizardShotScore     : WizardShotScore     = ScoreX(100)    ' NOT WIRED
Dim WizardCompleteScore : WizardCompleteScore = ScoreX(2000)   ' NOT WIRED

'*********** END OF BALL BONUS ***********
' Points per item counted during the ball.
Dim BonusMultiplierFactor   : BonusMultiplierFactor   = ScoreX(0.02)  ' times total switch count (incl. bumper, spinner, diner,
                                                                  ' grandparents), times bonus multiplier
Dim BonusSpinnerFactor      : BonusSpinnerFactor      = ScoreX(0.02)
Dim BonusBumperFactor       : BonusBumperFactor       = ScoreX(0.04)
Dim BonusDinerFactor        : BonusDinerFactor        = ScoreX(0.1)
Dim BonusGrandparentsFactor : BonusGrandparentsFactor = ScoreX(0.15)
Dim BonusModePlayedFactor   : BonusModePlayedFactor   = ScoreX(20)    ' per mode played this ball
Dim BonusMultiballWonFactor : BonusMultiballWonFactor = ScoreX(20)    ' per Jess/Dean or Logan win this ball
