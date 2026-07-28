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
'   ZGCF: GLF Configurations  (src/game/_configuration.vbs)
'
' DELETED in the GLF migration - do not re-add:
'   ZTUT (tutorial links)  ZDMD (FlexDMD)      ZDRN (GLF owns the trough)
'   ZSCR (GLF player vars) ZLIS (ROM listener) ZRDT (no drop targets)
'   ZTST (shot tester)     ZQUE (GLF SetDelay) ZLOG   ZCRD   ZPHY


Option Explicit
Randomize
SetLocale 1033

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs In order To run this table, available In the vp10 package"
On Error GoTo 0
