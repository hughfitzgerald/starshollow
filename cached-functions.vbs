Function Glf_0(args)
	Glf_0 = 4000
End Function
glf_funcRefMap.Add "4000", "Glf_0"
Function Glf_1(args)
	Glf_1 = 20000
End Function
glf_funcRefMap.Add "20000", "Glf_1"
Function Glf_2(args)
	On Error Resume Next
	    Glf_2 = devices.timers.attract_pulse.ticks = 1
	If Err Then Glf_2 = False
End Function
glf_funcRefMap.Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 1}", "Glf_2"
Function Glf_3(args)
	On Error Resume Next
	    Glf_3 = devices.timers.attract_pulse.ticks = 3
	If Err Then Glf_3 = False
End Function
glf_funcRefMap.Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 3}", "Glf_3"
Function Glf_4(args)
	Glf_4 = 0
End Function
glf_funcRefMap.Add "0", "Glf_4"
Function Glf_5(args)
	Glf_5 = -1
End Function
glf_funcRefMap.Add "-1", "Glf_5"
Function Glf_6(args)
	Glf_6 = 4
End Function
glf_funcRefMap.Add "4", "Glf_6"
Function Glf_7(args)
	On Error Resume Next
	    Glf_7 = GetPlayerState("ball_just_started") = 1
	If Err Then Glf_7 = False
End Function
glf_funcRefMap.Add "s_Trigger1_inactive{current_player.ball_just_started == 1}", "Glf_7"
Function Glf_8(args)
	Glf_8 = 1
End Function
glf_funcRefMap.Add "1", "Glf_8"
Function Glf_9(args)
	Glf_9 = 15000
End Function
glf_funcRefMap.Add "15000", "Glf_9"
Function Glf_10(args)
	Glf_10 = 5000
End Function
glf_funcRefMap.Add "5000", "Glf_10"
Function Glf_11(args)
	Glf_11 = 3000
End Function
glf_funcRefMap.Add "3000", "Glf_11"
Function Glf_12(args)
	Glf_12 = 2000
End Function
glf_funcRefMap.Add "2000", "Glf_12"
Function Glf_13(args)
	Glf_13 = 3
End Function
glf_funcRefMap.Add "3", "Glf_13"
Function Glf_14(args)
	Glf_14 = 1 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "1 * current_player.scoring_multiplier", "Glf_14"
Function Glf_15(args)
	Glf_15 = 10 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "10 * current_player.scoring_multiplier", "Glf_15"
Function Glf_16(args)
	Glf_16 = 100 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "100 * current_player.scoring_multiplier", "Glf_16"
Function Glf_17(args)
	Glf_17 = 333 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "333 * current_player.scoring_multiplier", "Glf_17"
Function Glf_18(args)
	Glf_18 = 500 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "500 * current_player.scoring_multiplier", "Glf_18"
Function Glf_19(args)
	Glf_19 = 1000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "1000 * current_player.scoring_multiplier", "Glf_19"
Function Glf_20(args)
	Glf_20 = 2000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "2000 * current_player.scoring_multiplier", "Glf_20"
Function Glf_21(args)
	Glf_21 = 3000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "3000 * current_player.scoring_multiplier", "Glf_21"
Function Glf_22(args)
	Glf_22 = 3333 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "3333 * current_player.scoring_multiplier", "Glf_22"
Function Glf_23(args)
	Glf_23 = 5000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "5000 * current_player.scoring_multiplier", "Glf_23"
Function Glf_24(args)
	Glf_24 = 10000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "10000 * current_player.scoring_multiplier", "Glf_24"
Function Glf_25(args)
	Glf_25 = 20000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "20000 * current_player.scoring_multiplier", "Glf_25"
Function Glf_26(args)
	Glf_26 = 30000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "30000 * current_player.scoring_multiplier", "Glf_26"
Function Glf_27(args)
	Glf_27 = 33333 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "33333 * current_player.scoring_multiplier", "Glf_27"
Function Glf_28(args)
	Glf_28 = 50000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "50000 * current_player.scoring_multiplier", "Glf_28"
