'*********************************************************************
' Stars Hollow Showdown
'*********************************************************************
'
' Built on GLF (https://github.com/mpcarr/vpx-glf), which is itself an
' adaptation of the VPW example table scripting approach.
'
' This file is concatenated FIRST - the leading underscore matters, the
' grunt/concat glob is alphabetical. Everything below runs before any
' other source file.
'
' === TABLE OF CONTENTS ===
'   ZCON: Constants and Global Variables
'   ZOPT: User Options
'   ZTIM: Timers
'   ZINI: Table Initialization and Exiting
'   ZKEY: Key Press Handling
'   ZMAT: General Math Functions
'   ZANI: Misc Animations
'   ZFLP: Flippers (incl. nFozzy/Roth physics)
'   ZSLG: Slingshots (incl. sling correction)
'   ZBMP: Bumpers
'   ZGII: GI
'   ZDMP: Rubber Dampeners (incl. TargetBouncer)
'   ZSOL: Other Solenoids
'   ZKIC: Kickers, Saucers
'   ZTRI: Triggers
'   ZTAR: Targets
'   ZRST: Roth Stand-Up Targets
'   ZSHA: Ambient Ball Shadows
'   ZBRL: Ball Rolling and Drop Sounds
'   ZRRL: Ramp Rolling Sounds
'   ZFLE: Fleep Mechanical Sounds
'   ZFLD: Flupper Domes
'   ZFLB: Flupper Bumpers
'   ZVRR: VR Room
'   ZDMD: FlexDMD
'   ZFBC: FlexDMD BCP Controller (GLF slide/widget player -> FlexDMD)
'   ZGCF: GLF Configurations  (src/game/_configuration.vbs)
'   ZDSP: DMD slide/widget list      (src/game/dmd/display_config.vbs)
'   ZDSC: DMD scenes that are code   (src/game/dmd/display_scenes.vbs)
'
' DELETED in the GLF migration - do not re-add:
'   ZTUT (tutorial links)                      ZDRN (GLF owns the trough)
'   ZSCR (GLF player vars) ZLIS (ROM listener) ZRDT (no drop targets)
'   ZTST (shot tester)     ZQUE (GLF SetDelay) ZLOG   ZCRD   ZPHY
'
' DOF IDs
' ------------
' E101 0/1 Trigger for ball in launcher
' E102 0/1 Indicates whether start button will do anything (ie, enough credits and/or we haven't reached max players)
' E103 0/1 LeftFlipper
' E104 0/1 RightFlipper
' E105 2 Leftslingshot
' E106 2 Rightslingshot
' E107 2 top slingshot
' E108 2 top bumper left red
' E109 2 top bumper right yellow
' E110 2 scoop solenoid
' E111 2 plunger auto fire
' E112 2 diverter pin
' E113 2 lock pin
' E114 2 knocker
' E120 2 flashers red
' E121 2 flashers green
' E122 2 flashers orange
' E123 2 flashers blue
' E124 2 flashers yellow

Option Explicit
Randomize
SetLocale 1033

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs In order To run this table, available In the vp10 package"
On Error GoTo 0
