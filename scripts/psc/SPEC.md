# Specification: Pinball Show Compiler (PSC)

PSC is a build-time Python tool for Stars Hollow Showdown. It does two jobs:

1. **Light groups in one place.** You define groups in one config file. PSC writes them into each light's
   GLF tags (the VPX `blink_pattern` field) in the extracted `gameitems/*.json`, and reads them back when it builds the hardware map.
2. **Show compilation.** You write layered show choreography in YAML. PSC compiles it into GLF VBScript (`CreateGlfShow` blocks).

Backglass bulbs are first-class: they can be put in groups with playfield lights and driven by the same shows.

---

## 1. Scope

**v1 covers:**
- Light groups: defining them, syncing them to the JSON, and validating them.
- Backglass bulbs, through proxy lights (section 5).
- Light patterns: `solid`, `flash`, `chase`, `sweep`, `breathe`, layered with priorities.
- Default color per light or group, so most shows never name a color.

**Deferred:**
- Sounds, slides, widgets, nested sub-shows.
- Generic DOF toys like shakers or beacons. The table has no DOF hardware today besides the backglass.

**Non-goals:**
- Replacing the GMC/Godot show pipeline or `mpf-show-convert.js`. They keep working as they are. PSC doesn't use them.

---

## 2. Tech stack & layout

- Python 3.12+, managed as a `uv` project in `scripts/psc/`. Dependencies: `pyyaml`, plus `pytest` for development.
- PSC emits VBScript directly. There is no intermediate MPF YAML.
- `glf.vbs` is pulled from upstream (`npm run update-glf`), so PSC never relies on patching it.

| Path | Role | Owner |
|---|---|---|
| `scripts/psc/` | Tool source, tests | PSC code |
| `scripts/src/psc/hardware.yaml` | Groups, colors, backglass bulbs, anchors (source of truth) | Hand-edited |
| `scripts/src/psc/shows/*.yaml` | Show choreography | Hand-edited |
| `starshollow/gameitems/Light.*.json` | Light positions, colors, applied tags | vpxtool, plus PSC (`blink_pattern` only) |
| `starshollow/collections.json` | `glf_lights` collection: the set of lights GLF drives | VPX, plus PSC (proxy membership) |
| `starshollow.directb2s` | Backglass bulb IDs and positions | B2S Designer (read-only for PSC) |
| `scripts/src/game/shows/psc_shows.vbs` | Compiled output: `Sub CreatePscShows()` | Generated. Never edit. |
| `scripts/src/game/psc_backglass_mirror.vbs` | Proxy-to-DOF mirror (section 5), called from `FrameTimer_Timer` | Hand-written, once |

`psc_shows.vbs` sits inside the existing Grunt concat glob `src/game/**/*.vbs`. Next to `CreateGeneralShows()` in
`_configuration.vbs`, add one call: `CreatePscShows()`.

---

## 3. Hardware config (`hardware.yaml`)

```yaml
anchors:                   # named points in table coordinates, for radial sweeps and chase ordering
  drain: [476, 2050]
  pops:  [610, 520]

lights:                    # default color per light (required unless a group sets it)
  l12: ff2020
  FL1: ffb464

groups:
  GI:
    color: ffb464
    members: ["@collection:GI"]           # import a VPX collection
  slim_inserts:
    members: [l40, l41, l42, l43, l44, l45]
  lukes:
    color: 30a0ff
    members: ["l1*"]                      # glob over glf_lights names
  left_ramp_fx:                           # mixes playfield and backglass
    members: [l20, l21, l22, FL1, bg_flash_lower_left]
  all_inserts:
    members: ["@slim_inserts", "@lukes"]  # group composition

backglass:
  source: ../../starshollow.directb2s
  bulbs:                  # threshold: on while the proxy's brightest channel is above it (0-254)
    bg_logo:              { b2s_id: 1, threshold: 127 }
    bg_flash_lower_left:  { b2s_id: 2, color: ffffff }
    bg_flash_upper_left:  { b2s_id: 3 }
    bg_flash_upper_right: { b2s_id: 4 }
    bg_flash_lower_right: { b2s_id: 5 }
```

