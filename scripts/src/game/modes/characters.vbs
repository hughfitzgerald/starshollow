Class Character
    Public Name
    Public Lights
    Public Color
    Public HitEvent
    Public Count
    Public Callouts
End Class

Function NewCharacter(name, lights, color, hitEvent, count, callouts)
    Dim c
    Set c = New Character
    c.Name = name
    c.Lights = lights
    c.Color = color
    c.HitEvent = hitEvent
    c.Count = count
    c.Callouts = callouts
    Set NewCharacter = c
End Function

Dim sookie, kirk, lane, paris
Set sookie = NewCharacter("sookie", Array("Light001", "Light002", "Light003"), "78bec0", "any_spinner_hit", 50, Array("voc_lookgreat"))
Set kirk = NewCharacter("kirk", Array("Light004", "Light005", "Light006"), "bae046", "any_bumper_hit", 10, Array("voc_prostrate", "voc_tm_deer_wolf"))
Set lane = NewCharacter("lane", Array("Light007", "Light008", "Light009"), "d938c7", "any_sling_hit", 10, Array("voc_fd_punch_ifwegetmarried", "voc_fd_punch_myface"))
Set paris = NewCharacter("paris", Array("Light010", "Light011", "Light012"), "bf3957", "any_ramp_hit", 5, Array("voc_fd_punch_bathroom", "voc_fd_punch_keepwalking"))

Dim characters
characters = Array(sookie, kirk, lane, paris)

Sub CreateCharactersMode()
    Dim x, y
    With CreateGlfMode("characters", 230)
        .StartEvents = Array("mode_base_started")
        .StopEvents = Array("mode_base_stopped")
        With .EventPlayer()
            For x = 0 To UBound(characters)
                For y = 0 To UBound(characters(x).Lights)
                    .Add characters(x).Name & "_" & (y+1) & "_lit", Array(characters(x).Name & "_lit:{light:" & (y+1) & "}")
                Next
                .Add characters(x).Name & "_lit{kwargs.light == " & UBound(characters(x).Lights) + 1 & "}", Array(characters(x).Name & "_complete")
            Next
            ' Add a cool sound effect when you earn each one
            ' ALONG WITH a funny callout for each one
            ' When you actually COMPLETE one, do a quick fun lightshow, too
            ' AND I still like the idea of a 3d mesh for each character: spoon in bowl for Sookie, snare drum (or kick drum) for lane, something for Paris, "Kirk's" sign for Kirk
        End With
        With .SlidePlayer()
            For x = 0 To UBound(characters)
                With .EventName(characters(x).Name & "_lit{kwargs.light == " & UBound(characters(x).Lights) + 1 & "}")
                    .Slide = characters(x).Name & "_complete"
                    .Action = "play"
                    .Priority = 2
                End With
                With .EventName(characters(x).Name & "_lit{kwargs.light < " & UBound(characters(x).Lights) + 1 & "}")
                    .Slide = characters(x).Name & "_advance"
                    .Action = "play"
                    .Priority = 1
                End With
                With .EventName(characters(x).Name & "_hit")
                    .Slide = characters(x).Name
                    .Action = "play"
                End With
            Next
        End With
        With .RandomEventPlayer()
            For x = 0 To UBound(characters)
                With .EventName(characters(x).Name & "_lit")
                    For y = 0 To UBound(characters(x).Callouts)
                        .Add characters(x).Name & "_callout_" & (y+1), 1
                    Next
                End With
            Next
        End With
        With .SoundPlayer()
            For x = 0 To UBound(characters)
                For y = 0 To UBound(characters(x).Callouts)
                    With .EventName(characters(x).Name & "_callout_" & (y+1))
                        .Key = "key_" & characters(x).Name & "_callout_" & (y+1)
                        .Sound = characters(x).Callouts(y)
                    End With
                Next
            Next
        End With
        For x = 0 To UBound(characters)
            For y = 0 To UBound(characters(x).Lights)
                With .Shots(characters(x).Name & "_" & (y+1))
                    .Profile = "flicker_on"
                    .Persist = True
                    With .Tokens()
                        .Add "lights", characters(x).Lights(y)
                        .Add "color", characters(x).Color
                    End With
                    With .ControlEvents()
                        .Events = Array(characters(x).Name & "_lit{kwargs.light == " & (y+1) & "}")
                        .State = 1
                    End With
                End With
            Next
            With .Counters(characters(x).Name & "_hit_events")
                .CountEvents = Array(characters(x).HitEvent)
                .CountCompleteValue = characters(x).Count
                .EventsWhenHit = Array(characters(x).Name & "_hit")
                .EventsWhenComplete = Array(characters(x).Name & "_counter_complete")
                .RestartEvents = Array(characters(x).Name & "_lit{kwargs.light < " & (UBound(characters(x).Lights) + 1) & "}")
                .DisableOnComplete = True
                .PersistState = True
            End With
            With .StateMachines(characters(x).Name + "_state")
                .Debug = True
                .StartingState = "light_0"
                .PersistState = True
                For y = 0 To UBound(characters(x).Lights) + 1
                    With .States("light_" & y)
                        .Label = "Light " & y
                        .EventsWhenStarted = Array(characters(x).Name & "_" & y & "_lit")
                    End With
                    If y < UBound(characters(x).Lights) + 1 Then
                        With .Transitions()
                            .Source = Array("light_" & y)
                            .Target = "light_" & (y+1)
                            .Events = Array(characters(x).Name & "_counter_complete")
                        End With
                    End If
                Next
            End With
        Next
    End With
End Sub