'*******************************************
'  ZFBC: FlexDMD BCP Controller (local)
'*******************************************
'
' Lets the GLF slide player and widget player drive FlexDMD directly,
' with no Godot Media Controller and no socket.
'
' HOW IT WORKS
'
' Every place GLF plays a slide or a widget has the same shape:
'
'     If useBcp = True Then
'         bcpController.PlaySlide slide, mode, event, action, expire, priority, kwargs
'     End If
'
' There is no second branch and no event fired for "a slide was played" -
' if useBcp is False, or bcpController was never assigned, those calls do
' nothing at all. But bcpController is only a variable holding an object,
' and GLF never checks what class that object is. Give it an object with
' the same method names and GLF cannot tell the difference. That is all
' GlfFlexDmdBcpController below is.
'
' WHAT YOU EDIT
'
' Nothing in this file, normally. Every slide and widget the table has is
' listed in
'
'     src/game/dmd/display_config.vbs
'
' where a GIF slide and a text widget are one line each:
'
'     With CreateDmdSlide("kirk-dances") : .Gif = "kirk-dances.gif" : End With
'     With CreateDmdWidget("ball_save")  : .Text = "BALL SAVED"     : End With
'
' and the scenes that are real code (the scoreboard, the attract intro,
' the mode panel) name Builder/Ticker Subs that live in
'
'     src/game/dmd/display_scenes.vbs
'
' The name is then immediately usable from mode config:
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
' What lives down at the bottom of THIS file is the machinery behind
' those two Create calls: the entry class, the two registries, and the
' render path that turns an entry into ShowScene/AddActor/DMDBigText.
'
' SLIDES AND WIDGETS
'
' The two are the same kind of thing here - an entry in a registry - and
' the difference is how a mode reaches them, which is worth keeping:
'
'   A SLIDE is played and then stays until something takes it away. The
'   slide player passes the triggering event's kwargs through, so a slide
'   can show live data, and .Action = "remove" takes it back off.
'
'   A WIDGET is fired and forgotten. The widget player passes no kwargs
'   and has no remove, so a widget only ever leaves by its .Expire
'   running out or by its mode stopping.
'
' Neither says anything about what gets drawn. Either one can be a GIF,
' a still, a line of text or a built scene, and either one can be a LAYER
' (below).
'
' THE STACK
'
' The light stack and the segment display stack live inside GLF, so their
' priority layering is automatic. Nothing equivalent exists for slides -
' on a real setup that stacking is Godot's job. This file implements it:
' every played slide and widget is kept in one priority-ordered stack
' (ties broken by most recent), and each render works out what the DMD
' should look like from the whole stack rather than from one entry.
' Entries are tagged with the mode that played them, so ModeStop clears
' that mode's entries automatically.
'
' When the stack empties the last scene is deliberately LEFT on the DMD
' rather than blanked - that keeps the scoreboard up between balls, when
' base mode has stopped and nothing has played a slide yet. See
' FlexDmd_StackEmpty if you want a different fallback.
'
' LAYERS
'
' An entry with a scene of its own and an .Over is a LAYER: instead of
' replacing what is on the DMD, its FlexDMD Group is added as a child of
' the scene underneath, and taken off again when it leaves the stack.
' That is the whole mechanism - two images that slide in over the mode
' panel are a layer, an animated GIF over the scoreboard is a layer.
'
'     With CreateDmdSlide("luke_and_lorelei")
'         .Builder = "DmdBuild_LukeAndLorelei"
'         .Ticker  = "DmdTick_LukeAndLorelei"
'         .Over    = "mode"
'     End With
'
' .Over says what the layer belongs on top of:
'
'   a slide name   that slide is the layer's backdrop. Playing the layer
'                  brings the backdrop up if it is not already there, and
'                  the layer is held back (not drawn on the wrong scene)
'                  if something else has since taken the DMD.
'   "current"      whatever is on screen will do.
'
' Layers are attached lowest priority first, which is the order FlexDMD
' draws them in, so the highest priority ends up on top. Each one's
' .Ticker runs every frame while it is attached, after the backdrop's,
' and is handed its own entry - so it reaches its actors through
' entry.Scene() rather than hunting the whole stage, which would also
' search the scene underneath.
'
' A layer builder has two rules: build a Group of its own and hand it
' back with entry.SetScene (do not reach into FlexDMD.Stage), and leave
' ClearBackground False, or the layer paints over its own backdrop.
'
' An entry with no scene is never a layer. It still uses .Over the same
' way, to name the backdrop it needs - see TEXT below.
'
' TEXT
'
' A .Text entry draws through DMDBigText, and the only thing that puts
' DMDBigText on screen is DmdTick_Score, the scoreboard's ticker. So a
' text entry needs the scoreboard underneath it, and .Over is how it
' says so. The defaults keep the two players behaving the way you would
' expect:
'
'   a text SLIDE with no .Over falls back to FlexDmdTextBackdrop, and
'   brings the scoreboard up - a slide is allowed to take the screen.
'
'   a text WIDGET with no .Over falls back to nothing, and appears only
'   if the scoreboard happens to be up already - a notification must not
'   yank the slide out from under itself.
'
' Either can say otherwise: .Over = "current" never disturbs anything,
' and .Over = "score" always brings the scoreboard up.
'
' THE COST OF useBcp = True
'
' Attaching a controller flips useBcp on, and that flag gates more than
' slides. GLF will also push every dispatched event, player add, ball
' start/end and variable change at bcpController.Send, and poll
' GetMessages every 300ms. Those are wire-protocol messages with nowhere
' to go here, so the controller drops them - but GLF still builds the
' strings, which is a small per-event cost you would also be paying with
' a real Godot controller attached.
'
' REVERTING TO REAL BCP
'
' Turn the "Glf Backbox Control Protocol" table option On. FlexBcp_Attach
' below stands down whenever that option is set, GLF connects to Godot
' the normal way, and every slide, widget and show entry keeps working
' unmodified - the only thing that changed is what sits behind
' bcpController.


