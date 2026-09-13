'******************************************************
'  ZANI: Misc Animations
'******************************************************

Sub LeftFlipper_Animate
	dim a: a = LeftFlipper.CurrentAngle
	FlipperLSh.RotZ = a
	LFLogo.RotZ = a
	'Add any left flipper related animations here
	dim b: b = LeftFlipper2.CurrentAngle
	LFLogo2.RotZ = b
End Sub

Sub RightFlipper_Animate
	dim a: a = RightFlipper.CurrentAngle
	FlipperRSh.RotZ = a
	RFlogo.RotZ = a
	'Add any right flipper related animations here
End Sub


'******************************************************
' 	Z3DI:   3D INSERTS
'******************************************************
'
'
' Before you get started adding the inserts to your playfield in VPX, there are a few things you need to have done to prepare:
'	 1. Cut out all the inserts on the playfield image so there is alpha transparency where they should be.
'	  Make sure the playfield material has Opacity Active checkbox checked.
'	2. All the  insert text and/or images that lie over the insert plastic needs to be in its own file with
'	   alpha transparency. Many playfields may require finding the original font and remaking the insert text.
'
' To add the inserts:
'	1. Import all the textures (images) and materials from this file that start with the word "Insert" into your Table
'   2. Copy and past the two primitves that make up the insert you want to use. One primitive is for the on state, the other for the off state.
'   3. Align the primitives with the associated insert light. Name the on and off primitives correctly.
'   5. You will need to manually tweak the disable lighting value and material parameters to achielve the effect you want.
'
'
' Quick Reference:  Laying the Inserts ( Tutorial From Iaakki)
' - Each insert consists of two primitives. On and Off primitive. Suggested naming convention is to use lamp number in the name. For example
'   is lamp number is 57, the On primitive is "p57" and the Off primitive is "p57off". This makes it easier to work on script side.
' - When starting from a new table, I'd first select to make few inserts that look quite similar. Lets say there is total of 6 small triangle
'   inserts, 4 yellow and 2 blue ones.
' - Import the insert on/off images from the image manager and the vpx materials used from the sample project first, and those should appear
'   selected properly in the primitive settings when you paste your actual insert trays in your target table . Then open up your target project
'   at same time as the sample project and use copy&paste to copy desired inserts to target project.
' - There are quite many parameters in primitive that affect a lot how they will look. I wouldn't mess too much with them. Use Size options to
'   scale the insert properly into PF hole. Some insert primitives may have incorrect pivot point, which means that changing the depth, you may
'   also need to alter the Z-position too.
' - Once you have the first insert in place, wire it up in the script (detailed in part 3 below). Then set the light bulb's intensity to zero,
'   so it won't harass the adjustment.
' - Start up the game with F6 and visually see if the On-primitive blinks properly. If it is too dim, hit D and open editor. Write:
' - p57.BlendDisableLighting = 300 and hit enter
' - -> The insert should appear differently. Find good looking brightness level. Not too bright as the light bulb is still missing. Just generic good light.
'	 - If you cannot find proper light color or "mood", you can also fiddle with primitive material values. Provided material should be
'	   quite ok for most of the cases.
'	 - Now when you have found proper DL value (165), but that into script:
' - That one insert is now adjusted and you should be able to copy&paste rest of the triangle inserts in place and name them correctly. And add them
'   into script. And fine tune their brightness and color.
'
' Light bulbs and ball reflection:
'
' - This kind of lighted primitives are not giving you ball reflections. Also some more glow vould be needed to make the insert to bloom correctly.
' - Take the original lamp (l57), set the bulb mode enabled, set Halo Height to -3 (something that is inside the 2 insert primitives). I'd start with
'   falloff 100, falloff Power 2-2.5, Intensity 10, scale mesh 10, Transmit 5.
' - Start the game with F6, throw a ball on it and move the ball near the blinking insert. Visually see how the reflection looks.
' - Hit D once the reflection is the highest. Open light editor and start fine tuning the bulb values to achieve realistic look for the reflection.
' - Falloff Power value is the one that will affect reflection creatly. The higher the power value is, the brighter the reflection on the ball is.
'   This is the reason why falloff is rather large and falloff power is quite low. Change scale mesh if reflection is too small or large.
' - Transmit value can bring nice bloom for the insert, but it may also affect to other primitives nearby. Sometimes one need to set transmit to
'   zero to avoid affecting surrounding plastics. If you really need to have higher transmit value, you may set Disable Lighting From Below to 1
'   in surrounding primitive. This may remove the problem, but can make the primitive look worse too.

