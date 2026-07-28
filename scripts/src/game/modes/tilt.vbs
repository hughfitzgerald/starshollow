
'*******************************************
'  Tilt Mode
'*******************************************
' Priority 10000 - above everything, because a tilt has to win.
'
' Runs for the whole ball and watches the nudge keys. GLF's Glf_KeyDown
' already calls Glf_CheckTilt on every nudge; this mode is what turns those
' checks into warnings and eventually a tilt.
'
' Three warnings then tilt. On tilt, GLF dispatches "tilt", which is in the
' base mode's StopEvents - so the flippers die, the inserts go out, and the
' ball drains without scoring. That's the whole point.

Sub CreateTiltMode()

    With CreateGlfMode("tilt", 10000)

        .StartEvents = Array("ball_started")
        .StopEvents  = Array("ball_will_end")

        With .Tilt()
            .MultipleHitWindow  = 3000   'ignore repeat hits inside this window
            .SettleTime         = 5000   'ball must settle this long after tilt
            .WarningsToTilt     = 3
            .ResetWarningEvents = Array("mode_tilt_started")
        End With

    End With

End Sub