' DMDTimer's interval, in ms - Expire is given in seconds, DMDBigText
' counts DMD frames. Keep in sync with the DMDTimer object in the table.
Const FlexDmdFrameMs = 17

' Expire used for a widget that did not set one.
Const FlexDmdDefaultWidgetExpire = 1.3

' The backdrop a text SLIDE falls back to when it names no .Over.
' DMDBigText is drawn by this scene's ticker and by no other, so this is
' the only value that makes an unqualified text slide visible.
Const FlexDmdTextBackdrop = "score"

' Our controller instance, when one is attached. Null otherwise.
' bcpController points at the same object; this second reference is what
' the delay callback below uses, so it never has to care what GLF has
' since done with bcpController.
Dim glfFlexBcp : glfFlexBcp = Null

' The two registries, name -> GlfDmdEntry, filled by CreateFlexDmdDisplay
' in src/game/dmd/display_config.vbs. Kept apart so a slide and a widget
' may share a name, and so an unmapped name says which of the two it was
' looking for.
Dim FlexDmdSlides : Set FlexDmdSlides = CreateObject("Scripting.Dictionary")
Dim FlexDmdWidgets : Set FlexDmdWidgets = CreateObject("Scripting.Dictionary")

' The entry whose scene is on the DMD, or Nothing. This is the backdrop
' every layer attaches to, and the first Ticker DMDTimer_Timer runs.
Dim FlexDmdCurrent : Set FlexDmdCurrent = Nothing

' The layers attached to it, entry.Key -> GlfDmdEntry, in attach order -
' which is back-to-front, because a FlexDMD Group draws its actors in the
' order they were added.
Dim FlexDmdLayers : Set FlexDmdLayers = CreateObject("Scripting.Dictionary")


'*******************************************
'  Wiring
'*******************************************

' Attach the local controller. Idempotent - safe to call as often as you
' like, which matters because Glf_Options tears bcpController down on
' every option event.
'
' Called from Table1_Init (after Flex_Init, so the scenes exist) and from
' Table1_OptionEvent (after Glf_Options, to put it back).
Sub FlexBcp_Attach()
    If UseFlexDMD = 0 Then Exit Sub

    ' The real Godot controller wins if the table option asks for it.
    ' Same Option() call Glf_Options makes, so this only reads the value.
    If Table1.Option("Glf Backbox Control Protocol", 0, 1, 1, 0, 0, Array("Off", "On")) = 1 Then
        Exit Sub
    End If

    If IsObject(bcpController) Then
        ' Identity comparison rather than TypeName - see the note on
        ' FlexDmd_Kwarg below. TypeName() segfaults VPX's macOS VBScript
        ' engine, so this file never calls it.
        Dim isOurs : isOurs = False
        If IsObject(glfFlexBcp) Then
            If bcpController Is glfFlexBcp Then isOurs = True
        End If

        If Not isOurs Then
            ' Somebody else's controller - leave it alone.
            Exit Sub
        End If
        If bcpController.Connected Then
            ' Already ours and live. Nothing to do but make sure GLF is
            ' still routing to it.
            useBcp = True
            Exit Sub
        End If
        ' Ours, but Disconnect has been through it - replace it below.
    End If

    Set glfFlexBcp = (new GlfFlexDmdBcpController)()
    Set bcpController = glfFlexBcp
    useBcp = True
End Sub


' Fired by SetDelay when a stack item's Expire elapses. args is the stack
' key, which is also the delay's name - see FlexBcp_StackKey.
Sub Glf_FlexDmdSlideExpired(args)
    If IsObject(glfFlexBcp) Then
        glfFlexBcp.RemoveStackItem args
    End If
End Sub


'*******************************************
'  The controller
'*******************************************
' Implements every method GLF calls on bcpController. PlaySlide,
' PlayWidget, ModeStart, ModeStop, ModeList, SendPlayerVariable,
' SendMachineVariable, Send, GetMessages, Reset and Disconnect all have
' live call sites in GLF once useBcp is True - Send and GetMessages
' especially, which Glf_BcpSendEvent and Glf_BcpUpdate reach for on
' ordinary events, nowhere near a slide. RemoveSlide, PlaySound,
' StopSound and SlidesClear have none today; they are here so a later GLF
' version that starts calling them finds something to call.

