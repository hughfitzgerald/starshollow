
'*******************************************
'  ZTIM: Timers
'*******************************************
' queue.Tick removed (ZQUE deleted - use GLF SetDelay / GlfTimer).
' DMDTimer is gone with ZDMD.
'
' Glf_GameTimer is NOT declared here - it is a VPX Timer object you add in
' the editor (Enabled, Interval -1). GLF drives it itself.

Dim FrameTime, InitFrameTime
InitFrameTime = 0

' --- GLF event-pump fallback -----------------------------------------
' Glf_GameTimer_Timer is GLF's entire event loop. DispatchPinEvent only
' QUEUES and SetDelay only schedules - nothing executes until it ticks.
' It normally runs off a VPX Timer object named Glf_GameTimer.
'
' If that timer is missing, or VPX will not bind its _Timer sub (the sub
' lives inside the ExecuteGlobal'd script, not the table script), the
' whole framework goes silently dead: no attract mode, no start button,
' no ball release, and no error.
'
' This takes over automatically if the real pump has not run within 2
' seconds of load. FrameTimer is also Interval -1, so it ticks at exactly
' the same rate. Harmless if Glf_GameTimer works - the check disables it.
Dim glf_pump_checked  : glf_pump_checked = False
Dim glf_pump_fallback : glf_pump_fallback = False

FrameTimer.Interval = -1
Sub FrameTimer_Timer()
	FrameTime = GameTime - InitFrameTime
	InitFrameTime = GameTime
	RollingUpdate
	DoSTAnim
	DoDTAnim
	BSUpdate
	Cor.Update         ' rubber dampener incoming-velocity tracking (was CorTimer)
	UpdateGlfInserts   ' insert primitives follow GLF light colour
	PscBackglassMirror ' backglass bulbs follow their PSC proxy lights

	If Not glf_pump_checked And GameTime > 2000 Then
		glf_pump_checked = True
		If glf_lastEventExecutionTime = 0 Then
			glf_pump_fallback = True
			Debug.Print "GLF: Glf_GameTimer never fired - FrameTimer is now driving the event pump."
		End If
	End If
	If glf_pump_fallback Then Glf_GameTimer_Timer
End Sub

' Cor.Update used to run in a dedicated 10ms CorTimer (VPW default). A timer
' faster than the frame rate breaks VPX frame pacing (table audit warning),
' so it now runs once per frame in FrameTimer above. The CorTimer object is
' kept in the editor but disabled.