' ---- FOR EXAMPLE PUROSE ONLY. DELETE BELOW WHEN USING FOR REAL -----
' NOTE: The below timer is for flashing the inserts as a demonstration. Should be replaced by actual lamp states.
'	   In other words, delete this sub (InsertFlicker_timer) and associated timer if you are going to use with a ROM.
' Dim flickerX, FlickerState
' FlickerState = 0
' Sub InsertFlicker_timer
' 	If FlickerState = 0 Then
' 		For flickerX = 0 To 19
' 			If flickerX < 6 Or flickerX > 9 Then
' 				AllLamps(flickerX).state = False
' 			ElseIf BonusX(flickerX - 6) = False Then
' 				AllLamps(flickerX).state = False
' 			End If
' 		Next
' 		FlickerState = 1
' 	Else
' 		For flickerX = 0 To 19
' 			If flickerX < 6 Or flickerX > 9 Then
' 				AllLamps(flickerX).state = True
' 			ElseIf BonusX(flickerX - 6) = False Then
' 				AllLamps(flickerX).state = True
' 			End If
' 		Next
' 		FlickerState = 0
' 	End If
' End Sub
'
' --- Insert primitives under GLF ------------------------------------
' These were intensity-driven:
'     p11.BlendDisableLighting = 200 * (l11.GetInPlayIntensity / l11.Intensity)
' That does not work under GLF. Glf_RegisterLights sets light.State = 1 on
' every glf_lights member permanently and modulates COLOR only
' (Glf_SetLight writes light.Color and nothing else). So GetInPlayIntensity
' is pinned at full and every insert primitive renders fully lit forever.
'
' GlfInsertGlow reads the light's colour instead, so the primitive tracks
' what GLF is actually doing. Black (000000, GLF's "off") -> 0.
' The per-light lNN_animate subs are GONE on purpose. VPX raises _Animate
' when a light's STATE changes or it fades. GLF never changes state - it
' pins State = 1 and writes Color - so those subs were effectively never
' called and each insert primitive kept whatever BlendDisableLighting it
' had at design time. That is the "always lit" symptom.
'
' Driving them from FrameTimer instead makes the update unconditional and
' independent of VPX's light events.
' Update these Arrays by populating the gameitems.json with latest light sets 
' and running generate-arrays.py. Go to scripts directory and run "uv run generate-arrays.py"
Dim GlfInsertLights, GlfInsertPrims
GlfInsertLights = Array(l9, l8, l1, l12, l11, l13, l14, l15, l16, l17, l18, l52, l51, l53, l54, l55, l56, l21, l24, l23, l27, l28, l22, l25, l26, l31, l34, l32, l33, l7, l57, l58, l59, l60, l61, l62, l63, l64, l65, l66, l67, l68, l69, l70, l71, l72)
GlfInsertPrims  = Array(p9, p8, p1, p12, p11, p13, p14, p15, p16, p17, p18, p52, p51, p53, p54, p55, p56, p21, p24, p23, p27, p28, p22, p25, p26, p31, p34, p32, p33, p7, p57, p58, p59, p60, p61, p62, p63, p64, p65, p66, p67, p68, p69, p70, p71, p72)

Sub UpdateGlfInserts()
    Dim i, g
    For i = 0 To UBound(GlfInsertLights)
        g = GlfInsertGlow(GlfInsertLights(i))
        GlfInsertPrims(i).BlendDisableLighting = g

        ' Also drive the light's own State. Glf_RegisterLights pins
        ' State = 1 forever and only writes Color, so an insert that is
        ' rendered by the LIGHT (bulb mesh / halo) rather than by its
        ' primitive stays visible even at colour 000000. Killing State
        ' when the colour is fully black makes both styles go dark.
        ' Any non-black colour restores State = 1 so fades still show.
        If g = 0 Then
            If GlfInsertLights(i).State <> 0 Then GlfInsertLights(i).State = 0
        Else
            If GlfInsertLights(i).State <> 1 Then GlfInsertLights(i).State = 1
        End If
    Next
End Sub

Function GlfInsertGlow(lgt)
    Dim c : c = CLng(lgt.Color)
    ' VPX colours are BGR-packed longs; take the brightest channel.
    Dim r, g, b
    r = c And 255
    g = (c \ 256) And 255
    b = (c \ 65536) And 255
    Dim m : m = r
    If g > m Then m = g
    If b > m Then m = b
    GlfInsertGlow = 200 * (m / 255)
End Function

' ' 
' 

