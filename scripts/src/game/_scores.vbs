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

' A tier-1 switch value: ScoreX plus 10, so the tens digit of the final score
' varies from game to game (for match).
Function SwitchScore(multiplier)
    Dim points : points = Round(BaseScore * multiplier) + 10
    If Not ScoreValues.Exists(CStr(points)) Then ScoreValues.Add CStr(points), points
    SwitchScore = points
End Function


'*********** PLAYFIELD (base mode) ***********
' Live value per hit. Totals in comments include the item bonus factor and the
' per-switch bonus at 1x bonus X (see END OF BALL BONUS).
Dim InlaneScore         : InlaneScore         = SwitchScore(0.02)
Dim TopLaneScore        : TopLaneScore        = SwitchScore(0.05)   ' each bonus lane rollover
Dim OutlaneScore        : OutlaneScore        = SwitchScore(0.1)
Dim SlingScore          : SlingScore          = SwitchScore(0.05)
Dim SpinnerScore        : SpinnerScore        = SwitchScore(0.03)
Dim BumperScore         : BumperScore         = SwitchScore(0.1)
Dim StarTargetScore     : StarTargetScore     = SwitchScore(0.1)
Dim UnlitRampScore      : UnlitRampScore      = ScoreX(0.5)
Dim DinerDropTargetScore: DinerDropTargetScore= ScoreX(0.25)   ' drop target guarding Luke's kicker
Dim DinerKickerScore    : DinerKickerScore    = ScoreX(0.4)    ' Luke's kicker; total 0.52x: 0.4 + 0.1 + 0.02
Dim GrandparentsScore   : GrandparentsScore   = ScoreX(0.5)    ' crossfield shot; total 0.67x: 0.5 + 0.15 + 0.02
Dim LoganCaptiveScore   : LoganCaptiveScore   = ScoreX(0.5)    ' captive ball outside multiball

'*********** JESS / DEAN TARGETS ***********
' Separate from the Star targets.
Dim JessDeanTargetScore : JessDeanTargetScore = SwitchScore(0.2)    ' each standup
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
Dim ModeCompleteScore           : ModeCompleteScore           = ScoreX(10)   ' last a timed mode's full timer without draining
Dim KimsAntiquesCompleteScore   : KimsAntiquesCompleteScore   = ScoreX(20)   ' same, and without hitting Miss Kim (a second way to lose)
Dim DinnerShotScore             : DinnerShotScore             = ScoreX(5)
Dim DinnerJackpotScore          : DinnerJackpotScore          = ScoreX(20)
Dim FdPunchShotScore            : FdPunchShotScore            = ScoreX(5)
Dim LbtbShotScore               : LbtbShotScore               = ScoreX(5)
Dim KimsAntiquesShotScore       : KimsAntiquesShotScore       = ScoreX(2)    ' any shot but the right ramp; relights the jackpot
Dim KimsAntiquesJackpotScore    : KimsAntiquesJackpotScore    = ScoreX(10)   ' right ramp, when lit
Const KimsAntiquesPlayfieldX = 3   ' playfield multiplier for the whole mode (a multiplier, not a score)
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

'*********** REPLAY ***********
' Score that earns a replay (a threshold, not an award). Checked by
' ReplayCheck in _configuration.vbs; one replay per player per game.
Dim ReplayScore             : ReplayScore             = ScoreX(300)


Class MysteryAward
    Public Short
    Public Text
    Public EventName
    Public Condition
    Public Probability
End Class

' condition: a GLF condition ("" for none) that must pass for the award to be
' picked. It goes on the random pick, not on eventName: GLF does not evaluate
' {conditions} on posted events, so "start_jd_multiball{...}" would be posted
' as that literal event name and nothing would listen for it.
Function NewMysteryAward(short, text, eventName, condition, probability)
    Dim m : Set m = New MysteryAward
    m.Short = short
    m.Text = text
    m.EventName = eventName
    m.Condition = condition
    m.Probability = probability
    Set NewMysteryAward = m
End Function

Dim mysteryAwards
mysteryAwards = Array( _
    NewMysteryAward("eb", "Lite Extra Ball", "eb_now_lit", "current_player.shot_eb_ready < 1", 1), _
    NewMysteryAward("ab", "Add-a-Ball", "add_a_ball", "modes.jd_multiball.active==False and modes.ll_multiball.active==False", .6), _
    NewMysteryAward("bs", "Big Score", ScoreEvent(MysteryBigScore, WithMultiplier), "", .1), _
    NewMysteryAward("ib", "Increase Bonus", "qualify_multiplier_group_on_complete", "current_player.bonus_x < 8", 1), _
    NewMysteryAward("jd", "Jess/Dean MB", "start_jd_multiball", "modes.jd_multiball.active==False and modes.ll_multiball.active==False and modes.dance_marathon.active==False and modes.town_meeting.active==False and modes.dinner.active==False and modes.kims_antiques.active==False and modes.lbtb.active==False and modes.fd_punch.active==False", .1), _
    NewMysteryAward("ss", "Small Score", ScoreEvent(MysterySmallScore, WithMultiplier), "", 1), _
    NewMysteryAward("al", "Advance Logan", "advance_logan", "current_player.shot_logan_qualify <= 1", 1), _
    NewMysteryAward("ms", "Medium Score", ScoreEvent(MysteryMediumScore, WithMultiplier), "", .5) _
)