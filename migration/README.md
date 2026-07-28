# GLF migration tools

Four standalone scripts for moving a VPW-example-derived VPX table onto the GLF
framework. Each uses PEP 723 inline metadata and stdlib only, so:

```
uv run glf_audit.py --help
```

They're deliberately separate rather than one command: the migration has
irreversible steps, and the plan files (`migration.toml`, `renames.toml`,
`collections.toml`) are the record of what you decided and why. Keep them in
git next to the table.

| Script | Job | Writes? |
|---|---|---|
| `glf_audit.py` | analysis, requirement checks, dead-code and unresolved-reference detection | no, ever |
| `glf_split.py` | strip dead procedures, split `script.vbs` into `src/vpx/` | yes |
| `glf_rename.py` | rename objects across gameitems, collections, scripts | yes |
| `glf_collections.py` | build the four `glf_*` collections | yes |
| `glf_scaffold.py` | build pipeline, `CreateSounds()` from ffprobe, mode skeletons, segment displays | yes (new files) |
| `glf_callbacks.py` | migrate handler bodies into GLF callback signatures | yes (new files) |

Everything that writes defaults to a dry run and needs `--apply` (or writes to
a fresh `--out`). Backups are made once, as `*.bak` / `*.pre-glf`.

---

## The sequence

Assumes `vpxtool extract MyTable.vpx` has produced `./MyTable/`.

### 0. Build pipeline

Before touching the table, on the stock GLF example:

```
uv run glf_scaffold.py project --name MyTable --root . --zini
```

Writes the 17-line in-VPX loader, `_main.vbs` (with `Option Explicit` and the
`controller.vbs` load), `Gruntfile.js` with the glob order commented, and
`package.json`. With `--zini` it also emits a rewritten `Table1_Init` /
`Table1_Exit`.

Get the edit-save-F5 loop working before migrating anything.

### 0b. Baseline

```
uv run glf_audit.py --table ./MyTable --json audit-before.json
```

Read the whole report. Sections 1 (requirements) and 3 (dead handlers) drive
the next two steps. Commit `audit-before.json` — diffing it against a later run
is the fastest way to see what a step actually did.

### 1. Strip dead code and split the script

```
uv run glf_split.py --script ./MyTable/script.vbs --init-plan migration.toml
```

Then edit `migration.toml`:

- paste the dead handler names from audit section 3 into `strip_procedures`
- review every section's `action`

The defaults encode the VPW→GLF mapping: physics and sound sections are `keep`,
sections GLF replaces outright (`ZDRN`, `ZSCR`, `ZLIS`, `ZQUE`) are `delete`,
and anything containing a mix of game logic and helpers you'll want (`ZBMP`,
`ZTRI`, `ZTAR`, `ZGII`) is `rewrite` rather than `delete` — nothing that might
still be needed is silently dropped. Deleted sections are parked in
`src/_deleted/` rather than thrown away.

```
uv run glf_split.py --script ./MyTable/script.vbs --plan migration.toml \
                    --out scripts/src/vpx --dry-run
uv run glf_split.py --script ./MyTable/script.vbs --plan migration.toml \
                    --out scripts/src/vpx
```

`--comment-strip` comments procedures out instead of deleting them, if you'd
rather see what left.

The splitter is boundary-aware: it never cuts a `Sub` in half, and it re-scans
line numbers after stripping. Sections marked `rewrite` get a `TODO: GLF
REWRITE` banner with the reason.

### 2. Rename objects

Do this *before* writing any mode configs. Event names are string literals
(`"s_Bumper1_active"`), so renaming later means editing config you've already
written.

```
uv run glf_rename.py --table ./MyTable --init-map renames.toml
$EDITOR renames.toml
uv run glf_rename.py --table ./MyTable --map renames.toml \
                     --scripts scripts/src --dry-run
uv run glf_rename.py --table ./MyTable --map renames.toml \
                     --scripts scripts/src --apply
```

Matching is case-insensitive (VBScript is) and boundary-aware. Renaming `sw11`
→ `s_ST11` rewrites `sw11` and `sw11_Hit`, and leaves `sw11o`, `psw11`, and the
VBScript variable `ST11` alone. String literals are counted and reported but
not rewritten unless you pass `--strings`.

The tool refuses to run if a target name collides, if a name isn't a valid
identifier, or if you try to rename something GLF hardcodes (`Drain`,
`swTrough1`–`swTrough7`).

### 3. Build the GLF collections

```
uv run glf_collections.py --table ./MyTable --init-plan collections.toml
$EDITOR collections.toml
uv run glf_collections.py --table ./MyTable --plan collections.toml \
                          --scripts scripts/src --dry-run
```

This one has the interlock that matters most. GLF generates `<name>_Hit`,
`<name>_UnHit`, `<name>_Slingshot` and `<name>_Spin` for collection members via
`ExecuteGlobal` at `Glf_Init`. If one of your subs is still there, you get a
duplicate-procedure error. The tool cross-references your sources and refuses
to write until every conflict is gone:

```
REFUSING TO RUN:
  glf_switches: s_Bumper1 still has s_Bumper1_Hit in .../10_ZBMP_Bumpers.vbs
    — GLF generates that sub, so this would be a duplicate-procedure error
```

