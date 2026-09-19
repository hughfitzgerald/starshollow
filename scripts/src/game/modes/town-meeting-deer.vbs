Sub CreateTownMeetingDeerMode()
    With CreateGlfMode("town_meeting_deer", 900)
        .StartEvents = Array("town_meeting_deer_start")
        .StopEvents = Array("tm_shots_off", "mode_town_meeting_stopping")
        .Debug = True

        With .RandomEventPlayer()
            With .EventName("tm_shot_hit")
                .Add "tm_deer_voc_1", 1
                .Add "tm_deer_voc_2", 1
                .Add "tm_deer_voc_3", 1
                .Add "tm_deer_voc_4", 1
                .Add "tm_deer_voc_5", 1
            End With
        End With

        With .SoundPlayer()
            With .EventName("mode_town_meeting_deer_started")
                .Key = "key_voc_tm_deer_population"
                .Sound = "voc_tm_deer_population"
            End With
            With .EventName("tm_deer_voc_1")
                .Key = "key_voc_tm_deer_bambies"
                .Sound = "voc_tm_deer_bambies"
            End With
            With .EventName("tm_deer_voc_2")
                .Key = "key_voc_tm_deer_flying"
                .Sound = "voc_tm_deer_flying"
            End With
            With .EventName("tm_deer_voc_3")
                .Key = "key_voc_tm_deer_leavethemalone"
                .Sound = "voc_tm_deer_leavethemalone"
            End With
            With .EventName("tm_deer_voc_4")
                .Key = "key_voc_tm_deer_partialelimination"
                .Sound = "voc_tm_deer_partialelimination"
            End With
            With .EventName("tm_deer_voc_5")
                .Key = "key_voc_tm_deer_wolf"
                .Sound = "voc_tm_deer_wolf"
            End With
        End With
    End With
End Sub