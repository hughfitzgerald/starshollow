Class Character
    Public Name
    Public Lights
    Public Color
    Public HitEvent
    Public Count
End Class

Function NewCharacter(name, lights, color, hitEvent, count)
    Dim c
    Set c = New Character
    c.Name = name
    c.Lights = lights
    c.Color = color
    c.HitEvent = hitEvent
    c.Count = count
    Set NewCharacter = c
End Function

Dim sookie, kirk, lane, paris
Set sookie = NewCharacter("sookie", Array("Light001", "Light002", "Light003"), "78bec0", "s_DropTargetKicker_active", 5)
Set kirk = NewCharacter("kirk", Array("Light004", "Light005", "Light006"), "bae046", "s_left_spinner_active", 4)
Set lane = NewCharacter("lane", Array("Light007", "Light008", "Light009"), "d938c7", "s_right_spinner_active", 3)
Set paris = NewCharacter("paris", Array("Light010", "Light011", "Light012"), "bf3957", "s_ST11_active", 2)

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
                    .Add characters(x).HitEvent & "{device.counters." & characters(x).Name & "_hit_events.value == " & (characters(x).Count * (y+1)) - 1 & "}", Array(characters(x).Name & "_" & (y+1) & "_lit")
                Next
            Next
        End With
        For x = 0 To UBound(characters)
            For y = 0 To UBound(characters(x).Lights)
                With .Shots(characters(x).Name & "_" & (y+1))
                    .Profile = "flicker_on"
                    With .Tokens()
                        .Add "lights", characters(x).Lights(y)
                        .Add "color", characters(x).Color
                    End With
                    With .ControlEvents()
                        .Events = Array(characters(x).Name & "_" & (y+1) & "_lit")
                        .State = 1
                    End With
                End With
            Next
        Next
        For x = 0 To UBound(characters)
            With .Counters(characters(x).Name & "_hit_events")
                .CountEvents = Array(characters(x).HitEvent)
                .PersistState = True
            End With
        Next
    End With
End Sub