Function Glf_29(args)
	Glf_29 = 100000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "100000 * current_player.scoring_multiplier", "Glf_29"
Function Glf_30(args)
	Glf_30 = 200000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "200000 * current_player.scoring_multiplier", "Glf_30"
Function Glf_31(args)
	Glf_31 = 500000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "500000 * current_player.scoring_multiplier", "Glf_31"
Function Glf_32(args)
	Glf_32 = 1000000 * GetPlayerState("scoring_multiplier")
End Function
glf_funcRefMap.Add "1000000 * current_player.scoring_multiplier", "Glf_32"
Function Glf_33(args)
	Glf_33 = 2
End Function
glf_funcRefMap.Add "2", "Glf_33"
Function Glf_34(args)
	On Error Resume Next
	    Glf_34 = GetPlayerState("ball_just_started") = 1
	If Err Then Glf_34 = False
End Function
glf_funcRefMap.Add "mode_skillshots_started{current_player.ball_just_started == 1}", "Glf_34"
Function Glf_35(args)
	On Error Resume Next
	    Glf_35 = GetPlayerState("extra_balls") = 0
	If Err Then Glf_35 = False
End Function
glf_funcRefMap.Add "check_eb{current_player.extra_balls == 0}", "Glf_35"
Function Glf_36(args)
	On Error Resume Next
	    Glf_36 = GetPlayerState("extra_balls") > 0
	If Err Then Glf_36 = False
End Function
glf_funcRefMap.Add "check_eb{current_player.extra_balls > 0}", "Glf_36"
Function Glf_37(args)
	On Error Resume Next
	    Glf_37 = GetPlayerState("shot_eb_ready") = 1
	If Err Then Glf_37 = False
End Function
glf_funcRefMap.Add "s_complete_right_ramp_active{current_player.shot_eb_ready == 1}", "Glf_37"
Function Glf_38(args)
	On Error Resume Next
	    Glf_38 = GetPlayerState("extra_ball_eb_awarded") < 3
	If Err Then Glf_38 = False
End Function
glf_funcRefMap.Add "eb_now_lit{current_player.extra_ball_eb_awarded < 3}", "Glf_38"
Function Glf_39(args)
	On Error Resume Next
	    Glf_39 = GetPlayerState("shot_ramp") = 1
	If Err Then Glf_39 = False
End Function
glf_funcRefMap.Add "s_complete_right_ramp_active{current_player.shot_ramp == 1}", "Glf_39"
Function Glf_40(args)
	Glf_40 = 10000
End Function
glf_funcRefMap.Add "10000", "Glf_40"
Function Glf_41(args)
	Glf_41 = 1000
