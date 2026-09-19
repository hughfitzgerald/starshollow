
Sub CreateBackglassShows()
    With CreateGlfShow("backglass_logo_on_show")
        With .AddStep(0.01, Null, Null)
            With .DOFEvent("1")
                .Action = "DOF_ON"
            End With
        End With
    End With
    With CreateGlfShow("backglass_logo_off_show")
        With .AddStep(0.01, Null, Null)
            With .DOFEvent("1")
                .Action = "DOF_OFF"
            End With
        End With
    End With

    With CreateGlfShow("backglass_flash1_show")
        With .AddStep(0.01, Null, Null)
            With .DOFEvent("2")
                .Action = "DOF_ON"
            End With
        End With
        With .AddStep(0.2, Null, Null)
            With .DOFEvent("2")
                .Action = "DOF_OFF"
            End With
        End With
    End With

    With CreateGlfShow("backglass_flash2_show")
        With .AddStep(0.01, Null, Null)
            With .DOFEvent("3")
                .Action = "DOF_ON"
            End With
        End With
        With .AddStep(0.2, Null, Null)
            With .DOFEvent("3")
                .Action = "DOF_OFF"
            End With
        End With
    End With

    With CreateGlfShow("backglass_flash3_show")
        With .AddStep(0.01, Null, Null)
            With .DOFEvent("4")
                .Action = "DOF_ON"
            End With
        End With
        With .AddStep(0.2, Null, Null)
            With .DOFEvent("4")
                .Action = "DOF_OFF"
            End With
        End With
    End With

    With CreateGlfShow("backglass_flash4_show")
        With .AddStep(0.01, Null, Null)
            With .DOFEvent("5")
                .Action = "DOF_ON"
            End With
        End With
        With .AddStep(0.2, Null, Null)
            With .DOFEvent("5")
                .Action = "DOF_OFF"
            End With
        End With
    End With
End Sub