Class GlfFlexDmdBcpController

    Private m_stack      ' stack key -> GlfFlexDmdStackItem
    Private m_current    ' name of the scene on the DMD ("" = none)
    Private m_drawn      ' stack key whose .Text/.Callback was last drawn
    Private m_seq        ' monotonic counter, breaks priority ties
    Private m_connected

    Public default Function Init()
        Set m_stack = CreateObject("Scripting.Dictionary")
        m_current = ""
        m_drawn = ""
        m_seq = 0
        m_connected = True
        Set Init = Me
    End Function

    ' The scene currently on the DMD, or "" - handy from the debugger.
    Public Property Get CurrentSlide() : CurrentSlide = m_current : End Property

    ' False once Disconnect has run. FlexBcp_Attach uses this to tell a
    ' live controller from a spent one.
    Public Property Get Connected() : Connected = m_connected : End Property


    '--- Slides --------------------------------------------------------

    Public Sub PlaySlide(slide, context, calling_context, action, expire, priority, kwargs)
        If m_connected = False Then Exit Sub
        If FlexBcp_Str(slide) = "" Then Exit Sub

        If LCase(FlexBcp_Str(action)) = "remove" Then
            RemoveSlide slide
            Exit Sub
        End If

        Push slide, False, context, FlexBcp_Num(expire), priority, kwargs
    End Sub

    Public Sub RemoveSlide(slide)
        If m_connected = False Then Exit Sub
        RemoveStackItem FlexBcp_StackKey(slide, False)
    End Sub

    ' Drop one item by stack key. This is what the expiry delay calls,
    ' and it is the single way anything leaves the stack.
    Public Sub RemoveStackItem(key)
        If m_connected = False Then Exit Sub
        If m_stack.Exists(key) Then
            Log "Remove " & key
            m_stack.Remove key
            RemoveDelay key
        End If
        Render ""
    End Sub

    ' Drop everything a given mode played - slides and widgets both. GLF
    ' has no internal caller for this, but ModeStop below does exactly
    ' what the real BCP controller does and calls it, so a mode's display
    ' cleans itself up.
    Public Sub SlidesClear(context)
        If m_connected = False Then Exit Sub

        If m_stack.Count = 0 Then Exit Sub

        Dim ctx : ctx = FlexBcp_StripMode(context)
        Dim doomed() : ReDim doomed(m_stack.Count)
        Dim n : n = -1
        Dim key, item
        For Each key In m_stack.Keys()
            Set item = m_stack(key)
            If item.Context = ctx Then
                n = n + 1
                doomed(n) = key
            End If
        Next

        If n = -1 Then Exit Sub

        Dim i
        For i = 0 To n
            Log "SlidesClear " & ctx & " -> removing " & doomed(i)
            m_stack.Remove doomed(i)
            RemoveDelay doomed(i)
        Next
        Render ""
    End Sub


    '--- Widgets -------------------------------------------------------
    ' Same stack, different registry. The widget player passes no kwargs
    ' and no action, so a widget has no (token) text to fill in and no
    ' way to be removed early - its .Expire, or its mode stopping.

    Public Sub PlayWidget(widget, context, calling_context, priority, expire)
        If m_connected = False Then Exit Sub
        If FlexBcp_Str(widget) = "" Then Exit Sub

        Dim secs : secs = FlexBcp_Num(expire)
        If secs <= 0 Then secs = FlexDmdDefaultWidgetExpire

        Push widget, True, context, secs, priority, Null
    End Sub


    '--- Modes ---------------------------------------------------------

    Public Sub ModeStart(name, priority)
    End Sub

    Public Sub ModeStop(name)
        SlidesClear name
    End Sub

    Public Sub ModeList()
    End Sub


    '--- Sound ---------------------------------------------------------
    ' GLF's own SoundPlayer handles audio locally and never routes it
    ' through bcpController, so there is nothing to do here.

    Public Sub PlaySound(sound, context, calling_context, priority)
    End Sub

    Public Sub StopSound(sound)
    End Sub


    '--- Raw BCP surface -----------------------------------------------
    ' Once useBcp is True, GLF pushes every dispatched event, player add,
    ' ball start/end and variable change at these. They are wire-protocol
    ' messages for a process that does not exist here, so they are dropped
    ' - but they must exist, or those paths error out.

    ' Deliberately not logged: this one is hit on every dispatched event,
    ' and building the log string would cost more than the drop.
    Public Sub Send(commandMessage)
    End Sub

    ' Glf_BcpUpdate polls this every 300ms and returns early on Empty.
    Public Function GetMessages()
        GetMessages = Empty
    End Function

    Public Sub Reset()
    End Sub

    Public Sub SendPlayerVariable(name, value, prevValue)
    End Sub

    Public Sub SendMachineVariable(name, value, prevValue)
    End Sub

    Public Sub Disconnect()
        If m_connected Then
            Log "Disconnect"
            m_connected = False
            useBcp = False
            m_stack.RemoveAll
            m_current = ""
            m_drawn = ""
            FlexDmd_ClearLayers()
        End If
    End Sub


    '--- Internals -----------------------------------------------------

    ' Put an entry on the stack, or refresh the one already there, and
    ' re-render. isWidget picks the registry the name is looked up in,
    ' and is half of the stack key - a slide and a widget may share a
    ' name and be on the stack at the same time.
    Private Sub Push(name, isWidget, context, expire, priority, kwargs)
        Dim key : key = FlexBcp_StackKey(name, isWidget)

        Dim item
        If m_stack.Exists(key) Then
            Set item = m_stack(key)
        Else
            Set item = (new GlfFlexDmdStackItem)(name, isWidget)
            m_stack.Add key, item
        End If

        m_seq = m_seq + 1
        item.Priority = FlexBcp_Num(priority)
        item.Context = FlexBcp_StripMode(context)
        item.Expire = expire
        item.Seq = m_seq
        item.SetKwargs kwargs

        Log "Play " & key & " (context=" & item.Context & _
            ", priority=" & item.Priority & ", expire=" & expire & ")"

        ' The stack key doubles as the delay name, so replaying an entry
        ' restarts its expiry rather than stacking a second one.
        RemoveDelay key
        If expire > 0 Then
            SetDelay key, "Glf_FlexDmdSlideExpired", key, expire * 1000
        End If

        ' Pass the key as the forced one, so replaying what is already
        ' showing restarts its animation instead of being skipped.
        Render key
    End Sub

    ' Work out what the DMD should look like from the whole stack, and
    ' make it so. forceKey re-renders that one entry even when nothing
    ' about the stack changed; pass "" for "only what changed".
    Private Sub Render(forceKey)
        Dim keys : keys = OrderedKeys()
        Dim i, n, entry, topEntry, topItem, topKey, baseEntry
        Dim wanted()

        If UBound(keys) < 0 Then
            ' Nothing left in the stack. Leave the last scene up, but
            ' forget it, so replaying it later renders again.
            m_current = ""
            m_drawn = ""
            FlexDmd_ClearLayers()
            FlexDmd_StackEmpty()
            Exit Sub
        End If

        ' Flex_Init has not run yet - change nothing, so the next Render
        ' still has all of this to draw.
        If Not IsObject(FlexDMD) Then Exit Sub

        ' The top entry that is NOT a layer: the one whose .Callback or
        ' .Text gets drawn, and the usual answer to "what is playing".
        Set topEntry = Nothing
        Set topItem = Nothing
        topKey = ""
        For i = UBound(keys) To 0 Step -1
            Set entry = ItemEntry(m_stack(keys(i)))
            If Not entry Is Nothing Then
                If Not entry.IsLayer Then
                    Set topEntry = entry
                    Set topItem = m_stack(keys(i))
                    topKey = keys(i)
                    Exit For
                End If
            End If
        Next

        ' A Callback takes the whole render over - no backdrop, no
        ' layers, nothing but the Sub it names.
        If Not topEntry Is Nothing Then
            If topEntry.Callback <> "" Then
                If topKey <> m_drawn Or topKey = forceKey Then
                    FlexDmd_DrawEntry topEntry, ItemKwargs(topItem), ItemHold(topItem, topEntry)
                    m_drawn = topKey
                End If
                Exit Sub
            End If
        End If

        ' The backdrop. Walking from the top down, the first item that
        ' knows what belongs underneath it decides: a full-screen scene
        ' is its own backdrop, a layer or a text entry names one with
        ' .Over, and an entry happy with whatever is already up (.Over =
        ' "current", or a bare text widget) passes the question on down.
        Set baseEntry = Nothing
        For i = UBound(keys) To 0 Step -1
            Set entry = ItemEntry(m_stack(keys(i)))
            If Not entry Is Nothing Then
                If entry.HasScene And Not entry.IsLayer Then
                    Set baseEntry = entry
                Else
                    Set baseEntry = FlexDmd_Backdrop(entry)
                End If
                If Not baseEntry Is Nothing Then Exit For
            End If
        Next

        If Not baseEntry Is Nothing Then
            If Not (FlexDmdCurrent Is baseEntry) Then
                FlexDmd_Present baseEntry
            ElseIf forceKey <> "" Then
                ' Replaying the backdrop itself restarts it. Replaying
                ' something that merely sits ON it must not - that would
                ' rebuild the stage, and restart the scoreboard's
                ' scrolling title, on every tick of a countdown.
                If m_stack.Exists(forceKey) Then
                    If ItemEntry(m_stack(forceKey)) Is baseEntry Then
                        FlexDmd_Present baseEntry
                    End If
                End If
            End If
        End If

        ' Then the layers, lowest priority first. A layer whose backdrop
        ' is not what ended up on screen is held back rather than drawn
        ' over the wrong scene - it will appear if its backdrop returns.
        ReDim wanted(UBound(keys))
        n = -1
        For i = 0 To UBound(keys)
            Set entry = ItemEntry(m_stack(keys(i)))
            If Not entry Is Nothing Then
                If entry.IsLayer Then
                    If FlexDmd_LayerFits(entry) Then
                        n = n + 1
                        Set wanted(n) = entry
                    End If
                End If
            End If
        Next
        FlexDmd_SetLayers wanted, n

        ' And last, whatever the top entry draws for itself.
        If Not topEntry Is Nothing Then
            If topKey <> m_drawn Or topKey = forceKey Then
                FlexDmd_DrawEntry topEntry, ItemKwargs(topItem), ItemHold(topItem, topEntry)
            End If
        End If
        m_drawn = topKey

        m_current = ""
        If Not FlexDmdCurrent Is Nothing Then m_current = FlexDmdCurrent.Name
    End Sub

    ' The registry entry a stack item names, or Nothing when the config
    ' has no such name.
    Private Function ItemEntry(item)
        If item.IsWidget Then
            Set ItemEntry = FlexDmd_Lookup(FlexDmdWidgets, item.Name)
        Else
            Set ItemEntry = FlexDmd_Lookup(FlexDmdSlides, item.Name)
        End If
    End Function

    ' kwargs is an object or Null, so it cannot be a property - see
    ' GlfFlexDmdStackItem.SetKwargs.
    Private Function ItemKwargs(item)
        If item.HasKwargs Then
            Set ItemKwargs = item.Kwargs()
        Else
            ItemKwargs = Null
        End If
    End Function

    ' How long a text entry's DMDBigText is held. A widget uses the
    ' .Expire its mode config gave it, so the text and the stack item go
    ' away together; a slide uses its own .Hold.
    Private Function ItemHold(item, entry)
        If entry.IsWidget Then
            ItemHold = item.Expire
        Else
            ItemHold = entry.Hold
        End If
    End Function

    ' True when stack item aKey sorts below bKey: lower priority, or the
    ' same priority and played earlier.
    Private Function Below(aKey, bKey)
        Dim a : Set a = m_stack(aKey)
        Dim b : Set b = m_stack(bKey)
        If a.Priority <> b.Priority Then
            Below = (a.Priority < b.Priority)
        Else
            Below = (a.Seq < b.Seq)
        End If
    End Function

    ' Every stack key, lowest first. Insertion sort - the stack is a
    ' handful of entries, never more, and this runs only when one of
    ' them is played or removed.
    Private Function OrderedKeys()
        Dim count : count = m_stack.Count
        If count = 0 Then
            OrderedKeys = Array()
            Exit Function
        End If

        Dim keys : keys = m_stack.Keys()
        Dim i, j, moving
        For i = 1 To count - 1
            moving = keys(i)
            j = i - 1
            Do While j >= 0
                If Not Below(moving, keys(j)) Then Exit Do
                keys(j + 1) = keys(j)
                j = j - 1
            Loop
            keys(j + 1) = moving
        Next
        OrderedKeys = keys
    End Function

    Private Sub Log(message)
        Glf_WriteDebugLog "flexdmd_bcp", message
    End Sub