**Values:** PSC loads YAML with every scalar as text and converts it per field. An unquoted color like `000000` stays a
color instead of becoming the number 0.

**Member syntax:**
- a light name
- a glob, such as `l1*`. Matches sort naturally, so `l2` comes before `l10`.
- `@group`
- `@collection:Name`, a VPX collection
- `@area:<conditions>`, every light whose position matches all the comma-separated conditions on `x` and `y`.
  For example, `@area:x<476,y>=1250` is the lower-left of the table. Backglass proxies count at their virtual
  positions above the playfield.

A group can also have `exclude:`, a list in the same syntax. Those lights are removed after the members resolve.
For example: `{ members: ["@area:y<700"], exclude: [bg_logo] }`. Every resolved member must be in `glf_lights`,
or be a backglass bulb. Anything else is an error.

**Default colors.** Every GLF light must get a default color from `hardware.yaml`. A show uses it whenever a layer
doesn't set `color:`. The first match wins:
1. The layer's `color` in the show.
2. The light's own entry: `lights.<name>: ff2020`, or the long form `{ color: ff2020 }`.
3. `color` on a group the light belongs to. If two of its groups set different colors and the light has no entry of its
   own, that's an error.
4. Backglass bulbs only: `backglass.bulbs.<name>.color`.

There is no fallback to the VPX light color or a global default. If any light has no color, `psc map` and `psc compile`
fail and list the lights to add. `psc map` shows where each light's color comes from.

---

## 4. Group sync (`psc sync`)

`hardware.yaml` is the source of truth. The tags in the JSON are the applied state.

- For every light in `glf_lights`, PSC sets `blink_pattern` to the sorted, comma-joined names of the groups containing it.
  Lights in no group get `""`. This also clears the VPX default `"10"`, which GLF currently registers as a junk tag `T_10`.
- Lights outside `glf_lights` are never touched.
- **Edits are surgical.** PSC rewrites only the `"blink_pattern": "..."` line by text replacement. It never re-serializes
  vpxtool's JSON, so diffs stay one line per light and float formatting is never disturbed.
- `psc sync --check` writes nothing. It exits non-zero and prints the differences if the JSON doesn't match the config.
  `psc compile` runs this check first.
- `psc import-groups` is a one-time bootstrap. It prints a `groups:` block built from the tags already in the JSON.
- At compile time, group membership is read back from the JSON tags. Member order comes from `hardware.yaml`.
- GLF also uses tags to link lights to lightmaps named with `_T_<tag>_`. Avoid group names that match such element names.

**Workflow hazard:** after `psc sync`, run `npm run assemble-vpx` before opening VPX. If you extract from an older `.vpx`, the
tags revert. `sync --check` catches this, and the next `psc sync` repairs it.

---

## 5. Backglass bulbs as proxy lights

The table controls backglass bulbs through `DOF <b2s_id>, 0|1`. Today that happens in `backglass_shows.vbs`. Driving DOF
straight from compiled shows has two problems, both confirmed in `glf.vbs`:

- DOF commands bypass GLF's per-light priority stack, so two shows driving one bulb clobber each other.
- `StopRunningShow` restores lights but never touches DOF, so a show stopped mid-flash leaves the bulb on.

Instead, each backglass bulb gets a **proxy light**. That's a hidden VPX `Light` object named after the bulb, for example
`bg_logo`, that is a member of `glf_lights`. GLF treats it like any other light: tags, priorities, stop cleanup, and fades.

- **Creation:** `psc sync` creates the proxies. It clones a template `Light.*.json` and sets `name`, `center`, and `visible: false`.
  It then adds the file to `gameitems.json` and the bulb to the `glf_lights` collection. Re-runs update proxies in place.
  If cloning proves fragile in testing, the fallback is to create the proxies once by hand in VPX. PSC then only verifies them.
- **Position:** each proxy's `center` is set to a virtual spot above the playfield top. By default, the bulb's B2S X maps
  linearly onto the table width, at a fixed y above the playfield. A bulb can override this with `position: [x, y]`.
  Sweeps and chase ordering then include backglass bulbs naturally.
