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
	    Glf_10 = glf_machine_vars("captive_ball_captive").GetValue() = 0
	If Err Then Glf_10 = False
End Function
Function Glf_11(args)
	On Error Resume Next
	    Glf_11 = glf_machine_vars("captive_ball_captive").GetValue() = 0 and GetPlayerState("llmb_shoot_again_active") = 0
	If Err Then Glf_11 = False
End Function
Function Glf_12(args)
	Glf_12 = 1
End Function
Function Glf_13(args)
	Glf_13 = "GAME OVER"
End Function
Function Glf_14(args)
	Glf_14 = glf_machine_vars("last_score").GetValue()
End Function
Function Glf_15(args)
	Glf_15 = ""
End Function
Function Glf_16(args)
	Glf_16 = 10
End Function
Function Glf_17(args)
	On Error Resume Next
	    Glf_17 = GetPlayerState("ball_just_started") = 1
	If Err Then Glf_17 = False
End Function
Function Glf_18(args)
	On Error Resume Next
	    Glf_18 = glf_modes("eob_bonus").GetValue("active") = False and glf_modes("dance_marathon").GetValue("active") = False and glf_modes("town_meeting").GetValue("active") = False and glf_modes("dinner").GetValue("active") = False and glf_modes("fd_punch").GetValue("active") = False and glf_modes("kims_antiques").GetValue("active") = False and glf_modes("lbtb").GetValue("active") = False
	If Err Then Glf_18 = False
End Function
Function Glf_19(args)
	Glf_19 = 200
End Function
Function Glf_20(args)
	Glf_20 = 244
End Function
Function Glf_21(args)
	Glf_21 = 50
End Function
Function Glf_22(args)
	Glf_22 = 36
End Function
Function Glf_23(args)
	Glf_23 = 188
End Function
Function Glf_24(args)
	Glf_24 = 52
End Function
Function Glf_25(args)
	Glf_25 = 234
End Function
Function Glf_26(args)
	Glf_26 = 332
End Function
Function Glf_27(args)
	On Error Resume Next
	    Glf_27 = glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_27 = False
End Function
Function Glf_28(args)
	On Error Resume Next
	    Glf_28 = glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_28 = False
End Function
Function Glf_29(args)
	On Error Resume Next
	    Glf_29 = glf_modes("fd_punch").GetValue("active")=False
	If Err Then Glf_29 = False
End Function
Function Glf_30(args)
	On Error Resume Next
	    Glf_30 = glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_30 = False
End Function
Function Glf_31(args)
	On Error Resume Next
	    Glf_31 = glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_31 = False
End Function
Function Glf_32(args)
	On Error Resume Next
	    Glf_32 = glf_modes("lbtb").GetValue("active")=False
	If Err Then Glf_32 = False
End Function
Function Glf_33(args)
	On Error Resume Next
	    Glf_33 = glf_modes("lbtb").GetValue("active")=False
	If Err Then Glf_33 = False
End Function
Function Glf_34(args)
	Glf_34 = 15000
End Function
Function Glf_35(args)
	Glf_35 = 5000
End Function
Function Glf_36(args)
	Glf_36 = 3000
End Function
Function Glf_37(args)
	Glf_37 = 2000
End Function
Function Glf_38(args)
	On Error Resume Next
	    Glf_38 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_38 = False
End Function
Function Glf_39(args)
	On Error Resume Next
	    Glf_39 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_39 = False
End Function
Function Glf_40(args)
	On Error Resume Next
	    Glf_40 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_40 = False
End Function
Function Glf_41(args)
	On Error Resume Next
	    Glf_41 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_41 = False
End Function
Function Glf_42(args)
	On Error Resume Next
	    Glf_42 = GetPlayerState("hs_input_ready") = 1
	If Err Then Glf_42 = False
End Function
Function Glf_43(args)
	On Error Resume Next
	    Glf_43 = glf_machine_vars("high_score_initials_chars").GetValue() = 3
	If Err Then Glf_43 = False
