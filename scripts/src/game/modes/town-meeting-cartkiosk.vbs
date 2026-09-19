Sub CreateTownMeetingCartKioskMode()
    With CreateGlfMode("town_meeting_cartkiosk", 905)
        .StartEvents = Array("town_meeting_cartkiosk_start")
        .StopEvents = Array("tm_shots_off", "mode_town_meeting_stopping")
        .Debug = True

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
                .Priority = 90
            End With
            With .EventName("tm_cartkiosk_voc_1")
                .Key = "key_voc_tm_cartkiosk_cartkiosk1"
                .Sound = "voc_tm_cartkiosk_cartkiosk1"
            End With
            With .EventName("tm_cartkiosk_voc_2")
                .Key = "key_voc_tm_cartkiosk_cartkiosk2"
                .Sound = "voc_tm_cartkiosk_cartkiosk2"
            End With
            With .EventName("tm_cartkiosk_voc_3")
                .Key = "key_voc_tm_cartkiosk_sexyornot"
                .Sound = "voc_tm_cartkiosk_sexyornot"
            End With
            With .EventName("tm_cartkiosk_voc_4")
                .Key = "key_voc_tm_cartkiosk_sexysquash"
                .Sound = "voc_tm_cartkiosk_sexysquash"
            End With
            With .EventName("tm_cartkiosk_voc_5")
                .Key = "key_voc_tm_cartkiosk_transcript"
                .Sound = "voc_tm_cartkiosk_transcript"
            End With
        End With
    End With
End Sub