- **Mirror:** `psc_backglass_mirror.vbs` runs every frame from `FrameTimer_Timer`. It reads each proxy's `.Color`, which is where
  GLF writes brightness and color. When a proxy's on/off state changes, it calls `DOF id, 1` or `DOF id, 0`.
  "On" means any channel above a threshold, 0 by default and configurable per bulb. Bulbs are on/off only, so fades become a
  single switch at the threshold crossing.
- **Generation:** PSC writes the bulb-to-B2S-ID table into `psc_shows.vbs`, so the mirror script itself never changes.
- After migrating, `backglass_shows.vbs` can be deleted.

---

## 6. Show schema

One show per file. File name and `show` must match.

```yaml
show: ramp_hit
length: 1200ms           # optional; default is the end of the last layer. Sets the loop period.
layers:                  # later layers sit on top of earlier ones
  - target: lukes
    pattern: breathe
    period: 1000ms
    min: 20              # brightness 0-100
    max: 100

  - target: left_ramp_fx
    pattern: sweep
    direction: up        # up | down | left | right | out | in
    anchor: drain        # required for out/in
    speed: 1500          # table units per second
    width: 120           # band at full brightness, in table units
    tail: 200ms          # fade-out after the band passes
    color: ff00ff        # optional; overrides resolved colors

  - target: [FL1, bg_logo]
    pattern: flash
    start: 300ms
    count: 3
    on: 80ms
    off: 80ms
```

