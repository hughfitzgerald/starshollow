Const hurryUpDuration = 20 ' Duration in seconds
Const hurryUpTickMs = 100 ' How often the value updates, in milliseconds
Dim hurryUpSteps, hurryUpPointsPerStep

' GlfTimer ticks move by 1, so the timer counts steps and each step is worth hurryUpPointsPerStep.
' Current value = HurryUpStartScore + ticks * hurryUpPointsPerStep
' (HurryUpStartScore and HurryUpEndScore are in _scores.vbs)

Sub CreateHurryupMode()
    Dim x, hurryUpValue
    hurryUpSteps = (hurryUpDuration * 1000) / hurryUpTickMs
    hurryUpPointsPerStep = (HurryUpEndScore - HurryUpStartScore) / hurryUpSteps
    With CreateGlfMode("hurryup", 240)
        .StartEvents = Array("mode_base_started")
        .StopEvents = Array("mode_base_stopping")
        .Debug = True

        With .EventPlayer()
            ' Shortcut to finish hurryup mode for testing purposes only
            ' .Add "mode_hurryup_started", Array("s_slim_target_ramp2_active", "s_slim_target_ramp3_active", "s_slim_target_ramp4_active", "s_slim_target_hidden1_active", "s_slim_target_hidden2_active")
            
            .Add "star_light_group_on_complete", Array("start_hurryup_timer")
            .Add "start_hurryup_timer", Array(ModeSlideEvent("play_hurryup_mode_slide", "HURRY-UP", "SHOOT LUKE'S TO COLLECT JACKPOT"))

            'Each star target scores only when hit unlit
            For x = 1 To 6
                .Add "star_light_" & x & "_unlit_hit", Array(ScoreEvent(StarTargetScore, WithMultiplier))
            Next

            hurryUpValue = HurryUpStartScore & " + device.timers.hurryup.ticks * " & hurryUpPointsPerStep
            .Add "s_DropTargetKicker_active{device.timers.hurryup.ticks != 0}", Array(ScoreEventExpr(hurryUpValue, NoMultiplier), "hurryup_achieved:{points:" & hurryUpValue & "}")

            .Add "timer_hurryup_complete", Array("hurryup_is_over")
            .Add "hurryup_achieved", Array("hurryup_is_over")
        End With

        With .Timers("hurryup")
            .Debug = True
            .StartValue = 0
            .EndValue = hurryUpSteps
            .TickInterval = hurryUpTickMs
            .Direction = "up"
            With .ControlEvents()
                .EventName = "start_hurryup_timer"
                .Action = "start"
            End With
            With .ControlEvents()
                .EventName = "hurryup_achieved"
                .Action = "stop"
            End With
            With .ControlEvents()
                .EventName = "hurryup_is_over"
                .Action = "reset"
            End With
        End With

        With .SlidePlayer()
            With .EventName("play_hurryup_mode_slide")
                .Slide = "mode"
                .Action = "play"
                .Priority = 1000
            End With
            With .EventName("hurryup_is_over")
                .Slide = "mode"
                .Action = "remove"
            End With
            With .EventName("hurryup_achieved")
                .Slide = "hurryup_achieved"
                .Action = "play"
            End With
        End With

        With .VariablePlayer()
            With .EventName("start_hurryup_timer")
                With .Variable("mode_display_timer")
                    .Action = "set"
                    .String = """"""
                End With
            End With
            With .EventName("timer_hurryup_tick")
                With .Variable("mode_display_score")
                    .Action = "set"
                    .Int = HurryUpStartScore & " + kwargs.ticks * " & hurryUpPointsPerStep
                End With
            End With
        End With


        With .ShotGroups("star_light_group")
            .Shots = Array("star_light_1", "star_light_2", "star_light_3", "star_light_4", "star_light_5", "star_light_6")
            .RestartEvents = Array("star_light_group_on_complete")
        End With

        For x = 1 To 4
            With .Shots("star_light_" & x)
                .Profile = "star_lights"
                With .Tokens()
                    .Add "lights", "l" & (x + 65)
                End With
                .Switch = "s_slim_target_ramp" & x
            End With
        Next
        For x = 1 To 2
            With .Shots("star_light_" & (x + 4))
                .Profile = "star_lights"
                With .Tokens()
                    .Add "lights", "l" & (x + 69)
                End With
                .Switch = "s_slim_target_hidden" & x
            End With
        Next
        
        With .ShotProfiles("star_lights")
            With .States("unlit")
                .Show = "off"
            End With
            With .States("on")
                .Show = "flicker_color_on"
                .Speed = 4
                .Priority = 100
                With .Tokens()
                    .Add "color", BonusLaneColor
                End With
            End With
        End With

        With .RandomEventPlayer()
            With .EventName("star_target_hit")
                .Add "stars_callout", 1.1
                .Add "hollow_callout", 1
            End With
        End With

        With .SoundPlayer()
            With .EventName("stars_callout")
                .Key = "key_voc_stars"
                .Sound = "voc_stars"
                .Priority = -1
            End With
            With .EventName("hollow_callout")
                .Key = "key_voc_hollow"
                .Sound = "voc_hollow"
                .Priority = -1
            End With
            With .EventName("hurryup_achieved")
                .Key = "key_voc_shocksme"
                .Sound = "voc_shocksme"
            End With
        End With
    End With
End Sub