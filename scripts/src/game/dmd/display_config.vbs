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
' A SLIDE replaces what is on the DMD. A WIDGET is a transient overlay
' drawn on top of the scoreboard - it only appears while the scoreboard
' is the slide on screen, which is what "overlay" means here.
'
' ADDING ONE
'
'   A GIF, dropped in StarsHollowDMD/, is one line:
'       With CreateDmdSlide("kirk-dances") : .Gif = "kirk-dances.gif" : End With
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
'   .Image      still image, same
'   .Text       literal text, with (name) tokens from the event's kwargs
'   .Builder    Sub name, builds the scene once at Flex_Init
'   .Ticker     Sub name, runs every DMD frame while this is on screen
'   .Callback   Sub name, replaces the default render entirely
'   .RenderMode one of the FlexDMD_RenderMode_* constants (default DMD_GRAY)
'   .Effect     "solid" or "blink"  (slides default solid, widgets blink)
'   .Hold       seconds a text SLIDE stays up (default 1.2). Widgets use
'               the .Expire from mode config instead.
'   .Over       for a text slide, the slide it draws on top of and will
'               put up if it is not already showing (slides default
'               "score", widgets default to nothing)
'   .ResetFrame True to zero FlexFrame before showing, for a scene whose
'               ticker keys on absolute frame numbers
'   .Aliases    Array of extra names that resolve to this same entry
'
' Only one of .Gif / .Image / .Text / .Builder / .Callback is needed; the
' rest have defaults that reproduce what the table does today.

Sub CreateFlexDmdDisplay()

    '*******************************************
    '  Slides
    '*******************************************

    ' The scoreboard, and the only scene that draws widget text.
    With CreateDmdSlide("score")
        .Builder = "DmdBuild_Score"
        .Ticker  = "DmdTick_Score"
        .Aliases = Array("base")
    End With

    ' The attract intro. Its ticker keys on absolute frame numbers
    ' (88, 110), so it only plays from a reset counter.
    With CreateDmdSlide("welcome")
        .Builder    = "DmdBuild_Welcome"
        .Ticker     = "DmdTick_Welcome"
        .ResetFrame = True
        .Aliases    = Array("attract")
    End With

    With CreateDmdSlide("multiball")   : .Gif = "multiball.gif"   : End With
    With CreateDmdSlide("jackpot")     : .Gif = "jackpot.gif"     : End With
    With CreateDmdSlide("kirk-dances") : .Gif = "kirk-dances.gif" : End With

    ' Bonus X and the drop target bonus tiers
    With CreateDmdSlide("bonus_x")  : .Gif = "bonusx.gif"  : End With
    With CreateDmdSlide("no_bonus") : .Gif = "nobonus.gif" : End With
    With CreateDmdSlide("bonus_1")  : .Gif = "bonus1.gif"  : End With
    With CreateDmdSlide("bonus_2")  : .Gif = "bonus2.gif"  : End With
    With CreateDmdSlide("bonus_3")  : .Gif = "bonus3.gif"  : End With

    ' The Dance Marathon countdown. A slide and not a widget because only
    ' the slide player passes the triggering event's kwargs through, and
    ' the count lives in there - GLF's timer puts "ticks_remaining" in the
    ' kwargs of every timer_X_tick.
    '
    ' Held slightly longer than the 1s tick interval so the text does not
    ' blink out between ticks, and solid rather than blinking because it
    ' is continuous, not a notification.
    With CreateDmdSlide("dance_marathon_timer")
        .Text = "(ticks_remaining) SEC"
        .Hold = 1.2
    End With


    '*******************************************
    '  Widgets
    '*******************************************

    With CreateDmdWidget("ball_save")            : .Text = "BALL SAVED"              : End With
    With CreateDmdWidget("launch")               : .Text = "LAUNCH"                  : End With
    With CreateDmdWidget("ball_1_locked")        : .Text = "BALL 1 LOCKED"           : End With
    With CreateDmdWidget("ball_2_locked")        : .Text = "BALL 2 LOCKED"           : End With
    With CreateDmdWidget("skillshot")            : .Text = "SKILLSHOT HIT"           : End With
    With CreateDmdWidget("extra_ball_lit")       : .Text = "EXTRA BALL LIT"          : End With
    With CreateDmdWidget("extra_ball")           : .Text = "EXTRA BALL"              : End With
    With CreateDmdWidget("dance_marathon")       : .Text = "DANCE MARATHON"          : End With
    With CreateDmdWidget("dance_marathon_done")  : .Text = "DANCE MARATHON COMPLETE" : End With
    With CreateDmdWidget("team_jess")            : .Text = "TEAM JESS"               : End With
    With CreateDmdWidget("team_dean")            : .Text = "TEAM DEAN"               : End With
    With CreateDmdWidget("jess_wins")            : .Text = "TEAM JESS WINS"          : End With
    With CreateDmdWidget("dean_wins")            : .Text = "TEAM DEAN WINS"          : End With

    ' Generic: whatever the event carried under "text". Nothing is drawn
    ' if the event carried none.
    With CreateDmdWidget("text") : .Text = "(text)" : End With

End Sub
