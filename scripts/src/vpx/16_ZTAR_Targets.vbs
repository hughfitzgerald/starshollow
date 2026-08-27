
'********************************************
'   ZTAR: Targets
'********************************************
' The s_ST11_Hit .. s_ST18_Hit subs are GONE - GLF generates them from the
' CreateGlfStanduptarget config (UseRothStanduptarget + RothSTSwitchID).
' Only the TargetBouncer subs for the bounce-detection walls remain.
' Those objects keep their original names (sw11o..sw18o) - they are not
' switches and must NOT go in any collection.

Sub sw11o_Hit
	TargetBouncer ActiveBall, 1
End Sub

Sub sw12o_Hit
	TargetBouncer ActiveBall, 1
End Sub

Sub sw13o_Hit
	TargetBouncer ActiveBall, 1
End Sub

Sub sw14o_Hit
	TargetBouncer ActiveBall, 1
End Sub

Sub sw15o_Hit
	TargetBouncer ActiveBall, 1
End Sub

Sub sw16o_Hit
	TargetBouncer ActiveBall, 1
End Sub

Sub sw17o_Hit
	TargetBouncer ActiveBall, 1
End Sub

Sub sw18o_Hit
	TargetBouncer ActiveBall, 1
End Sub