End Function
Function Glf_44(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text",  glf_machine_vars("high_score_initials").GetValue()
	Set Glf_44 = kwargs
	If Err Then Glf_44 = Null
End Function
Function Glf_45(args)
	On Error Resume Next
		Dim kwargs : Set kwargs = GlfKwargs()
	kwargs.Add "text",  glf_machine_vars("high_score_initials").GetValue()
	Set Glf_45 = kwargs
	If Err Then Glf_45 = Null
End Function
Function Glf_46(args)
	On Error Resume Next
	    Glf_46 = glf_machine_vars("high_score_initials_chars").GetValue() < 3
	If Err Then Glf_46 = False
End Function
Function Glf_47(args)
	Glf_47 = GetPlayerStateForPlayer(0, "score")
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
	    Glf_50 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 0
	If Err Then Glf_50 = False
End Function
Function Glf_51(args)
	Glf_51 = glf_machine_vars("high_score_initials").GetValue() & "A"
End Function
Function Glf_52(args)
	On Error Resume Next
	    Glf_52 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 1
	If Err Then Glf_52 = False
End Function
Function Glf_53(args)
	Glf_53 = glf_machine_vars("high_score_initials").GetValue() & "B"
End Function
Function Glf_54(args)
	On Error Resume Next
	    Glf_54 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 2
	If Err Then Glf_54 = False
End Function
Function Glf_55(args)
	Glf_55 = glf_machine_vars("high_score_initials").GetValue() & "C"
End Function
Function Glf_56(args)
	On Error Resume Next
	    Glf_56 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 3
	If Err Then Glf_56 = False
End Function
Function Glf_57(args)
	Glf_57 = glf_machine_vars("high_score_initials").GetValue() & "D"
End Function
Function Glf_58(args)
	On Error Resume Next
	    Glf_58 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 4
	If Err Then Glf_58 = False
End Function
Function Glf_59(args)
	Glf_59 = glf_machine_vars("high_score_initials").GetValue() & "E"
End Function
Function Glf_60(args)
	On Error Resume Next
	    Glf_60 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 5
	If Err Then Glf_60 = False
End Function
Function Glf_61(args)
	Glf_61 = glf_machine_vars("high_score_initials").GetValue() & "F"
End Function
Function Glf_62(args)
	On Error Resume Next
	    Glf_62 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 6
	If Err Then Glf_62 = False
End Function
Function Glf_63(args)
	Glf_63 = glf_machine_vars("high_score_initials").GetValue() & "G"
End Function
Function Glf_64(args)
	On Error Resume Next
	    Glf_64 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 7
	If Err Then Glf_64 = False
End Function
Function Glf_65(args)
	Glf_65 = glf_machine_vars("high_score_initials").GetValue() & "H"
End Function
Function Glf_66(args)
	On Error Resume Next
	    Glf_66 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 8
	If Err Then Glf_66 = False
End Function
Function Glf_67(args)
	Glf_67 = glf_machine_vars("high_score_initials").GetValue() & "I"
End Function
Function Glf_68(args)
	On Error Resume Next
	    Glf_68 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 9
	If Err Then Glf_68 = False
End Function
Function Glf_69(args)
	Glf_69 = glf_machine_vars("high_score_initials").GetValue() & "J"
End Function
Function Glf_70(args)
	On Error Resume Next
	    Glf_70 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 10
	If Err Then Glf_70 = False
End Function
Function Glf_71(args)
	Glf_71 = glf_machine_vars("high_score_initials").GetValue() & "K"
End Function
Function Glf_72(args)
	On Error Resume Next
	    Glf_72 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 11
	If Err Then Glf_72 = False
End Function
Function Glf_73(args)
	Glf_73 = glf_machine_vars("high_score_initials").GetValue() & "L"
End Function
Function Glf_74(args)
	On Error Resume Next
	    Glf_74 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 12
	If Err Then Glf_74 = False
End Function
Function Glf_75(args)
	Glf_75 = glf_machine_vars("high_score_initials").GetValue() & "M"
End Function
Function Glf_76(args)
	On Error Resume Next
	    Glf_76 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 13
	If Err Then Glf_76 = False
End Function
Function Glf_77(args)
	Glf_77 = glf_machine_vars("high_score_initials").GetValue() & "N"
End Function
Function Glf_78(args)
	On Error Resume Next
	    Glf_78 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 14
	If Err Then Glf_78 = False
End Function
Function Glf_79(args)
	Glf_79 = glf_machine_vars("high_score_initials").GetValue() & "O"
End Function
Function Glf_80(args)
	On Error Resume Next
	    Glf_80 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 15
	If Err Then Glf_80 = False
End Function
Function Glf_81(args)
	Glf_81 = glf_machine_vars("high_score_initials").GetValue() & "P"
End Function
Function Glf_82(args)
	On Error Resume Next
	    Glf_82 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 16
	If Err Then Glf_82 = False
End Function
Function Glf_83(args)
	Glf_83 = glf_machine_vars("high_score_initials").GetValue() & "Q"
End Function
Function Glf_84(args)
	On Error Resume Next
	    Glf_84 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 17
	If Err Then Glf_84 = False
End Function
Function Glf_85(args)
	Glf_85 = glf_machine_vars("high_score_initials").GetValue() & "R"
End Function
Function Glf_86(args)
	On Error Resume Next
	    Glf_86 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 18
	If Err Then Glf_86 = False
End Function
Function Glf_87(args)
	Glf_87 = glf_machine_vars("high_score_initials").GetValue() & "S"
End Function
Function Glf_88(args)
	On Error Resume Next
	    Glf_88 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 19
	If Err Then Glf_88 = False
End Function
Function Glf_89(args)
	Glf_89 = glf_machine_vars("high_score_initials").GetValue() & "T"
End Function
Function Glf_90(args)
	On Error Resume Next
	    Glf_90 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 20
	If Err Then Glf_90 = False
End Function
Function Glf_91(args)
	Glf_91 = glf_machine_vars("high_score_initials").GetValue() & "U"
End Function
Function Glf_92(args)
	On Error Resume Next
	    Glf_92 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 21
	If Err Then Glf_92 = False
End Function
Function Glf_93(args)
	Glf_93 = glf_machine_vars("high_score_initials").GetValue() & "V"
End Function
Function Glf_94(args)
	On Error Resume Next
	    Glf_94 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 22
	If Err Then Glf_94 = False
End Function
Function Glf_95(args)
	Glf_95 = glf_machine_vars("high_score_initials").GetValue() & "W"
End Function
Function Glf_96(args)
	On Error Resume Next
	    Glf_96 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 23
	If Err Then Glf_96 = False
End Function
Function Glf_97(args)
	Glf_97 = glf_machine_vars("high_score_initials").GetValue() & "X"
End Function
Function Glf_98(args)
	On Error Resume Next
	    Glf_98 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 24
	If Err Then Glf_98 = False
End Function
Function Glf_99(args)
	Glf_99 = glf_machine_vars("high_score_initials").GetValue() & "Y"
End Function
Function Glf_100(args)
	On Error Resume Next
	    Glf_100 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 25
	If Err Then Glf_100 = False
End Function
Function Glf_101(args)
	Glf_101 = glf_machine_vars("high_score_initials").GetValue() & "Z"
End Function
Function Glf_102(args)
	On Error Resume Next
	    Glf_102 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 26
	If Err Then Glf_102 = False
End Function
Function Glf_103(args)
	Glf_103 = glf_machine_vars("high_score_initials").GetValue() & "0"
End Function
Function Glf_104(args)
	On Error Resume Next
	    Glf_104 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 27
	If Err Then Glf_104 = False
End Function
Function Glf_105(args)
	Glf_105 = glf_machine_vars("high_score_initials").GetValue() & "1"
End Function
Function Glf_106(args)
	On Error Resume Next
	    Glf_106 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 28
	If Err Then Glf_106 = False
End Function
Function Glf_107(args)
	Glf_107 = glf_machine_vars("high_score_initials").GetValue() & "2"
End Function
Function Glf_108(args)
	On Error Resume Next
	    Glf_108 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 29
	If Err Then Glf_108 = False
End Function
Function Glf_109(args)
	Glf_109 = glf_machine_vars("high_score_initials").GetValue() & "3"
End Function
Function Glf_110(args)
	On Error Resume Next
	    Glf_110 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 30
	If Err Then Glf_110 = False
End Function
Function Glf_111(args)
	Glf_111 = glf_machine_vars("high_score_initials").GetValue() & "4"
End Function
Function Glf_112(args)
	On Error Resume Next
	    Glf_112 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 31
	If Err Then Glf_112 = False
End Function
Function Glf_113(args)
	Glf_113 = glf_machine_vars("high_score_initials").GetValue() & "5"
End Function
Function Glf_114(args)
	On Error Resume Next
	    Glf_114 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 32
	If Err Then Glf_114 = False
End Function
Function Glf_115(args)
	Glf_115 = glf_machine_vars("high_score_initials").GetValue() & "6"
End Function
Function Glf_116(args)
	On Error Resume Next
	    Glf_116 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 33
	If Err Then Glf_116 = False
End Function
Function Glf_117(args)
	Glf_117 = glf_machine_vars("high_score_initials").GetValue() & "7"
End Function
Function Glf_118(args)
	On Error Resume Next
	    Glf_118 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 34
	If Err Then Glf_118 = False
End Function
Function Glf_119(args)
	Glf_119 = glf_machine_vars("high_score_initials").GetValue() & "8"
End Function
Function Glf_120(args)
	On Error Resume Next
	    Glf_120 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 35
	If Err Then Glf_120 = False
End Function
Function Glf_121(args)
	Glf_121 = glf_machine_vars("high_score_initials").GetValue() & "9"
End Function
Function Glf_122(args)
	On Error Resume Next
	    Glf_122 = (((glf_machine_vars("high_score_initials_index").GetValue() Mod 37) + 37) Mod 37) = 36
	If Err Then Glf_122 = False
End Function
Function Glf_123(args)
	Glf_123 = glf_machine_vars("high_score_initials").GetValue() & "_"
End Function
Function Glf_124(args)
	Glf_124 = glf_dispatch_current_kwargs("player_num")
End Function
Function Glf_125(args)
	Glf_125 = 60
End Function
Function Glf_126(args)
	Glf_126 = 5
End Function
Function Glf_127(args)
	On Error Resume Next
	    Glf_127 = Glf_GameVariable("tilted") = False
	If Err Then Glf_127 = False
End Function
Function Glf_128(args)
	On Error Resume Next
	    Glf_128 = GetPlayerState("total_switches_hit")  > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_128 = False
End Function
Function Glf_129(args)
	On Error Resume Next
	    Glf_129 = GetPlayerState("total_switches_hit") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_129 = False
End Function
Function Glf_130(args)
	On Error Resume Next
	    Glf_130 = GetPlayerState("bumper_count")        > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_130 = False
End Function
Function Glf_131(args)
	On Error Resume Next
	    Glf_131 = GetPlayerState("bumper_count")       = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_131 = False
End Function
Function Glf_132(args)
	On Error Resume Next
	    Glf_132 = GetPlayerState("diner_count")         > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_132 = False
End Function
Function Glf_133(args)
	On Error Resume Next
	    Glf_133 = GetPlayerState("diner_count")        = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_133 = False
End Function
Function Glf_134(args)
	On Error Resume Next
	    Glf_134 = GetPlayerState("grandparents_count")  > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_134 = False
End Function
Function Glf_135(args)
	On Error Resume Next
	    Glf_135 = GetPlayerState("grandparents_count") = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_135 = False
End Function
Function Glf_136(args)
	On Error Resume Next
	    Glf_136 = GetPlayerState("spinner_count")       > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_136 = False
End Function
Function Glf_137(args)
	On Error Resume Next
	    Glf_137 = GetPlayerState("spinner_count")      = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_137 = False
End Function
Function Glf_138(args)
	On Error Resume Next
	    Glf_138 = GetPlayerState("mode_llmb_score")     > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_138 = False
End Function
Function Glf_139(args)
	On Error Resume Next
	    Glf_139 = GetPlayerState("mode_llmb_score")    = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_139 = False
End Function
Function Glf_140(args)
	On Error Resume Next
	    Glf_140 = GetPlayerState("mode_jdmb_score")     > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_140 = False
End Function
Function Glf_141(args)
	On Error Resume Next
	    Glf_141 = GetPlayerState("mode_jdmb_score")    = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_141 = False
End Function
Function Glf_142(args)
	On Error Resume Next
	    Glf_142 = GetPlayerState("mode_dance_marathon_score")       > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_142 = False
End Function
Function Glf_143(args)
	On Error Resume Next
	    Glf_143 = GetPlayerState("mode_dance_marathon_score")      = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_143 = False
End Function
Function Glf_144(args)
	On Error Resume Next
	    Glf_144 = GetPlayerState("mode_town_meeting_score")       > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_144 = False
End Function
Function Glf_145(args)
	On Error Resume Next
	    Glf_145 = GetPlayerState("mode_town_meeting_score")      = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_145 = False
End Function
Function Glf_146(args)
	On Error Resume Next
	    Glf_146 = GetPlayerState("mode_lbtb_score")     > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_146 = False
End Function
Function Glf_147(args)
	On Error Resume Next
	    Glf_147 = GetPlayerState("mode_lbtb_score")    = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_147 = False
End Function
Function Glf_148(args)
	On Error Resume Next
	    Glf_148 = GetPlayerState("mode_kims_antiques_score")       > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_148 = False
End Function
Function Glf_149(args)
	On Error Resume Next
	    Glf_149 = GetPlayerState("mode_kims_antiques_score")      = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_149 = False
End Function
Function Glf_150(args)
	On Error Resume Next
	    Glf_150 = GetPlayerState("mode_dinner_score")   > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_150 = False
End Function
Function Glf_151(args)
	On Error Resume Next
	    Glf_151 = GetPlayerState("mode_dinner_score")  = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_151 = False
End Function
Function Glf_152(args)
	On Error Resume Next
	    Glf_152 = GetPlayerState("mode_fd_punch_score")    > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_152 = False
End Function
Function Glf_153(args)
	On Error Resume Next
	    Glf_153 = GetPlayerState("mode_fd_punch_score")   = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_153 = False
End Function
Function Glf_154(args)
	On Error Resume Next
	    Glf_154 = GetPlayerState("bonus_total")         > 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_154 = False
End Function
Function Glf_155(args)
	On Error Resume Next
	    Glf_155 = GetPlayerState("bonus_total")        = 0 And GetPlayerState("bonus_skip") = 0
	If Err Then Glf_155 = False
End Function
Function Glf_156(args)
	Glf_156 = GetPlayerState("bonus_multiplier") * 1000 * GetPlayerState("total_switches_hit") + GetPlayerState("bumper_count") * 2000 + GetPlayerState("diner_count") * 3000 + GetPlayerState("grandparents_count") * 4000 + GetPlayerState("spinner_count") * 1000
End Function
Function Glf_157(args)
	Glf_157 = GetPlayerState("bonus_total")
End Function
Function Glf_158(args)
	Glf_158 = "BONUS " & GetPlayerState("bonus_multiplier") & "x"
End Function
Function Glf_159(args)
	Glf_159 = GetPlayerState("bonus_multiplier") * 1000 * GetPlayerState("total_switches_hit")
End Function
Function Glf_160(args)
	Glf_160 = "COFFEE COFFEE COFFEE"
End Function
Function Glf_161(args)
	Glf_161 = GetPlayerState("bumper_count") & " CUPS x " & BonusBumperFactor
End Function
Function Glf_162(args)
	Glf_162 = "LUKE'S DINER"
End Function
Function Glf_163(args)
	Glf_163 = GetPlayerState("diner_count") & " MEALS x " & BonusDinerFactor
End Function
Function Glf_164(args)
	Glf_164 = "GRANDPARENTS"
End Function
Function Glf_165(args)
	Glf_165 = GetPlayerState("grandparents_count") & " VISITS x " & BonusGrandparentsFactor
End Function
Function Glf_166(args)
	Glf_166 = "FAST TALKING"
End Function
Function Glf_167(args)
	Glf_167 = GetPlayerState("spinner_count") & " QUIPS x " & BonusSpinnerFactor
End Function
Function Glf_168(args)
	Glf_168 = "LOCK-AWAY LOGAN"
End Function
Function Glf_169(args)
	Glf_169 = GetPlayerState("mode_llmb_score")
End Function
Function Glf_170(args)
	Glf_170 = "JESS & DEAN: TO THE DEATH"
End Function
Function Glf_171(args)
	Glf_171 = GetPlayerState("mode_jdmb_score")
End Function
Function Glf_172(args)
	Glf_172 = "DANCE MARATHON"
End Function
Function Glf_173(args)
	Glf_173 = GetPlayerState("mode_dance_marathon_score")
End Function
Function Glf_174(args)
	Glf_174 = "TOWN MEETING"
End Function
Function Glf_175(args)
	Glf_175 = GetPlayerState("mode_town_meeting_score")
End Function
Function Glf_176(args)
	Glf_176 = "LUKE BREAKS THE BELLS"
End Function
Function Glf_177(args)
	Glf_177 = GetPlayerState("mode_lbtb_score")
End Function
Function Glf_178(args)
	Glf_178 = "KIM'S ANTIQUES"
End Function
Function Glf_179(args)
	Glf_179 = GetPlayerState("mode_kims_antiques_score")
End Function
Function Glf_180(args)
	Glf_180 = "FRIDAY NIGHT DINNER"
End Function
Function Glf_181(args)
	Glf_181 = GetPlayerState("mode_dinner_score")
End Function
Function Glf_182(args)
	Glf_182 = "FOUNDER'S DAY PUNCH"
End Function
Function Glf_183(args)
	Glf_183 = GetPlayerState("mode_fd_punch_score")
End Function
Function Glf_184(args)
	Glf_184 = "TOTAL BONUS"
End Function
Function Glf_185(args)
	On Error Resume Next
	    Glf_185 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_185 = False
End Function
Function Glf_186(args)
	On Error Resume Next
	    Glf_186 = GetPlayerState("is_lock_qualified") = 1
	If Err Then Glf_186 = False
End Function
Function Glf_187(args)
	On Error Resume Next
	    Glf_187 = GetPlayerState("multiball_lock_locked_balls") = 2
	If Err Then Glf_187 = False
End Function
Function Glf_188(args)
	On Error Resume Next
	    Glf_188 = glf_dispatch_current_kwargs("total_balls_locked") = 1
	If Err Then Glf_188 = False
End Function
Function Glf_189(args)
	On Error Resume Next
	    Glf_189 = glf_dispatch_current_kwargs("total_balls_locked") = 2
	If Err Then Glf_189 = False
End Function
Function Glf_190(args)
	On Error Resume Next
	    Glf_190 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_190 = False
End Function
Function Glf_191(args)
	On Error Resume Next
	    Glf_191 = glf_ball_holds("captive_ramp_kicker_hold").GetValue("balls_held") = 1
	If Err Then Glf_191 = False
End Function
Function Glf_192(args)
	Glf_192 = 2
End Function
Function Glf_193(args)
	On Error Resume Next
	    Glf_193 = GetPlayerState("logan_cooldown_active") = 0
	If Err Then Glf_193 = False
End Function
Function Glf_194(args)
	On Error Resume Next
	    Glf_194 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_194 = False
End Function
Function Glf_195(args)
	On Error Resume Next
	    Glf_195 = GetPlayerState("ball_just_started") = 1
	If Err Then Glf_195 = False
End Function
Function Glf_196(args)
	On Error Resume Next
	    Glf_196 = GetPlayerState("ball_just_started") = 0
	If Err Then Glf_196 = False
End Function
Function Glf_197(args)
	On Error Resume Next
	    Glf_197 = GetPlayerState("ss1_started") = 1
	If Err Then Glf_197 = False
End Function
Function Glf_198(args)
	On Error Resume Next
	    Glf_198 = GetPlayerState("shot_ss_bonus_lane_7") = 1
	If Err Then Glf_198 = False
End Function
Function Glf_199(args)
	On Error Resume Next
	    Glf_199 = GetPlayerState("shot_ss_bonus_lane_8") = 1
	If Err Then Glf_199 = False
End Function
Function Glf_200(args)
	On Error Resume Next
	    Glf_200 = GetPlayerState("shot_ss_bonus_lane_9") = 1
	If Err Then Glf_200 = False
End Function
Function Glf_201(args)
	On Error Resume Next
	    Glf_201 = GetPlayerState("shot_bonus_lane_7") = 0
	If Err Then Glf_201 = False
End Function
Function Glf_202(args)
	On Error Resume Next
	    Glf_202 = GetPlayerState("shot_bonus_lane_8") = 0
	If Err Then Glf_202 = False
End Function
Function Glf_203(args)
	On Error Resume Next
	    Glf_203 = GetPlayerState("shot_bonus_lane_9") = 0
	If Err Then Glf_203 = False
End Function
Function Glf_204(args)
	On Error Resume Next
	    Glf_204 = GetPlayerState("shot_logan_light") = 1
	If Err Then Glf_204 = False
End Function
Function Glf_205(args)
	On Error Resume Next
	    Glf_205 = GetPlayerState("shot_kims_antiques_minigame") <> 1
	If Err Then Glf_205 = False
End Function
Function Glf_206(args)
	On Error Resume Next
	    Glf_206 = GetPlayerState("shot_kims_antiques_minigame") = 1 and GetPlayerState("shot_logan_light") = 0 and glf_modes("ll_multiball").GetValue("active") = False and glf_modes("jd_multiball").GetValue("active") = False
	If Err Then Glf_206 = False
End Function
Function Glf_207(args)
	On Error Resume Next
	    Glf_207 = GetPlayerState("shot_kims_antiques_minigame") = 1
	If Err Then Glf_207 = False
End Function
Function Glf_208(args)
	On Error Resume Next
	    Glf_208 = glf_modes("eob_bonus").GetValue("active") = False
	If Err Then Glf_208 = False
End Function
Function Glf_209(args)
	On Error Resume Next
	    Glf_209 = GetPlayerState("shot_kims_antiques_minigame") = 0
	If Err Then Glf_209 = False
End Function
Function Glf_210(args)
	On Error Resume Next
	    Glf_210 = GetPlayerState("extra_balls") = 0
	If Err Then Glf_210 = False
End Function
Function Glf_211(args)
	On Error Resume Next
	    Glf_211 = GetPlayerState("extra_balls") > 0
	If Err Then Glf_211 = False
End Function
Function Glf_212(args)
	On Error Resume Next
	    Glf_212 = GetPlayerState("shot_eb_ready") = 1
	If Err Then Glf_212 = False
End Function
Function Glf_213(args)
	Glf_213 = 3
End Function
Function Glf_214(args)
	On Error Resume Next
	    Glf_214 = GetPlayerState("extra_ball_eb_awarded") < 3
	If Err Then Glf_214 = False
End Function
Function Glf_215(args)
	On Error Resume Next
	    Glf_215 = GetPlayerState("shot_mystery_ready")=0
	If Err Then Glf_215 = False
End Function
Function Glf_216(args)
	On Error Resume Next
	    Glf_216 = GetPlayerState("shot_mystery_ready")=1 and glf_modes("jd_multiball").GetValue("active")=False and glf_modes("ll_multiball").GetValue("active")=False
	If Err Then Glf_216 = False
End Function
Function Glf_217(args)
	Glf_217 = 10000
End Function
Function Glf_218(args)
	On Error Resume Next
	    Glf_218 = glf_machine_vars("game_modes_enabled").GetValue() = 1
	If Err Then Glf_218 = False
End Function
Function Glf_219(args)
	On Error Resume Next
	    Glf_219 = GetPlayerState("shot_ramp") = 1
	If Err Then Glf_219 = False
End Function
Function Glf_220(args)
	Glf_220 = GetPlayerState("mode_dance_marathon_score")
End Function
Function Glf_221(args)
	Glf_221 = "HIT FLASHING SHOTS TO SCORE"
End Function
Function Glf_222(args)
	Glf_222 = glf_dispatch_current_kwargs("ticks_remaining")
End Function
Function Glf_223(args)
	Glf_223 = 40000
End Function
Function Glf_224(args)
	Glf_224 = 14
End Function
Function Glf_225(args)
	On Error Resume Next
	    Glf_225 = glf_timers("dm_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_225 = False
End Function
Function Glf_226(args)
	Glf_226 = 15
End Function
Function Glf_227(args)
	Glf_227 = 6
End Function
Function Glf_228(args)
	Glf_228 = 8
End Function
Function Glf_229(args)
	On Error Resume Next
	    Glf_229 = glf_timers("town_meeting_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_229 = False
End Function
Function Glf_230(args)
	Glf_230 = 20
End Function
Function Glf_231(args)
	Glf_231 = GetPlayerState("mode_town_meeting_score")
End Function
Function Glf_232(args)
	Glf_232 = 100000
End Function
Function Glf_233(args)
	Glf_233 = GetPlayerState("mode_dinner_score")
End Function
Function Glf_234(args)
	Glf_234 = "SHOOT ORBITS TO SCORE"
End Function
Function Glf_235(args)
	On Error Resume Next
	    Glf_235 = glf_timers("fd_punch_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_235 = False
End Function
Function Glf_236(args)
	Glf_236 = GetPlayerState("mode_fd_punch_score")
End Function
Function Glf_237(args)
	Glf_237 = GetPlayerState("mode_kims_antiques_score")
End Function
Function Glf_238(args)
	On Error Resume Next
	    Glf_238 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_238 = False
End Function
Function Glf_239(args)
	On Error Resume Next
	    Glf_239 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_239 = False
End Function
Function Glf_240(args)
	On Error Resume Next
	    Glf_240 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_240 = False
End Function
Function Glf_241(args)
	On Error Resume Next
	    Glf_241 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_241 = False
End Function
Function Glf_242(args)
	On Error Resume Next
	    Glf_242 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_242 = False
End Function
Function Glf_243(args)
	On Error Resume Next
	    Glf_243 = GetPlayerState("bells_not_hit") = 0
	If Err Then Glf_243 = False
End Function
Function Glf_244(args)
	Glf_244 = 7
End Function
Function Glf_245(args)
	Glf_245 = 11.5
End Function
Function Glf_246(args)
	On Error Resume Next
	    Glf_246 = glf_timers("lbtb_intro_delay").GetValue("ticks") > 0
	If Err Then Glf_246 = False
End Function
Function Glf_247(args)
	On Error Resume Next
	    Glf_247 = glf_drop_targets("drop3").GetValue("state") = 1
	If Err Then Glf_247 = False
End Function
Function Glf_248(args)
	On Error Resume Next
	    Glf_248 = glf_drop_targets("drop4").GetValue("state") = 1
	If Err Then Glf_248 = False
End Function
Function Glf_249(args)
	On Error Resume Next
	    Glf_249 = glf_drop_targets("drop5").GetValue("state") = 1
	If Err Then Glf_249 = False
End Function
Function Glf_250(args)
	On Error Resume Next
	    Glf_250 = glf_drop_targets("drop6").GetValue("state") = 1
	If Err Then Glf_250 = False
End Function
Function Glf_251(args)
	On Error Resume Next
	    Glf_251 = glf_drop_targets("drop7").GetValue("state") = 1
	If Err Then Glf_251 = False
End Function
Function Glf_252(args)
	On Error Resume Next
	    Glf_252 = glf_drop_targets("drop8").GetValue("state") = 1
	If Err Then Glf_252 = False
End Function
Function Glf_253(args)
	Glf_253 = "LUKE BREAKS THE BELLS!"
End Function
Function Glf_254(args)
	Glf_254 = GetPlayerState("mode_lbtb_score")
End Function
Function Glf_255(args)
	Glf_255 = "JESS VS. DEAN: TO THE DEATH"
End Function
Function Glf_256(args)
	Glf_256 = GetPlayerState("mode_jdmb_score")
End Function
Function Glf_257(args)
	Glf_257 = "TEAM JESS: LEFT RAMP - TEAM LOGAN: RIGHT RAMP"
End Function
Function Glf_258(args)
	Glf_258 = 1000000
End Function
Function Glf_259(args)
	On Error Resume Next
	    Glf_259 = GetPlayerState("mode_llmb_score")>=150000
	If Err Then Glf_259 = False
End Function
Function Glf_260(args)
	On Error Resume Next
	    Glf_260 = GetPlayerState("shot_win_logan_light")=0
	If Err Then Glf_260 = False
End Function
Function Glf_261(args)
	On Error Resume Next
	    Glf_261 = GetPlayerState("shot_win_logan_light")=1
	If Err Then Glf_261 = False
End Function
Function Glf_262(args)
	Glf_262 = GetPlayerState("mode_llmb_score")
End Function
Function Glf_263(args)
	Glf_263 = "HIT BUMPERS TO BASH LOGAN"
End Function
Function Glf_264(args)
	Glf_264 = "LOCK-AWAY LOGAN IN THE SCOOP"
End Function
Function Glf_265(args)
	Glf_265 = 10000000
End Function
Function Glf_266(args)
	Glf_266 = 1 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_267(args)
	Glf_267 = 10 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_268(args)
	Glf_268 = 100 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_269(args)
	Glf_269 = 333 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_270(args)
	Glf_270 = 500 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_271(args)
	Glf_271 = 1000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_272(args)
	Glf_272 = 2000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_273(args)
	Glf_273 = 3000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_274(args)
	Glf_274 = 3333 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_275(args)
	Glf_275 = 5000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_276(args)
	Glf_276 = 10000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_277(args)
	Glf_277 = 20000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_278(args)
	Glf_278 = 30000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_279(args)
	Glf_279 = 33333 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_280(args)
	Glf_280 = 50000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_281(args)
	Glf_281 = 100000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_282(args)
	Glf_282 = 200000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_283(args)
	Glf_283 = 500000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_284(args)
	Glf_284 = 1000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_285(args)
	Glf_285 = 10000000 * GetPlayerState("scoring_multiplier")
End Function
Function Glf_286(args)
	Glf_286 = 1000
End Function
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
Dim glf_gi026_lmarr : glf_gi026_lmarr = Array()
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
Dim glf_FL1_lmarr : glf_FL1_lmarr = Array(f_fl1_,p_base_fl1,p_fl1_)
glf_lightMaps.Add "FL1", glf_FL1_lmarr
Dim glf_FL2_lmarr : glf_FL2_lmarr = Array(f_fl2_,p_base_fl2,p_fl2_)
glf_lightMaps.Add "FL2", glf_FL2_lmarr
Dim glf_FL3_lmarr : glf_FL3_lmarr = Array(f_fl3_,p_base_fl3,p_fl3_)
glf_lightMaps.Add "FL3", glf_FL3_lmarr
Dim glf_FL4_lmarr : glf_FL4_lmarr = Array(f_fl4_,p_base_fl4,p_fl4_)
glf_lightMaps.Add "FL4", glf_FL4_lmarr
Dim glf_FL5_lmarr : glf_FL5_lmarr = Array(f_fl5_,p_base_fl5,p_fl5_)
glf_lightMaps.Add "FL5", glf_FL5_lmarr
Dim glf_SkillshotLight_lmarr : glf_SkillshotLight_lmarr = Array()
glf_lightMaps.Add "SkillshotLight", glf_SkillshotLight_lmarr
Dim glf_l72_lmarr : glf_l72_lmarr = Array()
glf_lightMaps.Add "l72", glf_l72_lmarr
Dim glf_l28_lmarr : glf_l28_lmarr = Array()
glf_lightMaps.Add "l28", glf_l28_lmarr

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
glf_funcRefMap.Add "s_captive_ball_active{machine.captive_ball_captive == 0}", "Glf_10"
glf_funcRefMap.Add "ball_drain{machine.captive_ball_captive == 0 and current_player.llmb_shoot_again_active == 0}", "Glf_11"
glf_funcRefMap.Add "1", "Glf_12"
glf_funcRefMap.Add """GAME OVER""", "Glf_13"
glf_funcRefMap.Add "machine.last_score", "Glf_14"
glf_funcRefMap.Add """""", "Glf_15"
glf_funcRefMap.Add "10", "Glf_16"
glf_funcRefMap.Add "s_Trigger1_inactive{current_player.ball_just_started == 1}", "Glf_17"
glf_funcRefMap.Add "timer_base_music_complete{modes.eob_bonus.active == False and modes.dance_marathon.active == False and modes.town_meeting.active == False and modes.dinner.active == False and modes.fd_punch.active == False and modes.kims_antiques.active == False and modes.lbtb.active == False}", "Glf_18"
glf_funcRefMap.Add "200", "Glf_19"
glf_funcRefMap.Add "244", "Glf_20"
glf_funcRefMap.Add "50", "Glf_21"
glf_funcRefMap.Add "36", "Glf_22"
glf_funcRefMap.Add "188", "Glf_23"
glf_funcRefMap.Add "52", "Glf_24"
glf_funcRefMap.Add "234", "Glf_25"
glf_funcRefMap.Add "332", "Glf_26"
glf_funcRefMap.Add "drop_target_drop1_down{modes.fd_punch.active==False}", "Glf_27"
glf_funcRefMap.Add "diner_callout{modes.fd_punch.active==False}", "Glf_28"
glf_funcRefMap.Add "grandparents_callout{modes.fd_punch.active==False}", "Glf_29"
glf_funcRefMap.Add "auto_fire_coil_bumper1_activate{modes.ll_multiball.active==False}", "Glf_30"
glf_funcRefMap.Add "auto_fire_coil_bumper5_activate{modes.ll_multiball.active==False}", "Glf_31"
glf_funcRefMap.Add "auto_fire_coil_right_sling_activate{modes.lbtb.active==False}", "Glf_32"
glf_funcRefMap.Add "auto_fire_coil_left_sling_activate{modes.lbtb.active==False}", "Glf_33"
glf_funcRefMap.Add "15000", "Glf_34"
glf_funcRefMap.Add "5000", "Glf_35"
glf_funcRefMap.Add "3000", "Glf_36"
glf_funcRefMap.Add "2000", "Glf_37"
glf_funcRefMap.Add "game_will_end{machine.game_modes_enabled == 1}", "Glf_38"
glf_funcRefMap.Add "s_right_magna_key_active{current_player.hs_input_ready == 1}", "Glf_39"
glf_funcRefMap.Add "s_plunger_key_active{current_player.hs_input_ready == 1}", "Glf_40"
glf_funcRefMap.Add "s_lockbar_key_active{current_player.hs_input_ready == 1}", "Glf_41"
glf_funcRefMap.Add "s_start_active{current_player.hs_input_ready == 1}", "Glf_42"
glf_funcRefMap.Add "text_inputted.1{machine.high_score_initials_chars == 3}", "Glf_43"
glf_funcRefMap.Add "text_input_high_score_complete:{text: machine.high_score_initials}", "Glf_44"
glf_funcRefMap.Add "text_inputted{machine.high_score_initials_chars < 3}", "Glf_46"
glf_funcRefMap.Add "players[0].score", "Glf_47"
glf_funcRefMap.Add "s_left_flipper_active.2{current_player.hs_input_ready == 1}", "Glf_48"
glf_funcRefMap.Add "s_right_flipper_active.2{current_player.hs_input_ready == 1}", "Glf_49"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 0}", "Glf_50"
glf_funcRefMap.Add "machine.high_score_initials & ""A""", "Glf_51"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 1}", "Glf_52"
glf_funcRefMap.Add "machine.high_score_initials & ""B""", "Glf_53"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 2}", "Glf_54"
glf_funcRefMap.Add "machine.high_score_initials & ""C""", "Glf_55"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 3}", "Glf_56"
glf_funcRefMap.Add "machine.high_score_initials & ""D""", "Glf_57"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 4}", "Glf_58"
glf_funcRefMap.Add "machine.high_score_initials & ""E""", "Glf_59"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 5}", "Glf_60"
glf_funcRefMap.Add "machine.high_score_initials & ""F""", "Glf_61"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 6}", "Glf_62"
glf_funcRefMap.Add "machine.high_score_initials & ""G""", "Glf_63"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 7}", "Glf_64"
glf_funcRefMap.Add "machine.high_score_initials & ""H""", "Glf_65"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 8}", "Glf_66"
glf_funcRefMap.Add "machine.high_score_initials & ""I""", "Glf_67"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 9}", "Glf_68"
glf_funcRefMap.Add "machine.high_score_initials & ""J""", "Glf_69"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 10}", "Glf_70"
glf_funcRefMap.Add "machine.high_score_initials & ""K""", "Glf_71"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 11}", "Glf_72"
glf_funcRefMap.Add "machine.high_score_initials & ""L""", "Glf_73"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 12}", "Glf_74"
glf_funcRefMap.Add "machine.high_score_initials & ""M""", "Glf_75"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 13}", "Glf_76"
glf_funcRefMap.Add "machine.high_score_initials & ""N""", "Glf_77"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 14}", "Glf_78"
glf_funcRefMap.Add "machine.high_score_initials & ""O""", "Glf_79"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 15}", "Glf_80"
glf_funcRefMap.Add "machine.high_score_initials & ""P""", "Glf_81"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 16}", "Glf_82"
glf_funcRefMap.Add "machine.high_score_initials & ""Q""", "Glf_83"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 17}", "Glf_84"
glf_funcRefMap.Add "machine.high_score_initials & ""R""", "Glf_85"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 18}", "Glf_86"
glf_funcRefMap.Add "machine.high_score_initials & ""S""", "Glf_87"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 19}", "Glf_88"
glf_funcRefMap.Add "machine.high_score_initials & ""T""", "Glf_89"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 20}", "Glf_90"
glf_funcRefMap.Add "machine.high_score_initials & ""U""", "Glf_91"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 21}", "Glf_92"
glf_funcRefMap.Add "machine.high_score_initials & ""V""", "Glf_93"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 22}", "Glf_94"
glf_funcRefMap.Add "machine.high_score_initials & ""W""", "Glf_95"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 23}", "Glf_96"
glf_funcRefMap.Add "machine.high_score_initials & ""X""", "Glf_97"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 24}", "Glf_98"
glf_funcRefMap.Add "machine.high_score_initials & ""Y""", "Glf_99"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 25}", "Glf_100"
glf_funcRefMap.Add "machine.high_score_initials & ""Z""", "Glf_101"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 26}", "Glf_102"
glf_funcRefMap.Add "machine.high_score_initials & ""0""", "Glf_103"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 27}", "Glf_104"
glf_funcRefMap.Add "machine.high_score_initials & ""1""", "Glf_105"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 28}", "Glf_106"
glf_funcRefMap.Add "machine.high_score_initials & ""2""", "Glf_107"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 29}", "Glf_108"
glf_funcRefMap.Add "machine.high_score_initials & ""3""", "Glf_109"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 30}", "Glf_110"
glf_funcRefMap.Add "machine.high_score_initials & ""4""", "Glf_111"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 31}", "Glf_112"
glf_funcRefMap.Add "machine.high_score_initials & ""5""", "Glf_113"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 32}", "Glf_114"
glf_funcRefMap.Add "machine.high_score_initials & ""6""", "Glf_115"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 33}", "Glf_116"
glf_funcRefMap.Add "machine.high_score_initials & ""7""", "Glf_117"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 34}", "Glf_118"
glf_funcRefMap.Add "machine.high_score_initials & ""8""", "Glf_119"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 35}", "Glf_120"
glf_funcRefMap.Add "machine.high_score_initials & ""9""", "Glf_121"
glf_funcRefMap.Add "text_inputted.3{(((machine.high_score_initials_index Mod 37) + 37) Mod 37) == 36}", "Glf_122"
glf_funcRefMap.Add "machine.high_score_initials & ""_""", "Glf_123"
glf_funcRefMap.Add "{kwargs.player_num}", "Glf_124"
glf_funcRefMap.Add "60", "Glf_125"
glf_funcRefMap.Add "5", "Glf_126"
glf_funcRefMap.Add "ball_ending{game.tilted == False}", "Glf_127"
glf_funcRefMap.Add "play_bonus_show1{current_player.total_switches_hit  > 0 && current_player.bonus_skip == 0}", "Glf_128"
glf_funcRefMap.Add "play_bonus_show1{current_player.total_switches_hit == 0 && current_player.bonus_skip == 0}", "Glf_129"
glf_funcRefMap.Add "play_bonus_show2{current_player.bumper_count        > 0 && current_player.bonus_skip == 0}", "Glf_130"
glf_funcRefMap.Add "play_bonus_show2{current_player.bumper_count       == 0 && current_player.bonus_skip == 0}", "Glf_131"
glf_funcRefMap.Add "play_bonus_show3{current_player.diner_count         > 0 && current_player.bonus_skip == 0}", "Glf_132"
glf_funcRefMap.Add "play_bonus_show3{current_player.diner_count        == 0 && current_player.bonus_skip == 0}", "Glf_133"
glf_funcRefMap.Add "play_bonus_show4{current_player.grandparents_count  > 0 && current_player.bonus_skip == 0}", "Glf_134"
glf_funcRefMap.Add "play_bonus_show4{current_player.grandparents_count == 0 && current_player.bonus_skip == 0}", "Glf_135"
glf_funcRefMap.Add "play_bonus_show5{current_player.spinner_count       > 0 && current_player.bonus_skip == 0}", "Glf_136"
glf_funcRefMap.Add "play_bonus_show5{current_player.spinner_count      == 0 && current_player.bonus_skip == 0}", "Glf_137"
glf_funcRefMap.Add "play_bonus_show6{current_player.mode_llmb_score     > 0 && current_player.bonus_skip == 0}", "Glf_138"
glf_funcRefMap.Add "play_bonus_show6{current_player.mode_llmb_score    == 0 && current_player.bonus_skip == 0}", "Glf_139"
glf_funcRefMap.Add "play_bonus_show7{current_player.mode_jdmb_score     > 0 && current_player.bonus_skip == 0}", "Glf_140"
glf_funcRefMap.Add "play_bonus_show7{current_player.mode_jdmb_score    == 0 && current_player.bonus_skip == 0}", "Glf_141"
glf_funcRefMap.Add "play_bonus_show8{current_player.mode_dance_marathon_score       > 0 && current_player.bonus_skip == 0}", "Glf_142"
glf_funcRefMap.Add "play_bonus_show8{current_player.mode_dance_marathon_score      == 0 && current_player.bonus_skip == 0}", "Glf_143"
glf_funcRefMap.Add "play_bonus_show9{current_player.mode_town_meeting_score       > 0 && current_player.bonus_skip == 0}", "Glf_144"
glf_funcRefMap.Add "play_bonus_show9{current_player.mode_town_meeting_score      == 0 && current_player.bonus_skip == 0}", "Glf_145"
glf_funcRefMap.Add "play_bonus_show10{current_player.mode_lbtb_score     > 0 && current_player.bonus_skip == 0}", "Glf_146"
glf_funcRefMap.Add "play_bonus_show10{current_player.mode_lbtb_score    == 0 && current_player.bonus_skip == 0}", "Glf_147"
glf_funcRefMap.Add "play_bonus_show11{current_player.mode_kims_antiques_score       > 0 && current_player.bonus_skip == 0}", "Glf_148"
glf_funcRefMap.Add "play_bonus_show11{current_player.mode_kims_antiques_score      == 0 && current_player.bonus_skip == 0}", "Glf_149"
glf_funcRefMap.Add "play_bonus_show12{current_player.mode_dinner_score   > 0 && current_player.bonus_skip == 0}", "Glf_150"
glf_funcRefMap.Add "play_bonus_show12{current_player.mode_dinner_score  == 0 && current_player.bonus_skip == 0}", "Glf_151"
glf_funcRefMap.Add "play_bonus_show13{current_player.mode_fd_punch_score    > 0 && current_player.bonus_skip == 0}", "Glf_152"
glf_funcRefMap.Add "play_bonus_show13{current_player.mode_fd_punch_score   == 0 && current_player.bonus_skip == 0}", "Glf_153"
glf_funcRefMap.Add "play_bonus_show14{current_player.bonus_total         > 0 && current_player.bonus_skip == 0}", "Glf_154"
glf_funcRefMap.Add "play_bonus_show14{current_player.bonus_total        == 0 && current_player.bonus_skip == 0}", "Glf_155"
glf_funcRefMap.Add "current_player.bonus_multiplier * 1000 * current_player.total_switches_hit + current_player.bumper_count * 2000 + current_player.diner_count * 3000 + current_player.grandparents_count * 4000 + current_player.spinner_count * 1000", "Glf_156"
glf_funcRefMap.Add "current_player.bonus_total", "Glf_157"
glf_funcRefMap.Add """BONUS "" & current_player.bonus_multiplier & ""x""", "Glf_158"
glf_funcRefMap.Add "current_player.bonus_multiplier * 1000 * current_player.total_switches_hit", "Glf_159"
glf_funcRefMap.Add """COFFEE COFFEE COFFEE""", "Glf_160"
glf_funcRefMap.Add "current_player.bumper_count & "" CUPS x "" & BonusBumperFactor", "Glf_161"
glf_funcRefMap.Add """LUKE'S DINER""", "Glf_162"
glf_funcRefMap.Add "current_player.diner_count & "" MEALS x "" & BonusDinerFactor", "Glf_163"
glf_funcRefMap.Add """GRANDPARENTS""", "Glf_164"
glf_funcRefMap.Add "current_player.grandparents_count & "" VISITS x "" & BonusGrandparentsFactor", "Glf_165"
glf_funcRefMap.Add """FAST TALKING""", "Glf_166"
glf_funcRefMap.Add "current_player.spinner_count & "" QUIPS x "" & BonusSpinnerFactor", "Glf_167"
glf_funcRefMap.Add """LOCK-AWAY LOGAN""", "Glf_168"
glf_funcRefMap.Add "current_player.mode_llmb_score", "Glf_169"
glf_funcRefMap.Add """JESS & DEAN: TO THE DEATH""", "Glf_170"
glf_funcRefMap.Add "current_player.mode_jdmb_score", "Glf_171"
glf_funcRefMap.Add """DANCE MARATHON""", "Glf_172"
glf_funcRefMap.Add "current_player.mode_dance_marathon_score", "Glf_173"
glf_funcRefMap.Add """TOWN MEETING""", "Glf_174"
glf_funcRefMap.Add "current_player.mode_town_meeting_score", "Glf_175"
glf_funcRefMap.Add """LUKE BREAKS THE BELLS""", "Glf_176"
glf_funcRefMap.Add "current_player.mode_lbtb_score", "Glf_177"
glf_funcRefMap.Add """KIM'S ANTIQUES""", "Glf_178"
glf_funcRefMap.Add "current_player.mode_kims_antiques_score", "Glf_179"
glf_funcRefMap.Add """FRIDAY NIGHT DINNER""", "Glf_180"
glf_funcRefMap.Add "current_player.mode_dinner_score", "Glf_181"
glf_funcRefMap.Add """FOUNDER'S DAY PUNCH""", "Glf_182"
glf_funcRefMap.Add "current_player.mode_fd_punch_score", "Glf_183"
glf_funcRefMap.Add """TOTAL BONUS""", "Glf_184"
glf_funcRefMap.Add "mode_skillshots_stopped{machine.game_modes_enabled == 1}", "Glf_185"
glf_funcRefMap.Add "mode_jd_multiball_qualify_started{current_player.is_lock_qualified == 1}", "Glf_186"
glf_funcRefMap.Add "s_lock3_trigger_active{current_player.multiball_lock_locked_balls == 2}", "Glf_187"
glf_funcRefMap.Add "multiball_lock_multiball_lock_locked_ball{kwargs.total_balls_locked == 1}", "Glf_188"
glf_funcRefMap.Add "multiball_lock_multiball_lock_locked_ball{kwargs.total_balls_locked == 2}", "Glf_189"
glf_funcRefMap.Add "mode_base_started{machine.game_modes_enabled == 1}", "Glf_190"
glf_funcRefMap.Add "mode_base_stopping{device.ball_holds.captive_ramp_kicker_hold.balls_held == 1}", "Glf_191"
glf_funcRefMap.Add "2", "Glf_192"
glf_funcRefMap.Add "s_captive_ball_active{current_player.logan_cooldown_active == 0}", "Glf_193"
glf_funcRefMap.Add "new_ball_started{machine.game_modes_enabled == 1}", "Glf_194"
glf_funcRefMap.Add "mode_skillshots_started{current_player.ball_just_started == 1}", "Glf_195"
glf_funcRefMap.Add "mode_skillshots_started{current_player.ball_just_started == 0}", "Glf_196"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.ss1_started == 1}", "Glf_197"
glf_funcRefMap.Add "s_sw7_active{current_player.shot_ss_bonus_lane_7 == 1}", "Glf_198"
glf_funcRefMap.Add "s_sw8_active{current_player.shot_ss_bonus_lane_8 == 1}", "Glf_199"
glf_funcRefMap.Add "s_sw9_active{current_player.shot_ss_bonus_lane_9 == 1}", "Glf_200"
glf_funcRefMap.Add "light_ss_bonus_lane_7{current_player.shot_bonus_lane_7 == 0}", "Glf_201"
glf_funcRefMap.Add "light_ss_bonus_lane_8{current_player.shot_bonus_lane_8 == 0}", "Glf_202"
glf_funcRefMap.Add "light_ss_bonus_lane_9{current_player.shot_bonus_lane_9 == 0}", "Glf_203"
glf_funcRefMap.Add "check_minigame{current_player.shot_logan_light == 1}", "Glf_204"
glf_funcRefMap.Add "check_minigame{current_player.shot_kims_antiques_minigame != 1}", "Glf_205"
glf_funcRefMap.Add "check_minigame{current_player.shot_kims_antiques_minigame == 1 and current_player.shot_logan_light == 0 and modes.ll_multiball.active == False and modes.jd_multiball.active == False}", "Glf_206"
glf_funcRefMap.Add "clear_selected_minigame{current_player.shot_kims_antiques_minigame == 1}", "Glf_207"
glf_funcRefMap.Add "choose_new_minigame{modes.eob_bonus.active == False}", "Glf_208"
glf_funcRefMap.Add "kims_antiques_minigame_lit{current_player.shot_kims_antiques_minigame == 0}", "Glf_209"
glf_funcRefMap.Add "check_eb{current_player.extra_balls == 0}", "Glf_210"
glf_funcRefMap.Add "check_eb{current_player.extra_balls > 0}", "Glf_211"
glf_funcRefMap.Add "s_complete_right_ramp_active{current_player.shot_eb_ready == 1}", "Glf_212"
glf_funcRefMap.Add "3", "Glf_213"
glf_funcRefMap.Add "eb_now_lit{current_player.extra_ball_eb_awarded < 3}", "Glf_214"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==0}", "Glf_215"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_mystery_ready==1 and modes.jd_multiball.active==False and modes.ll_multiball.active==False}", "Glf_216"
glf_funcRefMap.Add "10000", "Glf_217"
glf_funcRefMap.Add "ball_started{machine.game_modes_enabled == 1}", "Glf_218"
glf_funcRefMap.Add "s_complete_right_ramp_active{current_player.shot_ramp == 1}", "Glf_219"
glf_funcRefMap.Add "{current_player.mode_dance_marathon_score}", "Glf_220"
glf_funcRefMap.Add """HIT FLASHING SHOTS TO SCORE""", "Glf_221"
glf_funcRefMap.Add "kwargs.ticks_remaining", "Glf_222"
glf_funcRefMap.Add "40000", "Glf_223"
glf_funcRefMap.Add "14", "Glf_224"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.dm_intro_delay.ticks > 0}", "Glf_225"
glf_funcRefMap.Add "15", "Glf_226"
glf_funcRefMap.Add "6", "Glf_227"
glf_funcRefMap.Add "8", "Glf_228"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.town_meeting_intro_delay.ticks > 0}", "Glf_229"
glf_funcRefMap.Add "20", "Glf_230"
glf_funcRefMap.Add "{current_player.mode_town_meeting_score}", "Glf_231"
glf_funcRefMap.Add "100000", "Glf_232"
glf_funcRefMap.Add "{current_player.mode_dinner_score}", "Glf_233"
glf_funcRefMap.Add """SHOOT ORBITS TO SCORE""", "Glf_234"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.fd_punch_intro_delay.ticks > 0}", "Glf_235"
glf_funcRefMap.Add "{current_player.mode_fd_punch_score}", "Glf_236"
glf_funcRefMap.Add "{current_player.mode_kims_antiques_score}", "Glf_237"
glf_funcRefMap.Add "drop_target_drop3_down{current_player.bells_not_hit == 0}", "Glf_238"
glf_funcRefMap.Add "drop_target_drop4_down{current_player.bells_not_hit == 0}", "Glf_239"
glf_funcRefMap.Add "drop_target_drop5_down{current_player.bells_not_hit == 0}", "Glf_240"
glf_funcRefMap.Add "drop_target_drop6_down{current_player.bells_not_hit == 0}", "Glf_241"
glf_funcRefMap.Add "drop_target_drop7_down{current_player.bells_not_hit == 0}", "Glf_242"
glf_funcRefMap.Add "drop_target_drop8_down{current_player.bells_not_hit == 0}", "Glf_243"
glf_funcRefMap.Add "7", "Glf_244"
glf_funcRefMap.Add "11.5", "Glf_245"
glf_funcRefMap.Add "skip_minigame_intro{device.timers.lbtb_intro_delay.ticks > 0}", "Glf_246"
glf_funcRefMap.Add "drop3_reset{device.drop_targets.drop3.state == 1}", "Glf_247"
glf_funcRefMap.Add "drop4_reset{device.drop_targets.drop4.state == 1}", "Glf_248"
glf_funcRefMap.Add "drop5_reset{device.drop_targets.drop5.state == 1}", "Glf_249"
glf_funcRefMap.Add "drop6_reset{device.drop_targets.drop6.state == 1}", "Glf_250"
glf_funcRefMap.Add "drop7_reset{device.drop_targets.drop7.state == 1}", "Glf_251"
glf_funcRefMap.Add "drop8_reset{device.drop_targets.drop8.state == 1}", "Glf_252"
glf_funcRefMap.Add """LUKE BREAKS THE BELLS!""", "Glf_253"
glf_funcRefMap.Add "{current_player.mode_lbtb_score}", "Glf_254"
glf_funcRefMap.Add """JESS VS. DEAN: TO THE DEATH""", "Glf_255"
glf_funcRefMap.Add "{current_player.mode_jdmb_score}", "Glf_256"
glf_funcRefMap.Add """TEAM JESS: LEFT RAMP - TEAM LOGAN: RIGHT RAMP""", "Glf_257"
glf_funcRefMap.Add "1000000", "Glf_258"
glf_funcRefMap.Add "logan_bumper_hit{current_player.mode_llmb_score>=150000}", "Glf_259"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==0}", "Glf_260"
glf_funcRefMap.Add "balldevice_scoop_ball_entered{current_player.shot_win_logan_light==1}", "Glf_261"
glf_funcRefMap.Add "{current_player.mode_llmb_score}", "Glf_262"
glf_funcRefMap.Add """HIT BUMPERS TO BASH LOGAN""", "Glf_263"
glf_funcRefMap.Add """LOCK-AWAY LOGAN IN THE SCOOP""", "Glf_264"
glf_funcRefMap.Add "10000000", "Glf_265"
glf_funcRefMap.Add "1 * current_player.scoring_multiplier", "Glf_266"
glf_funcRefMap.Add "10 * current_player.scoring_multiplier", "Glf_267"
glf_funcRefMap.Add "100 * current_player.scoring_multiplier", "Glf_268"
glf_funcRefMap.Add "333 * current_player.scoring_multiplier", "Glf_269"
glf_funcRefMap.Add "500 * current_player.scoring_multiplier", "Glf_270"
glf_funcRefMap.Add "1000 * current_player.scoring_multiplier", "Glf_271"
glf_funcRefMap.Add "2000 * current_player.scoring_multiplier", "Glf_272"
glf_funcRefMap.Add "3000 * current_player.scoring_multiplier", "Glf_273"
glf_funcRefMap.Add "3333 * current_player.scoring_multiplier", "Glf_274"
glf_funcRefMap.Add "5000 * current_player.scoring_multiplier", "Glf_275"
glf_funcRefMap.Add "10000 * current_player.scoring_multiplier", "Glf_276"
glf_funcRefMap.Add "20000 * current_player.scoring_multiplier", "Glf_277"
glf_funcRefMap.Add "30000 * current_player.scoring_multiplier", "Glf_278"
glf_funcRefMap.Add "33333 * current_player.scoring_multiplier", "Glf_279"
glf_funcRefMap.Add "50000 * current_player.scoring_multiplier", "Glf_280"
glf_funcRefMap.Add "100000 * current_player.scoring_multiplier", "Glf_281"
glf_funcRefMap.Add "200000 * current_player.scoring_multiplier", "Glf_282"
glf_funcRefMap.Add "500000 * current_player.scoring_multiplier", "Glf_283"
glf_funcRefMap.Add "1000000 * current_player.scoring_multiplier", "Glf_284"
glf_funcRefMap.Add "10000000 * current_player.scoring_multiplier", "Glf_285"
glf_funcRefMap.Add "1000", "Glf_286"