End Class


' One entry on the stack - which entry was played, by whom, how loudly
' and when. What it DRAWS is the GlfDmdEntry this names; this class is
' only the playing of it.
Class GlfFlexDmdStackItem

    Private m_name, m_isWidget
    Private m_priority, m_context, m_seq, m_expire, m_kwargs

    ' The name as GLF played it - which may be an alias.
    Public Property Get Name() : Name = m_name : End Property

    ' Which registry it was played out of.
    Public Property Get IsWidget() : IsWidget = m_isWidget : End Property

    Public Property Get Priority() : Priority = m_priority : End Property
    Public Property Let Priority(input) : m_priority = input : End Property

    Public Property Get Context() : Context = m_context : End Property
    Public Property Let Context(input) : m_context = input : End Property

    Public Property Get Seq() : Seq = m_seq : End Property
    Public Property Let Seq(input) : m_seq = input : End Property

    Public Property Get Expire() : Expire = m_expire : End Property
    Public Property Let Expire(input) : m_expire = input : End Property

    Public default Function Init(itemName, isWidget)
        m_name = itemName
        m_isWidget = isWidget
        m_priority = 0
        m_context = ""
        m_seq = 0
        m_expire = 0
        m_kwargs = Null
        Set Init = Me
    End Function

    ' kwargs is whatever the event carried - a Scripting.Dictionary, or
    ' Null from a show step or the widget player. Property Let cannot
    ' take an object, hence the pair of methods.
    Public Sub SetKwargs(input)
        If IsObject(input) Then
            Set m_kwargs = input
        Else
            m_kwargs = Null
        End If
    End Sub

    Public Property Get HasKwargs()
        HasKwargs = IsObject(m_kwargs)
    End Property

    Public Function Kwargs()
        If IsObject(m_kwargs) Then
            Set Kwargs = m_kwargs
        Else
            Kwargs = Null
        End If
    End Function

