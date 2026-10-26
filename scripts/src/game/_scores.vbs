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
' Using a value in a mode:
'   - Through the score mode (applies current_player.scoring_multiplier):
'         .Add "s_Bumper1_active", Array(ScoreEvent(BumperScore), ...)
'   - Directly in a variable player (no playfield multiplier):
'         .Int = DinnerShotScore
'
' ScoreX() records every value it returns, and the score mode creates a
' score_<value> event for each one, so any value defined here can be used
' with ScoreEvent() without maintaining a separate list.

Const BaseScore = 10000

Dim ScoreValues : Set ScoreValues = CreateObject("Scripting.Dictionary")

' Returns BaseScore * multiplier, rounded to a whole number of points.
Function ScoreX(multiplier)
    Dim points : points = Round(BaseScore * multiplier)
    If Not ScoreValues.Exists(CStr(points)) Then ScoreValues.Add CStr(points), points
    ScoreX = points
End Function

' Returns the score mode event that awards the given points.
Function ScoreEvent(points)
    ScoreEvent = "score_" & points
End Function


'*********** PLAYFIELD (base mode) ***********
Dim BumperScore         : BumperScore         = ScoreX(0.5)
Dim SlingScore          : SlingScore          = ScoreX(0.5)
Dim SpinnerScore        : SpinnerScore        = ScoreX(0.3)
Dim UnlitRampScore      : UnlitRampScore      = ScoreX(1)
Dim StarTargetScore     : StarTargetScore     = ScoreX(0.1)
Dim DinerKickerScore    : DinerKickerScore    = ScoreX(1)
Dim GrandparentsScore   : GrandparentsScore   = ScoreX(1)

'*********** RAMP SHOT / EXTRA BALL ***********
Dim LitRampScore        : LitRampScore        = ScoreX(20)
Dim ExtraBallScore      : ExtraBallScore      = ScoreX(10)

'*********** SKILLSHOTS ***********
Dim Skillshot1Score     : Skillshot1Score     = ScoreX(50)
Dim Skillshot2Score     : Skillshot2Score     = ScoreX(20)
Dim Skillshot3Score     : Skillshot3Score     = ScoreX(30)

'*********** MYSTERY ***********
Dim MysteryBigScore     : MysteryBigScore     = ScoreX(1000)

'*********** HURRY-UP ***********
' The hurry-up value counts up from start to end over the hurry-up duration.
Dim HurryUpStartScore   : HurryUpStartScore   = ScoreX(50)
Dim HurryUpEndScore     : HurryUpEndScore     = ScoreX(200)

'*********** MODES ***********
Dim DinnerShotScore             : DinnerShotScore             = ScoreX(2)
Dim FdPunchShotScore            : FdPunchShotScore            = ScoreX(2)
Dim LbtbShotScore               : LbtbShotScore               = ScoreX(2)
Dim KimsAntiquesShotScore       : KimsAntiquesShotScore       = ScoreX(2)
Dim TownMeetingShotScore        : TownMeetingShotScore        = ScoreX(2)
Dim TownMeetingLukesShotScore   : TownMeetingLukesShotScore   = ScoreX(10)
Dim DanceMarathonFirstShotScore : DanceMarathonFirstShotScore = ScoreX(2)
Dim DanceMarathonSecondShotScore: DanceMarathonSecondShotScore= ScoreX(4)

'*********** JESS / DEAN MULTIBALL ***********
Dim JDRampScore         : JDRampScore         = ScoreX(1)
Dim JDWinScore          : JDWinScore          = ScoreX(100)

'*********** LOGAN MULTIBALL ***********
Dim LoganBumperScore        : LoganBumperScore        = ScoreX(1)
Dim LoganTotallyBashedScore : LoganTotallyBashedScore = ScoreX(1000)
Dim LoganLockedAwayScore    : LoganLockedAwayScore    = ScoreX(1000)
' Mode score needed to totally bash Logan (a target, not an award).
Dim LoganScoreToWin         : LoganScoreToWin         = ScoreX(15)

'*********** END OF BALL BONUS ***********
' Points per item counted during the ball.
Dim BonusMultiplierFactor   : BonusMultiplierFactor   = ScoreX(0.1)   ' per switch hit, times bonus multiplier
Dim BonusSpinnerFactor      : BonusSpinnerFactor      = ScoreX(0.1)
Dim BonusBumperFactor       : BonusBumperFactor       = ScoreX(0.2)
Dim BonusDinerFactor        : BonusDinerFactor        = ScoreX(0.3)
Dim BonusGrandparentsFactor : BonusGrandparentsFactor = ScoreX(0.4)