It also excludes Flupper-owned lights (`bumperbiglight*`, `Flasherlight*`) from
`glf_lights` by default, since `Glf_Init` forces every member to `000000` and
would fight the ZFLD/ZFLB fade code.

### 4. Migrate the callback bodies

```
uv run glf_callbacks.py --table ./MyTable --scripts scripts/src/vpx \
    --out scripts/src/game/_callbacks.vbs \
    --scoring-out scripts/src/game/_scoring.suggested.vbs
```

Reads your handlers, writes two new files, modifies nothing:

- `_Hit` / `_Slingshot` bodies wrapped in the autofire shape, with **`ActiveBall`
  rewritten to `args(1)`** — the substitution that otherwise fails silently
- `_Timer` bodies converted to `EjectCallback(ball)` for kickers
- `Threshold` enable/disable pairs generated for bumpers
- bare `Addscore N` calls lifted out and emitted as `.Add "x_active",
  Array("score_N")` lines
- `Select Case` scoring in `STAction`/`DTAction` lifted the same way

It also detects that VPW's `SolLFlipper(Enabled)` / `SolRFlipper(Enabled)`
already match GLF's flipper signature exactly — those need no migration at
all, just `.ActionCallback = "SolLFlipper"`.

### 5. Modes and sounds

```
uv run glf_scaffold.py modes --out scripts/src/game/modes \
    --scores 10,250,1000,5000,10000 \
    --scoring scripts/src/game/_scoring.suggested.vbs

uv run glf_scaffold.py sounds --audio ./sounds \
    --out scripts/src/game/modes/sounds.vbs
```

`modes` emits score, base and attract skeletons, folding the lifted scoring
straight into base mode's `EventPlayer`. The base skeleton omits the
`.SlidePlayer()`, `.WidgetPlayer()` and `.SegmentDisplayPlayer()` blocks — they
need BCP/Godot or segment light groups.

`sounds` shells out to ffprobe for exact durations (GLF sequences on them) and
classifies by `mus_` / `sfx_` / `voc_` filename prefix.

### 5b. Segment (alphanumeric) display, if skipping FlexDMD/Godot for now

```
uv run glf_scaffold.py segments \
    --displays "player1:8:14,player2:8:14,ball:2:7,credits:2:7" \
    --table ./MyTable --out scripts/src/game/_segments.vbs --apply
```

GLF's segment display (`GlfLightSegmentDisplay`) needs a real Light object at
every character position, whether you render it to real playfield lights, to
a B2S backglass, or to GLF's own virtual-DMD renderer — the "virtual" option
only hides these lights at runtime, it does not remove the requirement that
they exist. This generates them as harmless off-table placeholder lights
(parked at `--park-x`/`--park-y`, invisible once virtual mode is on) plus the
`CreateGlfLightSegmentDisplay` config with `ExternalFlexDmdSegmentIndex`
offsets packed into GLF's fixed 32-character budget. Refuses to run over
budget rather than silently truncating.

Two 8-character 14-segment player displays alone is 240 Light objects, so
start narrow — a 6-digit score and a 2-digit ball number is enough to get
modes working.

### 6. Find what's still broken

```
uv run glf_audit.py --table ./MyTable --scripts scripts/src \
                    --glf scripts/src/glf/glf.vbs
```

Section 7 lists every identifier referenced but never defined anywhere in the
tree. VBScript resolves at runtime, so these are exactly the things that fail
at load or on first ball rather than at edit time — a helper that lived in a
section you deleted, a light that no longer exists, a call into the shot tester
from `Table1_KeyDown`.

It is a heuristic. `vpmTimer`, `DOFContactors` and friends come from
`core.vbs`, which is loaded at runtime and so always shows as unresolved;
so do late-bound COM members. Treat the high-count names as real and work down.

### 7. Reassemble and re-audit

```
vpxtool assemble ./MyTable
uv run glf_audit.py --table ./MyTable --scripts scripts/src --json audit-after.json
diff <(jq -S . audit-before.json) <(jq -S . audit-after.json)
```

---

## Notes

**These tools don't write GLF logic.** They handle the mechanical, error-prone
parts — the ones where a missed reference produces a table that loads and then
misbehaves quietly. Writing `ConfigureGlfDevices`, converting callbacks to
GLF's four different signatures, and building modes is still hand work.

**Run `glf_audit.py` after every step.** It's read-only and fast, and the
requirement checks catch the things that fail at `Glf_Init` rather than at
edit time.

**The section splitter assumes VPW's `ZXXX:` banner convention.** If your
script has drifted from it, `--sections-only` will show you what it found
before you commit to a split.

**The splitter will not silently drop code.** Anything above the first `ZXXX`
banner goes to `00_ZPRE_Preamble.vbs` — in most VPW tables `Option Explicit`,
`Randomize` and the `controller.vbs` load sit in that region or inside `ZTUT`,
and losing them is a nasty, quiet failure. If a section you marked `delete`
still contains executable lines, the tool prints them and refuses to write
until you pass `--allow-delete-code`.

**`glf_split.py --init-plan` bakes in one table's assumptions** (non-ROM,
FlexDMD rather than Godot). Read the `note` on each section rather than
trusting the `action`.