End Class


'*******************************************
'  The registry
'*******************************************
' The entries are written in src/game/dmd/display_config.vbs. This is the
' machinery behind them: the entry class, the two Create functions, the
' one-time scene build, and the render path that turns an entry into
' ShowScene / AddActor / DMDBigText.

' One slide or one widget.
Class GlfDmdEntry

    Public Gif           ' animated file in the FlexDMD project folder
    Public Image         ' still image, same
    Public Text          ' literal text, with (name) kwargs tokens
    Public Builder       ' Sub name: builds the scene once, at Flex_Init
    Public Ticker        ' Sub name: runs every frame while this is on screen
    Public Callback      ' Sub name: replaces the render entirely
    Public RenderMode    ' one of the FlexDMD_RenderMode_* constants
    Public Effect        ' "solid" or "blink"
    Public Hold          ' seconds a text slide stays up
    Public Over          ' what this entry is drawn ON TOP of - see LAYERS
    Public ResetFrame    ' zero FlexFrame before showing
    Public Aliases       ' extra names resolving to this same entry

    ' The name as written in config - used for logs and for naming the
    ' FlexDMD actors of an auto-built scene. Read-only, the way every GLF
    ' class exposes its own name.
    Private m_name
    Public Property Get Name() : Name = m_name : End Property

    ' Which registry this was created in. Only the two defaults in Init
    ' and the text backdrop rule in FlexDmd_Backdrop turn on it.
    Private m_isWidget
    Public Property Get IsWidget() : IsWidget = m_isWidget : End Property

    ' Unique across both registries, since a slide and a widget are
    ' allowed to share a name. Doubles as the stack key and as the name
    ' of that item's expiry delay - see FlexBcp_StackKey, which builds
    ' the same string from a name that has not been looked up yet.
    Public Property Get Key()
        Key = FlexBcp_StackKey(m_name, m_isWidget)
    End Property

    ' The FlexDMD Group, once built. Property Let cannot take an object,
    ' hence the pair of methods - the same shape as the stack item's
    ' SetKwargs above.
    Private m_scene

    ' True when this entry draws ON TOP of another scene instead of
    ' replacing it: it has a scene of its own, and an .Over saying what
    ' that scene belongs on. A text entry has no scene of its own, so it
    ' is never a layer - it uses .Over to pick a backdrop, not to be one.
    Public Property Get IsLayer()
        IsLayer = HasScene
        If IsLayer Then IsLayer = (FlexBcp_Str(Over) <> "")
    End Property

    ' While attached: the entry this layer is a child of. Nothing
    ' otherwise. FlexDmd_ClearLayers needs it to detach from the right
    ' group even after the DMD has moved on.
    Private m_parent
    Public Property Get Parent()
        If IsObject(m_parent) Then Set Parent = m_parent Else Set Parent = Nothing
    End Property
    Public Sub SetParent(input)
        If IsObject(input) Then Set m_parent = input Else Set m_parent = Nothing
    End Sub

    ' FlexFrame at the moment this layer went on, so a Ticker can animate
    ' from zero however many times the layer is replayed.
    Private m_attachFrame
    Public Property Get AttachedAtFrame() : AttachedAtFrame = m_attachFrame : End Property
    Public Sub SetAttachFrame(input) : m_attachFrame = input : End Sub

    Public default Function Init(entryName, isWidget)
        m_name = entryName
        m_isWidget = isWidget
        Set m_parent = Nothing
        m_attachFrame = 0
        Gif = ""
        Image = ""
        Text = ""
        Builder = ""
        Ticker = ""
        Callback = ""
        RenderMode = FlexDMD_RenderMode_DMD_GRAY_4
        ResetFrame = False
        Aliases = Array()
        Hold = 1.2

        ' .Over is left empty for both, so setting it always means the
        ' same thing: "I am drawn on top of this." What differs is the
        ' fallback when it is NOT set, and that is a property of text -
        ' see FlexDmd_Backdrop.
        Over = ""

        If isWidget Then
            ' A widget is a notification, so text blinks.
            Effect = "blink"
        Else
            ' A text slide is continuous, so it does not.
            Effect = "solid"
        End If

        Set Init = Me
    End Function

    Public Sub SetScene(input) : Set m_scene = input : End Sub
    Public Property Get HasScene() : HasScene = IsObject(m_scene) : End Property

    Public Function Scene()
        If IsObject(m_scene) Then
            Set Scene = m_scene
        Else
            Set Scene = Nothing
        End If
    End Function

End Class


' Called from display_config.vbs. Both return the new entry so the caller
' can fill it in with a With block.
Function CreateDmdSlide(name)
    Set CreateDmdSlide = FlexDmd_Register(FlexDmdSlides, name, False)
