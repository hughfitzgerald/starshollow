
'*******************************************
'  ZTIM: Timers
'*******************************************
' queue.Tick removed (ZQUE deleted - use GLF SetDelay / GlfTimer).
' DoDTAnim stays out: this table has no drop targets.
' DMDTimer is gone with ZDMD.
'
' Glf_GameTimer is NOT declared here - it is a VPX Timer object you add in
' the editor (Enabled, Interval -1). GLF drives it itself.

Dim FrameTime, InitFrameTime
InitFrameTime = 0

FrameTimer.Interval = -1
Sub FrameTimer_Timer()
	FrameTime = GameTime - InitFrameTime
	InitFrameTime = GameTime
	RollingUpdate
	DoSTAnim
	BSUpdate
End Sub

'The CorTimer interval should be 10. Its sole purpose is Cor calculations.
CorTimer.Interval = 10
Sub CorTimer_Timer(): Cor.Update: End Sub
