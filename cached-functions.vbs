Function Glf_0(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "action",  "left"
	Set Glf_0 = kwargs
	If Err Then Glf_0 = Null
End Function
Function Glf_1(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "action",  "right"
	Set Glf_1 = kwargs
	If Err Then Glf_1 = Null
End Function
Function Glf_2(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "action",  "select"
	Set Glf_2 = kwargs
	If Err Then Glf_2 = Null
End Function
Function Glf_3(args)
	Glf_3 = 4000
End Function
Function Glf_4(args)
	Glf_4 = 20000
End Function
Function Glf_5(args)
	On Error Resume Next
	    Glf_5 = devices.timers.attract_pulse.ticks = 1
	If Err Then Glf_5 = False
End Function
Function Glf_6(args)
	On Error Resume Next
	    Glf_6 = devices.timers.attract_pulse.ticks = 3
	If Err Then Glf_6 = False
End Function
Function Glf_7(args)
	Glf_7 = 0
End Function
Function Glf_8(args)
	Glf_8 = -1
End Function
Function Glf_9(args)
	Glf_9 = 4
End Function
Function Glf_10(args)
	On Error Resume Next
	    Glf_10 = glf_machine_vars("credits").GetValue() >= 1 and (glf_machine_vars("game_active").GetValue() = 0 or (glf_machine_vars("num_players").GetValue() < 4 and GetPlayerState("ball") = 1))
	If Err Then Glf_10 = False
End Function
Function Glf_11(args)
	On Error Resume Next
	    Glf_11 = glf_machine_vars("credits").GetValue() < 1 or (glf_machine_vars("game_active").GetValue() = 1 and (glf_machine_vars("num_players").GetValue() >= 4 or GetPlayerState("ball") > 1))
	If Err Then Glf_11 = False
End Function
Function Glf_12(args)
	On Error Resume Next
	    Glf_12 = Glf_GameVariable("tilted") = True
	If Err Then Glf_12 = False
End Function
Function Glf_13(args)
	On Error Resume Next
	    Glf_13 = glf_machine_vars("captive_ball_captive").GetValue() = 0
	If Err Then Glf_13 = False
End Function
Function Glf_14(args)
	On Error Resume Next
	    Glf_14 = glf_machine_vars("captive_ball_captive").GetValue() = 0 and GetPlayerState("llmb_shoot_again_active") = 0
	If Err Then Glf_14 = False
End Function
Function Glf_15(args)
	Glf_15 = 1
End Function
Function Glf_16(args)
	Glf_16 = glf_dispatch_current_kwargs("num")
End Function
Function Glf_17(args)
	On Error Resume Next
	    Glf_17 = glf_dispatch_current_kwargs("num") > 1
	If Err Then Glf_17 = False
End Function
Function Glf_18(args)
	On Error Resume Next
	    Glf_18 = glf_dispatch_current_kwargs("num") = 2
	If Err Then Glf_18 = False
End Function
Function Glf_19(args)
	On Error Resume Next
	    Glf_19 = glf_dispatch_current_kwargs("num") = 3
	If Err Then Glf_19 = False
End Function
Function Glf_20(args)
	On Error Resume Next
	    Glf_20 = glf_dispatch_current_kwargs("num") = 4
	If Err Then Glf_20 = False
End Function
Function Glf_21(args)
	Glf_21 = 10
End Function
Function Glf_22(args)
	On Error Resume Next
	    Glf_22 = GetPlayerState("ball_just_started") = 1
	If Err Then Glf_22 = False
End Function
Function Glf_23(args)
	On Error Resume Next
	    Glf_23 = glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_23 = False
End Function
Function Glf_24(args)
	On Error Resume Next
	    Glf_24 = glf_modes("eob_bonus").GetValue("active") = False and glf_modes("dance_marathon").GetValue("active") = False and glf_modes("town_meeting").GetValue("active") = False and glf_modes("dinner").GetValue("active") = False and glf_modes("fd_punch").GetValue("active") = False and glf_modes("kims_antiques").GetValue("active") = False and glf_modes("lbtb").GetValue("active") = False
	If Err Then Glf_24 = False
End Function
Function Glf_25(args)
	Glf_25 = 200
End Function
Function Glf_26(args)
	Glf_26 = 244
End Function
Function Glf_27(args)
	Glf_27 = 50
End Function
Function Glf_28(args)
	Glf_28 = 36
End Function
Function Glf_29(args)
	Glf_29 = 188
End Function
Function Glf_30(args)
	Glf_30 = 52
End Function
Function Glf_31(args)
	Glf_31 = 234
End Function
Function Glf_32(args)
	Glf_32 = 332
End Function
Function Glf_33(args)
	On Error Resume Next
	    Glf_33 = glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_33 = False
End Function
Function Glf_34(args)
	On Error Resume Next
	    Glf_34 = glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_34 = False
End Function
Function Glf_35(args)
	On Error Resume Next
	    Glf_35 = glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_35 = False
End Function
Function Glf_36(args)
	On Error Resume Next
	    Glf_36 = glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_36 = False
End Function
Function Glf_37(args)
	On Error Resume Next
	    Glf_37 = glf_modes("lbtb").GetValue("active")=False
	If Err Then Glf_37 = False
End Function
Function Glf_38(args)
	On Error Resume Next
	    Glf_38 = glf_modes("lbtb").GetValue("active")=False
	If Err Then Glf_38 = False
End Function
Function Glf_39(args)
	On Error Resume Next
	    Glf_39 = glf_machine_vars("num_players").GetValue() > 1 and GetPlayerState("number") = 1
	If Err Then Glf_39 = False
End Function
Function Glf_40(args)
	On Error Resume Next
	    Glf_40 = glf_machine_vars("num_players").GetValue() > 1 and GetPlayerState("number") = 2
	If Err Then Glf_40 = False
End Function
Function Glf_41(args)
	On Error Resume Next
	    Glf_41 = glf_machine_vars("num_players").GetValue() > 1 and GetPlayerState("number") = 3
	If Err Then Glf_41 = False
End Function
Function Glf_42(args)
	On Error Resume Next
	    Glf_42 = glf_machine_vars("num_players").GetValue() > 1 and GetPlayerState("number") = 4
	If Err Then Glf_42 = False
End Function
Function Glf_43(args)
	Glf_43 = 15000
End Function
Function Glf_44(args)
	Glf_44 = 5000
End Function
Function Glf_45(args)
	Glf_45 = 3000
End Function
Function Glf_46(args)
	Glf_46 = 2000
End Function
Function Glf_47(args)
	On Error Resume Next
	    Glf_47 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_47 = False
End Function
Function Glf_48(args)
	On Error Resume Next
	    Glf_48 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_48 = False
End Function
Function Glf_49(args)
	On Error Resume Next
	    Glf_49 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_49 = False
End Function
Function Glf_50(args)
	On Error Resume Next
	    Glf_50 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_50 = False
End Function
Function Glf_51(args)
	On Error Resume Next
	    Glf_51 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_51 = False
End Function
Function Glf_52(args)
	On Error Resume Next
	    Glf_52 = glf_machine_vars("high_score_initials_chars").GetValue() = 3
	If Err Then Glf_52 = False
End Function
Function Glf_53(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text",  glf_machine_vars("high_score_initials").GetValue()
	Set Glf_53 = kwargs
	If Err Then Glf_53 = Null
End Function
Function Glf_54(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text",  glf_machine_vars("high_score_initials").GetValue()
	Set Glf_54 = kwargs
	If Err Then Glf_54 = Null
End Function
Function Glf_55(args)
	On Error Resume Next
	    Glf_55 = glf_machine_vars("high_score_initials_chars").GetValue() < 3
	If Err Then Glf_55 = False
End Function
Function Glf_56(args)
	Glf_56 = GetPlayerStateForPlayer(0, "score")
End Function
Function Glf_57(args)
	On Error Resume Next
	    Glf_57 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_57 = False
End Function
Function Glf_58(args)
	On Error Resume Next
	    Glf_58 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_58 = False
End Function
Function Glf_59(args)
	On Error Resume Next
	    Glf_59 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 0
	If Err Then Glf_59 = False
End Function
Function Glf_60(args)
	Glf_60 = glf_machine_vars("high_score_initials").GetValue() & "A"
End Function
Function Glf_61(args)
	On Error Resume Next
	    Glf_61 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 1
	If Err Then Glf_61 = False
End Function
Function Glf_62(args)
	Glf_62 = glf_machine_vars("high_score_initials").GetValue() & "B"
End Function
Function Glf_63(args)
	On Error Resume Next
	    Glf_63 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 2
	If Err Then Glf_63 = False
End Function
Function Glf_64(args)
	Glf_64 = glf_machine_vars("high_score_initials").GetValue() & "C"
End Function
Function Glf_65(args)
	On Error Resume Next
	    Glf_65 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 3
	If Err Then Glf_65 = False
End Function
Function Glf_66(args)
	Glf_66 = glf_machine_vars("high_score_initials").GetValue() & "D"
End Function
Function Glf_67(args)
	On Error Resume Next
	    Glf_67 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 4
	If Err Then Glf_67 = False
End Function
Function Glf_68(args)
	Glf_68 = glf_machine_vars("high_score_initials").GetValue() & "E"
End Function
Function Glf_69(args)
	On Error Resume Next
	    Glf_69 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 5
	If Err Then Glf_69 = False
End Function
Function Glf_70(args)
	Glf_70 = glf_machine_vars("high_score_initials").GetValue() & "F"
End Function
Function Glf_71(args)
	On Error Resume Next
	    Glf_71 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 6
	If Err Then Glf_71 = False
End Function
Function Glf_72(args)
	Glf_72 = glf_machine_vars("high_score_initials").GetValue() & "G"
End Function
Function Glf_73(args)
	On Error Resume Next
	    Glf_73 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 7
	If Err Then Glf_73 = False
End Function
Function Glf_74(args)
	Glf_74 = glf_machine_vars("high_score_initials").GetValue() & "H"
End Function
Function Glf_75(args)
	On Error Resume Next
	    Glf_75 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 8
	If Err Then Glf_75 = False
End Function
Function Glf_76(args)
	Glf_76 = glf_machine_vars("high_score_initials").GetValue() & "I"
End Function
Function Glf_77(args)
	On Error Resume Next
	    Glf_77 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 9
	If Err Then Glf_77 = False
End Function
Function Glf_78(args)
	Glf_78 = glf_machine_vars("high_score_initials").GetValue() & "J"
End Function
Function Glf_79(args)
	On Error Resume Next
	    Glf_79 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 10
	If Err Then Glf_79 = False
End Function
Function Glf_80(args)
	Glf_80 = glf_machine_vars("high_score_initials").GetValue() & "K"
End Function
Function Glf_81(args)
	On Error Resume Next
	    Glf_81 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 11
	If Err Then Glf_81 = False
End Function
Function Glf_82(args)
	Glf_82 = glf_machine_vars("high_score_initials").GetValue() & "L"
End Function
Function Glf_83(args)
	On Error Resume Next
	    Glf_83 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 12
	If Err Then Glf_83 = False
End Function
Function Glf_84(args)
	Glf_84 = glf_machine_vars("high_score_initials").GetValue() & "M"
End Function
Function Glf_85(args)
	On Error Resume Next
	    Glf_85 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 13
	If Err Then Glf_85 = False
End Function
Function Glf_86(args)
	Glf_86 = glf_machine_vars("high_score_initials").GetValue() & "N"
End Function
Function Glf_87(args)
	On Error Resume Next
	    Glf_87 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 14
	If Err Then Glf_87 = False
End Function
Function Glf_88(args)
	Glf_88 = glf_machine_vars("high_score_initials").GetValue() & "O"
End Function
Function Glf_89(args)
	On Error Resume Next
	    Glf_89 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 15
	If Err Then Glf_89 = False
End Function
Function Glf_90(args)
	Glf_90 = glf_machine_vars("high_score_initials").GetValue() & "P"
End Function
Function Glf_91(args)
	On Error Resume Next
	    Glf_91 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 16
	If Err Then Glf_91 = False
End Function
Function Glf_92(args)
	Glf_92 = glf_machine_vars("high_score_initials").GetValue() & "Q"
End Function
Function Glf_93(args)
	On Error Resume Next
	    Glf_93 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 17
	If Err Then Glf_93 = False
End Function
Function Glf_94(args)
	Glf_94 = glf_machine_vars("high_score_initials").GetValue() & "R"
End Function
Function Glf_95(args)
	On Error Resume Next
	    Glf_95 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 18
	If Err Then Glf_95 = False
End Function
Function Glf_96(args)
	Glf_96 = glf_machine_vars("high_score_initials").GetValue() & "S"
End Function
Function Glf_97(args)
	On Error Resume Next
	    Glf_97 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 19
	If Err Then Glf_97 = False
End Function
Function Glf_98(args)
	Glf_98 = glf_machine_vars("high_score_initials").GetValue() & "T"
End Function
Function Glf_99(args)
	On Error Resume Next
	    Glf_99 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 20
	If Err Then Glf_99 = False
End Function
Function Glf_100(args)
	Glf_100 = glf_machine_vars("high_score_initials").GetValue() & "U"
End Function
Function Glf_101(args)
	On Error Resume Next
	    Glf_101 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 21
	If Err Then Glf_101 = False
End Function
Function Glf_102(args)
	Glf_102 = glf_machine_vars("high_score_initials").GetValue() & "V"
End Function
Function Glf_103(args)
	On Error Resume Next
	    Glf_103 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 22
	If Err Then Glf_103 = False
End Function
Function Glf_104(args)
	Glf_104 = glf_machine_vars("high_score_initials").GetValue() & "W"
End Function
Function Glf_105(args)
	On Error Resume Next
	    Glf_105 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 23
	If Err Then Glf_105 = False
End Function
Function Glf_106(args)
	Glf_106 = glf_machine_vars("high_score_initials").GetValue() & "X"
End Function
Function Glf_107(args)
	On Error Resume Next
	    Glf_107 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 24
	If Err Then Glf_107 = False
End Function
Function Glf_108(args)
	Glf_108 = glf_machine_vars("high_score_initials").GetValue() & "Y"
End Function
Function Glf_109(args)
	On Error Resume Next
	    Glf_109 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 25
	If Err Then Glf_109 = False
End Function
Function Glf_110(args)
	Glf_110 = glf_machine_vars("high_score_initials").GetValue() & "Z"
End Function
Function Glf_111(args)
	On Error Resume Next
	    Glf_111 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 26
	If Err Then Glf_111 = False
End Function
Function Glf_112(args)
	Glf_112 = glf_machine_vars("high_score_initials").GetValue() & "0"
End Function
Function Glf_113(args)
	On Error Resume Next
	    Glf_113 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 27
	If Err Then Glf_113 = False
End Function
Function Glf_114(args)
	Glf_114 = glf_machine_vars("high_score_initials").GetValue() & "1"
End Function
Function Glf_115(args)
	On Error Resume Next
	    Glf_115 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 28
	If Err Then Glf_115 = False
End Function
Function Glf_116(args)
	Glf_116 = glf_machine_vars("high_score_initials").GetValue() & "2"
End Function
Function Glf_117(args)
	On Error Resume Next
	    Glf_117 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 29
	If Err Then Glf_117 = False
End Function
Function Glf_118(args)
	Glf_118 = glf_machine_vars("high_score_initials").GetValue() & "3"
End Function
Function Glf_119(args)
	On Error Resume Next
	    Glf_119 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 30
	If Err Then Glf_119 = False
End Function
Function Glf_120(args)
	Glf_120 = glf_machine_vars("high_score_initials").GetValue() & "4"
End Function
Function Glf_121(args)
	On Error Resume Next
	    Glf_121 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 31
	If Err Then Glf_121 = False
End Function
Function Glf_122(args)
	Glf_122 = glf_machine_vars("high_score_initials").GetValue() & "5"
End Function
Function Glf_123(args)
	On Error Resume Next
	    Glf_123 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 32
	If Err Then Glf_123 = False
End Function
Function Glf_124(args)
	Glf_124 = glf_machine_vars("high_score_initials").GetValue() & "6"
End Function
Function Glf_125(args)
	On Error Resume Next
	    Glf_125 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 33
	If Err Then Glf_125 = False
End Function
Function Glf_126(args)
	Glf_126 = glf_machine_vars("high_score_initials").GetValue() & "7"
End Function
Function Glf_127(args)
	On Error Resume Next
	    Glf_127 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 34
	If Err Then Glf_127 = False
End Function
Function Glf_128(args)
	Glf_128 = glf_machine_vars("high_score_initials").GetValue() & "8"
End Function
Function Glf_129(args)
	On Error Resume Next
	    Glf_129 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 35
	If Err Then Glf_129 = False
End Function
Function Glf_130(args)
	Glf_130 = glf_machine_vars("high_score_initials").GetValue() & "9"
End Function
Function Glf_131(args)
	On Error Resume Next
	    Glf_131 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 36
	If Err Then Glf_131 = False
End Function
Function Glf_132(args)
	Glf_132 = glf_machine_vars("high_score_initials").GetValue() & "_"
End Function
Function Glf_133(args)
	Glf_133 = ""
End Function
Function Glf_134(args)
	Glf_134 = glf_dispatch_current_kwargs("player_num")
End Function
Function Glf_135(args)
	Glf_135 = 60
End Function
Function Glf_136(args)
	Glf_136 = 5
End Function
Function Glf_137(args)
	On Error Resume Next
	    Glf_137 = Glf_GameVariable("tilted") = False
	If Err Then Glf_137 = False
End Function
Function Glf_138(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", GetPlayerState("bonus_total")
	Set Glf_138 = kwargs
	If Err Then Glf_138 = Null
End Function
Function Glf_139(args)
	On Error Resume Next
	    Glf_139 = GetPlayerState("total_switches_hit")  > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_139 = False
End Function
Function Glf_140(args)
	On Error Resume Next
	    Glf_140 = GetPlayerState("total_switches_hit") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_140 = False
End Function
Function Glf_141(args)
	On Error Resume Next
	    Glf_141 = GetPlayerState("bumper_count")        > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_141 = False
End Function
Function Glf_142(args)
	On Error Resume Next
	    Glf_142 = GetPlayerState("bumper_count")       = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_142 = False
End Function
Function Glf_143(args)
	On Error Resume Next
	    Glf_143 = GetPlayerState("diner_count")         > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_143 = False
End Function
Function Glf_144(args)
	On Error Resume Next
	    Glf_144 = GetPlayerState("diner_count")        = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_144 = False
End Function
Function Glf_145(args)
	On Error Resume Next
	    Glf_145 = GetPlayerState("grandparents_count")  > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_145 = False
End Function
Function Glf_146(args)
	On Error Resume Next
	    Glf_146 = GetPlayerState("grandparents_count") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_146 = False
End Function
Function Glf_147(args)
	On Error Resume Next
	    Glf_147 = GetPlayerState("spinner_count")       > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_147 = False
End Function
Function Glf_148(args)
	On Error Resume Next
	    Glf_148 = GetPlayerState("spinner_count")      = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_148 = False
End Function
Function Glf_149(args)
	On Error Resume Next
	    Glf_149 = GetPlayerState("mode_llmb_score")     > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_149 = False
End Function
Function Glf_150(args)
	On Error Resume Next
	    Glf_150 = GetPlayerState("mode_llmb_score")    = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_150 = False
End Function
Function Glf_151(args)
	On Error Resume Next
	    Glf_151 = GetPlayerState("mode_jdmb_score")     > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_151 = False
End Function
Function Glf_152(args)
	On Error Resume Next
	    Glf_152 = GetPlayerState("mode_jdmb_score")    = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_152 = False
End Function
Function Glf_153(args)
	On Error Resume Next
	    Glf_153 = GetPlayerState("mode_dance_marathon_score")       > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_153 = False
End Function
Function Glf_154(args)
	On Error Resume Next
	    Glf_154 = GetPlayerState("mode_dance_marathon_score")      = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_154 = False
End Function
Function Glf_155(args)
	On Error Resume Next
	    Glf_155 = GetPlayerState("mode_town_meeting_score")       > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_155 = False
End Function
Function Glf_156(args)
	On Error Resume Next
	    Glf_156 = GetPlayerState("mode_town_meeting_score")      = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_156 = False
End Function
Function Glf_157(args)
	On Error Resume Next
	    Glf_157 = GetPlayerState("mode_lbtb_score")     > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_157 = False
End Function
Function Glf_158(args)
	On Error Resume Next
	    Glf_158 = GetPlayerState("mode_lbtb_score")    = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_158 = False
End Function
Function Glf_159(args)
	On Error Resume Next
	    Glf_159 = GetPlayerState("mode_kims_antiques_score")       > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_159 = False
End Function
Function Glf_160(args)
	On Error Resume Next
	    Glf_160 = GetPlayerState("mode_kims_antiques_score")      = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_160 = False
End Function
Function Glf_161(args)
	On Error Resume Next
	    Glf_161 = GetPlayerState("mode_dinner_score")   > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_161 = False
End Function
Function Glf_162(args)
	On Error Resume Next
	    Glf_162 = GetPlayerState("mode_dinner_score")  = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_162 = False
End Function
Function Glf_163(args)
	On Error Resume Next
	    Glf_163 = GetPlayerState("mode_fd_punch_score")    > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_163 = False
End Function
Function Glf_164(args)
	On Error Resume Next
	    Glf_164 = GetPlayerState("mode_fd_punch_score")   = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_164 = False
End Function
Function Glf_165(args)
	On Error Resume Next
	    Glf_165 = GetPlayerState("bonus_total")         > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_165 = False
End Function
Function Glf_166(args)
	On Error Resume Next
	    Glf_166 = GetPlayerState("bonus_total")        = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_166 = False
End Function
Function Glf_167(args)
	Glf_167 = Glf_FormatValue(GetPlayerState("bonus_multiplier") * 1000 * GetPlayerState("total_switches_hit") + GetPlayerState("bumper_count") * 2000 + GetPlayerState("diner_count") * 5000 + GetPlayerState("grandparents_count") * 7500 + GetPlayerState("spinner_count") * 1000, ",")
End Function
Function Glf_168(args)
	Glf_168 = "BONUS " & GetPlayerState("bonus_multiplier") & "x"
End Function
Function Glf_169(args)
	Glf_169 = Glf_FormatValue(GetPlayerState("bonus_multiplier") * 1000 * GetPlayerState("total_switches_hit"), ",")
End Function
Function Glf_170(args)
	Glf_170 = "COFFEE COFFEE COFFEE"
End Function
Function Glf_171(args)
	Glf_171 = GetPlayerState("bumper_count") & " CUPS x " & BonusBumperFactor
End Function
Function Glf_172(args)
	Glf_172 = "LUKE'S DINER"
End Function
Function Glf_173(args)
	Glf_173 = GetPlayerState("diner_count") & " MEALS x " & BonusDinerFactor
End Function
Function Glf_174(args)
	Glf_174 = "GRANDPARENTS"
End Function
Function Glf_175(args)
	Glf_175 = GetPlayerState("grandparents_count") & " VISITS x " & BonusGrandparentsFactor
End Function
Function Glf_176(args)
	Glf_176 = "FAST TALKING"
End Function
Function Glf_177(args)
	Glf_177 = GetPlayerState("spinner_count") & " QUIPS x " & BonusSpinnerFactor
End Function
Function Glf_178(args)
	Glf_178 = "LOCK-AWAY LOGAN"
End Function
Function Glf_179(args)
	Glf_179 = Glf_FormatValue(GetPlayerState("mode_llmb_score"), ",")
End Function
Function Glf_180(args)
	Glf_180 = "JESS & DEAN: TO THE DEATH"
End Function
Function Glf_181(args)
	Glf_181 = Glf_FormatValue(GetPlayerState("mode_jdmb_score"), ",")
End Function
Function Glf_182(args)
	Glf_182 = "DANCE MARATHON"
End Function
Function Glf_183(args)
	Glf_183 = Glf_FormatValue(GetPlayerState("mode_dance_marathon_score"), ",")
End Function
Function Glf_184(args)
	Glf_184 = "TOWN MEETING"
End Function
Function Glf_185(args)
	Glf_185 = Glf_FormatValue(GetPlayerState("mode_town_meeting_score"), ",")
End Function
Function Glf_186(args)
	Glf_186 = "LUKE BREAKS THE BELLS"
End Function
Function Glf_187(args)
	Glf_187 = Glf_FormatValue(GetPlayerState("mode_lbtb_score"), ",")
End Function
Function Glf_188(args)
	Glf_188 = "KIM'S ANTIQUES"
End Function
Function Glf_189(args)
	Glf_189 = Glf_FormatValue(GetPlayerState("mode_kims_antiques_score"), ",")
End Function
Function Glf_190(args)
	Glf_190 = "FRIDAY NIGHT DINNER"
End Function
Function Glf_191(args)
	Glf_191 = Glf_FormatValue(GetPlayerState("mode_dinner_score"), ",")
End Function
Function Glf_192(args)
	Glf_192 = "FOUNDER'S DAY PUNCH"
End Function
Function Glf_193(args)
	Glf_193 = Glf_FormatValue(GetPlayerState("mode_fd_punch_score"), ",")
End Function
Function Glf_194(args)
	Glf_194 = "TOTAL BONUS"
End Function
Function Glf_195(args)
	Glf_195 = Glf_FormatValue(GetPlayerState("bonus_total"), ",")
End Function
Function Glf_196(args)
	On Error Resume Next
	    Glf_196 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_196 = False
End Function
Function Glf_197(args)
	On Error Resume Next
	    Glf_197 = GetPlayerState("is_lock_qualified") = 0
	If Err Then Glf_197 = False
End Function
Function Glf_198(args)
	On Error Resume Next
	    Glf_198 = GetPlayerState("is_lock_qualified") = 1
	If Err Then Glf_198 = False
End Function
Function Glf_199(args)
	On Error Resume Next
	    Glf_199 = GetPlayerState("multiball_lock_locked_balls") = 2
	If Err Then Glf_199 = False
End Function
Function Glf_200(args)
	On Error Resume Next
	    Glf_200 = glf_dispatch_current_kwargs("total_balls_locked") = 1
	If Err Then Glf_200 = False
End Function
Function Glf_201(args)
	On Error Resume Next
	    Glf_201 = glf_dispatch_current_kwargs("total_balls_locked") = 2
	If Err Then Glf_201 = False
End Function
Function Glf_202(args)
	On Error Resume Next
	    Glf_202 = GetPlayerState("shot_bonus_lane_7") = 0
	If Err Then Glf_202 = False
End Function
Function Glf_203(args)
	On Error Resume Next
	    Glf_203 = GetPlayerState("shot_bonus_lane_7") = 1
	If Err Then Glf_203 = False
End Function
Function Glf_204(args)
	On Error Resume Next
	    Glf_204 = GetPlayerState("shot_bonus_lane_8") = 0
	If Err Then Glf_204 = False
End Function
Function Glf_205(args)
	On Error Resume Next
	    Glf_205 = GetPlayerState("shot_bonus_lane_8") = 1
	If Err Then Glf_205 = False
End Function
Function Glf_206(args)
	On Error Resume Next
	    Glf_206 = GetPlayerState("shot_bonus_lane_9") = 0
	If Err Then Glf_206 = False
End Function
Function Glf_207(args)
	On Error Resume Next
	    Glf_207 = GetPlayerState("shot_bonus_lane_9") = 1
	If Err Then Glf_207 = False
End Function
Function Glf_208(args)
	On Error Resume Next
	    Glf_208 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_208 = False
End Function
Function Glf_209(args)
	On Error Resume Next
	    Glf_209 = GetPlayerState("shot_logan_qualify") = 2
	If Err Then Glf_209 = False
End Function
Function Glf_210(args)
	On Error Resume Next
	    Glf_210 = GetPlayerState("shot_logan_qualify") = 3 and glf_ball_holds("captive_ramp_kicker_hold").GetValue("balls_held") = 0
	If Err Then Glf_210 = False
End Function
Function Glf_211(args)
	On Error Resume Next
	    Glf_211 = glf_ball_holds("captive_ramp_kicker_hold").GetValue("balls_held") = 1
	If Err Then Glf_211 = False
End Function
Function Glf_212(args)
	On Error Resume Next
	    Glf_212 = glf_ball_holds("captive_ramp_kicker_hold").GetValue("balls_held") = 1
	If Err Then Glf_212 = False
End Function
Function Glf_213(args)
	On Error Resume Next
	    Glf_213 = GetPlayerState("logan_cooldown_active") = 0
	If Err Then Glf_213 = False
End Function
Function Glf_214(args)
	Glf_214 = 2
End Function
Function Glf_215(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_215 = kwargs
	If Err Then Glf_215 = Null
End Function
Function Glf_216(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_216 = kwargs
	If Err Then Glf_216 = Null
End Function
Function Glf_217(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_217 = kwargs
	If Err Then Glf_217 = Null
End Function
Function Glf_218(args)
	On Error Resume Next
	    Glf_218 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_218 = False
End Function
Function Glf_219(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_219 = kwargs
	If Err Then Glf_219 = Null
End Function
Function Glf_220(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_220 = kwargs
	If Err Then Glf_220 = Null
End Function
Function Glf_221(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_221 = kwargs
	If Err Then Glf_221 = Null
End Function
Function Glf_222(args)
	On Error Resume Next
	    Glf_222 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_222 = False
End Function
Function Glf_223(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_223 = kwargs
	If Err Then Glf_223 = Null
End Function
Function Glf_224(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_224 = kwargs
	If Err Then Glf_224 = Null
End Function
Function Glf_225(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_225 = kwargs
	If Err Then Glf_225 = Null
End Function
Function Glf_226(args)
	On Error Resume Next
	    Glf_226 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_226 = False
End Function
Function Glf_227(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_227 = kwargs
	If Err Then Glf_227 = Null
End Function
Function Glf_228(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_228 = kwargs
	If Err Then Glf_228 = Null
End Function
Function Glf_229(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_229 = kwargs
	If Err Then Glf_229 = Null
End Function
Function Glf_230(args)
	On Error Resume Next
	    Glf_230 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_230 = False
End Function
Function Glf_231(args)
	On Error Resume Next
	    Glf_231 = glf_dispatch_current_kwargs("light") < 3
	If Err Then Glf_231 = False
End Function
Function Glf_232(args)
	On Error Resume Next
	    Glf_232 = glf_dispatch_current_kwargs("light") < 3
	If Err Then Glf_232 = False
End Function
Function Glf_233(args)
	On Error Resume Next
	    Glf_233 = glf_dispatch_current_kwargs("light") < 3
	If Err Then Glf_233 = False
End Function
Function Glf_234(args)
	On Error Resume Next
	    Glf_234 = glf_dispatch_current_kwargs("light") < 3
	If Err Then Glf_234 = False
End Function
Function Glf_235(args)
	On Error Resume Next
	    Glf_235 = glf_dispatch_current_kwargs("light") = 1
	If Err Then Glf_235 = False
End Function
Function Glf_236(args)
	On Error Resume Next
	    Glf_236 = glf_dispatch_current_kwargs("light") = 2
	If Err Then Glf_236 = False
End Function
Function Glf_237(args)
	On Error Resume Next
	    Glf_237 = glf_dispatch_current_kwargs("light") = 1
	If Err Then Glf_237 = False
End Function
Function Glf_238(args)
	On Error Resume Next
	    Glf_238 = glf_dispatch_current_kwargs("light") = 2
	If Err Then Glf_238 = False
End Function
Function Glf_239(args)
	On Error Resume Next
	    Glf_239 = glf_dispatch_current_kwargs("light") = 1
	If Err Then Glf_239 = False
End Function
Function Glf_240(args)
	On Error Resume Next
	    Glf_240 = glf_dispatch_current_kwargs("light") = 2
	If Err Then Glf_240 = False
End Function
Function Glf_241(args)
	On Error Resume Next
	    Glf_241 = glf_dispatch_current_kwargs("light") = 1
	If Err Then Glf_241 = False
End Function
Function Glf_242(args)
	On Error Resume Next
	    Glf_242 = glf_dispatch_current_kwargs("light") = 2
	If Err Then Glf_242 = False
End Function
Function Glf_243(args)
	On Error Resume Next
	    Glf_243 = glf_timers("hurryup").GetValue("ticks") <> 0
	If Err Then Glf_243 = False
End Function
Function Glf_244(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 500000 + glf_timers("hurryup").GetValue("ticks") * 7500
	Set Glf_244 = kwargs
	If Err Then Glf_244 = Null
End Function
Function Glf_245(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 500000 + glf_timers("hurryup").GetValue("ticks") * 7500
	Set Glf_245 = kwargs
	If Err Then Glf_245 = Null
End Function
Function Glf_246(args)
	Glf_246 = "HURRY-UP"
End Function
Function Glf_247(args)
	Glf_247 = "SHOOT LUKE'S TO COLLECT JACKPOT"
End Function
Function Glf_248(args)
	Glf_248 = 500000 + glf_dispatch_current_kwargs("ticks") * 7500
End Function
Function Glf_249(args)
	On Error Resume Next
	    Glf_249 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_249 = False
End Function
Function Glf_250(args)
	On Error Resume Next
	    Glf_250 = GetPlayerState("ball_just_started") = 1
	If Err Then Glf_250 = False
End Function
Function Glf_251(args)
	On Error Resume Next
	    Glf_251 = GetPlayerState("ball_just_started") = 0
	If Err Then Glf_251 = False
End Function
Function Glf_252(args)
	On Error Resume Next
	    Glf_252 = GetPlayerState("ss1_started") = 1
	If Err Then Glf_252 = False
End Function
Function Glf_253(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 750000
	Set Glf_253 = kwargs
	If Err Then Glf_253 = Null
End Function
Function Glf_254(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 200000
	Set Glf_254 = kwargs
	If Err Then Glf_254 = Null
End Function
Function Glf_255(args)
	On Error Resume Next
	    Glf_255 = GetPlayerState("shot_ss_bonus_lane_7") = 1
	If Err Then Glf_255 = False
End Function
Function Glf_256(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 400000
	Set Glf_256 = kwargs
	If Err Then Glf_256 = Null
End Function
Function Glf_257(args)
	On Error Resume Next
	    Glf_257 = GetPlayerState("shot_ss_bonus_lane_8") = 1
	If Err Then Glf_257 = False
End Function
Function Glf_258(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 400000
	Set Glf_258 = kwargs
	If Err Then Glf_258 = Null
End Function
Function Glf_259(args)
	On Error Resume Next
	    Glf_259 = GetPlayerState("shot_ss_bonus_lane_9") = 1
	If Err Then Glf_259 = False
End Function
Function Glf_260(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 400000
	Set Glf_260 = kwargs
	If Err Then Glf_260 = Null
End Function
Function Glf_261(args)
	On Error Resume Next
	    Glf_261 = GetPlayerState("shot_bonus_lane_7") = 0
	If Err Then Glf_261 = False
End Function
Function Glf_262(args)
	On Error Resume Next
	    Glf_262 = GetPlayerState("shot_bonus_lane_8") = 0
	If Err Then Glf_262 = False
End Function
Function Glf_263(args)
	On Error Resume Next
	    Glf_263 = GetPlayerState("shot_bonus_lane_9") = 0
	If Err Then Glf_263 = False
End Function
Function Glf_264(args)
	On Error Resume Next
	    Glf_264 = GetPlayerState("shot_logan_light") = 1
	If Err Then Glf_264 = False
End Function
Function Glf_265(args)
	On Error Resume Next
	    Glf_265 = GetPlayerState("shot_dance_marathon_minigame") <> 1 and GetPlayerState("shot_town_meeting_minigame") <> 1 and GetPlayerState("shot_dinner_minigame") <> 1 and GetPlayerState("shot_kims_antiques_minigame") <> 1 and GetPlayerState("shot_lbtb_minigame") <> 1 and GetPlayerState("shot_fd_punch_minigame") <> 1
	If Err Then Glf_265 = False
End Function
Function Glf_266(args)
	On Error Resume Next
	    Glf_266 = GetPlayerState("shot_dance_marathon_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_266 = False
End Function
Function Glf_267(args)
	On Error Resume Next
	    Glf_267 = GetPlayerState("shot_dance_marathon_minigame") = 1
	If Err Then Glf_267 = False
End Function
Function Glf_268(args)
	On Error Resume Next
	    Glf_268 = GetPlayerState("shot_town_meeting_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_268 = False
End Function
Function Glf_269(args)
	On Error Resume Next
	    Glf_269 = GetPlayerState("shot_town_meeting_minigame") = 1
	If Err Then Glf_269 = False
End Function
Function Glf_270(args)
	On Error Resume Next
	    Glf_270 = GetPlayerState("shot_dinner_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_270 = False
End Function
Function Glf_271(args)
	On Error Resume Next
	    Glf_271 = GetPlayerState("shot_dinner_minigame") = 1
	If Err Then Glf_271 = False
End Function
Function Glf_272(args)
	On Error Resume Next
	    Glf_272 = GetPlayerState("shot_kims_antiques_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_272 = False
End Function
Function Glf_273(args)
	On Error Resume Next
	    Glf_273 = GetPlayerState("shot_kims_antiques_minigame") = 1
	If Err Then Glf_273 = False
End Function
Function Glf_274(args)
	On Error Resume Next
	    Glf_274 = GetPlayerState("shot_lbtb_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_274 = False
End Function
Function Glf_275(args)
	On Error Resume Next
	    Glf_275 = GetPlayerState("shot_lbtb_minigame") = 1
	If Err Then Glf_275 = False
End Function
Function Glf_276(args)
	On Error Resume Next
	    Glf_276 = GetPlayerState("shot_fd_punch_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_276 = False
End Function
Function Glf_277(args)
	On Error Resume Next
	    Glf_277 = GetPlayerState("shot_fd_punch_minigame") = 1
	If Err Then Glf_277 = False
End Function
Function Glf_278(args)
	On Error Resume Next
	    Glf_278 = glf_modes("eob_bonus").GetValue("active") = False
	If Err Then Glf_278 = False
End Function
Function Glf_279(args)
	On Error Resume Next
	    Glf_279 = GetPlayerState("shot_dance_marathon_minigame") = 0
	If Err Then Glf_279 = False
End Function
Function Glf_280(args)
	On Error Resume Next
	    Glf_280 = GetPlayerState("shot_town_meeting_minigame") = 0
	If Err Then Glf_280 = False
End Function
Function Glf_281(args)
	On Error Resume Next
	    Glf_281 = GetPlayerState("shot_dinner_minigame") = 0
	If Err Then Glf_281 = False
End Function
Function Glf_282(args)
	On Error Resume Next
	    Glf_282 = GetPlayerState("shot_kims_antiques_minigame") = 0
	If Err Then Glf_282 = False
End Function
Function Glf_283(args)
	On Error Resume Next
	    Glf_283 = GetPlayerState("shot_lbtb_minigame") = 0
	If Err Then Glf_283 = False
End Function
Function Glf_284(args)
	On Error Resume Next
	    Glf_284 = GetPlayerState("shot_fd_punch_minigame") = 0
	If Err Then Glf_284 = False
End Function
Function Glf_285(args)
	On Error Resume Next
	    Glf_285 = GetPlayerState("extra_balls") = 0
	If Err Then Glf_285 = False
End Function
Function Glf_286(args)
	On Error Resume Next
	    Glf_286 = GetPlayerState("extra_balls") > 0
	If Err Then Glf_286 = False
End Function
Function Glf_287(args)
	On Error Resume Next
	    Glf_287 = GetPlayerState("shot_eb_ready") = 1
	If Err Then Glf_287 = False
End Function
Function Glf_288(args)
	Glf_288 = 3
End Function
Function Glf_289(args)
	On Error Resume Next
	    Glf_289 = GetPlayerState("extra_ball_eb_awarded") < 3
	If Err Then Glf_289 = False
End Function
Function Glf_290(args)
	On Error Resume Next
	    Glf_290 = GetPlayerState("shot_mystery_ready")=0
	If Err Then Glf_290 = False
End Function
Function Glf_291(args)
	On Error Resume Next
	    Glf_291 = GetPlayerState("shot_mystery_ready")=1 and glf_modes("jd_multiball").GetValue("active")=False and glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_291 = False
End Function
Function Glf_292(args)
	On Error Resume Next
	    Glf_292 = devices.timers.mystery_show.ticks = 1
	If Err Then Glf_292 = False
End Function
Function Glf_293(args)
	On Error Resume Next
	    Glf_293 = glf_modes("jd_multiball").GetValue("active")=False
	If Err Then Glf_293 = False
End Function
Function Glf_294(args)
	On Error Resume Next
	    Glf_294 = GetPlayerState("mystery_award") = 0
	If Err Then Glf_294 = False
End Function
Function Glf_295(args)
	On Error Resume Next
	    Glf_295 = GetPlayerState("mystery_award") = 1
	If Err Then Glf_295 = False
End Function
Function Glf_296(args)
	On Error Resume Next
	    Glf_296 = GetPlayerState("mystery_award") = 2
	If Err Then Glf_296 = False
End Function
Function Glf_297(args)
	On Error Resume Next
	    Glf_297 = GetPlayerState("mystery_award") = 3
	If Err Then Glf_297 = False
End Function
Function Glf_298(args)
	On Error Resume Next
	    Glf_298 = GetPlayerState("mystery_award") = 4
	If Err Then Glf_298 = False
End Function
Function Glf_299(args)
	On Error Resume Next
	    Glf_299 = GetPlayerState("mystery_award") = 5
	If Err Then Glf_299 = False
End Function
Function Glf_300(args)
	On Error Resume Next
	    Glf_300 = GetPlayerState("mystery_award") = 6
	If Err Then Glf_300 = False
End Function
Function Glf_301(args)
	On Error Resume Next
	    Glf_301 = GetPlayerState("mystery_award") = 7
	If Err Then Glf_301 = False
End Function
Function Glf_302(args)
	Glf_302 = 10000
End Function
Function Glf_303(args)
	Glf_303 = 6
End Function
Function Glf_304(args)
	Glf_304 = 7
End Function
Function Glf_305(args)
	On Error Resume Next
	    Glf_305 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_305 = False
End Function
Function Glf_306(args)
	On Error Resume Next
	    Glf_306 = GetPlayerState("shot_ramp") = 1
	If Err Then Glf_306 = False
End Function
Function Glf_307(args)
	On Error Resume Next
	    Glf_307 = glf_timers("dm_intro_delay").GetValue("ticks") = 27
	If Err Then Glf_307 = False
End Function
Function Glf_308(args)
	Glf_308 = 500000
End Function
Function Glf_309(args)
	Glf_309 = 100000
End Function
Function Glf_310(args)
	Glf_310 = GetPlayerState("mode_dance_marathon_score")
End Function
Function Glf_311(args)
	Glf_311 = "HIT FLASHING SHOTS TO SCORE"
End Function
Function Glf_312(args)
	Glf_312 = glf_dispatch_current_kwargs("ticks_remaining")
End Function
Function Glf_313(args)
	Glf_313 = 250000
End Function
Function Glf_314(args)
	Glf_314 = 1250000
End Function
Function Glf_315(args)
	Glf_315 = 28
End Function
Function Glf_316(args)
	On Error Resume Next
	    Glf_316 = glf_timers("dm_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_316 = False
End Function
Function Glf_317(args)
	Glf_317 = 15
End Function
Function Glf_318(args)
	Glf_318 = 8
End Function
Function Glf_319(args)
	On Error Resume Next
	    Glf_319 = glf_timers("town_meeting_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_319 = False
End Function
Function Glf_320(args)
	Glf_320 = 20
End Function
Function Glf_321(args)
	Glf_321 = GetPlayerState("mode_town_meeting_score")
End Function
Function Glf_322(args)
	Glf_322 = 750000
End Function
Function Glf_323(args)
	Glf_323 = GetPlayerState("mode_dinner_score")
End Function
Function Glf_324(args)
	Glf_324 = "SHOOT ORBITS TO SCORE"
End Function
Function Glf_325(args)
	On Error Resume Next
	    Glf_325 = glf_timers("fd_punch_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_325 = False
End Function
Function Glf_326(args)
	Glf_326 = GetPlayerState("mode_fd_punch_score")
End Function
Function Glf_327(args)
	Glf_327 = "SHOOT LUKE'S OR MANSION TO SCORE"
End Function
Function Glf_328(args)
	Glf_328 = GetPlayerState("mode_kims_antiques_score")
End Function
Function Glf_329(args)
	Glf_329 = "AVOID MISS KIM (SOLID LIGHT)"
End Function
Function Glf_330(args)
	On Error Resume Next
	    Glf_330 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_330 = False
End Function
Function Glf_331(args)
	On Error Resume Next
	    Glf_331 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_331 = False
End Function
Function Glf_332(args)
	On Error Resume Next
	    Glf_332 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_332 = False
End Function
Function Glf_333(args)
	On Error Resume Next
	    Glf_333 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_333 = False
End Function
Function Glf_334(args)
	On Error Resume Next
	    Glf_334 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_334 = False
End Function
Function Glf_335(args)
	On Error Resume Next
	    Glf_335 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_335 = False
End Function
Function Glf_336(args)
	Glf_336 = 11.5
End Function
Function Glf_337(args)
	On Error Resume Next
	    Glf_337 = glf_timers("lbtb_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_337 = False
End Function
Function Glf_338(args)
	On Error Resume Next
	    Glf_338 = glf_drop_targets("drop3").GetValue("state") = 1
	If Err Then Glf_338 = False
End Function
Function Glf_339(args)
	On Error Resume Next
	    Glf_339 = glf_drop_targets("drop4").GetValue("state") = 1
	If Err Then Glf_339 = False
End Function
Function Glf_340(args)
	On Error Resume Next
	    Glf_340 = glf_drop_targets("drop5").GetValue("state") = 1
	If Err Then Glf_340 = False
End Function
Function Glf_341(args)
	On Error Resume Next
	    Glf_341 = glf_drop_targets("drop6").GetValue("state") = 1
	If Err Then Glf_341 = False
End Function
Function Glf_342(args)
	On Error Resume Next
	    Glf_342 = glf_drop_targets("drop7").GetValue("state") = 1
	If Err Then Glf_342 = False
End Function
Function Glf_343(args)
	On Error Resume Next
	    Glf_343 = glf_drop_targets("drop8").GetValue("state") = 1
	If Err Then Glf_343 = False
End Function
Function Glf_344(args)
	Glf_344 = "LUKE BREAKS THE BELLS!"
End Function
Function Glf_345(args)
	Glf_345 = GetPlayerState("mode_lbtb_score")
End Function
Function Glf_346(args)
	Glf_346 = "BREAK BELLS TO SCORE"
End Function
Function Glf_347(args)
	Glf_347 = "JESS VS. DEAN: TO THE DEATH"
End Function
Function Glf_348(args)
	Glf_348 = GetPlayerState("mode_jdmb_score")
End Function
Function Glf_349(args)
	Glf_349 = "TEAM JESS: LEFT RAMP - TEAM LOGAN: RIGHT RAMP"
End Function
Function Glf_350(args)
	Glf_350 = 4000000
End Function
Function Glf_351(args)
	Glf_351 = 7500000
End Function
Function Glf_352(args)
	On Error Resume Next
	    Glf_352 = GetPlayerState("mode_llmb_score")>=2500000
	If Err Then Glf_352 = False
End Function
Function Glf_353(args)
	On Error Resume Next
	    Glf_353 = GetPlayerState("shot_win_logan_light")=0
	If Err Then Glf_353 = False
End Function
Function Glf_354(args)
	On Error Resume Next
	    Glf_354 = GetPlayerState("shot_win_logan_light")=1
	If Err Then Glf_354 = False
End Function
Function Glf_355(args)
	Glf_355 = GetPlayerState("mode_llmb_score")
End Function
Function Glf_356(args)
	Glf_356 = "HIT BUMPERS TO BASH LOGAN"
End Function
Function Glf_357(args)
	Glf_357 = "LOCK-AWAY LOGAN IN THE SCOOP"
End Function
Function Glf_358(args)
	Glf_358 = 50000
End Function
Function Glf_359(args)
	Glf_359 = 1000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_360(args)
	Glf_360 = 1000
End Function
Function Glf_361(args)
	Glf_361 = 2500 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_362(args)
	Glf_362 = 2500
End Function
Function Glf_363(args)
	Glf_363 = 5000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_364(args)
	Glf_364 = 1500 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_365(args)
	Glf_365 = 1500
End Function
Function Glf_366(args)
	Glf_366 = 25000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_367(args)
	Glf_367 = 25000
End Function
Function Glf_368(args)
	Glf_368 = 12500 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_369(args)
	Glf_369 = 12500
End Function
Function Glf_370(args)
	Glf_370 = 20000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_371(args)
	Glf_371 = 10000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_372(args)
	Glf_372 = 50000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_373(args)
	Glf_373 = 150000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_374(args)
	Glf_374 = 150000
End Function
Function Glf_375(args)
	Glf_375 = 100000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_376(args)
	Glf_376 = 250000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_377(args)
	Glf_377 = 750000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_378(args)
	Glf_378 = 200000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_379(args)
	Glf_379 = 200000
End Function
Function Glf_380(args)
	Glf_380 = 400000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_381(args)
	Glf_381 = 400000
End Function
Function Glf_382(args)
	Glf_382 = 1000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_383(args)
	Glf_383 = 1000000
End Function
Function Glf_384(args)
	Glf_384 = 2500000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_385(args)
	Glf_385 = 2500000
End Function
Function Glf_386(args)
	Glf_386 = 500000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_387(args)
	Glf_387 = 2000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_388(args)
	Glf_388 = 2000000
End Function
Function Glf_389(args)
	Glf_389 = 1250000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_390(args)
	Glf_390 = 4000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_391(args)
	Glf_391 = 7500000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_392(args)
	Glf_392 = 5000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_393(args)
	Glf_393 = 5000000
End Function
Function Glf_394(args)
	Glf_394 = 100000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_395(args)
	Glf_395 = 100000000
End Function
Function Glf_396(args)
	Glf_396 = 2000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_397(args)
	Glf_397 = 7500 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_398(args)
	Glf_398 = 7500
End Function
Function Glf_399(args)
	Glf_399 = glf_dispatch_current_kwargs("points") * GetPlayerState("scoring_multiplier")
End Function
Function Glf_400(args)
	Glf_400 = glf_dispatch_current_kwargs("points")
End Function
Dim glf_gi006_lmarr : glf_gi006_lmarr = Array(lm_gi006_plastics)
glf_lightMaps.Add "gi006", glf_gi006_lmarr
Dim glf_gi007_lmarr : glf_gi007_lmarr = Array(lm_gi007_plastics)
glf_lightMaps.Add "gi007", glf_gi007_lmarr
Dim glf_gi008_lmarr : glf_gi008_lmarr = Array()
glf_lightMaps.Add "gi008", glf_gi008_lmarr
Dim glf_gi009_lmarr : glf_gi009_lmarr = Array()
glf_lightMaps.Add "gi009", glf_gi009_lmarr
Dim glf_gi010_lmarr : glf_gi010_lmarr = Array(lm_gi010_plastics)
glf_lightMaps.Add "gi010", glf_gi010_lmarr
Dim glf_gi011_lmarr : glf_gi011_lmarr = Array(lm_gi011_plastics)
glf_lightMaps.Add "gi011", glf_gi011_lmarr
Dim glf_gi012_lmarr : glf_gi012_lmarr = Array(lm_gi012_plastics)
glf_lightMaps.Add "gi012", glf_gi012_lmarr
Dim glf_gi013_lmarr : glf_gi013_lmarr = Array(lm_gi013_plastics)
glf_lightMaps.Add "gi013", glf_gi013_lmarr
Dim glf_gi014_lmarr : glf_gi014_lmarr = Array(lm_gi014_plastics)
glf_lightMaps.Add "gi014", glf_gi014_lmarr
Dim glf_gi015_lmarr : glf_gi015_lmarr = Array(lm_gi015_plastics)
glf_lightMaps.Add "gi015", glf_gi015_lmarr
Dim glf_gi016_lmarr : glf_gi016_lmarr = Array(lm_gi016_plastics)
glf_lightMaps.Add "gi016", glf_gi016_lmarr
Dim glf_gi017_lmarr : glf_gi017_lmarr = Array(lm_gi017_plastics)
glf_lightMaps.Add "gi017", glf_gi017_lmarr
Dim glf_gi018_lmarr : glf_gi018_lmarr = Array(lm_gi018_plastics)
glf_lightMaps.Add "gi018", glf_gi018_lmarr
Dim glf_gi019_lmarr : glf_gi019_lmarr = Array(lm_gi019_plastics)
glf_lightMaps.Add "gi019", glf_gi019_lmarr
Dim glf_gi020_lmarr : glf_gi020_lmarr = Array(lm_gi020_plastics)
glf_lightMaps.Add "gi020", glf_gi020_lmarr
Dim glf_gi021_lmarr : glf_gi021_lmarr = Array(lm_gi021_plastics)
glf_lightMaps.Add "gi021", glf_gi021_lmarr
Dim glf_gi022_lmarr : glf_gi022_lmarr = Array(lm_gi022_plastics)
glf_lightMaps.Add "gi022", glf_gi022_lmarr
Dim glf_gi023_lmarr : glf_gi023_lmarr = Array(lm_gi023_plastics)
glf_lightMaps.Add "gi023", glf_gi023_lmarr
Dim glf_gi024_lmarr : glf_gi024_lmarr = Array(lm_gi024_plastics)
glf_lightMaps.Add "gi024", glf_gi024_lmarr
Dim glf_gi050_lmarr : glf_gi050_lmarr = Array(lm_gi050_plastics)
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
Dim glf_l21_lmarr : glf_l21_lmarr = Array()
glf_lightMaps.Add "l21", glf_l21_lmarr
Dim glf_l22_lmarr : glf_l22_lmarr = Array()
glf_lightMaps.Add "l22", glf_l22_lmarr
Dim glf_l23_lmarr : glf_l23_lmarr = Array()
glf_lightMaps.Add "l23", glf_l23_lmarr
Dim glf_l24_lmarr : glf_l24_lmarr = Array()
glf_lightMaps.Add "l24", glf_l24_lmarr
Dim glf_l25_lmarr : glf_l25_lmarr = Array()
glf_lightMaps.Add "l25", glf_l25_lmarr
Dim glf_l27_lmarr : glf_l27_lmarr = Array()
glf_lightMaps.Add "l27", glf_l27_lmarr
Dim glf_l31_lmarr : glf_l31_lmarr = Array()
glf_lightMaps.Add "l31", glf_l31_lmarr
Dim glf_l32_lmarr : glf_l32_lmarr = Array()
glf_lightMaps.Add "l32", glf_l32_lmarr
Dim glf_l33_lmarr : glf_l33_lmarr = Array()
glf_lightMaps.Add "l33", glf_l33_lmarr
Dim glf_l34_lmarr : glf_l34_lmarr = Array()
glf_lightMaps.Add "l34", glf_l34_lmarr
Dim glf_l26_lmarr : glf_l26_lmarr = Array()
glf_lightMaps.Add "l26", glf_l26_lmarr
Dim glf_l7_lmarr : glf_l7_lmarr = Array()
glf_lightMaps.Add "l7", glf_l7_lmarr
Dim glf_l57_lmarr : glf_l57_lmarr = Array()
glf_lightMaps.Add "l57", glf_l57_lmarr
Dim glf_gi026_lmarr : glf_gi026_lmarr = Array(lm_gi026_plastics)
glf_lightMaps.Add "gi026", glf_gi026_lmarr
Dim glf_l58_lmarr : glf_l58_lmarr = Array()
glf_lightMaps.Add "l58", glf_l58_lmarr
Dim glf_l60_lmarr : glf_l60_lmarr = Array()
glf_lightMaps.Add "l60", glf_l60_lmarr
Dim glf_l59_lmarr : glf_l59_lmarr = Array()
glf_lightMaps.Add "l59", glf_l59_lmarr
Dim glf_l61_lmarr : glf_l61_lmarr = Array()
glf_lightMaps.Add "l61", glf_l61_lmarr
Dim glf_l62_lmarr : glf_l62_lmarr = Array()
glf_lightMaps.Add "l62", glf_l62_lmarr
Dim glf_l63_lmarr : glf_l63_lmarr = Array()
glf_lightMaps.Add "l63", glf_l63_lmarr
Dim glf_l64_lmarr : glf_l64_lmarr = Array()
glf_lightMaps.Add "l64", glf_l64_lmarr
Dim glf_l65_lmarr : glf_l65_lmarr = Array()
glf_lightMaps.Add "l65", glf_l65_lmarr
Dim glf_l66_lmarr : glf_l66_lmarr = Array()
glf_lightMaps.Add "l66", glf_l66_lmarr
Dim glf_l67_lmarr : glf_l67_lmarr = Array()
glf_lightMaps.Add "l67", glf_l67_lmarr
Dim glf_l68_lmarr : glf_l68_lmarr = Array()
glf_lightMaps.Add "l68", glf_l68_lmarr
Dim glf_l69_lmarr : glf_l69_lmarr = Array()
glf_lightMaps.Add "l69", glf_l69_lmarr
Dim glf_l70_lmarr : glf_l70_lmarr = Array()
glf_lightMaps.Add "l70", glf_l70_lmarr
Dim glf_l71_lmarr : glf_l71_lmarr = Array()
glf_lightMaps.Add "l71", glf_l71_lmarr
Dim glf_FL1_lmarr : glf_FL1_lmarr = Array(f_fl1_,p_fl1_)
glf_lightMaps.Add "FL1", glf_FL1_lmarr
Dim glf_FL2_lmarr : glf_FL2_lmarr = Array(f_fl2_,p_fl2_)
glf_lightMaps.Add "FL2", glf_FL2_lmarr
Dim glf_FL3_lmarr : glf_FL3_lmarr = Array(f_fl3_,p_fl3_)
glf_lightMaps.Add "FL3", glf_FL3_lmarr
Dim glf_FL4_lmarr : glf_FL4_lmarr = Array(f_fl4_,p_fl4_)
glf_lightMaps.Add "FL4", glf_FL4_lmarr
Dim glf_FL5_lmarr : glf_FL5_lmarr = Array(f_fl5_,p_fl5_)
glf_lightMaps.Add "FL5", glf_FL5_lmarr
Dim glf_SkillshotLight_lmarr : glf_SkillshotLight_lmarr = Array()
glf_lightMaps.Add "SkillshotLight", glf_SkillshotLight_lmarr
Dim glf_l72_lmarr : glf_l72_lmarr = Array()
glf_lightMaps.Add "l72", glf_l72_lmarr
Dim glf_l28_lmarr : glf_l28_lmarr = Array()
glf_lightMaps.Add "l28", glf_l28_lmarr
Dim glf_bg_logo_lmarr : glf_bg_logo_lmarr = Array()
glf_lightMaps.Add "bg_logo", glf_bg_logo_lmarr
Dim glf_bg_flash_lower_left_lmarr : glf_bg_flash_lower_left_lmarr = Array()
glf_lightMaps.Add "bg_flash_lower_left", glf_bg_flash_lower_left_lmarr
Dim glf_bg_flash_upper_left_lmarr : glf_bg_flash_upper_left_lmarr = Array()
glf_lightMaps.Add "bg_flash_upper_left", glf_bg_flash_upper_left_lmarr
Dim glf_bg_flash_upper_right_lmarr : glf_bg_flash_upper_right_lmarr = Array()
glf_lightMaps.Add "bg_flash_upper_right", glf_bg_flash_upper_right_lmarr
Dim glf_bg_flash_lower_right_lmarr : glf_bg_flash_lower_right_lmarr = Array()
glf_lightMaps.Add "bg_flash_lower_right", glf_bg_flash_lower_right_lmarr
Dim glf_gi025_lmarr : glf_gi025_lmarr = Array(lm_gi025_plastics)
glf_lightMaps.Add "gi025", glf_gi025_lmarr
Dim glf_gi027_lmarr : glf_gi027_lmarr = Array(lm_gi027_plastics)
glf_lightMaps.Add "gi027", glf_gi027_lmarr
Dim glf_Light001_lmarr : glf_Light001_lmarr = Array(lm_light001_backwall)
glf_lightMaps.Add "Light001", glf_Light001_lmarr
Dim glf_Light002_lmarr : glf_Light002_lmarr = Array(lm_light002_backwall)
glf_lightMaps.Add "Light002", glf_Light002_lmarr
Dim glf_Light003_lmarr : glf_Light003_lmarr = Array(lm_light003_backwall)
glf_lightMaps.Add "Light003", glf_Light003_lmarr
Dim glf_Light004_lmarr : glf_Light004_lmarr = Array(lm_light004_backwall)
glf_lightMaps.Add "Light004", glf_Light004_lmarr
Dim glf_Light005_lmarr : glf_Light005_lmarr = Array(lm_light005_backwall)
glf_lightMaps.Add "Light005", glf_Light005_lmarr
Dim glf_Light006_lmarr : glf_Light006_lmarr = Array(lm_light006_backwall)
glf_lightMaps.Add "Light006", glf_Light006_lmarr
Dim glf_Light007_lmarr : glf_Light007_lmarr = Array(lm_light007_backwall)
glf_lightMaps.Add "Light007", glf_Light007_lmarr
Dim glf_Light008_lmarr : glf_Light008_lmarr = Array(lm_light008_backwall)
glf_lightMaps.Add "Light008", glf_Light008_lmarr
Dim glf_Light009_lmarr : glf_Light009_lmarr = Array(lm_light009_backwall)
glf_lightMaps.Add "Light009", glf_Light009_lmarr
Dim glf_Light010_lmarr : glf_Light010_lmarr = Array(lm_light010_backwall)
glf_lightMaps.Add "Light010", glf_Light010_lmarr
Dim glf_Light011_lmarr : glf_Light011_lmarr = Array(lm_light011_backwall)
glf_lightMaps.Add "Light011", glf_Light011_lmarr
Dim glf_Light012_lmarr : glf_Light012_lmarr = Array(lm_light012_backwall)
glf_lightMaps.Add "Light012", glf_Light012_lmarr

glf_funcRefMap.Add "text_input: {action: ""left""}", "Glf_0"
glf_funcRefMap.Add "text_input: {action: ""right""}", "Glf_1"
glf_funcRefMap.Add "text_input: {action: ""select""}", "Glf_2"
glf_funcRefMap.Add "4000", "Glf_3"
glf_funcRefMap.Add "20000", "Glf_4"
glf_funcRefMap.Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 1}", "Glf_5"
glf_funcRefMap.Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 3}", "Glf_6"
glf_funcRefMap.Add "0", "Glf_7"
glf_funcRefMap.Add "-1", "Glf_8"
glf_funcRefMap.Add "4", "Glf_9"
glf_funcRefMap.Add "check_start_button{machine.credits >= 1 and (machine.game_active == 0 or (machine.num_players < 4 and current_player.ball == 1))}", "Glf_10"
glf_funcRefMap.Add "check_start_button{machine.credits < 1 or (machine.game_active == 1 and (machine.num_players >= 4 or current_player.ball > 1))}", "Glf_11"
glf_funcRefMap.Add "ball_ending{game.tilted == True}", "Glf_12"
glf_funcRefMap.Add "s_captive_ball_active{machine.captive_ball_captive == 0}", "Glf_13"
glf_funcRefMap.Add "ball_drain{machine.captive_ball_captive == 0 and current_player.llmb_shoot_again_active == 0}", "Glf_14"
glf_funcRefMap.Add "1", "Glf_15"
glf_funcRefMap.Add "kwargs.num", "Glf_16"
glf_funcRefMap.Add "player_added{kwargs.num > 1}", "Glf_17"
glf_funcRefMap.Add "player_added{kwargs.num == 2}", "Glf_18"
glf_funcRefMap.Add "player_added{kwargs.num == 3}", "Glf_19"
glf_funcRefMap.Add "player_added{kwargs.num == 4}", "Glf_20"
glf_funcRefMap.Add "10", "Glf_21"
glf_funcRefMap.Add "s_Trigger1_inactive{current_player.ball_just_started == 1}", "Glf_22"
glf_funcRefMap.Add "drop_target_drop1_down{modes.fd_punch.active==False}", "Glf_23"
glf_funcRefMap.Add "timer_base_music_complete{modes.eob_bonus.active == False and modes.dance_marathon.active == False and modes.town_meeting.active == False and modes.dinner.active == False and modes.fd_punch.active == False and modes.kims_antiques.active == False and modes.lbtb.active == False}", "Glf_24"
glf_funcRefMap.Add "200", "Glf_25"
glf_funcRefMap.Add "244", "Glf_26"
glf_funcRefMap.Add "50", "Glf_27"
glf_funcRefMap.Add "36", "Glf_28"
glf_funcRefMap.Add "188", "Glf_29"
glf_funcRefMap.Add "52", "Glf_30"
glf_funcRefMap.Add "234", "Glf_31"
glf_funcRefMap.Add "332", "Glf_32"
glf_funcRefMap.Add "diner_callout{modes.fd_punch.active==False}", "Glf_33"
glf_funcRefMap.Add "grandparents_callout{modes.fd_punch.active==False}", "Glf_34"
glf_funcRefMap.Add "auto_fire_coil_bumper1_activate{modes.ll_multiball.active==False}", "Glf_35"
glf_funcRefMap.Add "auto_fire_coil_bumper5_activate{modes.ll_multiball.active==False}", "Glf_36"
glf_funcRefMap.Add "auto_fire_coil_right_sling_activate{modes.lbtb.active==False}", "Glf_37"
glf_funcRefMap.Add "auto_fire_coil_left_sling_activate{modes.lbtb.active==False}", "Glf_38"
glf_funcRefMap.Add "mode_base_started{machine.num_players > 1 and current_player.number == 1}", "Glf_39"
glf_funcRefMap.Add "mode_base_started{machine.num_players > 1 and current_player.number == 2}", "Glf_40"
glf_funcRefMap.Add "mode_base_started{machine.num_players > 1 and current_player.number == 3}", "Glf_41"
glf_funcRefMap.Add "mode_base_started{machine.num_players > 1 and current_player.number == 4}", "Glf_42"
glf_funcRefMap.Add "15000", "Glf_43"
glf_funcRefMap.Add "5000", "Glf_44"
glf_funcRefMap.Add "3000", "Glf_45"
glf_funcRefMap.Add "2000", "Glf_46"
glf_funcRefMap.Add "game_will_end{machine.game_modes_enabled == 1}", "Glf_47"
glf_funcRefMap.Add "s_right_magna_key_active{current_player.hs_input_ready == 1}", "Glf_48"
glf_funcRefMap.Add "s_plunger_key_active{current_player.hs_input_ready == 1}", "Glf_49"
glf_funcRefMap.Add "s_lockbar_key_active{current_player.hs_input_ready == 1}", "Glf_50"
glf_funcRefMap.Add "s_start_active{current_player.hs_input_ready == 1}", "Glf_51"
glf_funcRefMap.Add "text_inputted.1{machine.high_score_initials_chars == 3}", "Glf_52"
glf_funcRefMap.Add "text_input_high_score_complete:{text: machine.high_score_initials}", "Glf_53"
glf_funcRefMap.Add "text_inputted{machine.high_score_initials_chars < 3}", "Glf_55"
glf_funcRefMap.Add "players[0].score", "Glf_56"
glf_funcRefMap.Add "s_left_flipper_active.2{current_player.hs_input_ready == 1}", "Glf_57"
glf_funcRefMap.Add "s_right_flipper_active.2{current_player.hs_input_ready == 1}", "Glf_58"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 0}", "Glf_59"
glf_funcRefMap.Add "machine.high_score_initials & ""A""", "Glf_60"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 1}", "Glf_61"
glf_funcRefMap.Add "machine.high_score_initials & ""B""", "Glf_62"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 2}", "Glf_63"
glf_funcRefMap.Add "machine.high_score_initials & ""C""", "Glf_64"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 3}", "Glf_65"
glf_funcRefMap.Add "machine.high_score_initials & ""D""", "Glf_66"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 4}", "Glf_67"
glf_funcRefMap.Add "machine.high_score_initials & ""E""", "Glf_68"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 5}", "Glf_69"
glf_funcRefMap.Add "machine.high_score_initials & ""F""", "Glf_70"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 6}", "Glf_71"
glf_funcRefMap.Add "machine.high_score_initials & ""G""", "Glf_72"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 7}", "Glf_73"
glf_funcRefMap.Add "machine.high_score_initials & ""H""", "Glf_74"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 8}", "Glf_75"
glf_funcRefMap.Add "machine.high_score_initials & ""I""", "Glf_76"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 9}", "Glf_77"
glf_funcRefMap.Add "machine.high_score_initials & ""J""", "Glf_78"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 10}", "Glf_79"
glf_funcRefMap.Add "machine.high_score_initials & ""K""", "Glf_80"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 11}", "Glf_81"
glf_funcRefMap.Add "machine.high_score_initials & ""L""", "Glf_82"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 12}", "Glf_83"
glf_funcRefMap.Add "machine.high_score_initials & ""M""", "Glf_84"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 13}", "Glf_85"
glf_funcRefMap.Add "machine.high_score_initials & ""N""", "Glf_86"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 14}", "Glf_87"
glf_funcRefMap.Add "machine.high_score_initials & ""O""", "Glf_88"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 15}", "Glf_89"
glf_funcRefMap.Add "machine.high_score_initials & ""P""", "Glf_90"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 16}", "Glf_91"
glf_funcRefMap.Add "machine.high_score_initials & ""Q""", "Glf_92"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 17}", "Glf_93"
glf_funcRefMap.Add "machine.high_score_initials & ""R""", "Glf_94"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 18}", "Glf_95"
glf_funcRefMap.Add "machine.high_score_initials & ""S""", "Glf_96"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 19}", "Glf_97"
glf_funcRefMap.Add "machine.high_score_initials & ""T""", "Glf_98"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 20}", "Glf_99"
glf_funcRefMap.Add "machine.high_score_initials & ""U""", "Glf_100"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 21}", "Glf_101"
glf_funcRefMap.Add "machine.high_score_initials & ""V""", "Glf_102"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 22}", "Glf_103"
glf_funcRefMap.Add "machine.high_score_initials & ""W""", "Glf_104"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 23}", "Glf_105"
glf_funcRefMap.Add "machine.high_score_initials & ""X""", "Glf_106"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 24}", "Glf_107"
glf_funcRefMap.Add "machine.high_score_initials & ""Y""", "Glf_108"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 25}", "Glf_109"
glf_funcRefMap.Add "machine.high_score_initials & ""Z""", "Glf_110"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 26}", "Glf_111"
glf_funcRefMap.Add "machine.high_score_initials & ""0""", "Glf_112"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 27}", "Glf_113"
glf_funcRefMap.Add "machine.high_score_initials & ""1""", "Glf_114"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 28}", "Glf_115"
glf_funcRefMap.Add "machine.high_score_initials & ""2""", "Glf_116"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 29}", "Glf_117"
glf_funcRefMap.Add "machine.high_score_initials & ""3""", "Glf_118"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 30}", "Glf_119"
glf_funcRefMap.Add "machine.high_score_initials & ""4""", "Glf_120"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 31}", "Glf_121"
glf_funcRefMap.Add "machine.high_score_initials & ""5""", "Glf_122"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 32}", "Glf_123"
glf_funcRefMap.Add "machine.high_score_initials & ""6""", "Glf_124"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 33}", "Glf_125"
glf_funcRefMap.Add "machine.high_score_initials & ""7""", "Glf_126"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 34}", "Glf_127"
glf_funcRefMap.Add "machine.high_score_initials & ""8""", "Glf_128"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 35}", "Glf_129"
glf_funcRefMap.Add "machine.high_score_initials & ""9""", "Glf_130"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 36}", "Glf_131"
glf_funcRefMap.Add "machine.high_score_initials & ""_""", "Glf_132"
glf_funcRefMap.Add """""", "Glf_133"
glf_funcRefMap.Add "{kwargs.player_num}", "Glf_134"
glf_funcRefMap.Add "60", "Glf_135"
glf_funcRefMap.Add "5", "Glf_136"
glf_funcRefMap.Add "ball_ending{game.tilted == False}", "Glf_137"
glf_funcRefMap.Add "score_dynamic_flat:{points:current_player.bonus_total}", "Glf_138"
glf_funcRefMap.Add "play_bonus_show1{current_player.total_switches_hit  > 0 && current_player.bonus_skip == 0}", "Glf_139"
glf_funcRefMap.Add "play_bonus_show1{current_player.total_switches_hit == 0 && current_player.bonus_skip == 0}", "Glf_140"
glf_funcRefMap.Add "play_bonus_show2{current_player.bumper_count        > 0 && current_player.bonus_skip == 0}", "Glf_141"
glf_funcRefMap.Add "play_bonus_show2{current_player.bumper_count       == 0 && current_player.bonus_skip == 0}", "Glf_142"
glf_funcRefMap.Add "play_bonus_show3{current_player.diner_count         > 0 && current_player.bonus_skip == 0}", "Glf_143"
glf_funcRefMap.Add "play_bonus_show3{current_player.diner_count        == 0 && current_player.bonus_skip == 0}", "Glf_144"
glf_funcRefMap.Add "play_bonus_show4{current_player.grandparents_count  > 0 && current_player.bonus_skip == 0}", "Glf_145"
glf_funcRefMap.Add "play_bonus_show4{current_player.grandparents_count == 0 && current_player.bonus_skip == 0}", "Glf_146"
glf_funcRefMap.Add "play_bonus_show5{current_player.spinner_count       > 0 && current_player.bonus_skip == 0}", "Glf_147"
glf_funcRefMap.Add "play_bonus_show5{current_player.spinner_count      == 0 && current_player.bonus_skip == 0}", "Glf_148"
glf_funcRefMap.Add "play_bonus_show6{current_player.mode_llmb_score     > 0 && current_player.bonus_skip == 0}", "Glf_149"
glf_funcRefMap.Add "play_bonus_show6{current_player.mode_llmb_score    == 0 && current_player.bonus_skip == 0}", "Glf_150"
glf_funcRefMap.Add "play_bonus_show7{current_player.mode_jdmb_score     > 0 && current_player.bonus_skip == 0}", "Glf_151"
glf_funcRefMap.Add "play_bonus_show7{current_player.mode_jdmb_score    == 0 && current_player.bonus_skip == 0}", "Glf_152"
glf_funcRefMap.Add "play_bonus_show8{current_player.mode_dance_marathon_score       > 0 && current_player.bonus_skip == 0}", "Glf_153"
glf_funcRefMap.Add "play_bonus_show8{current_player.mode_dance_marathon_score      == 0 && current_player.bonus_skip == 0}", "Glf_154"
glf_funcRefMap.Add "play_bonus_show9{current_player.mode_town_meeting_score       > 0 && current_player.bonus_skip == 0}", "Glf_155"
glf_funcRefMap.Add "play_bonus_show9{current_player.mode_town_meeting_score      == 0 && current_player.bonus_skip == 0}", "Glf_156"
glf_funcRefMap.Add "play_bonus_show10{current_player.mode_lbtb_score     > 0 && current_player.bonus_skip == 0}", "Glf_157"
glf_funcRefMap.Add "play_bonus_show10{current_player.mode_lbtb_score    == 0 && current_player.bonus_skip == 0}", "Glf_158"
glf_funcRefMap.Add "play_bonus_show11{current_player.mode_kims_antiques_score       > 0 && current_player.bonus_skip == 0}", "Glf_159"
glf_funcRefMap.Add "play_bonus_show11{current_player.mode_kims_antiques_score      == 0 && current_player.bonus_skip == 0}", "Glf_160"
glf_funcRefMap.Add "play_bonus_show12{current_player.mode_dinner_score   > 0 && current_player.bonus_skip == 0}", "Glf_161"
glf_funcRefMap.Add "play_bonus_show12{current_player.mode_dinner_score  == 0 && current_player.bonus_skip == 0}", "Glf_162"
glf_funcRefMap.Add "play_bonus_show13{current_player.mode_fd_punch_score    > 0 && current_player.bonus_skip == 0}", "Glf_163"
glf_funcRefMap.Add "play_bonus_show13{current_player.mode_fd_punch_score   == 0 && current_player.bonus_skip == 0}", "Glf_164"
glf_funcRefMap.Add "play_bonus_show14{current_player.bonus_total         > 0 && current_player.bonus_skip == 0}", "Glf_165"
glf_funcRefMap.Add "play_bonus_show14{current_player.bonus_total        == 0 && current_player.bonus_skip == 0}", "Glf_166"
glf_funcRefMap.Add "{current_player.bonus_multiplier * 1000 * current_player.total_switches_hit + current_player.bumper_count * 2000 + current_player.diner_count * 5000 + current_player.grandparents_count * 7500 + current_player.spinner_count * 1000:,}", "Glf_167"
glf_funcRefMap.Add """BONUS "" & current_player.bonus_multiplier & ""x""", "Glf_168"
glf_funcRefMap.Add "{current_player.bonus_multiplier * 1000 * current_player.total_switches_hit:,}", "Glf_169"
glf_funcRefMap.Add """COFFEE COFFEE COFFEE""", "Glf_170"
glf_funcRefMap.Add "current_player.bumper_count & "" CUPS x "" & BonusBumperFactor", "Glf_171"
glf_funcRefMap.Add """LUKE'S DINER""", "Glf_172"
glf_funcRefMap.Add "current_player.diner_count & "" MEALS x "" & BonusDinerFactor", "Glf_173"
glf_funcRefMap.Add """GRANDPARENTS""", "Glf_174"
glf_funcRefMap.Add "current_player.grandparents_count & "" VISITS x "" & BonusGrandparentsFactor", "Glf_175"
glf_funcRefMap.Add """FAST TALKING""", "Glf_176"
glf_funcRefMap.Add "current_player.spinner_count & "" QUIPS x "" & BonusSpinnerFactor", "Glf_177"
glf_funcRefMap.Add """LOCK-AWAY LOGAN""", "Glf_178"
glf_funcRefMap.Add "{current_player.mode_llmb_score:,}", "Glf_179"
glf_funcRefMap.Add """JESS & DEAN: TO THE DEATH""", "Glf_180"
glf_funcRefMap.Add "{current_player.mode_jdmb_score:,}", "Glf_181"
glf_funcRefMap.Add """DANCE MARATHON""", "Glf_182"
glf_funcRefMap.Add "{current_player.mode_dance_marathon_score:,}", "Glf_183"
glf_funcRefMap.Add """TOWN MEETING""", "Glf_184"
glf_funcRefMap.Add "{current_player.mode_town_meeting_score:,}", "Glf_185"
glf_funcRefMap.Add """LUKE BREAKS THE BELLS""", "Glf_186"
glf_funcRefMap.Add "{current_player.mode_lbtb_score:,}", "Glf_187"
glf_funcRefMap.Add """KIM'S ANTIQUES""", "Glf_188"
glf_funcRefMap.Add "{current_player.mode_kims_antiques_score:,}", "Glf_189"
glf_funcRefMap.Add """FRIDAY NIGHT DINNER""", "Glf_190"
glf_funcRefMap.Add "{current_player.mode_dinner_score:,}", "Glf_191"
glf_funcRefMap.Add """FOUNDER'S DAY PUNCH""", "Glf_192"
glf_funcRefMap.Add "{current_player.mode_fd_punch_score:,}", "Glf_193"
glf_funcRefMap.Add """TOTAL BONUS""", "Glf_194"
glf_funcRefMap.Add "{current_player.bonus_total:,}", "Glf_195"
glf_funcRefMap.Add "mode_skillshots_stopped{machine.game_modes_enabled == 1}", "Glf_196"
glf_funcRefMap.Add "mode_jd_multiball_qualify_started{current_player.is_lock_qualified == 0}", "Glf_197"
glf_funcRefMap.Add "mode_jd_multiball_qualify_started{current_player.is_lock_qualified == 1}", "Glf_198"
glf_funcRefMap.Add "s_lock3_trigger_active{current_player.multiball_lock_locked_balls == 2}", "Glf_199"
glf_funcRefMap.Add "multiball_lock_multiball_lock_locked_ball{kwargs.total_balls_locked == 1}", "Glf_200"
glf_funcRefMap.Add "multiball_lock_multiball_lock_locked_ball{kwargs.total_balls_locked == 2}", "Glf_201"
glf_funcRefMap.Add "s_sw7_active{current_player.shot_bonus_lane_7 == 0}", "Glf_202"
glf_funcRefMap.Add "s_sw7_active{current_player.shot_bonus_lane_7 == 1}", "Glf_203"
glf_funcRefMap.Add "s_sw8_active{current_player.shot_bonus_lane_8 == 0}", "Glf_204"
glf_funcRefMap.Add "s_sw8_active{current_player.shot_bonus_lane_8 == 1}", "Glf_205"
glf_funcRefMap.Add "s_sw9_active{current_player.shot_bonus_lane_9 == 0}", "Glf_206"
glf_funcRefMap.Add "s_sw9_active{current_player.shot_bonus_lane_9 == 1}", "Glf_207"
glf_funcRefMap.Add "mode_base_started{machine.game_modes_enabled == 1}", "Glf_208"
glf_funcRefMap.Add "mode_ll_multiball_qualify_started{current_player.shot_logan_qualify == 2}", "Glf_209"
glf_funcRefMap.Add "mode_ll_multiball_qualify_started{current_player.shot_logan_qualify == 3 and device.ball_holds.captive_ramp_kicker_hold.balls_held == 0}", "Glf_210"
glf_funcRefMap.Add "mode_ll_multiball_qualify_started{device.ball_holds.captive_ramp_kicker_hold.balls_held == 1}", "Glf_211"
glf_funcRefMap.Add "mode_base_stopping{device.ball_holds.captive_ramp_kicker_hold.balls_held == 1}", "Glf_212"
glf_funcRefMap.Add "s_captive_ball_active{current_player.logan_cooldown_active == 0}", "Glf_213"
glf_funcRefMap.Add "2", "Glf_214"
glf_funcRefMap.Add "sookie_lit:{light:1}", "Glf_215"
glf_funcRefMap.Add "sookie_lit:{light:2}", "Glf_216"
glf_funcRefMap.Add "sookie_lit:{light:3}", "Glf_217"
glf_funcRefMap.Add "sookie_lit{kwargs.light == 3}", "Glf_218"
glf_funcRefMap.Add "kirk_lit:{light:1}", "Glf_219"
glf_funcRefMap.Add "kirk_lit:{light:2}", "Glf_220"
glf_funcRefMap.Add "kirk_lit:{light:3}", "Glf_221"
glf_funcRefMap.Add "kirk_lit{kwargs.light == 3}", "Glf_222"
glf_funcRefMap.Add "lane_lit:{light:1}", "Glf_223"
glf_funcRefMap.Add "lane_lit:{light:2}", "Glf_224"
glf_funcRefMap.Add "lane_lit:{light:3}", "Glf_225"
glf_funcRefMap.Add "lane_lit{kwargs.light == 3}", "Glf_226"
glf_funcRefMap.Add "paris_lit:{light:1}", "Glf_227"
glf_funcRefMap.Add "paris_lit:{light:2}", "Glf_228"
glf_funcRefMap.Add "paris_lit:{light:3}", "Glf_229"
glf_funcRefMap.Add "paris_lit{kwargs.light == 3}", "Glf_230"
glf_funcRefMap.Add "sookie_lit{kwargs.light < 3}", "Glf_231"
glf_funcRefMap.Add "kirk_lit{kwargs.light < 3}", "Glf_232"
glf_funcRefMap.Add "lane_lit{kwargs.light < 3}", "Glf_233"
glf_funcRefMap.Add "paris_lit{kwargs.light < 3}", "Glf_234"
glf_funcRefMap.Add "sookie_lit{kwargs.light == 1}", "Glf_235"
glf_funcRefMap.Add "sookie_lit{kwargs.light == 2}", "Glf_236"
glf_funcRefMap.Add "kirk_lit{kwargs.light == 1}", "Glf_237"
glf_funcRefMap.Add "kirk_lit{kwargs.light == 2}", "Glf_238"
glf_funcRefMap.Add "lane_lit{kwargs.light == 1}", "Glf_239"
glf_funcRefMap.Add "lane_lit{kwargs.light == 2}", "Glf_240"
glf_funcRefMap.Add "paris_lit{kwargs.light == 1}", "Glf_241"
glf_funcRefMap.Add "paris_lit{kwargs.light == 2}", "Glf_242"
glf_funcRefMap.Add "s_DropTargetKicker_active{device.timers.hurryup.ticks != 0}", "Glf_243"
glf_funcRefMap.Add "score_dynamic_flat:{points:500000 + device.timers.hurryup.ticks * 7500}", "Glf_244"
glf_funcRefMap.Add "hurryup_achieved:{points:500000 + device.timers.hurryup.ticks * 7500}", "Glf_245"
glf_funcRefMap.Add """HURRY-UP""", "Glf_246"
glf_funcRefMap.Add """SHOOT LUKE'S TO COLLECT JACKPOT""", "Glf_247"
glf_funcRefMap.Add "500000 + kwargs.ticks * 7500", "Glf_248"
glf_funcRefMap.Add "new_ball_started{machine.game_modes_enabled == 1}", "Glf_249"
glf_funcRefMap.Add "mode_skillshots_started{current_player.ball_just_started == 1}", "Glf_250"
glf_funcRefMap.Add "mode_skillshots_started{current_player.ball_just_started == 0}", "Glf_251"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.ss1_started == 1}", "Glf_252"
glf_funcRefMap.Add "ss_achieved:{points:750000}", "Glf_253"
glf_funcRefMap.Add "ss_achieved:{points:200000}", "Glf_254"
glf_funcRefMap.Add "s_sw7_active{current_player.shot_ss_bonus_lane_7 == 1}", "Glf_255"
glf_funcRefMap.Add "ss_achieved:{points:400000}", "Glf_256"
glf_funcRefMap.Add "s_sw8_active{current_player.shot_ss_bonus_lane_8 == 1}", "Glf_257"
glf_funcRefMap.Add "s_sw9_active{current_player.shot_ss_bonus_lane_9 == 1}", "Glf_259"
glf_funcRefMap.Add "light_ss_bonus_lane_7{current_player.shot_bonus_lane_7 == 0}", "Glf_261"
glf_funcRefMap.Add "light_ss_bonus_lane_8{current_player.shot_bonus_lane_8 == 0}", "Glf_262"
glf_funcRefMap.Add "light_ss_bonus_lane_9{current_player.shot_bonus_lane_9 == 0}", "Glf_263"
glf_funcRefMap.Add "check_minigame{current_player.shot_logan_light == 1}", "Glf_264"
glf_funcRefMap.Add "check_minigame{current_player.shot_dance_marathon_minigame != 1 and current_player.shot_town_meeting_minigame != 1 and current_player.shot_dinner_minigame != 1 and current_player.shot_kims_antiques_minigame != 1 and current_player.shot_lbtb_minigame != 1 and current_player.shot_fd_punch_minigame != 1}", "Glf_265"
glf_funcRefMap.Add "check_minigame{current_player.shot_dance_marathon_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_266"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_dance_marathon_minigame == 1}", "Glf_267"
glf_funcRefMap.Add "check_minigame{current_player.shot_town_meeting_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_268"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_town_meeting_minigame == 1}", "Glf_269"
glf_funcRefMap.Add "check_minigame{current_player.shot_dinner_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_270"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_dinner_minigame == 1}", "Glf_271"
glf_funcRefMap.Add "check_minigame{current_player.shot_kims_antiques_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_272"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_kims_antiques_minigame == 1}", "Glf_273"
glf_funcRefMap.Add "check_minigame{current_player.shot_lbtb_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_274"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_lbtb_minigame == 1}", "Glf_275"
glf_funcRefMap.Add "check_minigame{current_player.shot_fd_punch_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_276"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_fd_punch_minigame == 1}", "Glf_277"
glf_funcRefMap.Add "choose_new_minigame{modes.eob_bonus.active == False}", "Glf_278"
glf_funcRefMap.Add "dance_marathon_minigame_lit{current_player.shot_dance_marathon_minigame == 0}", "Glf_279"
glf_funcRefMap.Add "town_meeting_minigame_lit{current_player.shot_town_meeting_minigame == 0}", "Glf_280"
glf_funcRefMap.Add "dinner_minigame_lit{current_player.shot_dinner_minigame == 0}", "Glf_281"
glf_funcRefMap.Add "kims_antiques_minigame_lit{current_player.shot_kims_antiques_minigame == 0}", "Glf_282"
glf_funcRefMap.Add "lbtb_minigame_lit{current_player.shot_lbtb_minigame == 0}", "Glf_283"
glf_funcRefMap.Add "fd_punch_minigame_lit{current_player.shot_fd_punch_minigame == 0}", "Glf_284"
glf_funcRefMap.Add "check_eb{current_player.extra_balls == 0}", "Glf_285"
glf_funcRefMap.Add "check_eb{current_player.extra_balls > 0}", "Glf_286"
glf_funcRefMap.Add "s_complete_right_ramp_active{current_player.shot_eb_ready == 1}", "Glf_287"
glf_funcRefMap.Add "3", "Glf_288"
glf_funcRefMap.Add "eb_now_lit{current_player.extra_ball_eb_awarded < 3}", "Glf_289"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==0}", "Glf_290"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==1 and modes.jd_multiball.active==False and modes.ll_multiball.active==False}", "Glf_291"
glf_funcRefMap.Add "timer_mystery_show_tick{devices.timers.mystery_show.ticks == 1}", "Glf_292"
glf_funcRefMap.Add "restart_qualify_mystery{modes.jd_multiball.active==False}", "Glf_293"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 0}", "Glf_294"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 1}", "Glf_295"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 2}", "Glf_296"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 3}", "Glf_297"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 4}", "Glf_298"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 5}", "Glf_299"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 6}", "Glf_300"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 7}", "Glf_301"
glf_funcRefMap.Add "10000", "Glf_302"
glf_funcRefMap.Add "6", "Glf_303"
glf_funcRefMap.Add "7", "Glf_304"
glf_funcRefMap.Add "ball_started{machine.game_modes_enabled == 1}", "Glf_305"
glf_funcRefMap.Add "s_complete_right_ramp_active{current_player.shot_ramp == 1}", "Glf_306"
glf_funcRefMap.Add "timer_dm_intro_delay_tick{device.timers.dm_intro_delay.ticks == 27}", "Glf_307"
glf_funcRefMap.Add "500000", "Glf_308"
glf_funcRefMap.Add "100000", "Glf_309"
glf_funcRefMap.Add "{current_player.mode_dance_marathon_score}", "Glf_310"
glf_funcRefMap.Add """HIT FLASHING SHOTS TO SCORE""", "Glf_311"
glf_funcRefMap.Add "kwargs.ticks_remaining", "Glf_312"
glf_funcRefMap.Add "250000", "Glf_313"
glf_funcRefMap.Add "1250000", "Glf_314"
glf_funcRefMap.Add "28", "Glf_315"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.dm_intro_delay.ticks > 0}", "Glf_316"
glf_funcRefMap.Add "15", "Glf_317"
glf_funcRefMap.Add "8", "Glf_318"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.town_meeting_intro_delay.ticks > 0}", "Glf_319"
glf_funcRefMap.Add "20", "Glf_320"
glf_funcRefMap.Add "{current_player.mode_town_meeting_score}", "Glf_321"
glf_funcRefMap.Add "750000", "Glf_322"
glf_funcRefMap.Add "{current_player.mode_dinner_score}", "Glf_323"
glf_funcRefMap.Add """SHOOT ORBITS TO SCORE""", "Glf_324"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.fd_punch_intro_delay.ticks > 0}", "Glf_325"
glf_funcRefMap.Add "{current_player.mode_fd_punch_score}", "Glf_326"
glf_funcRefMap.Add """SHOOT LUKE'S OR MANSION TO SCORE""", "Glf_327"
glf_funcRefMap.Add "{current_player.mode_kims_antiques_score}", "Glf_328"
glf_funcRefMap.Add """AVOID MISS KIM (SOLID LIGHT)""", "Glf_329"
glf_funcRefMap.Add "drop_target_drop3_down{current_player.bells_not_hit == 0}", "Glf_330"
glf_funcRefMap.Add "drop_target_drop4_down{current_player.bells_not_hit == 0}", "Glf_331"
glf_funcRefMap.Add "drop_target_drop5_down{current_player.bells_not_hit == 0}", "Glf_332"
glf_funcRefMap.Add "drop_target_drop6_down{current_player.bells_not_hit == 0}", "Glf_333"
glf_funcRefMap.Add "drop_target_drop7_down{current_player.bells_not_hit == 0}", "Glf_334"
glf_funcRefMap.Add "drop_target_drop8_down{current_player.bells_not_hit == 0}", "Glf_335"
glf_funcRefMap.Add "11.5", "Glf_336"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.lbtb_intro_delay.ticks > 0}", "Glf_337"
glf_funcRefMap.Add "drop3_reset{device.drop_targets.drop3.state == 1}", "Glf_338"
glf_funcRefMap.Add "drop4_reset{device.drop_targets.drop4.state == 1}", "Glf_339"
glf_funcRefMap.Add "drop5_reset{device.drop_targets.drop5.state == 1}", "Glf_340"
glf_funcRefMap.Add "drop6_reset{device.drop_targets.drop6.state == 1}", "Glf_341"
glf_funcRefMap.Add "drop7_reset{device.drop_targets.drop7.state == 1}", "Glf_342"
glf_funcRefMap.Add "drop8_reset{device.drop_targets.drop8.state == 1}", "Glf_343"
glf_funcRefMap.Add """LUKE BREAKS THE BELLS!""", "Glf_344"
glf_funcRefMap.Add "{current_player.mode_lbtb_score}", "Glf_345"
glf_funcRefMap.Add """BREAK BELLS TO SCORE""", "Glf_346"
glf_funcRefMap.Add """JESS VS. DEAN: TO THE DEATH""", "Glf_347"
glf_funcRefMap.Add "{current_player.mode_jdmb_score}", "Glf_348"
glf_funcRefMap.Add """TEAM JESS: LEFT RAMP - TEAM LOGAN: RIGHT RAMP""", "Glf_349"
glf_funcRefMap.Add "4000000", "Glf_350"
glf_funcRefMap.Add "7500000", "Glf_351"
glf_funcRefMap.Add "logan_bumper_hit{current_player.mode_llmb_score>=2500000}", "Glf_352"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==0}", "Glf_353"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==1}", "Glf_354"
glf_funcRefMap.Add "{current_player.mode_llmb_score}", "Glf_355"
glf_funcRefMap.Add """HIT BUMPERS TO BASH LOGAN""", "Glf_356"
glf_funcRefMap.Add """LOCK-AWAY LOGAN IN THE SCOOP""", "Glf_357"
glf_funcRefMap.Add "50000", "Glf_358"
glf_funcRefMap.Add "1000 * current_player.scoring_multiplier", "Glf_359"
glf_funcRefMap.Add "1000", "Glf_360"
glf_funcRefMap.Add "2500 * current_player.scoring_multiplier", "Glf_361"
glf_funcRefMap.Add "2500", "Glf_362"
glf_funcRefMap.Add "5000 * current_player.scoring_multiplier", "Glf_363"
glf_funcRefMap.Add "1500 * current_player.scoring_multiplier", "Glf_364"
glf_funcRefMap.Add "1500", "Glf_365"
glf_funcRefMap.Add "25000 * current_player.scoring_multiplier", "Glf_366"
glf_funcRefMap.Add "25000", "Glf_367"
glf_funcRefMap.Add "12500 * current_player.scoring_multiplier", "Glf_368"
glf_funcRefMap.Add "12500", "Glf_369"
glf_funcRefMap.Add "20000 * current_player.scoring_multiplier", "Glf_370"
glf_funcRefMap.Add "10000 * current_player.scoring_multiplier", "Glf_371"
glf_funcRefMap.Add "50000 * current_player.scoring_multiplier", "Glf_372"
glf_funcRefMap.Add "150000 * current_player.scoring_multiplier", "Glf_373"
glf_funcRefMap.Add "150000", "Glf_374"
glf_funcRefMap.Add "100000 * current_player.scoring_multiplier", "Glf_375"
glf_funcRefMap.Add "250000 * current_player.scoring_multiplier", "Glf_376"
glf_funcRefMap.Add "750000 * current_player.scoring_multiplier", "Glf_377"
glf_funcRefMap.Add "200000 * current_player.scoring_multiplier", "Glf_378"
glf_funcRefMap.Add "200000", "Glf_379"
glf_funcRefMap.Add "400000 * current_player.scoring_multiplier", "Glf_380"
glf_funcRefMap.Add "400000", "Glf_381"
glf_funcRefMap.Add "1000000 * current_player.scoring_multiplier", "Glf_382"
glf_funcRefMap.Add "1000000", "Glf_383"
glf_funcRefMap.Add "2500000 * current_player.scoring_multiplier", "Glf_384"
glf_funcRefMap.Add "2500000", "Glf_385"
glf_funcRefMap.Add "500000 * current_player.scoring_multiplier", "Glf_386"
glf_funcRefMap.Add "2000000 * current_player.scoring_multiplier", "Glf_387"
glf_funcRefMap.Add "2000000", "Glf_388"
glf_funcRefMap.Add "1250000 * current_player.scoring_multiplier", "Glf_389"
glf_funcRefMap.Add "4000000 * current_player.scoring_multiplier", "Glf_390"
glf_funcRefMap.Add "7500000 * current_player.scoring_multiplier", "Glf_391"
glf_funcRefMap.Add "5000000 * current_player.scoring_multiplier", "Glf_392"
glf_funcRefMap.Add "5000000", "Glf_393"
glf_funcRefMap.Add "100000000 * current_player.scoring_multiplier", "Glf_394"
glf_funcRefMap.Add "100000000", "Glf_395"
glf_funcRefMap.Add "2000 * current_player.scoring_multiplier", "Glf_396"
glf_funcRefMap.Add "7500 * current_player.scoring_multiplier", "Glf_397"
glf_funcRefMap.Add "7500", "Glf_398"
glf_funcRefMap.Add "kwargs.points * current_player.scoring_multiplier", "Glf_399"
glf_funcRefMap.Add "kwargs.points", "Glf_400"

