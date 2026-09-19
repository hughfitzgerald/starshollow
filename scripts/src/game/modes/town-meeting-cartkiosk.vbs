Sub CreateTownMeetingCartKioskMode()
    With CreateGlfMode("town_meeting_cartkiosk", 905)
        .StartEvents = Array("town_meeting_cartkiosk_start")
        .StopEvents = Array("tm_shots_off", "mode_town_meeting_stopping")
        .Debug = True

        With .EventPlayer()
            .Add "stop_tm_sounds", Array("tm_cartkiosk_voc_1_stop", "tm_cartkiosk_voc_2_stop", "tm_cartkiosk_voc_3_stop", "tm_cartkiosk_voc_4_stop", "tm_cartkiosk_voc_5_stop")
        End With

        With .RandomEventPlayer()
            With .EventName("tm_shot_hit")
                .Add "tm_cartkiosk_voc_1", 1
                .Add "tm_cartkiosk_voc_2", 1
                .Add "tm_cartkiosk_voc_3", 1
                .Add "tm_cartkiosk_voc_4", 1
                .Add "tm_cartkiosk_voc_5", 1
            End With
        End With

        With .SoundPlayer()
            With .EventName("mode_town_meeting_cartkiosk_started")
                .Key = "key_voc_tm_cartkiosk_hirsutehippy"
                .Sound = "voc_tm_cartkiosk_hirsutehippy"
            End With
            With .EventName("stop_tm_sounds")
                .Key = "key_voc_tm_cartkiosk_hirsutehippy"
                .Sound = "voc_tm_cartkiosk_hirsutehippy"
                .Action = "stop"
            End With
            With .EventName("tm_cartkiosk_voc_1")
                .Key = "key_voc_tm_cartkiosk_cartkiosk1"
                .Sound = "voc_tm_cartkiosk_cartkiosk1"
            End With
            With .EventName("tm_cartkiosk_voc_1_stop")
                .Key = "key_voc_tm_cartkiosk_cartkiosk1"
                .Sound = "voc_tm_cartkiosk_cartkiosk1"
                .Action = "stop"
            End With
            With .EventName("tm_cartkiosk_voc_2")
                .Key = "key_voc_tm_cartkiosk_cartkiosk2"
                .Sound = "voc_tm_cartkiosk_cartkiosk2"
            End With
            With .EventName("tm_cartkiosk_voc_2_stop")
                .Key = "key_voc_tm_cartkiosk_cartkiosk2"
                .Sound = "voc_tm_cartkiosk_cartkiosk2"
                .Action = "stop"
            End With
            With .EventName("tm_cartkiosk_voc_3")
                .Key = "key_voc_tm_cartkiosk_sexyornot"
                .Sound = "voc_tm_cartkiosk_sexyornot"
            End With
            With .EventName("tm_cartkiosk_voc_3_stop")
                .Key = "key_voc_tm_cartkiosk_sexyornot"
                .Sound = "voc_tm_cartkiosk_sexyornot"
                .Action = "stop"
            End With
            With .EventName("tm_cartkiosk_voc_4")
                .Key = "key_voc_tm_cartkiosk_sexysquash"
                .Sound = "voc_tm_cartkiosk_sexysquash"
            End With
            With .EventName("tm_cartkiosk_voc_4_stop")
                .Key = "key_voc_tm_cartkiosk_sexysquash"
                .Sound = "voc_tm_cartkiosk_sexysquash"
                .Action = "stop"
            End With
            With .EventName("tm_cartkiosk_voc_5")
                .Key = "key_voc_tm_cartkiosk_transcript"
                .Sound = "voc_tm_cartkiosk_transcript"
            End With
            With .EventName("tm_cartkiosk_voc_5_stop")
                .Key = "key_voc_tm_cartkiosk_transcript"
                .Sound = "voc_tm_cartkiosk_transcript"
                .Action = "stop"
            End With
        End With
    End With
End Sub