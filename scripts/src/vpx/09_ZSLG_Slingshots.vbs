
'****************************************************************
'   ZSLG: Slingshots
'****************************************************************
' Slingshot bodies migrated to GLF autofire callbacks.
' ActiveBall is NOT reliable inside GLF dispatch - use args(1).
' The _Timer animation subs stay as normal VPX timers.

' RStep and LStep are the variables that increment the animation
Dim RStep, LStep, TStep

Sub RightSlingshotAction(args)
	Dim enabled : enabled = args(0)
	If enabled Then
		If Not IsNull(args(1)) Then RS.VelocityCorrect(args(1))
		RSling1.Visible = 1
		Sling1.TransY = -20   'Sling Metal Bracket
		RStep = 0
		s_RightSlingshot.TimerEnabled = 1
		s_RightSlingshot.TimerInterval = 10
		RandomSoundSlingshotRight Sling1
		DOF 104, DOFPulse
	End If
End Sub

Sub RightSlingshotDisabled(args) : End Sub
Sub RightSlingshotEnabled(args)  : End Sub

Sub s_RightSlingshot_Timer
	Select Case RStep
		Case 3
			RSLing1.Visible = 0
			RSLing2.Visible = 1
			Sling1.TransY = -10
		Case 4
			RSLing2.Visible = 0
			Sling1.TransY = 0
			s_RightSlingshot.TimerEnabled = 0
	End Select
	RStep = RStep + 1
End Sub

Sub LeftSlingshotAction(args)
	Dim enabled : enabled = args(0)
	If enabled Then
		If Not IsNull(args(1)) Then LS.VelocityCorrect(args(1))
		LSling1.Visible = 1
		Sling2.TransY = -20   'Sling Metal Bracket
		LStep = 0
		s_LeftSlingshot.TimerEnabled = 1
		s_LeftSlingshot.TimerInterval = 10
		RandomSoundSlingshotLeft Sling2
		DOF 103, DOFPulse
	End If
End Sub

Sub LeftSlingshotDisabled(args) : End Sub
Sub LeftSlingshotEnabled(args)  : End Sub

Sub s_LeftSlingshot_Timer
	Select Case LStep
		Case 3
			LSLing1.Visible = 0
			LSLing2.Visible = 1
			Sling2.TransY = -10
		Case 4
			LSLing2.Visible = 0
			Sling2.TransY = 0
			s_LeftSlingshot.TimerEnabled = 0
	End Select
	LStep = LStep + 1
End Sub

Sub TopSlingshotAction(args)
	Dim enabled : enabled = args(0)
	If enabled Then
		If Not IsNull(args(1)) Then TS.VelocityCorrect(args(1))
		TSling1.Visible = 1
		Sling3.TransY = -20   'Sling Metal Bracket
		TStep = 0
		s_TopSlingshot.TimerEnabled = 1
		s_TopSlingshot.TimerInterval = 10
		RandomSoundSlingshotLeft Sling3
		DOF 103, DOFPulse
	End If
End Sub

Sub TopSlingshotDisabled(args) : End Sub
Sub TopSlingshotEnabled(args)  : End Sub

Sub s_TopSlingshot_Timer
	Select Case TStep
		Case 3
			TSling1.Visible = 0
			TSling2.Visible = 1
			Sling3.TransY = -10
		Case 4
			TSling2.Visible = 0
			Sling3.TransY = 0
			s_TopSlingshot.TimerEnabled = 0
	End Select
	TStep = TStep + 1
End Sub


'******************************************************
'	ZSSC: SLINGSHOT CORRECTION FUNCTIONS by apophis
'******************************************************
' To add these slingshot corrections:
'	 - On the table, add the endpoint primitives that define the two ends of the Slingshot
'	 - Initialize the SlingshotCorrection objects in InitSlingCorrection
'	 - Call the .VelocityCorrect methods from the respective _Slingshot event sub

Dim LS
Set LS = New SlingshotCorrection
Dim RS
Set RS = New SlingshotCorrection
Dim TS
Set TS = New SlingshotCorrection

InitSlingCorrection

