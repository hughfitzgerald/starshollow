'*******************************************
'  DMD slides and widgets - the whole list
'*******************************************
'
' Everything the DMD can show, in one place. The name you give an entry
' here is the name you use from mode config:
'
'     With .SlidePlayer()
'         With .EventName("mode_base_started")
'             .Slide = "score"
'         End With
'     End With
'
'     With .WidgetPlayer()
'         With .EventName("ball_save_new_ball_saving_ball")
'             .Widget = "ball_save"
'             .Expire = 2
'         End With
'     End With
'
' ...and from a show step (.Slides("jackpot") / .Widgets("ball_save")).
'
' SLIDE vs WIDGET is about how a mode reaches the entry, not about what
' gets drawn:
'
'   A SLIDE is played and stays until something takes it away. The slide
'   player passes the triggering event's kwargs through, so a slide can
'   show live data, and .Action = "remove" takes it back off.
'
'   A WIDGET is fired and forgotten. The widget player passes no kwargs
'   and has no remove, so a widget leaves only when its .Expire runs out
'   or its mode stops.
'
' Either one can be a GIF, a still, a line of text or a built scene, and
' either one can be a LAYER.
'
' LAYERS
'
' An entry with a scene of its own and an .Over is drawn ON TOP of
' another scene instead of replacing it - its FlexDMD group is added to
' the backdrop's group, and taken off again when it leaves the stack.
' The backdrop keeps ticking underneath, and the layer gets its own
' ticker every frame:
'
'     With CreateDmdSlide("luke_and_lorelei")
'         .Builder = "DmdBuild_LukeAndLorelei"
'         .Ticker  = "DmdTick_LukeAndLorelei"
'         .Over    = "mode"        ' put the mode panel up and sit on it
'     End With
'
' .Over = "current" instead means "whatever is on screen will do".
' Layers stack by priority, lowest first, so the highest ends up on top.
'
' A .Text entry has no scene, so it is never a layer - it draws through
' DMDBigText, which only the scoreboard's ticker puts on screen, and its
' .Over names the backdrop it needs. A text slide with no .Over brings
' the scoreboard up; a text widget with no .Over disturbs nothing and so
' appears only when the scoreboard is already there.
'
' ADDING ONE
'
'   A GIF, dropped in StarsHollowDMD/, is one line:
'       With CreateDmdSlide("kirk-dances") : .Gif = "kirk-dances.gif" : End With
'
'   The same GIF as an overlay on whatever is showing is two:
'       With CreateDmdWidget("kirk-dances")
'           .Gif = "kirk-dances.gif" : .Over = "current"
'       End With
'
'   A line of text is one line:
'       With CreateDmdWidget("ball_save") : .Text = "BALL SAVED" : End With
'
'   Text can pull live values out of the event that played it, using the
'   same (token) syntax GLF shows use for (lights) and (color). A token
'   with nothing behind it resolves to an empty string:
'       .Text = "(ticks_remaining) SEC"
'
'   Anything more than that names a Sub in display_scenes.vbs - .Builder
'   to construct a scene once at startup, .Ticker to update it every DMD
'   frame while it is on screen, .Callback to take over the whole render.
'
' EVERY FIELD
'
'   .Gif        animated file in StarsHollowDMD/; the scene is built for you
'   .Image      still image, same - or, alongside .Text, a picture drawn
'               at the left with the text fitted into the space beside it
'   .Text       literal text, with (name) tokens from the event's kwargs;
'               (name:,) adds thousands commas to a number
'   .Builder    Sub name, builds the scene once at Flex_Init
'   .Ticker     Sub name, runs every DMD frame while this is on screen;
'               reads the event's kwargs with entry.Kwargs()
'   .Callback   Sub name, replaces the default render entirely
'   .RenderMode one of the FlexDMD_RenderMode_* constants (default DMD_GRAY_4)
'   .Effect     "solid" or "blink"  (default blink)
'   .Hold       seconds a text SLIDE stays up (default 1.2). Widgets use
'               the .Expire from mode config instead.
'   .Over       what this entry is drawn on top of: a slide name, or
'               "current" for whatever is showing. Empty (the default)
'               means full screen - except for a text SLIDE, which falls
'               back to the scoreboard because that is the only scene
'               that draws text.
'   .ResetFrame True to zero FlexFrame before showing, for a scene whose
'               ticker keys on absolute frame numbers
'   .Aliases    Array of extra names that resolve to this same entry
'   .Transition how this scene arrives on the DMD - see TRANSITIONS below
'   .TransitionOut  how it leaves, when nothing on the stack wants it any
'               more (its slide was removed, expired, or its mode stopped)
'
' Only one of .Gif / .Image / .Text / .Builder / .Callback is needed; the
' rest have defaults that reproduce what the table does today.
'
' TRANSITIONS
'
' A change of full-screen scene can be animated instead of cut. Write it
' as one line - the words in any order, anything left out defaulted:
'
'     .Transition    = "push left 0.4 out_cubic"
'     .TransitionOut = "push right"
'
' or field by field, which is the same thing:
'
'     With .Transition
'         .TransitionType = "push"   ' see the list below
'         .Direction      = "left"   ' left right up down (default left)
'         .Duration       = 0.4      ' seconds (default depends on type)
'         .Easing         = "out_cubic"
'     End With
'
'   none      a straight cut
'   push      both scenes move together, the new one pushing the old out
'   move_in   the new one slides in over the old (a cover)
'   move_out  the old one slides away, uncovering the new (a reveal)
'   wipe      the new one is uncovered in place by a moving edge
'   fade      through black
'   flash     a moment of solid white, then the new scene
'   curtain   two black doors close, the scene changes, they open
'
' Direction is the way the content TRAVELS: "left" brings the new scene
' in from the right. Easing takes the MPF names - linear, in_quad,
' out_quad, in_out_quad, and the same for cubic, quart, quint, sine,
' expo, circ, back, bounce and elastic. Durations default to 0.4s across
' and about half that up/down; fade 0.5, flash 0.08, curtain 0.7.
'
' Which one plays: when a scene is COVERED (whatever replaced it has
' higher priority, and it is still on the stack underneath) the arriving
' entry's .Transition is used. When a scene LEAVES, its own
' .TransitionOut is used first, then the arriving entry's .Transition.
' An entry's own setting always beats the table-wide default set by
' SetDmdDefaultTransition at the top of CreateFlexDmdDisplay, and
' "none" counts as a setting - it is how an entry opts out of one.
'
' Always a cut, whatever is set: the first scene shown, a replay of the
' scene already up, a change made underneath text (which covers the
' whole DMD), and a change within 0.25s of the last transition starting.
' Layers (.Over) do not transition; they ride along with their backdrop.
' The fade needs dmdtx_black25/50/75.png in StarsHollowDMD/.