End Function
glf_funcRefMap.Add "1000", "Glf_41"
Dim glf_gi006_lmarr : glf_gi006_lmarr = Array()
glf_lightMaps.Add "gi006", glf_gi006_lmarr
Dim glf_gi007_lmarr : glf_gi007_lmarr = Array()
glf_lightMaps.Add "gi007", glf_gi007_lmarr
Dim glf_gi008_lmarr : glf_gi008_lmarr = Array()
glf_lightMaps.Add "gi008", glf_gi008_lmarr
Dim glf_gi009_lmarr : glf_gi009_lmarr = Array()
glf_lightMaps.Add "gi009", glf_gi009_lmarr
Dim glf_gi010_lmarr : glf_gi010_lmarr = Array()
glf_lightMaps.Add "gi010", glf_gi010_lmarr
Dim glf_gi011_lmarr : glf_gi011_lmarr = Array()
glf_lightMaps.Add "gi011", glf_gi011_lmarr
Dim glf_gi012_lmarr : glf_gi012_lmarr = Array()
glf_lightMaps.Add "gi012", glf_gi012_lmarr
Dim glf_gi013_lmarr : glf_gi013_lmarr = Array()
glf_lightMaps.Add "gi013", glf_gi013_lmarr
Dim glf_gi014_lmarr : glf_gi014_lmarr = Array()
glf_lightMaps.Add "gi014", glf_gi014_lmarr
Dim glf_gi015_lmarr : glf_gi015_lmarr = Array()
glf_lightMaps.Add "gi015", glf_gi015_lmarr
Dim glf_gi016_lmarr : glf_gi016_lmarr = Array()
glf_lightMaps.Add "gi016", glf_gi016_lmarr
Dim glf_gi017_lmarr : glf_gi017_lmarr = Array()
glf_lightMaps.Add "gi017", glf_gi017_lmarr
Dim glf_gi018_lmarr : glf_gi018_lmarr = Array()
glf_lightMaps.Add "gi018", glf_gi018_lmarr
Dim glf_gi019_lmarr : glf_gi019_lmarr = Array()
glf_lightMaps.Add "gi019", glf_gi019_lmarr
Dim glf_gi020_lmarr : glf_gi020_lmarr = Array()
glf_lightMaps.Add "gi020", glf_gi020_lmarr
Dim glf_gi021_lmarr : glf_gi021_lmarr = Array()
glf_lightMaps.Add "gi021", glf_gi021_lmarr
Dim glf_gi022_lmarr : glf_gi022_lmarr = Array()
glf_lightMaps.Add "gi022", glf_gi022_lmarr
Dim glf_gi023_lmarr : glf_gi023_lmarr = Array()
glf_lightMaps.Add "gi023", glf_gi023_lmarr
Dim glf_gi024_lmarr : glf_gi024_lmarr = Array()
glf_lightMaps.Add "gi024", glf_gi024_lmarr
Dim glf_gi050_lmarr : glf_gi050_lmarr = Array()
glf_lightMaps.Add "gi050", glf_gi050_lmarr
Dim glf_l1_lmarr : glf_l1_lmarr = Array()
glf_lightMaps.Add "l1", glf_l1_lmarr
Dim glf_l11_lmarr : glf_l11_lmarr = Array()
glf_lightMaps.Add "l11", glf_l11_lmarr
Dim glf_l12_lmarr : glf_l12_lmarr = Array()
glf_lightMaps.Add "l12", glf_l12_lmarr
Dim glf_l13_lmarr : glf_l13_lmarr = Array()
glf_lightMaps.Add "l13", glf_l13_lmarr
Dim glf_l14_lmarr : glf_l14_lmarr = Array()
glf_lightMaps.Add "l14", glf_l14_lmarr
Dim glf_l15_lmarr : glf_l15_lmarr = Array()
glf_lightMaps.Add "l15", glf_l15_lmarr
Dim glf_l16_lmarr : glf_l16_lmarr = Array()
glf_lightMaps.Add "l16", glf_l16_lmarr
Dim glf_l17_lmarr : glf_l17_lmarr = Array()
glf_lightMaps.Add "l17", glf_l17_lmarr
Dim glf_l18_lmarr : glf_l18_lmarr = Array()
glf_lightMaps.Add "l18", glf_l18_lmarr
Dim glf_l8_lmarr : glf_l8_lmarr = Array()
glf_lightMaps.Add "l8", glf_l8_lmarr
Dim glf_l9_lmarr : glf_l9_lmarr = Array()
glf_lightMaps.Add "l9", glf_l9_lmarr
Dim glf_l51_lmarr : glf_l51_lmarr = Array()
glf_lightMaps.Add "l51", glf_l51_lmarr
Dim glf_l52_lmarr : glf_l52_lmarr = Array()
glf_lightMaps.Add "l52", glf_l52_lmarr
Dim glf_l53_lmarr : glf_l53_lmarr = Array()
glf_lightMaps.Add "l53", glf_l53_lmarr
Dim glf_l54_lmarr : glf_l54_lmarr = Array()
glf_lightMaps.Add "l54", glf_l54_lmarr
Dim glf_l55_lmarr : glf_l55_lmarr = Array()
glf_lightMaps.Add "l55", glf_l55_lmarr
Dim glf_l56_lmarr : glf_l56_lmarr = Array()
glf_lightMaps.Add "l56", glf_l56_lmarr