End Function

Function CreateDmdWidget(name)
    Set CreateDmdWidget = FlexDmd_Register(FlexDmdWidgets, name, True)
End Function

Function FlexDmd_Register(registry, name, isWidget)
    Dim entry : Set entry = (new GlfDmdEntry)(name, isWidget)
    Dim key : key = LCase(name)
    If registry.Exists(key) Then registry.Remove key
    registry.Add key, entry
    Set FlexDmd_Register = entry
End Function


' Build every scene the config asked for. Called from Flex_Init, once,
' after CreateFlexDmdDisplay has filled the registries.
Sub FlexDmd_BuildScenes()
    ' Scenes first, aliases second: an alias puts the SAME entry object
    ' under a second key, so building first means each entry is visited
    ' exactly once.
    FlexDmd_BuildRegistry FlexDmdSlides
    FlexDmd_BuildRegistry FlexDmdWidgets
    FlexDmd_RegisterAliases FlexDmdSlides
    FlexDmd_RegisterAliases FlexDmdWidgets
End Sub

Sub FlexDmd_BuildRegistry(registry)
    Dim key, entry, group
    Dim names : names = registry.Keys()

    For Each key In names
        Set entry = registry(key)
        If Not entry.HasScene Then
            If entry.Builder <> "" Then
                GetRef(entry.Builder)(entry)
            ElseIf entry.Gif <> "" Then
                Set group = FlexDMD.NewGroup(entry.Name)
                group.AddActor FlexDMD.NewVideo(entry.Name, entry.Gif)
                entry.SetScene group
            ElseIf entry.Image <> "" Then
                Set group = FlexDMD.NewGroup(entry.Name)
                group.AddActor FlexDMD.NewImage(entry.Name, entry.Image)
                entry.SetScene group
            End If
        End If
    Next
End Sub

Sub FlexDmd_RegisterAliases(registry)
    Dim key, entry, aliasName
    Dim names : names = registry.Keys()

    For Each key In names
        Set entry = registry(key)
        For Each aliasName In entry.Aliases
            If Not registry.Exists(LCase(aliasName)) Then
                registry.Add LCase(aliasName), entry
            End If
        Next
    Next
End Sub


'*******************************************
'  Showing them
'*******************************************

' The hand-wired route: put one entry on the DMD right now, ignoring the
' stack. FlexDmd_ShowSlide and FlexDmd_ShowWidget are its two front
' doors, and the AddPinEventListener note at the bottom of ZDMD is what
' they are for.
'
' The controller does NOT come through here - it renders from the stack,
' which is what lets an entry be taken away again. A layer shown this way
' becomes the only layer, and stays up until something else replaces the
' scene under it.
'
' holdSeconds is how long a text entry stays up; a scene entry ignores
' it and stays until something replaces it.
Sub FlexDmd_Render(entry, kwargs, holdSeconds)
    If entry.Callback <> "" Then
        GetRef(entry.Callback)(Array(entry.Name, kwargs, holdSeconds))
        Exit Sub
    End If

    ' Whatever this entry says belongs underneath it. Skipping the
    ' present when it is already up avoids rebuilding the stage, and
    ' restarting the scrolling title, on every tick.
    Dim backdrop : Set backdrop = FlexDmd_Backdrop(entry)
    If Not backdrop Is Nothing Then
        If Not (FlexDmdCurrent Is backdrop) Then FlexDmd_Present backdrop
    End If

    If entry.IsLayer Then
        Dim one(0)
        Set one(0) = entry
        If FlexDmd_LayerFits(entry) Then FlexDmd_SetLayers one, 0
        Exit Sub
    End If

    If entry.HasScene Then
        FlexDmd_Present entry
        Exit Sub
    End If

    FlexDmd_DrawEntry entry, kwargs, holdSeconds
End Sub


' slide name -> whatever the config said. The names are what you put in
' .Slide = "..." in mode config, or .Slides("...") in a show step.
'
' kwargs is the kwargs of the event that played the slide (a
' Scripting.Dictionary), or Null.
Sub FlexDmd_ShowSlide(slide, kwargs)
    If UseFlexDMD = 0 Then Exit Sub

    Dim entry : Set entry = FlexDmd_Lookup(FlexDmdSlides, slide)
    If entry Is Nothing Then
        Glf_WriteDebugLog "flexdmd_bcp", "No FlexDMD scene mapped for slide '" & slide & "'"
        Exit Sub
    End If

    FlexDmd_Render entry, kwargs, entry.Hold
End Sub


' widget name -> an overlay on the current slide.
'
' expireSeconds is the .Expire from config (or FlexDmdDefaultWidgetExpire
' when none was set), and is what a text overlay is held for.
'
' The widget player does not pass event kwargs today, so kwargs is Null
' from that path; a show step's .Widgets(...) is the same. It is passed
' through anyway so a widget's (token) text works if that ever changes.
Sub FlexDmd_ShowWidget(widget, expireSeconds, kwargs)
    If UseFlexDMD = 0 Then Exit Sub

    Dim entry : Set entry = FlexDmd_Lookup(FlexDmdWidgets, widget)
    If entry Is Nothing Then
        Glf_WriteDebugLog "flexdmd_bcp", "No FlexDMD overlay mapped for widget '" & widget & "'"
        Exit Sub
    End If

    FlexDmd_Render entry, kwargs, expireSeconds
End Sub


' Draw whatever an entry draws for ITSELF: a Callback that takes the
' render over, or a line of DMDBigText. A scene entry draws nothing here
' - by this point it has already been presented, or attached as a layer.
Sub FlexDmd_DrawEntry(entry, kwargs, holdSeconds)
    If entry.Callback <> "" Then
        GetRef(entry.Callback)(Array(entry.Name, kwargs, holdSeconds))
        Exit Sub
    End If

    If entry.HasScene Then Exit Sub
    If entry.Text = "" Then Exit Sub

    Dim message : message = FlexDmd_Interpolate(entry.Text, kwargs)
    If message <> "" Then
        DMDBigText message, FlexDmd_Frames(holdSeconds), FlexDmd_EffectCode(entry.Effect)
    End If
