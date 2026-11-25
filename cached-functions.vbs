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
	Glf_5 = 45000
End Function
Function Glf_6(args)
	Glf_6 = 6000
End Function
Function Glf_7(args)
	On Error Resume Next
	    Glf_7 = glf_modes("attract").GetValue("active")=False
	If Err Then Glf_7 = False
End Function
Function Glf_8(args)
	On Error Resume Next
	    Glf_8 = glf_modes("attract").GetValue("active")=False
	If Err Then Glf_8 = False
End Function
Function Glf_9(args)
	On Error Resume Next
	    Glf_9 = glf_modes("post_game").GetValue("active") = False
	If Err Then Glf_9 = False
End Function
Function Glf_10(args)
	On Error Resume Next
	    Glf_10 = devices.timers.attract_pulse.ticks = 1
	If Err Then Glf_10 = False
End Function
Function Glf_11(args)
	On Error Resume Next
	    Glf_11 = devices.timers.attract_pulse.ticks = 3
	If Err Then Glf_11 = False
End Function
Function Glf_12(args)
	On Error Resume Next
	    Glf_12 = glf_timers("attract_insert_coins").GetValue("ticks") = 4
	If Err Then Glf_12 = False
End Function
Function Glf_13(args)
	On Error Resume Next
	    Glf_13 = glf_timers("attract_insert_coins").GetValue("ticks") = 4
	If Err Then Glf_13 = False
End Function
Function Glf_14(args)
	On Error Resume Next
	    Glf_14 = glf_timers("attract_insert_coins").GetValue("ticks") = 4
	If Err Then Glf_14 = False
End Function
Function Glf_15(args)
	Glf_15 = 0
End Function
Function Glf_16(args)
	Glf_16 = -1
End Function
Function Glf_17(args)
	Glf_17 = 6
End Function
Function Glf_18(args)
	Glf_18 = 3
End Function
Function Glf_19(args)
	Glf_19 = 4
End Function
Function Glf_20(args)
	On Error Resume Next
	    Glf_20 = (glf_machine_vars("credits_whole_num").GetValue() >= 1 or glf_machine_vars("free_play").GetValue() = 1) and (Glf_GameVariable("num_players") = 0 or (Glf_GameVariable("num_players") < Glf_GameVariable("max_players") and GetPlayerState("ball") = 1))
	If Err Then Glf_20 = False
End Function
Function Glf_21(args)
	On Error Resume Next
	    Glf_21 = (glf_machine_vars("credits_whole_num").GetValue() < 1 and glf_machine_vars("free_play").GetValue() = 0) or (Glf_GameVariable("num_players") > 0 and (Glf_GameVariable("num_players") >= Glf_GameVariable("max_players") or GetPlayerState("ball") > 1))
	If Err Then Glf_21 = False
End Function
Function Glf_22(args)
	On Error Resume Next
	    Glf_22 = Glf_GameVariable("tilted") = True
	If Err Then Glf_22 = False
End Function
Function Glf_23(args)
	On Error Resume Next
	    Glf_23 = glf_machine_vars("captive_ball_captive").GetValue() = 0
	If Err Then Glf_23 = False
End Function
Function Glf_24(args)
	On Error Resume Next
	    Glf_24 = glf_machine_vars("captive_ball_captive").GetValue() = 0 and GetPlayerState("llmb_shoot_again_active") = 0
	If Err Then Glf_24 = False
End Function
Function Glf_25(args)
	On Error Resume Next
	    Glf_25 = glf_modes("base").GetValue("active") = False
	If Err Then Glf_25 = False
End Function
Function Glf_26(args)
	Glf_26 = 1
End Function
Function Glf_27(args)
	On Error Resume Next
	    Glf_27 = glf_dispatch_current_kwargs("num") > 1
	If Err Then Glf_27 = False
End Function
Function Glf_28(args)
	On Error Resume Next
	    Glf_28 = glf_dispatch_current_kwargs("num") = 2
	If Err Then Glf_28 = False
End Function
Function Glf_29(args)
	On Error Resume Next
	    Glf_29 = glf_dispatch_current_kwargs("num") = 3
	If Err Then Glf_29 = False
End Function
Function Glf_30(args)
	On Error Resume Next
	    Glf_30 = glf_dispatch_current_kwargs("num") = 4
	If Err Then Glf_30 = False
End Function
Function Glf_31(args)
	Glf_31 = 10
End Function
Function Glf_32(args)
	On Error Resume Next
	    Glf_32 = GetPlayerState("ball_just_started") = 1
	If Err Then Glf_32 = False
End Function
Function Glf_33(args)
	On Error Resume Next
	    Glf_33 = glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_33 = False
End Function
Function Glf_34(args)
	On Error Resume Next
	    Glf_34 = glf_modes("bonus").GetValue("active") = False and glf_modes("dance_marathon").GetValue("active") = False and glf_modes("town_meeting").GetValue("active") = False and glf_modes("dinner").GetValue("active") = False and glf_modes("fd_punch").GetValue("active") = False and glf_modes("kims_antiques").GetValue("active") = False and glf_modes("lbtb").GetValue("active") = False
	If Err Then Glf_34 = False
End Function
Function Glf_35(args)
	Glf_35 = 200
End Function
Function Glf_36(args)
	Glf_36 = 244.8
End Function
Function Glf_37(args)
	Glf_37 = 51.293333
End Function
Function Glf_38(args)
	Glf_38 = 36.506667
End Function
Function Glf_39(args)
	Glf_39 = 188.866667
End Function
Function Glf_40(args)
	Glf_40 = 53.04
End Function
Function Glf_41(args)
	Glf_41 = 234.826667
End Function
Function Glf_42(args)
	Glf_42 = 332.76
End Function
Function Glf_43(args)
	On Error Resume Next
	    Glf_43 = glf_modes("fd_punch").GetValue("active")=False and glf_modes("dinner").GetValue("active")=False
	If Err Then Glf_43 = False
End Function
Function Glf_44(args)
	On Error Resume Next
	    Glf_44 = glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_44 = False
End Function
Function Glf_45(args)
	On Error Resume Next
	    Glf_45 = glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_45 = False
End Function
Function Glf_46(args)
	On Error Resume Next
	    Glf_46 = glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_46 = False
End Function
Function Glf_47(args)
	On Error Resume Next
	    Glf_47 = glf_modes("lbtb").GetValue("active")=False
	If Err Then Glf_47 = False
End Function
Function Glf_48(args)
	On Error Resume Next
	    Glf_48 = glf_modes("lbtb").GetValue("active")=False
	If Err Then Glf_48 = False
End Function
Function Glf_49(args)
	On Error Resume Next
	    Glf_49 = Glf_GameVariable("num_players") > 1 and GetPlayerState("number") = 1
	If Err Then Glf_49 = False
End Function
Function Glf_50(args)
	On Error Resume Next
	    Glf_50 = Glf_GameVariable("num_players") > 1 and GetPlayerState("number") = 2
	If Err Then Glf_50 = False
End Function
Function Glf_51(args)
	On Error Resume Next
	    Glf_51 = Glf_GameVariable("num_players") > 1 and GetPlayerState("number") = 3
	If Err Then Glf_51 = False
End Function
Function Glf_52(args)
	On Error Resume Next
	    Glf_52 = Glf_GameVariable("num_players") > 1 and GetPlayerState("number") = 4
	If Err Then Glf_52 = False
End Function
Function Glf_53(args)
	Glf_53 = 15000
End Function
Function Glf_54(args)
	Glf_54 = 5000
End Function
Function Glf_55(args)
	Glf_55 = 3000
End Function
Function Glf_56(args)
	Glf_56 = 2000
End Function
Function Glf_57(args)
	On Error Resume Next
	    Glf_57 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_57 = False
End Function
Function Glf_58(args)
	On Error Resume Next
	    Glf_58 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_58 = False
End Function
Function Glf_59(args)
	On Error Resume Next
	    Glf_59 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_59 = False
End Function
Function Glf_60(args)
	On Error Resume Next
	    Glf_60 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_60 = False
End Function
Function Glf_61(args)
	On Error Resume Next
	    Glf_61 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_61 = False
End Function
Function Glf_62(args)
	On Error Resume Next
	    Glf_62 = glf_machine_vars("high_score_initials_chars").GetValue() = 3
	If Err Then Glf_62 = False