Sub InitSlingCorrection
	LS.Object = s_LeftSlingshot
	LS.EndPoint1 = EndPoint1LS
	LS.EndPoint2 = EndPoint2LS
	
	RS.Object = s_RightSlingshot
	RS.EndPoint1 = EndPoint1RS
	RS.EndPoint2 = EndPoint2RS

	TS.Object = s_TopSlingshot
	TS.EndPoint1 = EndPoint1TS
	TS.EndPoint2 = EndPoint2TS
	
	'Slingshot angle corrections (pt, BallPos in %, Angle in deg)
	' These values are best guesses. Retune them if needed based on specific table research.
	AddSlingsPt 0, 0.00, - 3
	AddSlingsPt 1, 0.30, - 5
	AddSlingsPt 2, 0.40,	-30
	AddSlingsPt 3, 0.60,	30
	AddSlingsPt 4, 0.70,	5
	AddSlingsPt 5, 1.00,	3
End Sub

Sub AddSlingsPt(idx, aX, aY)		'debugger wrapper for adjusting flipper script In-game
	Dim a
	a = Array(LS, RS, TS)
	Dim x
	For Each x In a
		x.addpoint idx, aX, aY
	Next
End Sub

'' The following sub are needed, however they may exist somewhere else in the script. Uncomment below if needed
'Dim PI: PI = 4*Atn(1)
'Function dSin(degrees)
'	dsin = sin(degrees * Pi/180)
'End Function
'Function dCos(degrees)
'	dcos = cos(degrees * Pi/180)
'End Function
'
'Function RotPoint(x,y,angle)
'	dim rx, ry
'	rx = x*dCos(angle) - y*dSin(angle)
'	ry = x*dSin(angle) + y*dCos(angle)
'	RotPoint = Array(rx,ry)
'End Function

Class SlingshotCorrection
	Public DebugOn, Enabled
	Private Slingshot, SlingX1, SlingX2, SlingY1, SlingY2
	
	Public ModIn, ModOut
	
	Private Sub Class_Initialize
		ReDim ModIn(0)
		ReDim Modout(0)
		Enabled = True
	End Sub
	
	Public Property Let Object(aInput)
		Set Slingshot = aInput
	End Property
	
	Public Property Let EndPoint1(aInput)
		SlingX1 = aInput.x
		SlingY1 = aInput.y
	End Property
	
	Public Property Let EndPoint2(aInput)
		SlingX2 = aInput.x
		SlingY2 = aInput.y
	End Property
	
	Public Sub AddPoint(aIdx, aX, aY)
		ShuffleArrays ModIn, ModOut, 1
		ModIn(aIDX) = aX
		ModOut(aIDX) = aY
		ShuffleArrays ModIn, ModOut, 0
		If GameTime > 100 Then Report
	End Sub
	
	Public Sub Report() 'debug, reports all coords in tbPL.text
		If Not debugOn Then Exit Sub
		Dim a1, a2
		a1 = ModIn
		a2 = ModOut
		Dim str, x
		For x = 0 To UBound(a1)
			str = str & x & ": " & Round(a1(x),4) & ", " & Round(a2(x),4) & vbNewLine
		Next
		TBPout.text = str
	End Sub
	
	
	Public Sub VelocityCorrect(aBall)
		Dim BallPos, XL, XR, YL, YR
		
		'Assign right and left end points
		If SlingX1 < SlingX2 Then
			XL = SlingX1
			YL = SlingY1
			XR = SlingX2
			YR = SlingY2
		Else
			XL = SlingX2
			YL = SlingY2
			XR = SlingX1
			YR = SlingY1
		End If
		
		'Find BallPos = % on Slingshot
		If Not IsEmpty(aBall.id) Then
			If Abs(XR - XL) > Abs(YR - YL) Then
				BallPos = PSlope(aBall.x, XL, 0, XR, 1)
			Else
				BallPos = PSlope(aBall.y, YL, 0, YR, 1)
			End If
			If BallPos < 0 Then BallPos = 0
			If BallPos > 1 Then BallPos = 1
		End If
		
		'Velocity angle correction
		If Not IsEmpty(ModIn(0) ) Then
			Dim Angle, RotVxVy
			Angle = LinearEnvelope(BallPos, ModIn, ModOut)
			'   debug.print " BallPos=" & BallPos &" Angle=" & Angle
			'   debug.print " BEFORE: aBall.Velx=" & aBall.Velx &" aBall.Vely" & aBall.Vely
			RotVxVy = RotPoint(aBall.Velx,aBall.Vely,Angle)
			If Enabled Then aBall.Velx = RotVxVy(0)
			If Enabled Then aBall.Vely = RotVxVy(1)
			'   debug.print " AFTER: aBall.Velx=" & aBall.Velx &" aBall.Vely" & aBall.Vely
			'   debug.print " "
		End If
	End Sub
End Class