**Common layer keys:** `target` (group, light, or list of either) or `each` (below), `pattern`, `start` (default 0, or
`after`), `color`, `brightness` (default 100), `priority` (default: the layer's index).

**Each.** `each:` runs one layer's pattern separately on several targets at once, as if the layer were copied with
`target:` set to each entry in turn. Entries are groups or lights, or a glob over group names such as `groove_*`
(matches in natural order). `target: [a, b]` would merge both groups into one list, so a chase would step across all
of them as one long chain; `each: [a, b]` runs a chase inside each group, both starting together:

```yaml
layers:
  - { target: all_lights, pattern: solid, brightness: 30 }   # baseline
  - { each: "groove_*", pattern: chase, order: y, interval: 80ms, tail: 120ms, count: 2 }
```

Everything else about the layer is shared: `start`, `priority`, `color` and the pattern's parameters. It works with any
pattern that takes a `target`; `beat` and `show` layers don't take it.

Groups of different sizes take different times (a chase pass lasts lights x `interval`), so `count` (or `cycles`) is
for the entry that runs longest. Every other entry keeps repeating its pattern until that entry's last light lets go,
and is cut off at that moment, mid-pass if need be, fading out with the same `tail`. So all the chases run for the
whole layer, and they end together.

**Fill.** `count: fill` (or `cycles: fill` for `breathe`) repeats a pattern until the show's `length`, which the show
must set. It works with or without `each`:

```yaml
length: 4s
layers:
  - { each: [jess, dean, scoop], pattern: chase, interval: 80ms, count: fill }
```

**Patterns:**

| Pattern | Keys | Meaning |
|---|---|---|
| `solid` | `duration` | On at `start` for `duration`. |
| `flash` | `count`, `on`, `off`, `fade?` | Blink the whole target. |
| `chase` | `order`, `interval`, `width`, `tail?`, `count?` | Step through lights one at a time. `order` is `listed`, `x`, `y`, `-x`, `-y`, or `angle:<anchor>`. `width` is how many lights are lit at once, so it must be less than the number of lights when `count` is more than 1. |
| `sweep` | `direction`, `anchor?`, `speed`, `width`, `tail` | Spatial band. Each light's on-time is its distance along the direction divided by `speed`. |
| `breathe` | `period`, `min`, `max`, `cycles?` | Two keyframes per cycle, using GLF's fade field. No dense sampling. |

**Times** accept `ms` or `s` suffixes. A bare number is milliseconds. A show with a `tempo:` also accepts musical
times: `3 steps`, `2 beats` or `1 bar`.

**Tempo.** `tempo: { bpm: 128, steps_per_beat: 4, beats_per_bar: 4 }`. Only `bpm` is required. A show with a tempo
and no `length` lasts a whole number of bars, so it loops on the beat. GLF works in 10ms steps, so a loop can drift
slightly against music unless a step is a whole multiple of 10ms. At 125 bpm, for example, a step is exactly 120ms.

**Resolution.** `resolution: 30ms` snaps all of a show's timing to a coarser grid. The default is 10ms. Use it when a
show over many lights would otherwise compile to a step on nearly every frame.

**Show layers** play another PSC show inside this one, `count` times back to back. `start: after` starts any layer
when the layer above it ends:

```yaml
layers:
  - { pattern: show, show: psc_groove, count: 3 }
  - { pattern: show, show: psc_all_lights_sweeps, count: 2, start: after }
```

The other show's compiled timeline is copied in at compile time and layered like any other layer. When each
repetition ends, its lights are released, just as GLF clears a show's lights when it ends, so an included show plays
exactly as it does on its own. Its fade-out tails fade to whatever is beneath the show layer, so an included show
layered over a baseline settles back onto that baseline. The result is still
one GLF show that stops cleanly, unlike GLF's own nested shows. A show layer can't take a `target`, `color` or
`brightness`. Shows can't include each other in a loop.

**Beat layers** use drum-tab notation. Each track maps a target (any group or light) to a pattern:

```yaml
tempo: { bpm: 128 }
layers:
  - { target: all_lights, pattern: solid, brightness: 43 }   # baseline: just a lower layer
  - pattern: beat
    attack: 80ms          # rise before each hit (default 0)
    hold: 0ms             # time at the peak (at least one grid step)
    decay: 80ms           # fall back to whatever is beneath
    count: 1              # times to repeat the pattern
    accents: { x: 80, X: 100 }   # symbol -> peak brightness (default x and X = 100)
    tracks:
      groove_lower_left: "x...x...x...x..."
      slim_inserts: |
        x.x.x.x. x.x.x.x.   # spaces, '|' and comments are visual only
        x.x.x.x. X.x.x.x.   # extra lines continue the pattern
```

- Each character is one tempo step. `.`, `-` and `_` are rests, and every other character must be an accent symbol.
- A light in several tracks takes the brightest hit on each step.
- If a hit's rise would start before the layer begins, it wraps to the end of the pattern. A looping show then
  anticipates the downbeat.
- If the next hit starts rising before the current one has decayed, the light goes straight into the next hit.

**Length.** By default a show lasts until its last pattern ends, including trailing off-time. For example, a flash ends
after its final `off`, and a sweep ends after its `gap`. An explicit `length` can extend that, but can't cut content short.

**Playing shows.** When a GLF show stops or finishes, its lights are removed, so a show only holds lights while it runs.
To keep lights on, play the show with `Loops = -1`. To fire it once, use `Loops = 0`.

**Tokens:** `color: (color)` passes a GLF token through unchanged, so one compiled show can serve many modes.
The light's resolved default is not applied in that case. Callers set the token through the show player's `Tokens`.

---

## 7. Compilation model

1. **Load.** Read `hardware.yaml`, the light JSON (name, center, color, tags), `glf_lights`, and the directb2s file.
   Run `sync --check`.
2. **Expand.** Turn each layer into per-light segments: start, end, brightness, color, fade-in, fade-out.
3. **Flatten.** All layers are resolved inside one GLF show. Layers are not compiled as sub-shows.
   - Why: GLF's `StopRunningShow` doesn't stop sub-shows that a parent show started. Stopping a mode's show
     would leave its child layers running.
   - At each time, a light shows the highest-priority layer that has it lit.
   - When a higher layer releases a light, the light falls back to the layer below. If that layer is mid-fade, PSC emits
     its interpolated value, assuming linear RGB, with the remaining fade time. If no layer has the light, PSC emits `stop`.
4. **Quantize.** Snap every keyframe to a 10ms grid. GLF rounds step durations to 0.01s anyway, and snapping keeps
   rounding from accumulating into drift on loops.
5. **Render fades.** GLF has a quirk here. When a show runs a step with lights, it cancels every fade the show's previous
   light step started, and those lights jump to their targets. PSC keeps a native GLF fade only if no other light step
   lands inside it. Otherwise PSC writes the fade as explicit 30ms frames. A light's first fade in a show starts from
   the value the light holds at the end of the show, so loops are seamless.
6. **Emit.** Use duration-form steps, `AddStep(Null, Null, <seconds>)`, as `general_shows.vbs` does. Each step's duration
   is the gap to the next keyframe. The last step runs to `length`, which makes loop periods exact.
   - Light strings are `"name|brightness|RRGGBB"` or `"name|brightness|RRGGBB|fade_ms"`.
   - A stop is `"name|100|stop"`. GLF reads the color from the third field, so a two-field `"name|stop"` would break.
   - Step durations are in **seconds**. The fade field is in **milliseconds**.
   - Only lights that changed are emitted in each step.
   - Every show ends with an empty marker step. GLF stops a show played once as soon as its last step runs, ignoring
     that step's duration, so without the marker the final step would never be visible. The marker goes 10ms before
     the end when there's room, which keeps loop periods exact.
   - Each light that isn't set at time 0 gets `stop` at time 0, so nothing carries over from the previous loop.

Output file shape:

```vbscript
' GENERATED BY PSC - DO NOT EDIT. Source: scripts/src/psc/shows/
Sub CreatePscShows()
    With CreateGlfShow("ramp_hit")
        With .AddStep(Null, Null, 0.08)
            .Lights = Array("l20|100|ff00ff", "bg_flash_lower_left|100|ffffff")
        End With
        ...
    End With
End Sub
```

**Validation.** All of these are errors and nothing is written:
- unknown targets or anchors, a layer with both `target` and `each`, or an `each` glob that matches no group
- `count: fill` in a show with no `length`
- color conflicts between groups
- missing `anchor` for out/in sweeps
- a show `length` shorter than its content
- duplicate show names, across PSC shows and a scan of existing `CreateGlfShow("...")` names in `scripts/src`

---

## 8. CLI & workflow

```
uv run psc sync [--check]     # apply groups and backglass proxies to the JSON
uv run psc import-groups      # one-time bootstrap from existing tags
uv run psc map                # print the hardware map: lights, positions, groups, colors
uv run psc compile            # sync --check, then write psc_shows.vbs
```

From `scripts/`, the same commands run as `npm run psc-sync`, `psc-map`, `psc-compile` and `psc-test`.

Typical loop:
1. Edit `hardware.yaml`, then run `psc sync` and `npm run assemble-vpx`.
2. Edit the show YAML, then run `psc compile`. Grunt concatenates the result into `starshollow.vbs`.
3. Test in VPX.

---

## 9. Milestones

1. **Groups.** Done. Config loading, `sync` and `--check`, `import-groups`, `map`. The table JSON is synced, and
   vpxtool assembles and re-extracts it unchanged, including the empty tags.
2. **Backglass proxies.** Built: proxy creation in `sync`, the mirror script, and the frame-timer hook.
   `psc_bg_flash_lower_left` is the PSC version of `backglass_flash1_show`. Still to do: test it in VPX. Done when a
   higher-priority show overrides a bulb, and stopping a show mid-flash turns the bulb off. After that, migrate
   `backglass_shows.vbs` and delete it.
3. **Compiler core.** Done. `solid`, `flash`, `chase`, color resolution, duration-form output, quantization, `CreatePscShows`.
4. **Layers and spatial.** Done. Flattening with priorities and fade fallback, `breathe`, `sweep`, tokens, fade rendering.
5. **Beats.** Done. Tempo, musical time units, `beat` layers, `@area` groups. `psc_groove` ports the old Godot
   drum groove to every light, including the backglass.
6. **Later.** Sounds, slides, widgets, generic DOF toys, sub-shows. Hits could also drive other patterns, for
   example a chase that moves one light per hit.

Tests live in `scripts/psc/tests` (`npm run psc-test`).

**Things to verify in VPX:**
- The table loads with the five proxy lights and with empty `blink_pattern` values.
- The backglass bulbs follow their proxies, and only one DOF command goes out per change.
- The example shows look right: `psc_flasher_sweep_up`, `psc_slim_inserts_demo`, `psc_bg_flash_lower_left`.
- In production mode, GLF loads lightmap links from `cached-functions.vbs`. Run the table once in development mode
  after a sync so that file includes the proxies.