Sub CreateFlexDmdDisplay()

    Dim x, i

    ' The table-wide transition: what a scene change does when neither
    ' entry involved says. The first is for arriving, the second for
    ' leaving ("" = the same). Leave this commented out and transitions
    ' are opt-in, entry by entry.
    ' SetDmdDefaultTransition "push left", "push right"

    '*******************************************
    '  Slides
    '*******************************************

    ' The scoreboard, and the only scene that draws widget text.
    ' No transitions of its own: it is the home screen, so whatever
    ' covers or uncovers it decides how that looks.
    With CreateDmdSlide("score")
        .Builder = "DmdBuild_Score"
        .Ticker  = "DmdTick_Score"
        .Aliases = Array("base")
    End With

    ' The attract intro. It animates with FlexDMD actions, which start
    ' when the scene goes on the DMD; .ResetFrame keeps FlexFrame counting
    ' from zero for anything that keys on it. Fading in and out marks
    ' attract <-> game as the big change it is.
    With CreateDmdSlide("welcome")
        .Builder       = "DmdBuild_Welcome"
        .Ticker        = "DmdTick_Welcome"
        .ResetFrame    = True
        .Aliases       = Array("attract")
        .Transition    = "fade 0.5"
        .TransitionOut = "fade 0.5"
    End With
    ' With CreateDmdSlide("welcome")   : .Image = "stars_hollow_town_dark_logo.png"   : End With

    With CreateDmdSlide("high_score")
        .Builder       = "DmdBuild_Initials"
        .Ticker        = "DmdTick_Initials"
        .Aliases       = Array("highscore")
        .Transition    = "curtain"
        .TransitionOut = "fade 0.5"
    End With

    With CreateDmdSlide("high_score_award")
        .Builder       = "DmdBuild_Award"
        .Ticker        = "DmdTick_Award"
        .Transition    = "fade 0.5"
        .TransitionOut = "fade 0.5"
    End With

    ' Rises over the score at the end of a ball, and leaves the way it came.
    With CreateDmdSlide("eob_bonus")
        .Builder       = "DmdBuild_Bonus"
        .Ticker        = "DmdTick_Bonus"
        .Transition    = "flash"
        .TransitionOut = "curtain"
        ' .Transition    = "move_in up"
        ' .TransitionOut = "move_out down"
    End With

    ' Forward into a mode, back out of it.
    With CreateDmdSlide("mode")
        .Builder       = "DmdBuild_Mode"
        .Ticker        = "DmdTick_Mode"
        .Transition    = "push left"
        .TransitionOut = "push right"
    End With

    ' Final scores after the game - one big score, or every player's.
    With CreateDmdSlide("game_over")
        .Builder       = "DmdBuild_GameOver"
        .Ticker        = "DmdTick_GameOver"
        .Transition    = "fade 0.6"
        .TransitionOut = "fade 0.5"
    End With

    ' A LAYER over the mode panel: two portraits that slide in from the
    ' edges and sit on top of it, rather than replacing it. Played and
    ' removed like any other slide - .Action = "remove", an .Expire, or
    ' the mode that played it stopping.
    With CreateDmdSlide("luke_and_lorelei")
        .Builder = "DmdBuild_LukeAndLorelei"
        .Ticker  = "DmdTick_LukeAndLorelei"
        .Over    = "mode"
    End With

    ' "Something happened NOW."
    With CreateDmdSlide("multiball")
        .Gif           = "multiball.gif"
        .Transition    = "flash"
        .TransitionOut = "move_out up"
    End With
    With CreateDmdSlide("kirk-dances")
        .Gif           = "kirk-dances.gif"
        ' .Transition    = "move_in down 0.5 out_bounce"
        .Transition   = "push left"
        ' .TransitionOut = "move_out up"
    End With
    With CreateDmdSlide("logan-hit")
        .Gif           = "logan_hit_short_small.gif"
        .Transition    = "move_in down 0.5 out_bounce"
        .TransitionOut = "move_out up"
    End With

    For i = 0 to UBound(mysteryAwards)
        With CreateDmdSlide("mystery_" & mysteryAwards(i).Short)
            .Builder       = "DmdBuild_Mystery_" & mysteryAwards(i).Short
            .Ticker        = "DmdTick_Mystery"
            .Transition    = "move_in down 0.5 out_bounce"
        End With
    Next

    With CreateDmdSlide("skillshot")
        .Text = "SKILLSHOT! (points:,)"
    End With

    With CreateDmdSlide("hurryup_achieved")
        .Text = "HURRY-UP BONUS (points:,)"
    End With

    Dim characterNames, characterImages, characterHitEvents
    characterNames = Array("sookie", "kirk", "lane", "paris")
    characterImages = Array("sookie.png", "kirk_stern.png", "lane_glasses.png", "paris.png")
    characterHitEvents = Array("SPINS", "BUMPERS", "SLINGS", "RAMPS")

    For i = 0 To UBound(characterNames)
        With CreateDmdSlide(characterNames(i))
            .Text = "(remaining) " & characterHitEvents(i) & " TO ADVANCE " & UCase(characterNames(i))
            .Image = characterImages(i)
            .Effect = "solid"
            .Hold = 0.75
        End With

        With CreateDmdSlide(characterNames(i) & "_advance")
            .Text = UCase(characterNames(i)) & " LEVEL (light) ACHIEVED"
            .Image = characterImages(i)
            .Effect = "solid"
        End With

        With CreateDmdSlide(characterNames(i) & "_complete")
            .Text = UCase(characterNames(i)) & " COMPLETE"
            .Image = characterImages(i)
            .Effect = "solid"
        End With
    Next

    '*******************************************
    '  Widgets
    '*******************************************

    With CreateDmdWidget("ball_save")            : .Text = "BALL SAVED"              : End With
    With CreateDmdWidget("launch")               : .Text = "LAUNCH"                  : End With
    With CreateDmdWidget("ball_1_locked")        : .Text = "BALL 1 LOCKED"           : End With
    With CreateDmdWidget("ball_2_locked")        : .Text = "BALL 2 LOCKED"           : End With
    ' With CreateDmdWidget("skillshot")            : .Text = "SKILLSHOT HIT"           : End With
    With CreateDmdWidget("extra_ball_lit")       : .Text = "EXTRA BALL LIT"          : End With
    With CreateDmdWidget("extra_ball")           : .Text = "EXTRA BALL"              : End With
    With CreateDmdWidget("dance_marathon")       : .Text = "DANCE MARATHON"          : End With
    With CreateDmdWidget("dance_marathon_done")  : .Text = "DANCE MARATHON COMPLETE" : End With
    With CreateDmdWidget("team_jess")            : .Text = "TEAM JESS"               : End With
    With CreateDmdWidget("team_dean")            : .Text = "TEAM DEAN"               : End With
    With CreateDmdWidget("jess_wins")            : .Text = "TEAM JESS WINS"          : End With
    With CreateDmdWidget("dean_wins")            : .Text = "TEAM DEAN WINS"          : End With

    ' Multiplayer: whose turn it is, and a player joining mid ball 1
    For x = 1 To 4
        With CreateDmdWidget("player_" & x & "_up")    : .Text = "PLAYER " & x & " UP"    : End With
        With CreateDmdWidget("player_" & x & "_added") : .Text = "PLAYER " & x & " ADDED" : End With
    Next

    ' Generic: whatever the event carried under "text". Nothing is drawn
    ' if the event carried none.
    With CreateDmdWidget("text") : .Text = "(text)" : End With

End Sub