End Function
Function Glf_63(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text",  glf_machine_vars("high_score_initials").GetValue()
	Set Glf_63 = kwargs
	If Err Then Glf_63 = Null
End Function
Function Glf_64(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text",  glf_machine_vars("high_score_initials").GetValue()
	Set Glf_64 = kwargs
	If Err Then Glf_64 = Null
End Function
Function Glf_65(args)
	On Error Resume Next
	    Glf_65 = glf_machine_vars("high_score_music_started").GetValue() = 0
	If Err Then Glf_65 = False
End Function
Function Glf_66(args)
	On Error Resume Next
	    Glf_66 = glf_machine_vars("high_score_initials_chars").GetValue() < 3
	If Err Then Glf_66 = False
End Function
Function Glf_67(args)
	Glf_67 = GetPlayerStateForPlayer(0, "score")
End Function
Function Glf_68(args)
	On Error Resume Next
	    Glf_68 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_68 = False
End Function
Function Glf_69(args)
	On Error Resume Next
	    Glf_69 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_69 = False
End Function
Function Glf_70(args)
	On Error Resume Next
	    Glf_70 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 0
	If Err Then Glf_70 = False
End Function
Function Glf_71(args)
	Glf_71 = glf_machine_vars("high_score_initials").GetValue() & "A"
End Function
Function Glf_72(args)
	On Error Resume Next
	    Glf_72 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 1
	If Err Then Glf_72 = False
End Function
Function Glf_73(args)
	Glf_73 = glf_machine_vars("high_score_initials").GetValue() & "B"
End Function
Function Glf_74(args)
	On Error Resume Next
	    Glf_74 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 2
	If Err Then Glf_74 = False
End Function
Function Glf_75(args)
	Glf_75 = glf_machine_vars("high_score_initials").GetValue() & "C"
End Function
Function Glf_76(args)
	On Error Resume Next
	    Glf_76 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 3
	If Err Then Glf_76 = False
End Function
Function Glf_77(args)
	Glf_77 = glf_machine_vars("high_score_initials").GetValue() & "D"
End Function
Function Glf_78(args)
	On Error Resume Next
	    Glf_78 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 4
	If Err Then Glf_78 = False
End Function
Function Glf_79(args)
	Glf_79 = glf_machine_vars("high_score_initials").GetValue() & "E"
End Function
Function Glf_80(args)
	On Error Resume Next
	    Glf_80 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 5
	If Err Then Glf_80 = False
End Function
Function Glf_81(args)
	Glf_81 = glf_machine_vars("high_score_initials").GetValue() & "F"
End Function
Function Glf_82(args)
	On Error Resume Next
	    Glf_82 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 6
	If Err Then Glf_82 = False
End Function
Function Glf_83(args)
	Glf_83 = glf_machine_vars("high_score_initials").GetValue() & "G"
End Function
Function Glf_84(args)
	On Error Resume Next
	    Glf_84 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 7
	If Err Then Glf_84 = False
End Function
Function Glf_85(args)
	Glf_85 = glf_machine_vars("high_score_initials").GetValue() & "H"
End Function
Function Glf_86(args)
	On Error Resume Next
	    Glf_86 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 8
	If Err Then Glf_86 = False
End Function
Function Glf_87(args)
	Glf_87 = glf_machine_vars("high_score_initials").GetValue() & "I"
End Function
Function Glf_88(args)
	On Error Resume Next
	    Glf_88 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 9
	If Err Then Glf_88 = False
End Function
Function Glf_89(args)
	Glf_89 = glf_machine_vars("high_score_initials").GetValue() & "J"
End Function
Function Glf_90(args)
	On Error Resume Next
	    Glf_90 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 10
	If Err Then Glf_90 = False
End Function
Function Glf_91(args)
	Glf_91 = glf_machine_vars("high_score_initials").GetValue() & "K"
End Function
Function Glf_92(args)
	On Error Resume Next
	    Glf_92 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 11
	If Err Then Glf_92 = False
End Function
Function Glf_93(args)
	Glf_93 = glf_machine_vars("high_score_initials").GetValue() & "L"
End Function
Function Glf_94(args)
	On Error Resume Next
	    Glf_94 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 12
	If Err Then Glf_94 = False
End Function
Function Glf_95(args)
	Glf_95 = glf_machine_vars("high_score_initials").GetValue() & "M"
End Function
Function Glf_96(args)
	On Error Resume Next
	    Glf_96 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 13
	If Err Then Glf_96 = False
End Function
Function Glf_97(args)
	Glf_97 = glf_machine_vars("high_score_initials").GetValue() & "N"
End Function
Function Glf_98(args)
	On Error Resume Next
	    Glf_98 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 14
	If Err Then Glf_98 = False
End Function
Function Glf_99(args)
	Glf_99 = glf_machine_vars("high_score_initials").GetValue() & "O"
End Function
Function Glf_100(args)
	On Error Resume Next
	    Glf_100 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 15
	If Err Then Glf_100 = False
End Function
Function Glf_101(args)
	Glf_101 = glf_machine_vars("high_score_initials").GetValue() & "P"
End Function
Function Glf_102(args)
	On Error Resume Next
	    Glf_102 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 16
	If Err Then Glf_102 = False
End Function
Function Glf_103(args)
	Glf_103 = glf_machine_vars("high_score_initials").GetValue() & "Q"
End Function
Function Glf_104(args)
	On Error Resume Next
	    Glf_104 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 17
	If Err Then Glf_104 = False
End Function
Function Glf_105(args)
	Glf_105 = glf_machine_vars("high_score_initials").GetValue() & "R"
End Function
Function Glf_106(args)
	On Error Resume Next
	    Glf_106 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 18
	If Err Then Glf_106 = False
End Function
Function Glf_107(args)
	Glf_107 = glf_machine_vars("high_score_initials").GetValue() & "S"
End Function
Function Glf_108(args)
	On Error Resume Next
	    Glf_108 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 19
	If Err Then Glf_108 = False
End Function
Function Glf_109(args)
	Glf_109 = glf_machine_vars("high_score_initials").GetValue() & "T"
End Function
Function Glf_110(args)
	On Error Resume Next
	    Glf_110 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 20
	If Err Then Glf_110 = False
End Function
Function Glf_111(args)
	Glf_111 = glf_machine_vars("high_score_initials").GetValue() & "U"
End Function
Function Glf_112(args)
	On Error Resume Next
	    Glf_112 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 21
	If Err Then Glf_112 = False
End Function
Function Glf_113(args)
	Glf_113 = glf_machine_vars("high_score_initials").GetValue() & "V"
End Function
Function Glf_114(args)
	On Error Resume Next
	    Glf_114 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 22
	If Err Then Glf_114 = False
End Function
Function Glf_115(args)
	Glf_115 = glf_machine_vars("high_score_initials").GetValue() & "W"
End Function
Function Glf_116(args)
	On Error Resume Next
	    Glf_116 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 23
	If Err Then Glf_116 = False
End Function
Function Glf_117(args)
	Glf_117 = glf_machine_vars("high_score_initials").GetValue() & "X"
End Function
Function Glf_118(args)
	On Error Resume Next
	    Glf_118 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 24
	If Err Then Glf_118 = False
End Function
Function Glf_119(args)
	Glf_119 = glf_machine_vars("high_score_initials").GetValue() & "Y"
End Function
Function Glf_120(args)
	On Error Resume Next
	    Glf_120 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 25
	If Err Then Glf_120 = False
End Function
Function Glf_121(args)
	Glf_121 = glf_machine_vars("high_score_initials").GetValue() & "Z"
End Function
Function Glf_122(args)
	On Error Resume Next
	    Glf_122 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 26
	If Err Then Glf_122 = False
End Function
Function Glf_123(args)
	Glf_123 = glf_machine_vars("high_score_initials").GetValue() & "0"
End Function
Function Glf_124(args)
	On Error Resume Next
	    Glf_124 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 27
	If Err Then Glf_124 = False
End Function
Function Glf_125(args)
	Glf_125 = glf_machine_vars("high_score_initials").GetValue() & "1"
End Function
Function Glf_126(args)
	On Error Resume Next
	    Glf_126 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 28
	If Err Then Glf_126 = False
End Function
Function Glf_127(args)
	Glf_127 = glf_machine_vars("high_score_initials").GetValue() & "2"
End Function
Function Glf_128(args)
	On Error Resume Next
	    Glf_128 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 29
	If Err Then Glf_128 = False
End Function
Function Glf_129(args)
	Glf_129 = glf_machine_vars("high_score_initials").GetValue() & "3"
End Function
Function Glf_130(args)
	On Error Resume Next
	    Glf_130 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 30
	If Err Then Glf_130 = False
End Function
Function Glf_131(args)
	Glf_131 = glf_machine_vars("high_score_initials").GetValue() & "4"
End Function
Function Glf_132(args)
	On Error Resume Next
	    Glf_132 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 31
	If Err Then Glf_132 = False
End Function
Function Glf_133(args)
	Glf_133 = glf_machine_vars("high_score_initials").GetValue() & "5"
End Function
Function Glf_134(args)
	On Error Resume Next
	    Glf_134 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 32
	If Err Then Glf_134 = False
End Function
Function Glf_135(args)
	Glf_135 = glf_machine_vars("high_score_initials").GetValue() & "6"
End Function
Function Glf_136(args)
	On Error Resume Next
	    Glf_136 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 33
	If Err Then Glf_136 = False
End Function
Function Glf_137(args)
	Glf_137 = glf_machine_vars("high_score_initials").GetValue() & "7"
End Function
Function Glf_138(args)
	On Error Resume Next
	    Glf_138 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 34
	If Err Then Glf_138 = False
End Function
Function Glf_139(args)
	Glf_139 = glf_machine_vars("high_score_initials").GetValue() & "8"
End Function
Function Glf_140(args)
	On Error Resume Next
	    Glf_140 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 35
	If Err Then Glf_140 = False
End Function
Function Glf_141(args)
	Glf_141 = glf_machine_vars("high_score_initials").GetValue() & "9"
End Function
Function Glf_142(args)
	On Error Resume Next
	    Glf_142 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 36
	If Err Then Glf_142 = False
End Function
Function Glf_143(args)
	Glf_143 = glf_machine_vars("high_score_initials").GetValue() & "_"
End Function
Function Glf_144(args)
	Glf_144 = ""
End Function
Function Glf_145(args)
	Glf_145 = glf_dispatch_current_kwargs("player_num")
End Function
Function Glf_146(args)
	Glf_146 = 60
End Function
Function Glf_147(args)
	Glf_147 = 5
End Function
Function Glf_148(args)
	Glf_148 = GetPlayerState("bonus_x") * 1000
End Function
Function Glf_149(args)
	Glf_149 = 7500
End Function
Function Glf_150(args)
	Glf_150 = 1000
End Function
Function Glf_151(args)
	On Error Resume Next
	    Glf_151 = glf_dispatch_current_kwargs("entry") = "switches"
	If Err Then Glf_151 = False
End Function
Function Glf_152(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "BONUS " & GetPlayerState("bonus_x") & "x"
	kwargs.Add "score", GetPlayerState("bonus_x") * BonusMultiplierFactor * GetPlayerState("total_switches_hit")
	Set Glf_152 = kwargs
	If Err Then Glf_152 = Null
End Function
Function Glf_153(args)
	On Error Resume Next
	    Glf_153 = glf_dispatch_current_kwargs("entry") = "coffee"
	If Err Then Glf_153 = False
End Function
Function Glf_154(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "COFFEE COFFEE COFFEE"
	kwargs.Add "score", GetPlayerState("bumper_count") & " CUPS x " & BonusBumperFactor
	Set Glf_154 = kwargs
	If Err Then Glf_154 = Null
End Function
Function Glf_155(args)
	On Error Resume Next
	    Glf_155 = glf_dispatch_current_kwargs("entry") = "diners"
	If Err Then Glf_155 = False
End Function
Function Glf_156(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "LUKE'S DINER"
	kwargs.Add "score", GetPlayerState("diner_count") & " MEALS x " & BonusDinerFactor
	Set Glf_156 = kwargs
	If Err Then Glf_156 = Null
End Function
Function Glf_157(args)
	On Error Resume Next
	    Glf_157 = glf_dispatch_current_kwargs("entry") = "grandparents"
	If Err Then Glf_157 = False
End Function
Function Glf_158(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "GRANDPARENTS"
	kwargs.Add "score", GetPlayerState("grandparents_count") & " VISITS x " & BonusGrandparentsFactor
	Set Glf_158 = kwargs
	If Err Then Glf_158 = Null
End Function
Function Glf_159(args)
	On Error Resume Next
	    Glf_159 = glf_dispatch_current_kwargs("entry") = "talking"
	If Err Then Glf_159 = False
End Function
Function Glf_160(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "FAST TALKING"
	kwargs.Add "score", GetPlayerState("spinner_count") & " QUIPS x " & BonusSpinnerFactor
	Set Glf_160 = kwargs
	If Err Then Glf_160 = Null
End Function
Function Glf_161(args)
	On Error Resume Next
	    Glf_161 = glf_dispatch_current_kwargs("entry") = "total" And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_161 = False
End Function
Function Glf_162(args)
	On Error Resume Next
	    Glf_162 = glf_dispatch_current_kwargs("entry") = "total" And GetPlayerState("bonus_skip") = 1
	If Err Then Glf_162 = False
End Function
Function Glf_163(args)
	On Error Resume Next
	    Glf_163 = GetPlayerState("mode_llmb_score") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_163 = False
End Function
Function Glf_164(args)
	On Error Resume Next
	    Glf_164 = GetPlayerState("mode_llmb_score") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_164 = False
End Function
Function Glf_165(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "LOCK-AWAY LOGAN"
	kwargs.Add "score", GetPlayerState("mode_llmb_score")
	Set Glf_165 = kwargs
	If Err Then Glf_165 = Null
End Function
Function Glf_166(args)
	On Error Resume Next
	    Glf_166 = GetPlayerState("mode_jdmb_score") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_166 = False
End Function
Function Glf_167(args)
	On Error Resume Next
	    Glf_167 = GetPlayerState("mode_jdmb_score") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_167 = False
End Function
Function Glf_168(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "JESS & DEAN" & Chr(58) & " TO THE DEATH"
	kwargs.Add "score", GetPlayerState("mode_jdmb_score")
	Set Glf_168 = kwargs
	If Err Then Glf_168 = Null
End Function
Function Glf_169(args)
	On Error Resume Next
	    Glf_169 = GetPlayerState("mode_dance_marathon_score") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_169 = False
End Function
Function Glf_170(args)
	On Error Resume Next
	    Glf_170 = GetPlayerState("mode_dance_marathon_score") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_170 = False
End Function
Function Glf_171(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "DANCE MARATHON"
	kwargs.Add "score", GetPlayerState("mode_dance_marathon_score")
	Set Glf_171 = kwargs
	If Err Then Glf_171 = Null
End Function
Function Glf_172(args)
	On Error Resume Next
	    Glf_172 = GetPlayerState("mode_town_meeting_score") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_172 = False
End Function
Function Glf_173(args)
	On Error Resume Next
	    Glf_173 = GetPlayerState("mode_town_meeting_score") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_173 = False
End Function
Function Glf_174(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "TOWN MEETING"
	kwargs.Add "score", GetPlayerState("mode_town_meeting_score")
	Set Glf_174 = kwargs
	If Err Then Glf_174 = Null
End Function
Function Glf_175(args)
	On Error Resume Next
	    Glf_175 = GetPlayerState("mode_lbtb_score") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_175 = False
End Function
Function Glf_176(args)
	On Error Resume Next
	    Glf_176 = GetPlayerState("mode_lbtb_score") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_176 = False
End Function
Function Glf_177(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "LUKE BREAKS THE BELLS"
	kwargs.Add "score", GetPlayerState("mode_lbtb_score")
	Set Glf_177 = kwargs
	If Err Then Glf_177 = Null
End Function
Function Glf_178(args)
	On Error Resume Next
	    Glf_178 = GetPlayerState("mode_kims_antiques_score") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_178 = False
End Function
Function Glf_179(args)
	On Error Resume Next
	    Glf_179 = GetPlayerState("mode_kims_antiques_score") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_179 = False
End Function
Function Glf_180(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "KIM'S ANTIQUES"
	kwargs.Add "score", GetPlayerState("mode_kims_antiques_score")
	Set Glf_180 = kwargs
	If Err Then Glf_180 = Null
End Function
Function Glf_181(args)
	On Error Resume Next
	    Glf_181 = GetPlayerState("mode_dinner_score") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_181 = False
End Function
Function Glf_182(args)
	On Error Resume Next
	    Glf_182 = GetPlayerState("mode_dinner_score") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_182 = False
End Function
Function Glf_183(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "FRIDAY NIGHT DINNER"
	kwargs.Add "score", GetPlayerState("mode_dinner_score")
	Set Glf_183 = kwargs
	If Err Then Glf_183 = Null
End Function
Function Glf_184(args)
	On Error Resume Next
	    Glf_184 = GetPlayerState("mode_fd_punch_score") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_184 = False
End Function
Function Glf_185(args)
	On Error Resume Next
	    Glf_185 = GetPlayerState("mode_fd_punch_score") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_185 = False
End Function
Function Glf_186(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "FOUNDER'S DAY PUNCH"
	kwargs.Add "score", GetPlayerState("mode_fd_punch_score")
	Set Glf_186 = kwargs
	If Err Then Glf_186 = Null
End Function
Function Glf_187(args)
	On Error Resume Next
	    Glf_187 = GetPlayerState("bonus_total") > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_187 = False
End Function
Function Glf_188(args)
	On Error Resume Next
	    Glf_188 = GetPlayerState("bonus_total") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_188 = False
End Function
Function Glf_189(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "TOTAL BONUS"
	kwargs.Add "score", GetPlayerState("bonus_total")
	Set Glf_189 = kwargs
	If Err Then Glf_189 = Null
End Function
Function Glf_190(args)
	On Error Resume Next
	    Glf_190 = GetPlayerState("bonus_counted") = 1
	If Err Then Glf_190 = False
End Function
Function Glf_191(args)
	On Error Resume Next
	    Glf_191 = glf_dispatch_current_kwargs("entry") = "total"
	If Err Then Glf_191 = False
End Function
Function Glf_192(args)
	Glf_192 = glf_dispatch_current_kwargs("score")
End Function
Function Glf_193(args)
	On Error Resume Next
	    Glf_193 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_193 = False
End Function
Function Glf_194(args)
	On Error Resume Next
	    Glf_194 = GetPlayerState("is_lock_qualified") = 0
	If Err Then Glf_194 = False
End Function
Function Glf_195(args)
	On Error Resume Next
	    Glf_195 = GetPlayerState("is_lock_qualified") = 1
	If Err Then Glf_195 = False
End Function
Function Glf_196(args)
	On Error Resume Next
	    Glf_196 = GetPlayerState("multiball_lock_locked_balls") = 2
	If Err Then Glf_196 = False
End Function
Function Glf_197(args)
	On Error Resume Next
	    Glf_197 = glf_dispatch_current_kwargs("total_balls_locked") = 1
	If Err Then Glf_197 = False
End Function
Function Glf_198(args)
	On Error Resume Next
	    Glf_198 = glf_dispatch_current_kwargs("total_balls_locked") = 2
	If Err Then Glf_198 = False
End Function
Function Glf_199(args)
	On Error Resume Next
	    Glf_199 = GetPlayerState("shot_bonus_lane_7") = 0
	If Err Then Glf_199 = False
End Function
Function Glf_200(args)
	On Error Resume Next
	    Glf_200 = GetPlayerState("shot_bonus_lane_7") = 1
	If Err Then Glf_200 = False
End Function
Function Glf_201(args)
	On Error Resume Next
	    Glf_201 = GetPlayerState("shot_bonus_lane_8") = 0
	If Err Then Glf_201 = False
End Function
Function Glf_202(args)
	On Error Resume Next
	    Glf_202 = GetPlayerState("shot_bonus_lane_8") = 1
	If Err Then Glf_202 = False
End Function
Function Glf_203(args)
	On Error Resume Next
	    Glf_203 = GetPlayerState("shot_bonus_lane_9") = 0
	If Err Then Glf_203 = False
End Function
Function Glf_204(args)
	On Error Resume Next
	    Glf_204 = GetPlayerState("shot_bonus_lane_9") = 1
	If Err Then Glf_204 = False
End Function
Function Glf_205(args)
	On Error Resume Next
	    Glf_205 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_205 = False
End Function
Function Glf_206(args)
	On Error Resume Next
	    Glf_206 = GetPlayerState("shot_logan_qualify") = 2
	If Err Then Glf_206 = False
End Function
Function Glf_207(args)
	On Error Resume Next
	    Glf_207 = GetPlayerState("shot_logan_qualify") = 3 and glf_ball_holds("captive_ramp_kicker_hold").GetValue("balls_held") = 0
	If Err Then Glf_207 = False
End Function
Function Glf_208(args)
	On Error Resume Next
	    Glf_208 = glf_ball_holds("captive_ramp_kicker_hold").GetValue("balls_held") = 1
	If Err Then Glf_208 = False
End Function
Function Glf_209(args)
	On Error Resume Next
	    Glf_209 = glf_ball_holds("captive_ramp_kicker_hold").GetValue("balls_held") = 1
	If Err Then Glf_209 = False
End Function
Function Glf_210(args)
	On Error Resume Next
	    Glf_210 = GetPlayerState("logan_cooldown_active") = 0
	If Err Then Glf_210 = False
End Function
Function Glf_211(args)
	On Error Resume Next
	    Glf_211 = GetPlayerState("shot_logan_qualify") = 0
	If Err Then Glf_211 = False
End Function
Function Glf_212(args)
	On Error Resume Next
	    Glf_212 = GetPlayerState("shot_logan_qualify") = 1
	If Err Then Glf_212 = False
End Function
Function Glf_213(args)
	Glf_213 = 2
End Function
Function Glf_214(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_214 = kwargs
	If Err Then Glf_214 = Null
End Function
Function Glf_215(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_215 = kwargs
	If Err Then Glf_215 = Null
End Function
Function Glf_216(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_216 = kwargs
	If Err Then Glf_216 = Null
End Function
Function Glf_217(args)
	On Error Resume Next
	    Glf_217 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_217 = False
End Function
Function Glf_218(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_218 = kwargs
	If Err Then Glf_218 = Null
End Function
Function Glf_219(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_219 = kwargs
	If Err Then Glf_219 = Null
End Function
Function Glf_220(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_220 = kwargs
	If Err Then Glf_220 = Null
End Function
Function Glf_221(args)
	On Error Resume Next
	    Glf_221 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_221 = False
End Function
Function Glf_222(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_222 = kwargs
	If Err Then Glf_222 = Null
End Function
Function Glf_223(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_223 = kwargs
	If Err Then Glf_223 = Null
End Function
Function Glf_224(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_224 = kwargs
	If Err Then Glf_224 = Null
End Function
Function Glf_225(args)
	On Error Resume Next
	    Glf_225 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_225 = False
End Function
Function Glf_226(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_226 = kwargs
	If Err Then Glf_226 = Null
End Function
Function Glf_227(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_227 = kwargs
	If Err Then Glf_227 = Null
End Function
Function Glf_228(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_228 = kwargs
	If Err Then Glf_228 = Null
End Function
Function Glf_229(args)
	On Error Resume Next
	    Glf_229 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_229 = False
End Function
Function Glf_230(args)
	On Error Resume Next
	    Glf_230 = glf_dispatch_current_kwargs("light") < 3
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
	    Glf_234 = glf_dispatch_current_kwargs("light") = 1
	If Err Then Glf_234 = False
End Function
Function Glf_235(args)
	On Error Resume Next
	    Glf_235 = glf_dispatch_current_kwargs("light") = 2
	If Err Then Glf_235 = False
End Function
Function Glf_236(args)
	Glf_236 = 50
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
	    Glf_243 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_243 = False
End Function
Function Glf_244(args)
	On Error Resume Next
	    Glf_244 = GetPlayerState("ball_just_started") = 1
	If Err Then Glf_244 = False
End Function
Function Glf_245(args)
	On Error Resume Next
	    Glf_245 = GetPlayerState("ball_just_started") = 0
	If Err Then Glf_245 = False
End Function
Function Glf_246(args)
	On Error Resume Next
	    Glf_246 = GetPlayerState("ss1_started") = 1
	If Err Then Glf_246 = False
End Function
Function Glf_247(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 750000
	Set Glf_247 = kwargs
	If Err Then Glf_247 = Null
End Function
Function Glf_248(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 200000
	Set Glf_248 = kwargs
	If Err Then Glf_248 = Null
End Function
Function Glf_249(args)
	On Error Resume Next
	    Glf_249 = GetPlayerState("shot_ss_bonus_lane_7") = 1
	If Err Then Glf_249 = False
End Function
Function Glf_250(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 400000
	Set Glf_250 = kwargs
	If Err Then Glf_250 = Null
End Function
Function Glf_251(args)
	On Error Resume Next
	    Glf_251 = GetPlayerState("shot_ss_bonus_lane_8") = 1
	If Err Then Glf_251 = False
End Function
Function Glf_252(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 400000
	Set Glf_252 = kwargs
	If Err Then Glf_252 = Null
End Function
Function Glf_253(args)
	On Error Resume Next
	    Glf_253 = GetPlayerState("shot_ss_bonus_lane_9") = 1
	If Err Then Glf_253 = False
End Function
Function Glf_254(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 400000
	Set Glf_254 = kwargs
	If Err Then Glf_254 = Null
End Function
Function Glf_255(args)
	On Error Resume Next
	    Glf_255 = GetPlayerState("shot_bonus_lane_7") = 0
	If Err Then Glf_255 = False
End Function
Function Glf_256(args)
	On Error Resume Next
	    Glf_256 = GetPlayerState("shot_bonus_lane_8") = 0
	If Err Then Glf_256 = False
End Function
Function Glf_257(args)
	On Error Resume Next
	    Glf_257 = GetPlayerState("shot_bonus_lane_9") = 0
	If Err Then Glf_257 = False
End Function
Function Glf_258(args)
	On Error Resume Next
	    Glf_258 = GetPlayerState("shot_logan_light") = 1
	If Err Then Glf_258 = False
End Function
Function Glf_259(args)
	On Error Resume Next
	    Glf_259 = GetPlayerState("shot_dance_marathon_minigame") <> 1 and GetPlayerState("shot_town_meeting_minigame") <> 1 and GetPlayerState("shot_dinner_minigame") <> 1 and GetPlayerState("shot_kims_antiques_minigame") <> 1 and GetPlayerState("shot_lbtb_minigame") <> 1 and GetPlayerState("shot_fd_punch_minigame") <> 1
	If Err Then Glf_259 = False
End Function
Function Glf_260(args)
	On Error Resume Next
	    Glf_260 = GetPlayerState("shot_dance_marathon_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_260 = False
End Function
Function Glf_261(args)
	On Error Resume Next
	    Glf_261 = GetPlayerState("shot_dance_marathon_minigame") = 1
	If Err Then Glf_261 = False
End Function
Function Glf_262(args)
	On Error Resume Next
	    Glf_262 = GetPlayerState("shot_town_meeting_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_262 = False
End Function
Function Glf_263(args)
	On Error Resume Next
	    Glf_263 = GetPlayerState("shot_town_meeting_minigame") = 1
	If Err Then Glf_263 = False
End Function
Function Glf_264(args)
	On Error Resume Next
	    Glf_264 = GetPlayerState("shot_dinner_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_264 = False
End Function
Function Glf_265(args)
	On Error Resume Next
	    Glf_265 = GetPlayerState("shot_dinner_minigame") = 1
	If Err Then Glf_265 = False
End Function
Function Glf_266(args)
	On Error Resume Next
	    Glf_266 = GetPlayerState("shot_kims_antiques_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_266 = False
End Function
Function Glf_267(args)
	On Error Resume Next
	    Glf_267 = GetPlayerState("shot_kims_antiques_minigame") = 1
	If Err Then Glf_267 = False
End Function
Function Glf_268(args)
	On Error Resume Next
	    Glf_268 = GetPlayerState("shot_lbtb_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_268 = False
End Function
Function Glf_269(args)
	On Error Resume Next
	    Glf_269 = GetPlayerState("shot_lbtb_minigame") = 1
	If Err Then Glf_269 = False
End Function
Function Glf_270(args)
	On Error Resume Next
	    Glf_270 = GetPlayerState("shot_fd_punch_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_270 = False
End Function
Function Glf_271(args)
	On Error Resume Next
	    Glf_271 = GetPlayerState("shot_fd_punch_minigame") = 1
	If Err Then Glf_271 = False
End Function
Function Glf_272(args)
	On Error Resume Next
	    Glf_272 = glf_modes("bonus").GetValue("active") = False
	If Err Then Glf_272 = False
End Function
Function Glf_273(args)
	On Error Resume Next
	    Glf_273 = GetPlayerState("shot_dance_marathon_minigame") = 0
	If Err Then Glf_273 = False
End Function
Function Glf_274(args)
	On Error Resume Next
	    Glf_274 = GetPlayerState("shot_town_meeting_minigame") = 0
	If Err Then Glf_274 = False
End Function
Function Glf_275(args)
	On Error Resume Next
	    Glf_275 = GetPlayerState("shot_dinner_minigame") = 0
	If Err Then Glf_275 = False
End Function
Function Glf_276(args)
	On Error Resume Next
	    Glf_276 = GetPlayerState("shot_kims_antiques_minigame") = 0
	If Err Then Glf_276 = False
End Function
Function Glf_277(args)
	On Error Resume Next
	    Glf_277 = GetPlayerState("shot_lbtb_minigame") = 0
	If Err Then Glf_277 = False
End Function
Function Glf_278(args)
	On Error Resume Next
	    Glf_278 = GetPlayerState("shot_fd_punch_minigame") = 0
	If Err Then Glf_278 = False
End Function
Function Glf_279(args)
	On Error Resume Next
	    Glf_279 = GetPlayerState("extra_balls") = 0
	If Err Then Glf_279 = False
End Function
Function Glf_280(args)
	On Error Resume Next
	    Glf_280 = GetPlayerState("extra_balls") > 0
	If Err Then Glf_280 = False
End Function
Function Glf_281(args)
	On Error Resume Next
	    Glf_281 = GetPlayerState("shot_eb_ready") = 1
	If Err Then Glf_281 = False
End Function
Function Glf_282(args)
	On Error Resume Next
	    Glf_282 = GetPlayerState("extra_ball_eb_awarded") < 3
	If Err Then Glf_282 = False
End Function
Function Glf_283(args)
	On Error Resume Next
	    Glf_283 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_283 = False
End Function
Function Glf_284(args)
	On Error Resume Next
	    Glf_284 = GetPlayerState("shot_ramp") = 1
	If Err Then Glf_284 = False
End Function
Function Glf_285(args)
	On Error Resume Next
	    Glf_285 = glf_timers("dm_intro_delay").GetValue("ticks") = 27
	If Err Then Glf_285 = False
End Function
Function Glf_286(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "DANCE MARATHON"
	kwargs.Add "instructions", "HIT FLASHING SHOTS TO SCORE"
	Set Glf_286 = kwargs
	If Err Then Glf_286 = Null
End Function
Function Glf_287(args)
	Glf_287 = 500000
End Function
Function Glf_288(args)
	Glf_288 = 100000
End Function
Function Glf_289(args)
	Glf_289 = GetPlayerState("mode_dance_marathon_score")
End Function
Function Glf_290(args)
	Glf_290 = glf_dispatch_current_kwargs("ticks_remaining")
End Function
Function Glf_291(args)
	Glf_291 = 250000
End Function
Function Glf_292(args)
	Glf_292 = 1250000
End Function
Function Glf_293(args)
	Glf_293 = 28
End Function
Function Glf_294(args)
	On Error Resume Next
	    Glf_294 = glf_timers("dm_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_294 = False
End Function
Function Glf_295(args)
	Glf_295 = 15
End Function
Function Glf_296(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "TOWN MEETING"
	kwargs.Add "instructions", "HIT FLASHING SHOTS TO SCORE"
	Set Glf_296 = kwargs
	If Err Then Glf_296 = Null
End Function
Function Glf_297(args)
	On Error Resume Next
	    Glf_297 = glf_timers("town_meeting_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_297 = False
End Function
Function Glf_298(args)
	Glf_298 = 7
End Function
Function Glf_299(args)
	Glf_299 = 20
End Function
Function Glf_300(args)
	Glf_300 = GetPlayerState("mode_town_meeting_score")
End Function
Function Glf_301(args)
	Glf_301 = 750000
End Function
Function Glf_302(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "FRIDAY NIGHT DINNER"
	kwargs.Add "instructions", "SHOOT ORBITS TO SCORE"
	Set Glf_302 = kwargs
	If Err Then Glf_302 = Null
End Function
Function Glf_303(args)
	Glf_303 = 9
End Function
Function Glf_304(args)
	On Error Resume Next
	    Glf_304 = glf_timers("dinner_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_304 = False
End Function
Function Glf_305(args)
	Glf_305 = GetPlayerState("mode_dinner_score")
End Function
Function Glf_306(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "FOUNDER'S DAY PUNCH"
	kwargs.Add "instructions", "SHOOT LUKE'S OR MANSION TO SCORE"
	Set Glf_306 = kwargs
	If Err Then Glf_306 = Null
End Function
Function Glf_307(args)
	On Error Resume Next
	    Glf_307 = glf_timers("fd_punch_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_307 = False
End Function
Function Glf_308(args)
	Glf_308 = GetPlayerState("mode_fd_punch_score")
End Function
Function Glf_309(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "AVOID MS. KIM"
	kwargs.Add "instructions", "3X SCORING - RIGHT RAMP JACKPOT"
	Set Glf_309 = kwargs
	If Err Then Glf_309 = Null
End Function
Function Glf_310(args)
	On Error Resume Next
	    Glf_310 = glf_dispatch_current_kwargs("ticks") = 1 And GetPlayerState("kims_warning_active") = 0
	If Err Then Glf_310 = False
End Function
Function Glf_311(args)
	On Error Resume Next
	    Glf_311 = GetPlayerState("shot_kims_jackpot") = 1
	If Err Then Glf_311 = False
End Function
Function Glf_312(args)
	On Error Resume Next
	    Glf_312 = GetPlayerState("shot_kims_jackpot") = 1
	If Err Then Glf_312 = False
End Function
Function Glf_313(args)
	On Error Resume Next
	    Glf_313 = glf_timers("kims_antiques_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_313 = False
End Function
Function Glf_314(args)
	Glf_314 = GetPlayerState("mode_kims_antiques_score")
End Function
Function Glf_315(args)
	Glf_315 = 1000000
End Function
Function Glf_316(args)
	On Error Resume Next
	    Glf_316 = GetPlayerState("shot_kims_antiques_left_ramp") <> 2
	If Err Then Glf_316 = False
End Function
Function Glf_317(args)
	On Error Resume Next
	    Glf_317 = GetPlayerState("shot_kims_antiques_right_ramp") <> 2
	If Err Then Glf_317 = False
End Function
Function Glf_318(args)
	On Error Resume Next
	    Glf_318 = GetPlayerState("shot_kims_antiques_captive") <> 2
	If Err Then Glf_318 = False
End Function
Function Glf_319(args)
	On Error Resume Next
	    Glf_319 = GetPlayerState("shot_kims_antiques_scoop") <> 2
	If Err Then Glf_319 = False
End Function
Function Glf_320(args)
	On Error Resume Next
	    Glf_320 = GetPlayerState("shot_kims_antiques_orbit_left") <> 2
	If Err Then Glf_320 = False
End Function
Function Glf_321(args)
	On Error Resume Next
	    Glf_321 = GetPlayerState("shot_kims_antiques_orbit_right") <> 2
	If Err Then Glf_321 = False
End Function
Function Glf_322(args)
	On Error Resume Next
	    Glf_322 = GetPlayerState("shot_kims_antiques_left_ramp") = 1
	If Err Then Glf_322 = False
End Function
Function Glf_323(args)
	On Error Resume Next
	    Glf_323 = GetPlayerState("shot_kims_antiques_left_ramp") = 2
	If Err Then Glf_323 = False
End Function
Function Glf_324(args)
	On Error Resume Next
	    Glf_324 = GetPlayerState("shot_kims_antiques_right_ramp") = 1
	If Err Then Glf_324 = False
End Function
Function Glf_325(args)
	On Error Resume Next
	    Glf_325 = GetPlayerState("shot_kims_antiques_right_ramp") = 2
	If Err Then Glf_325 = False
End Function
Function Glf_326(args)
	On Error Resume Next
	    Glf_326 = GetPlayerState("shot_kims_antiques_captive") = 1
	If Err Then Glf_326 = False
End Function
Function Glf_327(args)
	On Error Resume Next
	    Glf_327 = GetPlayerState("shot_kims_antiques_captive") = 2
	If Err Then Glf_327 = False
End Function
Function Glf_328(args)
	On Error Resume Next
	    Glf_328 = GetPlayerState("shot_kims_antiques_scoop") = 1
	If Err Then Glf_328 = False
End Function
Function Glf_329(args)
	On Error Resume Next
	    Glf_329 = GetPlayerState("shot_kims_antiques_scoop") = 2
	If Err Then Glf_329 = False
End Function
Function Glf_330(args)
	On Error Resume Next
	    Glf_330 = GetPlayerState("shot_kims_antiques_orbit_left") = 1
	If Err Then Glf_330 = False
End Function
Function Glf_331(args)
	On Error Resume Next
	    Glf_331 = GetPlayerState("shot_kims_antiques_orbit_left") = 2
	If Err Then Glf_331 = False
End Function
Function Glf_332(args)
	On Error Resume Next
	    Glf_332 = GetPlayerState("shot_kims_antiques_orbit_right") = 1
	If Err Then Glf_332 = False
End Function
Function Glf_333(args)
	On Error Resume Next
	    Glf_333 = GetPlayerState("shot_kims_antiques_orbit_right") = 2
	If Err Then Glf_333 = False
End Function
Function Glf_334(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "LUKE BREAKS THE BELLS!"
	kwargs.Add "instructions", "BREAK BELLS TO SCORE"
	Set Glf_334 = kwargs
	If Err Then Glf_334 = Null
End Function
Function Glf_335(args)
	On Error Resume Next
	    Glf_335 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_335 = False
End Function
Function Glf_336(args)
	On Error Resume Next
	    Glf_336 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_336 = False
End Function
Function Glf_337(args)
	On Error Resume Next
	    Glf_337 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_337 = False
End Function
Function Glf_338(args)
	On Error Resume Next
	    Glf_338 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_338 = False
End Function
Function Glf_339(args)
	On Error Resume Next
	    Glf_339 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_339 = False
End Function
Function Glf_340(args)
	On Error Resume Next
	    Glf_340 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_340 = False
End Function
Function Glf_341(args)
	Glf_341 = 11.5
End Function
Function Glf_342(args)
	On Error Resume Next
	    Glf_342 = glf_timers("lbtb_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_342 = False
End Function
Function Glf_343(args)
	On Error Resume Next
	    Glf_343 = glf_drop_targets("drop3").GetValue("state") = 1
	If Err Then Glf_343 = False
End Function
Function Glf_344(args)
	On Error Resume Next
	    Glf_344 = glf_drop_targets("drop4").GetValue("state") = 1
	If Err Then Glf_344 = False
End Function
Function Glf_345(args)
	On Error Resume Next
	    Glf_345 = glf_drop_targets("drop5").GetValue("state") = 1
	If Err Then Glf_345 = False
End Function
Function Glf_346(args)
	On Error Resume Next
	    Glf_346 = glf_drop_targets("drop6").GetValue("state") = 1
	If Err Then Glf_346 = False
End Function
Function Glf_347(args)
	On Error Resume Next
	    Glf_347 = glf_drop_targets("drop7").GetValue("state") = 1
	If Err Then Glf_347 = False
End Function
Function Glf_348(args)
	On Error Resume Next
	    Glf_348 = glf_drop_targets("drop8").GetValue("state") = 1
	If Err Then Glf_348 = False
End Function
Function Glf_349(args)
	Glf_349 = GetPlayerState("mode_lbtb_score")
End Function
Function Glf_350(args)
	Glf_350 = LbtbTime
End Function
Function Glf_351(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "LOCK-AWAY LOGAN"
	kwargs.Add "instructions", "HIT BUMPERS TO BASH LOGAN"
	Set Glf_351 = kwargs
	If Err Then Glf_351 = Null
End Function
Function Glf_352(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "LOCK-AWAY LOGAN"
	kwargs.Add "instructions", "LOCK-AWAY LOGAN IN THE SCOOP"
	Set Glf_352 = kwargs
	If Err Then Glf_352 = Null
End Function
Function Glf_353(args)
	On Error Resume Next
	    Glf_353 = GetPlayerState("shot_win_logan_light")=0
	If Err Then Glf_353 = False
End Function
Function Glf_354(args)
	On Error Resume Next
	    Glf_354 = GetPlayerState("shot_win_logan_light")=0
	If Err Then Glf_354 = False
End Function
Function Glf_355(args)
	On Error Resume Next
	    Glf_355 = GetPlayerState("mode_llmb_score")>=2500000
	If Err Then Glf_355 = False
End Function
Function Glf_356(args)
	On Error Resume Next
	    Glf_356 = GetPlayerState("shot_win_logan_light")=0
	If Err Then Glf_356 = False
End Function
Function Glf_357(args)
	On Error Resume Next
	    Glf_357 = GetPlayerState("shot_win_logan_light")=1 and glf_machine_vars("captive_capture_pending").GetValue()=0
	If Err Then Glf_357 = False
End Function
Function Glf_358(args)
	On Error Resume Next
	    Glf_358 = GetPlayerState("shot_win_logan_light")=1 and glf_machine_vars("captive_capture_pending").GetValue()=1
	If Err Then Glf_358 = False
End Function
Function Glf_359(args)
	On Error Resume Next
	    Glf_359 = GetPlayerState("llmb_won") = 0
	If Err Then Glf_359 = False
End Function
Function Glf_360(args)
	On Error Resume Next
	    Glf_360 = GetPlayerState("llmb_won") = 1
	If Err Then Glf_360 = False
End Function
Function Glf_361(args)
	Glf_361 = GetPlayerState("mode_llmb_score")
End Function
Function Glf_362(args)
	Glf_362 = 7500000
End Function
Function Glf_363(args)
	Glf_363 = 50000
End Function
Function Glf_364(args)
	Glf_364 = 10000
End Function
Function Glf_365(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text", "JESS VS. DEAN" & Chr(58) & " TO THE DEATH"
	kwargs.Add "instructions", "SHOOT RAMPS TO SCORE"
	Set Glf_365 = kwargs
	If Err Then Glf_365 = Null
End Function
Function Glf_366(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_366 = kwargs
	If Err Then Glf_366 = Null
End Function
Function Glf_367(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 1
	Set Glf_367 = kwargs
	If Err Then Glf_367 = Null
End Function
Function Glf_368(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_368 = kwargs
	If Err Then Glf_368 = Null
End Function
Function Glf_369(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 2
	Set Glf_369 = kwargs
	If Err Then Glf_369 = Null
End Function
Function Glf_370(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_370 = kwargs
	If Err Then Glf_370 = Null
End Function
Function Glf_371(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 3
	Set Glf_371 = kwargs
	If Err Then Glf_371 = Null
End Function
Function Glf_372(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 4
	Set Glf_372 = kwargs
	If Err Then Glf_372 = Null
End Function
Function Glf_373(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "light", 4
	Set Glf_373 = kwargs
	If Err Then Glf_373 = Null
End Function
Function Glf_374(args)
	Glf_374 = 12
End Function
Function Glf_375(args)
	On Error Resume Next
	    Glf_375 = GetPlayerState("jd_winner") = 1
	If Err Then Glf_375 = False
End Function
Function Glf_376(args)
	On Error Resume Next
	    Glf_376 = GetPlayerState("jd_winner") = 2
	If Err Then Glf_376 = False
End Function
Function Glf_377(args)
	On Error Resume Next
	    Glf_377 = GetPlayerState("jd_winner") = 0
	If Err Then Glf_377 = False
End Function
Function Glf_378(args)
	Glf_378 = GetPlayerState("mode_jdmb_score")
End Function
Function Glf_379(args)
	Glf_379 = 4000000
End Function
Function Glf_380(args)
	On Error Resume Next
	    Glf_380 = glf_dispatch_current_kwargs("light") = 0
	If Err Then Glf_380 = False
End Function
Function Glf_381(args)
	On Error Resume Next
	    Glf_381 = glf_dispatch_current_kwargs("light") = 1
	If Err Then Glf_381 = False
End Function
Function Glf_382(args)
	On Error Resume Next
	    Glf_382 = glf_dispatch_current_kwargs("light") = 2
	If Err Then Glf_382 = False
End Function
Function Glf_383(args)
	On Error Resume Next
	    Glf_383 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_383 = False
End Function
Function Glf_384(args)
	On Error Resume Next
	    Glf_384 = glf_dispatch_current_kwargs("light") = 4
	If Err Then Glf_384 = False
End Function
Function Glf_385(args)
	On Error Resume Next
	    Glf_385 = glf_dispatch_current_kwargs("light") = 0
	If Err Then Glf_385 = False
End Function
Function Glf_386(args)
	On Error Resume Next
	    Glf_386 = glf_dispatch_current_kwargs("light") = 1
	If Err Then Glf_386 = False
End Function
Function Glf_387(args)
	On Error Resume Next
	    Glf_387 = glf_dispatch_current_kwargs("light") = 2
	If Err Then Glf_387 = False
End Function
Function Glf_388(args)
	On Error Resume Next
	    Glf_388 = glf_dispatch_current_kwargs("light") = 3
	If Err Then Glf_388 = False
End Function
Function Glf_389(args)
	On Error Resume Next
	    Glf_389 = glf_dispatch_current_kwargs("light") = 4
	If Err Then Glf_389 = False
End Function
Function Glf_390(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 500000
	Set Glf_390 = kwargs
	If Err Then Glf_390 = Null
End Function
Function Glf_391(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 500000 + glf_timers("hurryup").GetValue("ticks") * 7500
	Set Glf_391 = kwargs
	If Err Then Glf_391 = Null
End Function
Function Glf_392(args)
	On Error Resume Next
	    Glf_392 = glf_timers("hurryup").GetValue("ticks") <> 0
	If Err Then Glf_392 = False
End Function
Function Glf_393(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 500000 + glf_timers("hurryup").GetValue("ticks") * 7500
	Set Glf_393 = kwargs
	If Err Then Glf_393 = Null
End Function
Function Glf_394(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "points", 500000 + glf_timers("hurryup").GetValue("ticks") * 7500
	Set Glf_394 = kwargs
	If Err Then Glf_394 = Null
End Function
Function Glf_395(args)
	On Error Resume Next
	    Glf_395 = GetPlayerState("shot_mystery_ready")=0
	If Err Then Glf_395 = False
End Function
Function Glf_396(args)
	On Error Resume Next
	    Glf_396 = GetPlayerState("shot_mystery_ready")=1 and glf_modes("jd_multiball").GetValue("active")=False and glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_396 = False
End Function
Function Glf_397(args)
	On Error Resume Next
	    Glf_397 = devices.timers.mystery_show.ticks = 1
	If Err Then Glf_397 = False
End Function
Function Glf_398(args)
	On Error Resume Next
	    Glf_398 = GetPlayerState("mystery_award") = 0
	If Err Then Glf_398 = False
End Function
Function Glf_399(args)
	On Error Resume Next
	    Glf_399 = GetPlayerState("mystery_award") = 1
	If Err Then Glf_399 = False
End Function
Function Glf_400(args)
	On Error Resume Next
	    Glf_400 = GetPlayerState("mystery_award") = 2
	If Err Then Glf_400 = False
End Function
Function Glf_401(args)
	On Error Resume Next
	    Glf_401 = GetPlayerState("mystery_award") = 3
	If Err Then Glf_401 = False
End Function
Function Glf_402(args)
	On Error Resume Next
	    Glf_402 = GetPlayerState("mystery_award") = 4
	If Err Then Glf_402 = False
End Function
Function Glf_403(args)
	On Error Resume Next
	    Glf_403 = GetPlayerState("mystery_award") = 5
	If Err Then Glf_403 = False
End Function
Function Glf_404(args)
	On Error Resume Next
	    Glf_404 = GetPlayerState("mystery_award") = 6
	If Err Then Glf_404 = False
End Function
Function Glf_405(args)
	On Error Resume Next
	    Glf_405 = GetPlayerState("mystery_award") = 7
	If Err Then Glf_405 = False
End Function
Function Glf_406(args)
	On Error Resume Next
	    Glf_406 = GetPlayerState("shot_eb_ready") < 1
	If Err Then Glf_406 = False
End Function
Function Glf_407(args)
	On Error Resume Next
	    Glf_407 = glf_modes("jd_multiball").GetValue("active")=False and glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_407 = False
End Function
Function Glf_408(args)
	On Error Resume Next
	    Glf_408 = GetPlayerState("bonus_x") < 8
	If Err Then Glf_408 = False
End Function
Function Glf_409(args)
	On Error Resume Next
	    Glf_409 = glf_modes("jd_multiball").GetValue("active")=False and glf_modes("ll_multiball").GetValue("active")=False and glf_modes("dance_marathon").GetValue("active")=False and glf_modes("town_meeting").GetValue("active")=False and glf_modes("dinner").GetValue("active")=False and glf_modes("kims_antiques").GetValue("active")=False and glf_modes("lbtb").GetValue("active")=False and glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_409 = False
End Function
Function Glf_410(args)
	On Error Resume Next
	    Glf_410 = GetPlayerState("shot_logan_qualify") <= 1
	If Err Then Glf_410 = False
End Function
Function Glf_411(args)
	Glf_411 = 1010 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_412(args)
	Glf_412 = 1010
End Function
Function Glf_413(args)
	Glf_413 = 2510 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_414(args)
	Glf_414 = 2510
End Function
Function Glf_415(args)
	Glf_415 = 5010 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_416(args)
	Glf_416 = 5010
End Function
Function Glf_417(args)
	Glf_417 = 1510 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_418(args)
	Glf_418 = 1510
End Function
Function Glf_419(args)
	Glf_419 = 25000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_420(args)
	Glf_420 = 25000
End Function
Function Glf_421(args)
	Glf_421 = 12500 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_422(args)
	Glf_422 = 12500
End Function
Function Glf_423(args)
	Glf_423 = 20000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_424(args)
	Glf_424 = 10010 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_425(args)
	Glf_425 = 10010
End Function
Function Glf_426(args)
	Glf_426 = 50000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_427(args)
	Glf_427 = 150000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_428(args)
	Glf_428 = 150000
End Function
Function Glf_429(args)
	Glf_429 = 100000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_430(args)
	Glf_430 = 250000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_431(args)
	Glf_431 = 750000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_432(args)
	Glf_432 = 200000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_433(args)
	Glf_433 = 200000
End Function
Function Glf_434(args)
	Glf_434 = 400000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_435(args)
	Glf_435 = 400000
End Function
Function Glf_436(args)
	Glf_436 = 1000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_437(args)
	Glf_437 = 2500000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_438(args)
	Glf_438 = 2500000
End Function
Function Glf_439(args)
	Glf_439 = 500000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_440(args)
	Glf_440 = 2000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_441(args)
	Glf_441 = 2000000
End Function
Function Glf_442(args)
	Glf_442 = 1250000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_443(args)
	Glf_443 = 4000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_444(args)
	Glf_444 = 7500000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_445(args)
	Glf_445 = 5000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_446(args)
	Glf_446 = 5000000
End Function
Function Glf_447(args)
	Glf_447 = 100000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_448(args)
	Glf_448 = 100000000
End Function
Function Glf_449(args)
	Glf_449 = 1000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_450(args)
	Glf_450 = 2000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_451(args)
	Glf_451 = 5000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_452(args)
	Glf_452 = 7500 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_453(args)
	Glf_453 = 15000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_454(args)
	Glf_454 = 15000000
End Function
Function Glf_455(args)
	Glf_455 = glf_dispatch_current_kwargs("points") * GetPlayerState("scoring_multiplier")
End Function
Function Glf_456(args)
	Glf_456 = glf_dispatch_current_kwargs("points")
End Function
Function Glf_457(args)
	Glf_457 = 8
End Function
Function Glf_458(args)
	Glf_458 = 250
End Function
Function Glf_459(args)
	Glf_459 = 1500
End Function
Function Glf_460(args)
	Glf_460 = 500
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
Dim glf_DeanLight1_lmarr : glf_DeanLight1_lmarr = Array()
glf_lightMaps.Add "DeanLight1", glf_DeanLight1_lmarr
Dim glf_DeanLight2_lmarr : glf_DeanLight2_lmarr = Array()
glf_lightMaps.Add "DeanLight2", glf_DeanLight2_lmarr
Dim glf_DeanLight3_lmarr : glf_DeanLight3_lmarr = Array()
glf_lightMaps.Add "DeanLight3", glf_DeanLight3_lmarr
Dim glf_DeanLight4_lmarr : glf_DeanLight4_lmarr = Array()
glf_lightMaps.Add "DeanLight4", glf_DeanLight4_lmarr
Dim glf_JessLight1_lmarr : glf_JessLight1_lmarr = Array()
glf_lightMaps.Add "JessLight1", glf_JessLight1_lmarr
Dim glf_JessLight2_lmarr : glf_JessLight2_lmarr = Array()
glf_lightMaps.Add "JessLight2", glf_JessLight2_lmarr
Dim glf_JessLight3_lmarr : glf_JessLight3_lmarr = Array()
glf_lightMaps.Add "JessLight3", glf_JessLight3_lmarr
Dim glf_JessLight4_lmarr : glf_JessLight4_lmarr = Array()
glf_lightMaps.Add "JessLight4", glf_JessLight4_lmarr
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
glf_funcRefMap.Add "45000", "Glf_5"
glf_funcRefMap.Add "6000", "Glf_6"
glf_funcRefMap.Add "reset_complete{modes.attract.active==False}", "Glf_7"
glf_funcRefMap.Add "game_ended{modes.attract.active==False}", "Glf_8"
glf_funcRefMap.Add "mode_attract_started{modes.post_game.active == False}", "Glf_9"
glf_funcRefMap.Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 1}", "Glf_10"
glf_funcRefMap.Add "timer_attract_pulse_tick{devices.timers.attract_pulse.ticks == 3}", "Glf_11"
glf_funcRefMap.Add "credits_added{device.timers.attract_insert_coins.ticks == 4}", "Glf_12"
glf_funcRefMap.Add "not_enough_credits{device.timers.attract_insert_coins.ticks == 4}", "Glf_13"
glf_funcRefMap.Add "s_right_flipper_active{device.timers.attract_insert_coins.ticks == 4}", "Glf_14"
glf_funcRefMap.Add "0", "Glf_15"
glf_funcRefMap.Add "-1", "Glf_16"
glf_funcRefMap.Add "6", "Glf_17"
glf_funcRefMap.Add "3", "Glf_18"
glf_funcRefMap.Add "4", "Glf_19"
glf_funcRefMap.Add "check_start_button{(machine.credits_whole_num >= 1 or machine.free_play == 1) and (game.num_players == 0 or (game.num_players < game.max_players and current_player.ball == 1))}", "Glf_20"
glf_funcRefMap.Add "check_start_button{(machine.credits_whole_num < 1 and machine.free_play == 0) or (game.num_players > 0 and (game.num_players >= game.max_players or current_player.ball > 1))}", "Glf_21"
glf_funcRefMap.Add "ball_ending{game.tilted == True}", "Glf_22"
glf_funcRefMap.Add "s_captive_ball_active{machine.captive_ball_captive == 0}", "Glf_23"
glf_funcRefMap.Add "ball_drain{machine.captive_ball_captive == 0 and current_player.llmb_shoot_again_active == 0}", "Glf_24"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{modes.base.active == False}", "Glf_25"
glf_funcRefMap.Add "1", "Glf_26"
glf_funcRefMap.Add "player_added{kwargs.num > 1}", "Glf_27"
glf_funcRefMap.Add "player_added{kwargs.num == 2}", "Glf_28"
glf_funcRefMap.Add "player_added{kwargs.num == 3}", "Glf_29"
glf_funcRefMap.Add "player_added{kwargs.num == 4}", "Glf_30"
glf_funcRefMap.Add "10", "Glf_31"
glf_funcRefMap.Add "s_Trigger1_inactive{current_player.ball_just_started == 1}", "Glf_32"
glf_funcRefMap.Add "drop_target_drop1_down{modes.fd_punch.active==False}", "Glf_33"
glf_funcRefMap.Add "timer_base_music_complete{modes.bonus.active == False and modes.dance_marathon.active == False and modes.town_meeting.active == False and modes.dinner.active == False and modes.fd_punch.active == False and modes.kims_antiques.active == False and modes.lbtb.active == False}", "Glf_34"
glf_funcRefMap.Add "200", "Glf_35"
glf_funcRefMap.Add "244.8", "Glf_36"
glf_funcRefMap.Add "51.293333", "Glf_37"
glf_funcRefMap.Add "36.506667", "Glf_38"
glf_funcRefMap.Add "188.866667", "Glf_39"
glf_funcRefMap.Add "53.04", "Glf_40"
glf_funcRefMap.Add "234.826667", "Glf_41"
glf_funcRefMap.Add "332.76", "Glf_42"
glf_funcRefMap.Add "grandparents_callout{modes.fd_punch.active==False and modes.dinner.active==False}", "Glf_43"
glf_funcRefMap.Add "diner_callout{modes.fd_punch.active==False}", "Glf_44"
glf_funcRefMap.Add "auto_fire_coil_bumper1_activate{modes.ll_multiball.active==False}", "Glf_45"
glf_funcRefMap.Add "auto_fire_coil_bumper5_activate{modes.ll_multiball.active==False}", "Glf_46"
glf_funcRefMap.Add "auto_fire_coil_right_sling_activate{modes.lbtb.active==False}", "Glf_47"
glf_funcRefMap.Add "auto_fire_coil_left_sling_activate{modes.lbtb.active==False}", "Glf_48"
glf_funcRefMap.Add "mode_base_started{game.num_players > 1 and current_player.number == 1}", "Glf_49"
glf_funcRefMap.Add "mode_base_started{game.num_players > 1 and current_player.number == 2}", "Glf_50"
glf_funcRefMap.Add "mode_base_started{game.num_players > 1 and current_player.number == 3}", "Glf_51"
glf_funcRefMap.Add "mode_base_started{game.num_players > 1 and current_player.number == 4}", "Glf_52"
glf_funcRefMap.Add "15000", "Glf_53"
glf_funcRefMap.Add "5000", "Glf_54"
glf_funcRefMap.Add "3000", "Glf_55"
glf_funcRefMap.Add "2000", "Glf_56"
glf_funcRefMap.Add "game_end_pause_done{machine.game_modes_enabled == 1}", "Glf_57"
glf_funcRefMap.Add "s_right_magna_key_active{current_player.hs_input_ready == 1}", "Glf_58"
glf_funcRefMap.Add "s_plunger_key_active{current_player.hs_input_ready == 1}", "Glf_59"
glf_funcRefMap.Add "s_lockbar_key_active{current_player.hs_input_ready == 1}", "Glf_60"
glf_funcRefMap.Add "s_start_active{current_player.hs_input_ready == 1}", "Glf_61"
glf_funcRefMap.Add "text_inputted.1{machine.high_score_initials_chars == 3}", "Glf_62"
glf_funcRefMap.Add "text_input_high_score_complete:{text: machine.high_score_initials}", "Glf_63"
glf_funcRefMap.Add "high_score_enter_initials{machine.high_score_music_started == 0}", "Glf_65"
glf_funcRefMap.Add "text_inputted{machine.high_score_initials_chars < 3}", "Glf_66"
glf_funcRefMap.Add "players[0].score", "Glf_67"
glf_funcRefMap.Add "s_left_flipper_active.2{current_player.hs_input_ready == 1}", "Glf_68"
glf_funcRefMap.Add "s_right_flipper_active.2{current_player.hs_input_ready == 1}", "Glf_69"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 0}", "Glf_70"
glf_funcRefMap.Add "machine.high_score_initials & ""A""", "Glf_71"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 1}", "Glf_72"
glf_funcRefMap.Add "machine.high_score_initials & ""B""", "Glf_73"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 2}", "Glf_74"
glf_funcRefMap.Add "machine.high_score_initials & ""C""", "Glf_75"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 3}", "Glf_76"
glf_funcRefMap.Add "machine.high_score_initials & ""D""", "Glf_77"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 4}", "Glf_78"
glf_funcRefMap.Add "machine.high_score_initials & ""E""", "Glf_79"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 5}", "Glf_80"
glf_funcRefMap.Add "machine.high_score_initials & ""F""", "Glf_81"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 6}", "Glf_82"
glf_funcRefMap.Add "machine.high_score_initials & ""G""", "Glf_83"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 7}", "Glf_84"
glf_funcRefMap.Add "machine.high_score_initials & ""H""", "Glf_85"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 8}", "Glf_86"
glf_funcRefMap.Add "machine.high_score_initials & ""I""", "Glf_87"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 9}", "Glf_88"
glf_funcRefMap.Add "machine.high_score_initials & ""J""", "Glf_89"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 10}", "Glf_90"
glf_funcRefMap.Add "machine.high_score_initials & ""K""", "Glf_91"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 11}", "Glf_92"
glf_funcRefMap.Add "machine.high_score_initials & ""L""", "Glf_93"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 12}", "Glf_94"
glf_funcRefMap.Add "machine.high_score_initials & ""M""", "Glf_95"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 13}", "Glf_96"
glf_funcRefMap.Add "machine.high_score_initials & ""N""", "Glf_97"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 14}", "Glf_98"
glf_funcRefMap.Add "machine.high_score_initials & ""O""", "Glf_99"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 15}", "Glf_100"
glf_funcRefMap.Add "machine.high_score_initials & ""P""", "Glf_101"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 16}", "Glf_102"
glf_funcRefMap.Add "machine.high_score_initials & ""Q""", "Glf_103"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 17}", "Glf_104"
glf_funcRefMap.Add "machine.high_score_initials & ""R""", "Glf_105"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 18}", "Glf_106"
glf_funcRefMap.Add "machine.high_score_initials & ""S""", "Glf_107"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 19}", "Glf_108"
glf_funcRefMap.Add "machine.high_score_initials & ""T""", "Glf_109"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 20}", "Glf_110"
glf_funcRefMap.Add "machine.high_score_initials & ""U""", "Glf_111"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 21}", "Glf_112"
glf_funcRefMap.Add "machine.high_score_initials & ""V""", "Glf_113"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 22}", "Glf_114"
glf_funcRefMap.Add "machine.high_score_initials & ""W""", "Glf_115"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 23}", "Glf_116"
glf_funcRefMap.Add "machine.high_score_initials & ""X""", "Glf_117"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 24}", "Glf_118"
glf_funcRefMap.Add "machine.high_score_initials & ""Y""", "Glf_119"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 25}", "Glf_120"
glf_funcRefMap.Add "machine.high_score_initials & ""Z""", "Glf_121"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 26}", "Glf_122"
glf_funcRefMap.Add "machine.high_score_initials & ""0""", "Glf_123"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 27}", "Glf_124"
glf_funcRefMap.Add "machine.high_score_initials & ""1""", "Glf_125"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 28}", "Glf_126"
glf_funcRefMap.Add "machine.high_score_initials & ""2""", "Glf_127"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 29}", "Glf_128"
glf_funcRefMap.Add "machine.high_score_initials & ""3""", "Glf_129"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 30}", "Glf_130"
glf_funcRefMap.Add "machine.high_score_initials & ""4""", "Glf_131"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 31}", "Glf_132"
glf_funcRefMap.Add "machine.high_score_initials & ""5""", "Glf_133"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 32}", "Glf_134"
glf_funcRefMap.Add "machine.high_score_initials & ""6""", "Glf_135"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 33}", "Glf_136"
glf_funcRefMap.Add "machine.high_score_initials & ""7""", "Glf_137"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 34}", "Glf_138"
glf_funcRefMap.Add "machine.high_score_initials & ""8""", "Glf_139"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 35}", "Glf_140"
glf_funcRefMap.Add "machine.high_score_initials & ""9""", "Glf_141"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 36}", "Glf_142"
glf_funcRefMap.Add "machine.high_score_initials & ""_""", "Glf_143"
glf_funcRefMap.Add """""", "Glf_144"
glf_funcRefMap.Add "{kwargs.player_num}", "Glf_145"
glf_funcRefMap.Add "60", "Glf_146"
glf_funcRefMap.Add "5", "Glf_147"
glf_funcRefMap.Add "current_player.bonus_x * 1000", "Glf_148"
glf_funcRefMap.Add "7500", "Glf_149"
glf_funcRefMap.Add "1000", "Glf_150"
glf_funcRefMap.Add "bonus_entry{kwargs.entry == ""switches""}", "Glf_151"
glf_funcRefMap.Add "show_bonus_slide:{text:""BONUS "" & current_player.bonus_x & ""x"",score:current_player.bonus_x * BonusMultiplierFactor * current_player.total_switches_hit}", "Glf_152"
glf_funcRefMap.Add "bonus_entry{kwargs.entry == ""coffee""}", "Glf_153"
glf_funcRefMap.Add "show_bonus_slide:{text:""COFFEE COFFEE COFFEE"",score:current_player.bumper_count & "" CUPS x "" & BonusBumperFactor}", "Glf_154"
glf_funcRefMap.Add "bonus_entry{kwargs.entry == ""diners""}", "Glf_155"
glf_funcRefMap.Add "show_bonus_slide:{text:""LUKE'S DINER"",score:current_player.diner_count & "" MEALS x "" & BonusDinerFactor}", "Glf_156"
glf_funcRefMap.Add "bonus_entry{kwargs.entry == ""grandparents""}", "Glf_157"
glf_funcRefMap.Add "show_bonus_slide:{text:""GRANDPARENTS"",score:current_player.grandparents_count & "" VISITS x "" & BonusGrandparentsFactor}", "Glf_158"
glf_funcRefMap.Add "bonus_entry{kwargs.entry == ""talking""}", "Glf_159"
glf_funcRefMap.Add "show_bonus_slide:{text:""FAST TALKING"",score:current_player.spinner_count & "" QUIPS x "" & BonusSpinnerFactor}", "Glf_160"
glf_funcRefMap.Add "bonus_entry{kwargs.entry == ""total"" && current_player.bonus_skip == 0}", "Glf_161"
glf_funcRefMap.Add "bonus_entry{kwargs.entry == ""total"" && current_player.bonus_skip == 1}", "Glf_162"
glf_funcRefMap.Add "play_bonus_show1{current_player.mode_llmb_score > 0 && current_player.bonus_skip == 0}", "Glf_163"
glf_funcRefMap.Add "play_bonus_show1{current_player.mode_llmb_score == 0 && current_player.bonus_skip == 0}", "Glf_164"
glf_funcRefMap.Add "show_bonus_slide:{text:""LOCK-AWAY LOGAN"",score:current_player.mode_llmb_score}", "Glf_165"
glf_funcRefMap.Add "play_bonus_show2{current_player.mode_jdmb_score > 0 && current_player.bonus_skip == 0}", "Glf_166"
glf_funcRefMap.Add "play_bonus_show2{current_player.mode_jdmb_score == 0 && current_player.bonus_skip == 0}", "Glf_167"
glf_funcRefMap.Add "show_bonus_slide:{text:""JESS & DEAN"" & Chr(58) & "" TO THE DEATH"",score:current_player.mode_jdmb_score}", "Glf_168"
glf_funcRefMap.Add "play_bonus_show3{current_player.mode_dance_marathon_score > 0 && current_player.bonus_skip == 0}", "Glf_169"
glf_funcRefMap.Add "play_bonus_show3{current_player.mode_dance_marathon_score == 0 && current_player.bonus_skip == 0}", "Glf_170"
glf_funcRefMap.Add "show_bonus_slide:{text:""DANCE MARATHON"",score:current_player.mode_dance_marathon_score}", "Glf_171"
glf_funcRefMap.Add "play_bonus_show4{current_player.mode_town_meeting_score > 0 && current_player.bonus_skip == 0}", "Glf_172"
glf_funcRefMap.Add "play_bonus_show4{current_player.mode_town_meeting_score == 0 && current_player.bonus_skip == 0}", "Glf_173"
glf_funcRefMap.Add "show_bonus_slide:{text:""TOWN MEETING"",score:current_player.mode_town_meeting_score}", "Glf_174"
glf_funcRefMap.Add "play_bonus_show5{current_player.mode_lbtb_score > 0 && current_player.bonus_skip == 0}", "Glf_175"
glf_funcRefMap.Add "play_bonus_show5{current_player.mode_lbtb_score == 0 && current_player.bonus_skip == 0}", "Glf_176"
glf_funcRefMap.Add "show_bonus_slide:{text:""LUKE BREAKS THE BELLS"",score:current_player.mode_lbtb_score}", "Glf_177"
glf_funcRefMap.Add "play_bonus_show6{current_player.mode_kims_antiques_score > 0 && current_player.bonus_skip == 0}", "Glf_178"
glf_funcRefMap.Add "play_bonus_show6{current_player.mode_kims_antiques_score == 0 && current_player.bonus_skip == 0}", "Glf_179"
glf_funcRefMap.Add "show_bonus_slide:{text:""KIM'S ANTIQUES"",score:current_player.mode_kims_antiques_score}", "Glf_180"
glf_funcRefMap.Add "play_bonus_show7{current_player.mode_dinner_score > 0 && current_player.bonus_skip == 0}", "Glf_181"
glf_funcRefMap.Add "play_bonus_show7{current_player.mode_dinner_score == 0 && current_player.bonus_skip == 0}", "Glf_182"
glf_funcRefMap.Add "show_bonus_slide:{text:""FRIDAY NIGHT DINNER"",score:current_player.mode_dinner_score}", "Glf_183"
glf_funcRefMap.Add "play_bonus_show8{current_player.mode_fd_punch_score > 0 && current_player.bonus_skip == 0}", "Glf_184"
glf_funcRefMap.Add "play_bonus_show8{current_player.mode_fd_punch_score == 0 && current_player.bonus_skip == 0}", "Glf_185"
glf_funcRefMap.Add "show_bonus_slide:{text:""FOUNDER'S DAY PUNCH"",score:current_player.mode_fd_punch_score}", "Glf_186"
glf_funcRefMap.Add "play_bonus_show9{current_player.bonus_total > 0 && current_player.bonus_skip == 0}", "Glf_187"
glf_funcRefMap.Add "play_bonus_show9{current_player.bonus_total == 0 && current_player.bonus_skip == 0}", "Glf_188"
glf_funcRefMap.Add "show_bonus_slide:{text:""TOTAL BONUS"",score:current_player.bonus_total}", "Glf_189"
glf_funcRefMap.Add "timer_bonus_skip_complete{current_player.bonus_counted == 1}", "Glf_190"
glf_funcRefMap.Add "bonus_entry{kwargs.entry == ""total""}", "Glf_191"
glf_funcRefMap.Add "kwargs.score", "Glf_192"
glf_funcRefMap.Add "mode_skillshots_stopped{machine.game_modes_enabled == 1}", "Glf_193"
glf_funcRefMap.Add "mode_jd_multiball_qualify_started{current_player.is_lock_qualified == 0}", "Glf_194"
glf_funcRefMap.Add "mode_jd_multiball_qualify_started{current_player.is_lock_qualified == 1}", "Glf_195"
glf_funcRefMap.Add "s_lock3_trigger_active{current_player.multiball_lock_locked_balls == 2}", "Glf_196"
glf_funcRefMap.Add "multiball_lock_multiball_lock_locked_ball{kwargs.total_balls_locked == 1}", "Glf_197"
glf_funcRefMap.Add "multiball_lock_multiball_lock_locked_ball{kwargs.total_balls_locked == 2}", "Glf_198"
glf_funcRefMap.Add "s_sw7_active{current_player.shot_bonus_lane_7 == 0}", "Glf_199"
glf_funcRefMap.Add "s_sw7_active{current_player.shot_bonus_lane_7 == 1}", "Glf_200"
glf_funcRefMap.Add "s_sw8_active{current_player.shot_bonus_lane_8 == 0}", "Glf_201"
glf_funcRefMap.Add "s_sw8_active{current_player.shot_bonus_lane_8 == 1}", "Glf_202"
glf_funcRefMap.Add "s_sw9_active{current_player.shot_bonus_lane_9 == 0}", "Glf_203"
glf_funcRefMap.Add "s_sw9_active{current_player.shot_bonus_lane_9 == 1}", "Glf_204"
glf_funcRefMap.Add "mode_base_started{machine.game_modes_enabled == 1}", "Glf_205"
glf_funcRefMap.Add "mode_ll_multiball_qualify_started{current_player.shot_logan_qualify == 2}", "Glf_206"
glf_funcRefMap.Add "mode_ll_multiball_qualify_started{current_player.shot_logan_qualify == 3 and device.ball_holds.captive_ramp_kicker_hold.balls_held == 0}", "Glf_207"
glf_funcRefMap.Add "mode_ll_multiball_qualify_started{device.ball_holds.captive_ramp_kicker_hold.balls_held == 1}", "Glf_208"
glf_funcRefMap.Add "mode_base_stopping{device.ball_holds.captive_ramp_kicker_hold.balls_held == 1}", "Glf_209"
glf_funcRefMap.Add "s_captive_ball_active{current_player.logan_cooldown_active == 0}", "Glf_210"
glf_funcRefMap.Add "logan_captive_ball_hit{current_player.shot_logan_qualify == 0}", "Glf_211"
glf_funcRefMap.Add "logan_captive_ball_hit{current_player.shot_logan_qualify == 1}", "Glf_212"
glf_funcRefMap.Add "2", "Glf_213"
glf_funcRefMap.Add "sookie_lit:{light:1}", "Glf_214"
glf_funcRefMap.Add "sookie_lit:{light:2}", "Glf_215"
glf_funcRefMap.Add "sookie_lit:{light:3}", "Glf_216"
glf_funcRefMap.Add "sookie_lit{kwargs.light == 3}", "Glf_217"
glf_funcRefMap.Add "kirk_lit:{light:1}", "Glf_218"
glf_funcRefMap.Add "kirk_lit:{light:2}", "Glf_219"
glf_funcRefMap.Add "kirk_lit:{light:3}", "Glf_220"
glf_funcRefMap.Add "kirk_lit{kwargs.light == 3}", "Glf_221"
glf_funcRefMap.Add "lane_lit:{light:1}", "Glf_222"
glf_funcRefMap.Add "lane_lit:{light:2}", "Glf_223"
glf_funcRefMap.Add "lane_lit:{light:3}", "Glf_224"
glf_funcRefMap.Add "lane_lit{kwargs.light == 3}", "Glf_225"
glf_funcRefMap.Add "paris_lit:{light:1}", "Glf_226"
glf_funcRefMap.Add "paris_lit:{light:2}", "Glf_227"
glf_funcRefMap.Add "paris_lit:{light:3}", "Glf_228"
glf_funcRefMap.Add "paris_lit{kwargs.light == 3}", "Glf_229"
glf_funcRefMap.Add "sookie_lit{kwargs.light < 3}", "Glf_230"
glf_funcRefMap.Add "kirk_lit{kwargs.light < 3}", "Glf_231"
glf_funcRefMap.Add "lane_lit{kwargs.light < 3}", "Glf_232"
glf_funcRefMap.Add "paris_lit{kwargs.light < 3}", "Glf_233"
glf_funcRefMap.Add "sookie_lit{kwargs.light == 1}", "Glf_234"
glf_funcRefMap.Add "sookie_lit{kwargs.light == 2}", "Glf_235"
glf_funcRefMap.Add "50", "Glf_236"
glf_funcRefMap.Add "kirk_lit{kwargs.light == 1}", "Glf_237"
glf_funcRefMap.Add "kirk_lit{kwargs.light == 2}", "Glf_238"
glf_funcRefMap.Add "lane_lit{kwargs.light == 1}", "Glf_239"
glf_funcRefMap.Add "lane_lit{kwargs.light == 2}", "Glf_240"
glf_funcRefMap.Add "paris_lit{kwargs.light == 1}", "Glf_241"
glf_funcRefMap.Add "paris_lit{kwargs.light == 2}", "Glf_242"
glf_funcRefMap.Add "new_ball_started{machine.game_modes_enabled == 1}", "Glf_243"
glf_funcRefMap.Add "mode_skillshots_started{current_player.ball_just_started == 1}", "Glf_244"
glf_funcRefMap.Add "mode_skillshots_started{current_player.ball_just_started == 0}", "Glf_245"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.ss1_started == 1}", "Glf_246"
glf_funcRefMap.Add "ss_achieved:{points:750000}", "Glf_247"
glf_funcRefMap.Add "ss_achieved:{points:200000}", "Glf_248"
glf_funcRefMap.Add "s_sw7_active{current_player.shot_ss_bonus_lane_7 == 1}", "Glf_249"
glf_funcRefMap.Add "ss_achieved:{points:400000}", "Glf_250"
glf_funcRefMap.Add "s_sw8_active{current_player.shot_ss_bonus_lane_8 == 1}", "Glf_251"
glf_funcRefMap.Add "s_sw9_active{current_player.shot_ss_bonus_lane_9 == 1}", "Glf_253"
glf_funcRefMap.Add "light_ss_bonus_lane_7{current_player.shot_bonus_lane_7 == 0}", "Glf_255"
glf_funcRefMap.Add "light_ss_bonus_lane_8{current_player.shot_bonus_lane_8 == 0}", "Glf_256"
glf_funcRefMap.Add "light_ss_bonus_lane_9{current_player.shot_bonus_lane_9 == 0}", "Glf_257"
glf_funcRefMap.Add "check_minigame{current_player.shot_logan_light == 1}", "Glf_258"
glf_funcRefMap.Add "check_minigame{current_player.shot_dance_marathon_minigame != 1 and current_player.shot_town_meeting_minigame != 1 and current_player.shot_dinner_minigame != 1 and current_player.shot_kims_antiques_minigame != 1 and current_player.shot_lbtb_minigame != 1 and current_player.shot_fd_punch_minigame != 1}", "Glf_259"
glf_funcRefMap.Add "check_minigame{current_player.shot_dance_marathon_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_260"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_dance_marathon_minigame == 1}", "Glf_261"
glf_funcRefMap.Add "check_minigame{current_player.shot_town_meeting_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_262"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_town_meeting_minigame == 1}", "Glf_263"
glf_funcRefMap.Add "check_minigame{current_player.shot_dinner_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_264"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_dinner_minigame == 1}", "Glf_265"
glf_funcRefMap.Add "check_minigame{current_player.shot_kims_antiques_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_266"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_kims_antiques_minigame == 1}", "Glf_267"
glf_funcRefMap.Add "check_minigame{current_player.shot_lbtb_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_268"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_lbtb_minigame == 1}", "Glf_269"
glf_funcRefMap.Add "check_minigame{current_player.shot_fd_punch_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_270"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_fd_punch_minigame == 1}", "Glf_271"
glf_funcRefMap.Add "choose_new_minigame{modes.bonus.active == False}", "Glf_272"
glf_funcRefMap.Add "dance_marathon_minigame_lit{current_player.shot_dance_marathon_minigame == 0}", "Glf_273"
glf_funcRefMap.Add "town_meeting_minigame_lit{current_player.shot_town_meeting_minigame == 0}", "Glf_274"
glf_funcRefMap.Add "dinner_minigame_lit{current_player.shot_dinner_minigame == 0}", "Glf_275"
glf_funcRefMap.Add "kims_antiques_minigame_lit{current_player.shot_kims_antiques_minigame == 0}", "Glf_276"
glf_funcRefMap.Add "lbtb_minigame_lit{current_player.shot_lbtb_minigame == 0}", "Glf_277"
glf_funcRefMap.Add "fd_punch_minigame_lit{current_player.shot_fd_punch_minigame == 0}", "Glf_278"
glf_funcRefMap.Add "check_eb{current_player.extra_balls == 0}", "Glf_279"
glf_funcRefMap.Add "check_eb{current_player.extra_balls > 0}", "Glf_280"
glf_funcRefMap.Add "s_complete_right_ramp_active{current_player.shot_eb_ready == 1}", "Glf_281"
glf_funcRefMap.Add "eb_now_lit{current_player.extra_ball_eb_awarded < 3}", "Glf_282"
glf_funcRefMap.Add "ball_started{machine.game_modes_enabled == 1}", "Glf_283"
glf_funcRefMap.Add "s_complete_right_ramp_active{current_player.shot_ramp == 1}", "Glf_284"
glf_funcRefMap.Add "timer_dm_intro_delay_tick{device.timers.dm_intro_delay.ticks == 27}", "Glf_285"
glf_funcRefMap.Add "play_dance_marathon_mode_slide:{text:""DANCE MARATHON"",instructions:""HIT FLASHING SHOTS TO SCORE""}", "Glf_286"
glf_funcRefMap.Add "500000", "Glf_287"
glf_funcRefMap.Add "100000", "Glf_288"
glf_funcRefMap.Add "{current_player.mode_dance_marathon_score}", "Glf_289"
glf_funcRefMap.Add "kwargs.ticks_remaining", "Glf_290"
glf_funcRefMap.Add "250000", "Glf_291"
glf_funcRefMap.Add "1250000", "Glf_292"
glf_funcRefMap.Add "28", "Glf_293"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.dm_intro_delay.ticks > 0}", "Glf_294"
glf_funcRefMap.Add "15", "Glf_295"
glf_funcRefMap.Add "play_town_meeting_mode_slide:{text:""TOWN MEETING"",instructions:""HIT FLASHING SHOTS TO SCORE""}", "Glf_296"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.town_meeting_intro_delay.ticks > 0}", "Glf_297"
glf_funcRefMap.Add "7", "Glf_298"
glf_funcRefMap.Add "20", "Glf_299"
glf_funcRefMap.Add "{current_player.mode_town_meeting_score}", "Glf_300"
glf_funcRefMap.Add "750000", "Glf_301"
glf_funcRefMap.Add "play_dinner_mode_slide:{text:""FRIDAY NIGHT DINNER"",instructions:""SHOOT ORBITS TO SCORE""}", "Glf_302"
glf_funcRefMap.Add "9", "Glf_303"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.dinner_intro_delay.ticks > 0}", "Glf_304"
glf_funcRefMap.Add "{current_player.mode_dinner_score}", "Glf_305"
glf_funcRefMap.Add "play_fd_punch_mode_slide:{text:""FOUNDER'S DAY PUNCH"",instructions:""SHOOT LUKE'S OR MANSION TO SCORE""}", "Glf_306"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.fd_punch_intro_delay.ticks > 0}", "Glf_307"
glf_funcRefMap.Add "{current_player.mode_fd_punch_score}", "Glf_308"
glf_funcRefMap.Add "play_kims_antiques_mode_slide:{text:""AVOID MS. KIM"",instructions:""3X SCORING - RIGHT RAMP JACKPOT""}", "Glf_309"
glf_funcRefMap.Add "timer_move_miss_kim_tick{kwargs.ticks == 1 && current_player.kims_warning_active == 0}", "Glf_310"
glf_funcRefMap.Add "kims_antiques_right_ramp_unlit_hit{current_player.shot_kims_jackpot == 1}", "Glf_311"
glf_funcRefMap.Add "kims_antiques_right_ramp_warning_hit{current_player.shot_kims_jackpot == 1}", "Glf_312"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.kims_antiques_intro_delay.ticks > 0}", "Glf_313"
glf_funcRefMap.Add "{current_player.mode_kims_antiques_score}", "Glf_314"
glf_funcRefMap.Add "1000000", "Glf_315"
glf_funcRefMap.Add "warn_kims_antiques_left_ramp{current_player.shot_kims_antiques_left_ramp != 2}", "Glf_316"
glf_funcRefMap.Add "warn_kims_antiques_right_ramp{current_player.shot_kims_antiques_right_ramp != 2}", "Glf_317"
glf_funcRefMap.Add "warn_kims_antiques_captive{current_player.shot_kims_antiques_captive != 2}", "Glf_318"
glf_funcRefMap.Add "warn_kims_antiques_scoop{current_player.shot_kims_antiques_scoop != 2}", "Glf_319"
glf_funcRefMap.Add "warn_kims_antiques_orbit_left{current_player.shot_kims_antiques_orbit_left != 2}", "Glf_320"
glf_funcRefMap.Add "warn_kims_antiques_orbit_right{current_player.shot_kims_antiques_orbit_right != 2}", "Glf_321"
glf_funcRefMap.Add "set_miss_kim{current_player.shot_kims_antiques_left_ramp == 1}", "Glf_322"
glf_funcRefMap.Add "clear_miss_kim{current_player.shot_kims_antiques_left_ramp == 2}", "Glf_323"
glf_funcRefMap.Add "set_miss_kim{current_player.shot_kims_antiques_right_ramp == 1}", "Glf_324"
glf_funcRefMap.Add "clear_miss_kim{current_player.shot_kims_antiques_right_ramp == 2}", "Glf_325"
glf_funcRefMap.Add "set_miss_kim{current_player.shot_kims_antiques_captive == 1}", "Glf_326"
glf_funcRefMap.Add "clear_miss_kim{current_player.shot_kims_antiques_captive == 2}", "Glf_327"
glf_funcRefMap.Add "set_miss_kim{current_player.shot_kims_antiques_scoop == 1}", "Glf_328"
glf_funcRefMap.Add "clear_miss_kim{current_player.shot_kims_antiques_scoop == 2}", "Glf_329"
glf_funcRefMap.Add "set_miss_kim{current_player.shot_kims_antiques_orbit_left == 1}", "Glf_330"
glf_funcRefMap.Add "clear_miss_kim{current_player.shot_kims_antiques_orbit_left == 2}", "Glf_331"
glf_funcRefMap.Add "set_miss_kim{current_player.shot_kims_antiques_orbit_right == 1}", "Glf_332"
glf_funcRefMap.Add "clear_miss_kim{current_player.shot_kims_antiques_orbit_right == 2}", "Glf_333"
glf_funcRefMap.Add "play_lbtb_mode_slide:{text:""LUKE BREAKS THE BELLS!"",instructions:""BREAK BELLS TO SCORE""}", "Glf_334"
glf_funcRefMap.Add "drop_target_drop3_down{current_player.bells_not_hit == 0}", "Glf_335"
glf_funcRefMap.Add "drop_target_drop4_down{current_player.bells_not_hit == 0}", "Glf_336"
glf_funcRefMap.Add "drop_target_drop5_down{current_player.bells_not_hit == 0}", "Glf_337"
glf_funcRefMap.Add "drop_target_drop6_down{current_player.bells_not_hit == 0}", "Glf_338"
glf_funcRefMap.Add "drop_target_drop7_down{current_player.bells_not_hit == 0}", "Glf_339"
glf_funcRefMap.Add "drop_target_drop8_down{current_player.bells_not_hit == 0}", "Glf_340"
glf_funcRefMap.Add "11.5", "Glf_341"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.lbtb_intro_delay.ticks > 0}", "Glf_342"
glf_funcRefMap.Add "drop3_reset{device.drop_targets.drop3.state == 1}", "Glf_343"
glf_funcRefMap.Add "drop4_reset{device.drop_targets.drop4.state == 1}", "Glf_344"
glf_funcRefMap.Add "drop5_reset{device.drop_targets.drop5.state == 1}", "Glf_345"
glf_funcRefMap.Add "drop6_reset{device.drop_targets.drop6.state == 1}", "Glf_346"
glf_funcRefMap.Add "drop7_reset{device.drop_targets.drop7.state == 1}", "Glf_347"
glf_funcRefMap.Add "drop8_reset{device.drop_targets.drop8.state == 1}", "Glf_348"
glf_funcRefMap.Add "{current_player.mode_lbtb_score}", "Glf_349"
glf_funcRefMap.Add "LbtbTime", "Glf_350"
glf_funcRefMap.Add "play_llmb_mode_slide:{text:""LOCK-AWAY LOGAN"",instructions:""HIT BUMPERS TO BASH LOGAN""}", "Glf_351"
glf_funcRefMap.Add "play_llmb_mode_slide:{text:""LOCK-AWAY LOGAN"",instructions:""LOCK-AWAY LOGAN IN THE SCOOP""}", "Glf_352"
glf_funcRefMap.Add "auto_fire_coil_bumper1_activate{current_player.shot_win_logan_light==0}", "Glf_353"
glf_funcRefMap.Add "auto_fire_coil_bumper5_activate{current_player.shot_win_logan_light==0}", "Glf_354"
glf_funcRefMap.Add "logan_bumper_hit{current_player.mode_llmb_score>=2500000}", "Glf_355"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==0}", "Glf_356"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==1 and machine.captive_capture_pending==0}", "Glf_357"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==1 and machine.captive_capture_pending==1}", "Glf_358"
glf_funcRefMap.Add "ll_multiball_end_callout{current_player.llmb_won == 0}", "Glf_359"
glf_funcRefMap.Add "ll_multiball_end_callout{current_player.llmb_won == 1}", "Glf_360"
glf_funcRefMap.Add "{current_player.mode_llmb_score}", "Glf_361"
glf_funcRefMap.Add "7500000", "Glf_362"
glf_funcRefMap.Add "50000", "Glf_363"
glf_funcRefMap.Add "10000", "Glf_364"
glf_funcRefMap.Add "play_jdmb_mode_slide:{text:""JESS VS. DEAN"" & Chr(58) & "" TO THE DEATH"",instructions:""SHOOT RAMPS TO SCORE""}", "Glf_365"
glf_funcRefMap.Add "jess_lit:{light:1}", "Glf_366"
glf_funcRefMap.Add "dean_lit:{light:1}", "Glf_367"
glf_funcRefMap.Add "jess_lit:{light:2}", "Glf_368"
glf_funcRefMap.Add "dean_lit:{light:2}", "Glf_369"
glf_funcRefMap.Add "jess_lit:{light:3}", "Glf_370"
glf_funcRefMap.Add "dean_lit:{light:3}", "Glf_371"
glf_funcRefMap.Add "jess_lit:{light:4}", "Glf_372"
glf_funcRefMap.Add "dean_lit:{light:4}", "Glf_373"
glf_funcRefMap.Add "12", "Glf_374"
glf_funcRefMap.Add "jd_multiball_end_callout{current_player.jd_winner == 1}", "Glf_375"
glf_funcRefMap.Add "jd_multiball_end_callout{current_player.jd_winner == 2}", "Glf_376"
glf_funcRefMap.Add "jd_multiball_end_callout{current_player.jd_winner == 0}", "Glf_377"
glf_funcRefMap.Add "{current_player.mode_jdmb_score}", "Glf_378"
glf_funcRefMap.Add "4000000", "Glf_379"
glf_funcRefMap.Add "jess_lit{kwargs.light == 0}", "Glf_380"
glf_funcRefMap.Add "jess_lit{kwargs.light == 1}", "Glf_381"
glf_funcRefMap.Add "jess_lit{kwargs.light == 2}", "Glf_382"
glf_funcRefMap.Add "jess_lit{kwargs.light == 3}", "Glf_383"
glf_funcRefMap.Add "jess_lit{kwargs.light == 4}", "Glf_384"
glf_funcRefMap.Add "dean_lit{kwargs.light == 0}", "Glf_385"
glf_funcRefMap.Add "dean_lit{kwargs.light == 1}", "Glf_386"
glf_funcRefMap.Add "dean_lit{kwargs.light == 2}", "Glf_387"
glf_funcRefMap.Add "dean_lit{kwargs.light == 3}", "Glf_388"
glf_funcRefMap.Add "dean_lit{kwargs.light == 4}", "Glf_389"
glf_funcRefMap.Add "play_hurryup_slide:{points:500000}", "Glf_390"
glf_funcRefMap.Add "hurryup_value_updated:{points:500000 + device.timers.hurryup.ticks * 7500}", "Glf_391"
glf_funcRefMap.Add "s_DropTargetKicker_active{device.timers.hurryup.ticks != 0}", "Glf_392"
glf_funcRefMap.Add "score_dynamic_flat:{points:500000 + device.timers.hurryup.ticks * 7500}", "Glf_393"
glf_funcRefMap.Add "hurryup_achieved:{points:500000 + device.timers.hurryup.ticks * 7500}", "Glf_394"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==0}", "Glf_395"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==1 and modes.jd_multiball.active==False and modes.ll_multiball.active==False}", "Glf_396"
glf_funcRefMap.Add "timer_mystery_show_tick{devices.timers.mystery_show.ticks == 1}", "Glf_397"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 0}", "Glf_398"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 1}", "Glf_399"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 2}", "Glf_400"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 3}", "Glf_401"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 4}", "Glf_402"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 5}", "Glf_403"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 6}", "Glf_404"
glf_funcRefMap.Add "timer_mystery_delay_complete{current_player.mystery_award == 7}", "Glf_405"
glf_funcRefMap.Add "mystery_eb{current_player.shot_eb_ready < 1}", "Glf_406"
glf_funcRefMap.Add "mystery_ab{modes.jd_multiball.active==False and modes.ll_multiball.active==False}", "Glf_407"
glf_funcRefMap.Add "mystery_ib{current_player.bonus_x < 8}", "Glf_408"
glf_funcRefMap.Add "mystery_jd{modes.jd_multiball.active==False and modes.ll_multiball.active==False and modes.dance_marathon.active==False and modes.town_meeting.active==False and modes.dinner.active==False and modes.kims_antiques.active==False and modes.lbtb.active==False and modes.fd_punch.active==False}", "Glf_409"
glf_funcRefMap.Add "mystery_al{current_player.shot_logan_qualify <= 1}", "Glf_410"
glf_funcRefMap.Add "1010 * current_player.scoring_multiplier", "Glf_411"
glf_funcRefMap.Add "1010", "Glf_412"
glf_funcRefMap.Add "2510 * current_player.scoring_multiplier", "Glf_413"
glf_funcRefMap.Add "2510", "Glf_414"
glf_funcRefMap.Add "5010 * current_player.scoring_multiplier", "Glf_415"
glf_funcRefMap.Add "5010", "Glf_416"
glf_funcRefMap.Add "1510 * current_player.scoring_multiplier", "Glf_417"
glf_funcRefMap.Add "1510", "Glf_418"
glf_funcRefMap.Add "25000 * current_player.scoring_multiplier", "Glf_419"
glf_funcRefMap.Add "25000", "Glf_420"
glf_funcRefMap.Add "12500 * current_player.scoring_multiplier", "Glf_421"
glf_funcRefMap.Add "12500", "Glf_422"
glf_funcRefMap.Add "20000 * current_player.scoring_multiplier", "Glf_423"
glf_funcRefMap.Add "10010 * current_player.scoring_multiplier", "Glf_424"
glf_funcRefMap.Add "10010", "Glf_425"
glf_funcRefMap.Add "50000 * current_player.scoring_multiplier", "Glf_426"
glf_funcRefMap.Add "150000 * current_player.scoring_multiplier", "Glf_427"
glf_funcRefMap.Add "150000", "Glf_428"
glf_funcRefMap.Add "100000 * current_player.scoring_multiplier", "Glf_429"
glf_funcRefMap.Add "250000 * current_player.scoring_multiplier", "Glf_430"
glf_funcRefMap.Add "750000 * current_player.scoring_multiplier", "Glf_431"
glf_funcRefMap.Add "200000 * current_player.scoring_multiplier", "Glf_432"
glf_funcRefMap.Add "200000", "Glf_433"
glf_funcRefMap.Add "400000 * current_player.scoring_multiplier", "Glf_434"
glf_funcRefMap.Add "400000", "Glf_435"
glf_funcRefMap.Add "1000000 * current_player.scoring_multiplier", "Glf_436"
glf_funcRefMap.Add "2500000 * current_player.scoring_multiplier", "Glf_437"
glf_funcRefMap.Add "2500000", "Glf_438"
glf_funcRefMap.Add "500000 * current_player.scoring_multiplier", "Glf_439"
glf_funcRefMap.Add "2000000 * current_player.scoring_multiplier", "Glf_440"
glf_funcRefMap.Add "2000000", "Glf_441"
glf_funcRefMap.Add "1250000 * current_player.scoring_multiplier", "Glf_442"
glf_funcRefMap.Add "4000000 * current_player.scoring_multiplier", "Glf_443"
glf_funcRefMap.Add "7500000 * current_player.scoring_multiplier", "Glf_444"
glf_funcRefMap.Add "5000000 * current_player.scoring_multiplier", "Glf_445"
glf_funcRefMap.Add "5000000", "Glf_446"
glf_funcRefMap.Add "100000000 * current_player.scoring_multiplier", "Glf_447"
glf_funcRefMap.Add "100000000", "Glf_448"
glf_funcRefMap.Add "1000 * current_player.scoring_multiplier", "Glf_449"
glf_funcRefMap.Add "2000 * current_player.scoring_multiplier", "Glf_450"
glf_funcRefMap.Add "5000 * current_player.scoring_multiplier", "Glf_451"
glf_funcRefMap.Add "7500 * current_player.scoring_multiplier", "Glf_452"
glf_funcRefMap.Add "15000000 * current_player.scoring_multiplier", "Glf_453"
glf_funcRefMap.Add "15000000", "Glf_454"
glf_funcRefMap.Add "kwargs.points * current_player.scoring_multiplier", "Glf_455"
glf_funcRefMap.Add "kwargs.points", "Glf_456"
glf_funcRefMap.Add "8", "Glf_457"
glf_funcRefMap.Add "250", "Glf_458"
glf_funcRefMap.Add "1500", "Glf_459"
glf_funcRefMap.Add "500", "Glf_460"