End Sub


' The scene an entry wants underneath itself, or Nothing for "whatever is
' already there".
'
' .Over names it. When .Over is empty the answer depends on what the
' entry is: a scene needs nothing under it, and a text entry needs the
' scoreboard, because DMDBigText is drawn by the scoreboard's ticker and
' by nothing else. A text SLIDE therefore falls back to it and brings it
' up, while a text WIDGET falls back to nothing - a notification that
' pulled the scoreboard up over a running mode animation would be worse
' than a notification that quietly does not appear.
Function FlexDmd_Backdrop(entry)
    Set FlexDmd_Backdrop = Nothing

    Dim want : want = LCase(FlexBcp_Str(entry.Over))
    If want = "current" Then Exit Function
    If want = "" Then
        If entry.HasScene Then Exit Function
        If entry.IsWidget Then Exit Function
        want = FlexDmdTextBackdrop
    End If

    Set FlexDmd_Backdrop = FlexDmd_Lookup(FlexDmdSlides, want)
End Function


' True when a layer belongs on the scene that is now up.
Function FlexDmd_LayerFits(entry)
    FlexDmd_LayerFits = False
    If Not entry.HasScene Then Exit Function
    If FlexDmdCurrent Is Nothing Then Exit Function

    ' "current" goes on anything, as long as there is something.
    If LCase(FlexBcp_Str(entry.Over)) = "current" Then
        FlexDmd_LayerFits = True
        Exit Function
    End If

    ' Anything else names one scene and goes on that and nothing else, so
    ' a layer whose backdrop lost the stack is held back rather than
    ' drawn over the wrong thing. A name that does not resolve fits
    ' nothing either - a typo should show up as a layer that never
    ' appears, not as one drawn over everything.
    Dim want : Set want = FlexDmd_Backdrop(entry)
    If want Is Nothing Then Exit Function
    FlexDmd_LayerFits = (want Is FlexDmdCurrent)
End Function


' Put an entry's scene on the DMD and make it the current one. This is
' the only place FlexDmdCurrent moves, which is what keeps "which tickers
' run" and "what is on screen" the same question.
Sub FlexDmd_Present(entry)
    If Not entry.HasScene Then Exit Sub

    ' A layer is a child of the scene it was attached to, not of the DMD.
    ' Leaving one on a scene that is going off screen would bring it back
    ' the next time that scene is shown, so they come off first - the
    ' render puts back whichever ones still fit.
    FlexDmd_ClearLayers()

    If entry.ResetFrame Then FlexFrame = 0
    ShowScene entry.Scene(), entry.RenderMode
    Set FlexDmdCurrent = entry
End Sub


' Make the attached layers match a list, and do nothing at all when they
' already do - reattaching is cheap but it churns the scene graph on
' every render, and FlexDMD counts an actor's action time only while it
' is on the stage.
'
' wanted is an array of entries, lowest priority first, and last is its
' last used index (-1 for none). They go on top of FlexDmdCurrent's
' scene in that order, which is the order FlexDMD draws them in.
Sub FlexDmd_SetLayers(wanted, last)
    If Not IsObject(FlexDMD) Then Exit Sub

    ' A layer cannot be drawn on its own.
    If FlexDmdCurrent Is Nothing Then
        FlexDmd_ClearLayers()
        Exit Sub
    End If

    Dim i, same, attached, parentScene, note
    same = (FlexDmdLayers.Count = last + 1)
    If same Then
        attached = FlexDmdLayers.Keys()
        For i = 0 To last
            If attached(i) <> wanted(i).Key Then same = False
            If Not (FlexDmdLayers(attached(i)).Parent Is FlexDmdCurrent) Then same = False
        Next
    End If
    If same Then Exit Sub

    FlexDmd_ClearLayers()
    If last < 0 Then Exit Sub

    note = ""
    Set parentScene = FlexDmdCurrent.Scene()

    FlexDMD.LockRenderThread
    For i = 0 To last
        ' One entry, attached once, however many names reached it - two
        ' stack items can be the same entry under an .Aliases name, and
        ' adding the same actor to a group twice draws it twice.
        If Not FlexDmdLayers.Exists(wanted(i).Key) Then
            wanted(i).SetParent FlexDmdCurrent
            wanted(i).SetAttachFrame FlexFrame
            parentScene.AddActor wanted(i).Scene()
            FlexDmdLayers.Add wanted(i).Key, wanted(i)
            note = note & " " & wanted(i).Name
        End If
    Next
    FlexDMD.UnlockRenderThread

    ' Logged outside the lock - the render thread is waiting on it.
    Glf_WriteDebugLog "flexdmd_bcp", "Layers on " & FlexDmdCurrent.Name & ":" & note
End Sub


' Take every layer back off whatever it was attached to. Safe to call
' when there are none, and safe to call before Flex_Init.
Sub FlexDmd_ClearLayers()
    If Not IsObject(FlexDMD) Then Exit Sub
    If FlexDmdLayers.Count = 0 Then Exit Sub

    Dim key, entry, parentScene
    FlexDMD.LockRenderThread
    For Each key In FlexDmdLayers.Keys()
        Set entry = FlexDmdLayers(key)
        If Not entry.Parent Is Nothing Then
            Set parentScene = entry.Parent.Scene()
            parentScene.RemoveActor entry.Scene()
        End If
        entry.SetParent Nothing
    Next
    FlexDmdLayers.RemoveAll
    FlexDMD.UnlockRenderThread
End Sub


