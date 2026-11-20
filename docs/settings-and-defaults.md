# Settings and defaults

Where each kind of setting gets its default, what can override it, and where to
make a change so it actually takes effect.

## The short version

| To change… | Edit | Then |
|---|---|---|
| A table option's default (anything in VPX's F12 / options menu) | The 5th argument of its `Table1.Option(...)` call | Nothing for players. Locally, `npm run reset-local-state`, or reset options in VPX |
| A table option's default for a GLF option (`glf.vbs` is upstream) | `release_ini_overrides.txt` | Ships as `<table>.ini` with the release |
| A machine var's or player var's starting value | `.InitialValue` / `Glf_SetInitialPlayerVar` in `_configuration.vbs` | If the var has `.Persist = True`, `npm run reset-local-state` to see it locally |
| The default high score table | `.Defaults("score")` in `_configuration.vbs` | `npm run reset-local-state` to see it locally |
| Anything else (sound bus volumes, `VRRoomChoice`, `UseFlexDMD`, colors) | The VBS line itself | Nothing. These have no other copy |

## Layer by layer

### VPX table options (`Table1.Option`)

```vbs
VolumeDial = Table1.Option("Mech Volume", 0, 1, 0.01, 0.8, 1)
'                          name           min max step default unit
```

- **Default:** the 5th argument. That's the only copy. The globals these
  calls assign (`VolumeDial`, `ColorLUT`, …) are declared without a value in
  `02_ZOPT_User_Options.vbs`, because `Table1_OptionEvent` sets them at
  startup before anything reads them.
- **Override:** `[TableOption]` in `<table>.ini` next to the `.vpx`. VPX
  writes it when the player changes options. It may also come from the
  release, if `release_ini_overrides.txt` has entries.
- **Key format:** VPX turns the display name into the ini key by replacing
  every character other than a letter, digit or underscore with `_`:
  `Tilt Sensitivity (digital nudge)` → `Tilt_Sensitivity__digital_nudge_`.
  `release_ini_overrides.txt` takes either form.
- **Declared twice:** an option can be read in more than one place (the GLF
  "Backbox Control Protocol" option is read in `glf.vbs` and in ZFBC), but
  every call must pass identical arguments. The build checks this.

`npm run check-table-options` lists the options and validates the overrides.
Both builds run the same check, and it fails the build if an override names an
option that doesn't exist, has a value out of range, or one option is declared
two different ways.

### What ships in the ini

- **Release (CI):** `release_ini_overrides.txt` entries only. If there are
  none (the normal case), no ini ships and every option uses its script
  default.
- **Dev (`npm run build-dev`):** the same, plus `Glf Debug Log = 1` and
  `Glf Debug Log Level = 1` (set in `build-dev.js`).

An ini only supplies defaults for a fresh install. A player who already
has saved options for the table keeps them.

### GLF machine vars

`CreateMachineVar(...)` in `_configuration.vbs`, plus the ones GLF makes itself
(`player1_score`…`player4_score`, `last_game_players`, the `credit_*`/`credits_*`
vars, `free_play`, `match_number`).

- **`.Persist = False`:** `.InitialValue` applies every session.
- **`.Persist = True`:** `.InitialValue` applies only until GLF first saves
  `[MachineVars]` in `<cGameName>_glf.ini`. After that the saved value wins.
- GLF turns **every** key in `[MachineVars]` into a machine var on load, so a
  var you've removed or renamed keeps existing on machines that saved it.
- `game_modes_enabled` is set from the "Game Modes Enabled" table option, so
  its `InitialValue` is only a placeholder.

### GLF high scores

`.Defaults("score")` is written to `[HighScores]` in `<cGameName>_glf.ini` only
when that section has no scores. From then on, the saved scores win.

### GLF game settings

`Glf_Init` sets `BallsPerGame = 3`, and then the "Balls Per Game" table option
immediately replaces it. Change the option's default, not that line (it's in
upstream `glf.vbs` anyway).

### VPX table-level settings

Difficulty, exposure, tone mapper and similar are stored in the table itself
(`starshollow/table.json`, set in the VPX editor). Your local `starshollow.ini`
may have a `[TableOverride]` section that replaces them for you only, so what
you play locally can differ from what players get.

## Seeing what a new player sees

```sh
cd scripts
npm run reset-local-state -- --dry-run   # show what would be removed
npm run reset-local-state
```

This removes `[TableOption]` and `[TableOverride]` from `starshollow.ini` (it
keeps window placement and plugin settings) and `[HighScores]`/`[MachineVars]`
from `starshollow_glf.ini`. It also deletes any `*_glf.ini` left over from an old
game name. Changed files are backed up to `.bak` first.
