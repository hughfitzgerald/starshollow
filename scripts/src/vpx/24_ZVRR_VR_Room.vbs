
'*******************************************
'   ZVRR: VR Room / VR Cabinet
'*******************************************
' VR is not being used yet but is deliberately left wired so it is not
' foreclosed. FlexDMD is gone, so the DMD flasher lines that referenced it
' are removed - re-add them if you ever bring a DMD back.

Dim VRThings
Sub InitVR()
	If VRRoom <> 0 Then
		If VRRoom = 1 Then
			For Each VRThings In VR_Cab
				VRThings.visible = 1
			Next
		End If
		If VRRoom = 2 Then
			For Each VRThings In VR_Cab
				VRThings.visible = 0
			Next
			PinCab_Backglass.visible = 1
		End If
	Else
		For Each VRThings In VR_Cab
			VRThings.visible = 0
		Next
	End If
End Sub
