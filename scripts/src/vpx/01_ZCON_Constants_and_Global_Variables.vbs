
'*******************************************
'  ZCON: Constants and Global Variables
'*******************************************
' Deleted vs. the original: PlayerScore(), CurrentPlayer, BIP, BIPL,
' BonusX(), FlexScenes(), and the vpwQueueManager instance. GLF owns
' player state and sequencing now. `Set queue = New vpwQueueManager` ran
' at top level and was a guaranteed load-time crash once ZQUE was removed.

' --- GLF required globals ---
Const cGameName = "StarsHollowShowdown"
Const BallSize  = 50                'Ball diameter in VPX units; must be 50
Const BallMass  = 1                 'Ball mass must be 1
Const tnob      = 5                 'Total playable balls (must equal swTrough count)
Const lob       = 0                 'Locked / captive balls

Dim gBOT                            'GLF fills this; use instead of GetBalls
Dim tablewidth  : tablewidth  = Table1.width
Dim tableheight : tableheight = Table1.height

' --- Table state ---
Dim DesktopMode : DesktopMode = Table1.ShowDT

'Detect if VPX is rendering in VR and make sure the VR Room choice is used
Dim VRRoom
If RenderingMode = 2 Then
	VRRoom = VRRoomChoice
Else
	VRRoom = 0
End If