' Run the per-frame updaters: the scene on the DMD first, then every
' layer on top of it, back to front. Called from DMDTimer_Timer, from
' inside the render lock - so a Ticker must not lock the render thread
' itself, and must not play or remove a slide, which would attach or
' detach a layer and take the lock again.
'
' A Ticker is handed its own entry, so it can reach its actors through
' entry.Scene() instead of FlexDMD.Stage. For a layer that matters:
' Stage searches the scene underneath too, and two scenes are allowed to
' hold labels of the same name.
Sub FlexDmd_Tick()
    Dim key, entry

    If Not FlexDmdCurrent Is Nothing Then
        If FlexDmdCurrent.Ticker <> "" Then
            GetRef(FlexDmdCurrent.Ticker)(FlexDmdCurrent)
        End If
    End If

    If FlexDmdLayers.Count = 0 Then Exit Sub
    For Each key In FlexDmdLayers.Keys()
        Set entry = FlexDmdLayers(key)
        If entry.Ticker <> "" Then GetRef(entry.Ticker)(entry)
    Next
End Sub


' Called when the last entry leaves the stack. Deliberately does nothing:
' the scene that was up stays up, which is what keeps the scoreboard on
' screen after base mode stops at the end of a ball. Its layers have
' already been detached by the time this runs.
'
' To blank the DMD instead:
'     FlexDMD.LockRenderThread : FlexDMD.Stage.RemoveAll : FlexDMD.UnlockRenderThread
'     Set FlexDmdCurrent = Nothing
Sub FlexDmd_StackEmpty()
End Sub


'*******************************************
'  Registry helpers
'*******************************************

' The entry registered under a name, or Nothing.
Function FlexDmd_Lookup(registry, name)
    Set FlexDmd_Lookup = Nothing

    Dim key : key = LCase(FlexBcp_Str(name))
    If key = "" Then Exit Function
    If registry.Exists(key) Then Set FlexDmd_Lookup = registry(key)
End Function


' "blink" -> DMDBigText's blinking effect, anything else -> solid.
Function FlexDmd_EffectCode(effect)
    If LCase(FlexBcp_Str(effect)) = "blink" Then
        FlexDmd_EffectCode = 1
    Else
        FlexDmd_EffectCode = 0
    End If
End Function


' Replace every (name) in a config string with the matching kwarg off the
' event that played it, the way GLF shows resolve (lights) and (color).
' A token with nothing behind it - a missing kwarg, or no kwargs at all -
' resolves to an empty string, so a text entry that is nothing but one
' token draws nothing rather than drawing a placeholder.
'
' Substitution never rescans what it just inserted: pos moves past the
' replacement, so a kwarg whose value happens to contain brackets cannot
' send this round again.
Function FlexDmd_Interpolate(text, kwargs)
    Dim result : result = text
    Dim pos : pos = 1
    Dim openAt, closeAt, token, value

    Do
        openAt = InStr(pos, result, "(")
        If openAt = 0 Then Exit Do

        closeAt = InStr(openAt + 1, result, ")")
        If closeAt = 0 Then Exit Do

        token = Mid(result, openAt + 1, closeAt - openAt - 1)
        value = FlexBcp_Str(FlexDmd_Kwarg(kwargs, token, ""))

        result = Left(result, openAt - 1) & value & Mid(result, closeAt + 1)
        pos = openAt + Len(value)
    Loop

    FlexDmd_Interpolate = result
End Function


'*******************************************
'  Helpers
'*******************************************

Function FlexDmd_Frames(seconds)
    FlexDmd_Frames = Int(FlexBcp_Num(seconds) * 1000 / FlexDmdFrameMs)
End Function

' Read one key out of an event's kwargs, with a fallback.
'
' NEVER call TypeName() on kwargs to check that it is a Dictionary. VPX's
' macOS VBScript engine (libwinevbs) segfaults on TypeName(<Scripting.
' Dictionary>) - Global_TypeName -> get_typeinfo dereferences a bad
' pointer and takes the whole process down with SIGSEGV, no script error.
' It is a real crash in the engine, not something this table did wrong,
' and it does not reproduce on Windows' vbscript.dll.
'
' IsObject plus On Error is the safe equivalent. Everything GLF puts in
' kwargs comes from GlfKwargs(), which is always a Scripting.Dictionary,
' so the only job left is to survive a caller passing something else.
Function FlexDmd_Kwarg(kwargs, key, fallback)
    FlexDmd_Kwarg = fallback
    If Not IsObject(kwargs) Then Exit Function

    On Error Resume Next
    If kwargs.Exists(key) Then FlexDmd_Kwarg = kwargs(key)
    On Error GoTo 0
End Function

Function FlexBcp_Num(value)
    If IsObject(value) Then
        FlexBcp_Num = 0
    ElseIf IsEmpty(value) Or IsNull(value) Then
        FlexBcp_Num = 0
    ElseIf IsNumeric(value) Then
        FlexBcp_Num = CDbl(value)
    Else
        FlexBcp_Num = 0
    End If
End Function

Function FlexBcp_Str(value)
    If IsObject(value) Then
        FlexBcp_Str = ""
    ElseIf IsEmpty(value) Or IsNull(value) Then
        FlexBcp_Str = ""
    Else
        FlexBcp_Str = CStr(value)
    End If
End Function

' The slide player passes the mode name unprefixed already; a show step
' can pass it with the "mode_" still on. Normalise, the way the real BCP
' controller does, so ModeStop's clear matches what PlaySlide stored.
Function FlexBcp_StripMode(value)
    FlexBcp_StripMode = Replace(FlexBcp_Str(value), "mode_", "")
End Function

' The stack key for a name, which is also the name of that item's expiry
' delay and the key a layer is tracked under. Prefixed by registry, so a
' slide and a widget of the same name are two different things, and
' namespaced so it cannot collide with another GLF delay.
'
' GlfDmdEntry.Key is this same string for an entry already looked up.
Function FlexBcp_StackKey(name, isWidget)
    If isWidget Then
        FlexBcp_StackKey = "flexdmd_w_" & LCase(FlexBcp_Str(name))
    Else
        FlexBcp_StackKey = "flexdmd_s_" & LCase(FlexBcp_Str(name))
    End If
End Function
