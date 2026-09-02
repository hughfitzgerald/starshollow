# VPX Lightmapper (VLM) + Blender — Working Guide, v2

**What changed from v1:** this version is written against the actual source of your
`vpx_lightmapper` fork (`__init__.py`, `vlm_import.py`, `vlm_collections.py`) and against
`francisdb/vpin`'s `light.rs`, rather than against the VPW video write-ups. Several steps that v1
described as manual turn out to be automated by the importer already, and several VPX-side
"settings" turn out not to exist as described. Those corrections are flagged inline with **[v1 was
wrong]**.

**Three scripts accompany this guide:**

| Script | Runs where | Does what |
| --- | --- | --- |
| `vlm_vpx_prep.py` | Host shell (Python 3) | Normalizes light settings on a `vpxtool`-extracted table |
| `vlm_rig.py` | Inside Blender | Classifies lights, applies node/material treatments, snaps sockets |
| `vlm_prep.py` | Inside Blender | Locks import flags, runs preflight validation, triggers the bake |

---

## 0. The honest automation map

Read this before anything else — it's the shortest path to knowing where your time actually goes.

**Automated by the importer itself (you do nothing):**
- Movable detection. `vlm_import.py` regexes the table's VBScript for animation properties
  (`.rotx`, `.transx`, `.objrotx`, `.size_x`…) and routes anything the script animates to
  `VPX.Import.Movable`. Bumper rings, gate wires, spinner plates, and drop-target-type hit targets
  go there unconditionally. **[v1 was wrong]** — v1 told you to hand-select movables and press M.
- Flippers and plungers. Item types 1 and 3 are `pass` in the importer — no geometry is created, so
  there's nothing to hide. **[v1 was wrong]**
- Insert cups. Created automatically with `indirect_only = True` already set.
- Playfield translucency map. Rendered automatically from the insert cups and wired into the
  playfield material's `TranslucencyMap` node. **[v1 was wrong]** — this is not Shader Editor work.
- Default collection tree, with bake/light modes already assigned:
  `VLM.Bake` → `Playfield`, `Parts` (group/opaque), `Overlay` (group/non-opaque), `Movables`
  (split/opaque); `VLM.Lights` → `All Lights` (split), `World` (solid).

**Automated by the three scripts:**
- Light property normalization in the VPX file (fader, colour, halo height, bulb visibility, shadows)
- GI light data linking + blackbody nodes
- Insert point→area conversion, disk shape, size/power, Z drop
- Asset-library material swaps (Steel, etc.) by VPX material name
- Bumper cap translucency
- Socket Z-snapping (heuristic — verify visually)
- Import-flag locking so `Update` stops reverting your work
- Preflight validation and batch invocation

**Still genuinely manual — see §5 for the full list:**
- Verifying socket/light placement by eye
- Plastics knife-cutting, if your table needs it
- HDRI selection and strength
- Aesthetic material judgement
- Reviewing the 25% test bake
- Script sync in VPX after export

---

## 1. Prerequisites

- **Visual Pinball X 10.8+** — additive-blended primitives are required for light maps.
- **Blender** — matched to whatever your fork currently supports. The stock `bl_info` declares
  `"blender": (3, 2, 0)`; your port targets 5.2.
- **The add-on**, installed and with dependencies resolved.
- **`vpxtool`** — `cargo install vpxtool`, or grab a release binary from
  `github.com/francisdb/vpxtool`.
- **The Blender pinball parts library** (`.blend`), for asset-library material swaps.
- **The three scripts**, somewhere importable.

### A macOS note on dependencies

The add-on declares three Python dependencies:

```python
vlm_dependencies.Dependency(module="olefile", ...),
vlm_dependencies.Dependency(module="PIL", package="Pillow", ...),
vlm_dependencies.Dependency(module="win32crypt", package="pywin32", ...),
```

`pywin32` is Windows-only. `dependencies_installed` gates registration of every operator and
property group, so on macOS this is a hard blocker unless your port has already relaxed it — which
it presumably has, since you're baking. Worth knowing that's *why* the whole add-on silently
fails to register if that check isn't patched.

Two more Windows-isms that are cosmetic but confusing on macOS:
- `force_open_console` calls `win32gui` and has an explicit early-`return` guard for non-Windows, so
  the "Console on bake" checkbox does nothing for you. Launch Blender from Terminal instead:
  `/Applications/Blender.app/Contents/MacOS/Blender`
- `batch_shutdown` runs `os.system("shutdown /s /t 1")` — Windows syntax, won't work.

---

## 2. Phase 1 — VPX preparation (mostly scripted)

### 2.1 The round trip

```bash
vpxtool extract MyTable.vpx
# → MyTable/gameitems/Light.<name>.json, Wall.*.json, Primitive.*.json, …
#   plus MyTable/gameitems.json as the index

python3 vlm_vpx_prep.py MyTable/ --dry-run    # inspect first
python3 vlm_vpx_prep.py MyTable/

vpxtool assemble MyTable/ MyTable-prepped.vpx
```

The extracted JSON is plain and diffable — put the extract directory in git before running the
script and you get a reviewable diff of every light change. That is a far better safety net than
editing the binary.

### 2.2 What the script sets, and the two corrections behind it

**[v1 was wrong] There is no "Render Mode: Halo / Classic" field.** The mode is derived from two
booleans, per `light.rs`:

| UI mode | `visible` | `is_bulb_light` |
| --- | --- | --- |
| Hidden | `false` | (any) |
| Classic | `true` | `false` |
| Halo | `true` | `true` |

**[v1 was wrong] "Incandescent, 120ms" is not one setting.** `fader` is an enum
(`none` / `linear` / `incandescent`, serialized as a lowercase string), and `fade_speed_up` /
`fade_speed_down` are two separate floats (`FASP` / `FASD`).

What the script writes:

| Field | GI lights | Insert lights |
| --- | --- | --- |
| `fader` | `"incandescent"` | `"incandescent"` |
| `fade_speed_up` / `_down` | 120.0 / 120.0 | 120.0 / 120.0 |
| `is_bulb_light` | `true` (→ Halo) | `false` (→ Classic) |
| `visible` | `true` | `true` |
| `show_bulb_mesh` | `true` | `false` |
| `mesh_radius` | 20.0 | — |
| `show_reflection_on_ball` | `true` | `true` |
| `shadows` | `"raytraced_ball_shadows"` | — |
| `bulb_halo_height` | 28.0 | 0.0 |
| `image` | — | `""` (clears decal) |
| `color` | warm peach | warm peach |

**Why 28 for `bulb_halo_height`:** a VPX ball is 50 units in diameter, so its centre is at 25.
Placing the light at 28 puts it just above the ball's equator, which is what makes raytraced ball
shadows cast outward correctly. `light.rs` confirms shadows are Halo-only — Classic lights don't
support them, which is consistent with only setting `shadows` on GI.

### 2.3 The naming rule — get this right before importing

Confirmed in `vlm_import.py`:

```python
is_gi = name.casefold().startswith("gi")
is_insert = not is_gi and (bulb or image == playfield_image or image == '') \
            and (not bulb or halo_height == 0) and (surface == '' or surface == '<None>')
```

Two consequences:

1. **GI lights must be named with a `gi` prefix.** This is the *only* signal. Get it wrong and GI
   lights sprout insert cups, or inserts don't get their translucency treatment.
2. `vlm_vpx_prep.py` classifies by the same rule, so it inherits the same dependency. If your names
   don't follow the convention, fix them in the JSON *first* (they're just `"name"` fields) and
   re-run.

Also from the release notes: lights named `l100a`, `l100b`, … export as if named `l100` — the
mechanism for splitting one logical lamp into several light maps that share a script target.

### 2.4 What's still manual in VPX

Open `MyTable-prepped.vpx` in the editor and do these by hand:

- [ ] **Delete duplicate stacked lights.** One VPX light per physical bulb. Check the script for
      direct name references (`Light23.State = 1`) before deleting any — collection-driven lights
      are safe, hard-coded ones aren't. This is judgement, not automation.
- [ ] **Layer organization** — GI on one layer, inserts on another. Only matters for your own
      selection convenience.
- [ ] **Table options:** Ambient Occlusion **off**, Screen Space Reflections **off**, Bloom Strength
      **0**. (Automatable in principle via `vpin`'s table-level record — not covered by the current
      script.)
- [ ] **Convert any `.bmp` images** to `.webp`/`.png` and re-import over the originals.
      `vlm_import.py` logs `"Unsupported bmp image file"` and sets `data = None` for these — you get
      an empty image, silently.
- [ ] **Import `VM_Materials.mat`** via Material Manager.
- [ ] **Save and press F5.** Confirm the table runs clean before going to Blender.

---

## 3. Phase 2 — Import into Blender

1. New file. Delete the default cube/camera/light. **Save the `.blend` into the same folder as the
   `.vpx`** — the cache is created relative to it.
2. Render properties: **Cycles**, **GPU Compute**. On macOS confirm Metal is actually selected in
   `Preferences > System > Cycles Render Devices`; a silent CPU fallback turns a 3-hour bake into an
   overnight one.
3. Scene properties → **VPX Importer** panel → **Import** (`vlm.new_from_vpx_operator`), select
   `MyTable-prepped.vpx`.

The operator sets `film_transparent` and `cycles.film_transparent_glass` for you.

### Importer options worth knowing

All on `scene.vlmSettings`:

| Property | Default | Notes |
| --- | --- | --- |
| `process_inserts` | `True` | Generates insert cups + translucency map |
| `use_pf_translucency_map` | `True` | Renders the translucency map |
| `process_plastics` | `True` | Auto-detects plastics (3mm-thick walls) and assigns glass materials |
| `bevel_plastics` | `1.0` | Bevel width on detected plastics |
| `light_size` / `light_intensity` | 5.0 / 250.0 | VPX→Blender conversion factors |
| `insert_size` / `insert_intensity` | 0.0 / 25.0 | Same, for inserts |
| `units_mode` | `'inch'` | **Affects the constants in `vlm_rig.py`** — see §4 |

Note `process_plastics`. **Plastics are authored as walls with the top visible and the sides
hidden** — that's the convention, and it's what you should be modelling to. The importer's
`is_plastic` test is thickness-only:

```python
is_plastic = 2.5 < (height_top - height_bottom) < 3.5
```

Visibility is handled separately, in material assignment: a wall with `side_visible` false gets
`VPX.Core.Mat.Invisible` on the side slot (slot 1), and the top gets `VPX.Core.Mat.Plastic` (or
`.NoAlpha` if the top image is opaque), plus a bevel modifier.

So a correctly-authored plastic — 3mm thick, top visible, sides hidden — is fully handled on import.
**If your plastics are real walls rather than one flat ramp plane, you don't need the knife-tool
workflow at all.**

---

## 4. Phase 3 — Run `vlm_rig.py`

In Blender's Text Editor or Python console:

```python
import vlm_rig
vlm_rig.rig_lights(bpy.context)
vlm_rig.swap_steel_materials(bpy.context)
vlm_rig.set_translucency(bpy.context, {"bumpertopmat1", "bumpertopmat3", "bumpertopmat5"}, 0.4)
bpy.ops.vlm.fitcamera()
```

### What each does

**`rig_lights()`** — classifies every light in `VLM.Lights`, then:
- GI lights: links object data (the Ctrl+L equivalent), adds a Blackbody node at 2700K, forces base
  colour to white
- Insert lights: converts Point→Area, disk shape, size 0.5, power 50W, drops Z by −0.06, Blackbody

**How it identifies inserts:** the importer doesn't leave its GI/insert classification on the object
afterward — only the `gi` name prefix is self-identifying. So the script uses the tell that every
insert has a sibling object with `vpx_subpart == 'InsertCup'` and the same `vpx_object`. That's
reliable as long as `process_inserts` was on at import.

**`swap_steel_materials()`** — you supply a set of *VPX material names* (from your table's Material
Manager), and it appends `Steel` from the asset library and swaps every matching slot. Materials are
named `VPX.Mat.<matname>[.<image>]`, so matching on the middle segment works. Write the list once;
it applies on every reimport forever.

**`set_translucency()`** — the shared `VPX.Material` node group exposes translucency at
`inputs[14]`, confirmed in `vlm_import.py`'s `update_material()`. One assignment per matched
material, no Shader Editor clicking.

### ⚠️ Verify the constants against your `units_mode`

The `0.5` / `50W` / `−0.06` values come from the VPW guide and are **VPX-unit-relative**. Your
project's `units_mode` defaults to `'inch'`, and `vlm_utils.get_global_scale()` applies a scale
factor throughout the importer. **Hand-place one insert light, note the values that look right, and
adjust the constants at the top of `vlm_rig.py` before trusting it across the whole table.**

---

## 5. Phase 4 — The genuinely manual pass

This is the irreducible part. Budget real time for it.

### 5.1 Socket and bulb placement

`vlm_rig.snap_sockets_to_surface()` raycasts downward and snaps each object to the first hit below
it. It gets most lights right. It is **a heuristic that cannot tell a plastic from a bracket from
the playfield**, so:

- [ ] Numpad 7 (top ortho), then orbit through the table and check every socket visually
- [ ] Anything the script logged as "No surface found" needs manual placement
- [ ] Confirm each light object sits on its bulb's **filament**, not the glass

For a missing bulb: select an existing one, **Shift+D**, name it explicitly (`G_light29`), and
**write the name down** — §7.2 needs it.

### 5.2 HDRI and world

- [ ] Shader Editor → World. The importer creates `VPX.Env.IBL` with an Environment Texture node
      named `VPX.Mat.Tex.IBL` (it looks for that exact name on update, so keep it).
- [ ] Load a neutral 4K interior HDRI. Set Background Strength to **0.4**.
- [ ] Delete the auto-generated `VPX.Env.L1` / `VPX.Env.L2` point lights in the World collection —
      the importer creates these from the VPX environment colour and they fight your HDRI.

### 5.3 Plastics, if needed

**Skip this section entirely** if your plastics are modelled properly — walls ~3mm thick with the
top visible and sides hidden. The importer handles those. This is only for legacy tables that fake
all their plastics with one flat ramp plane:

- [ ] Tab into Edit Mode, Numpad 7, **K** for Knife, trace each plastic's contour, double-click to
      close each loop, Enter
- [ ] **3** (face select), select the traced faces, **P** → Separate by Selection, delete the waste
- [ ] Drag "Plastics with Decal" from the Asset Browser, select your cuts, Shift-click the asset,
      **Ctrl+L** → Copy Modifiers, then again → Link Materials, delete the asset
- [ ] Relink the image node to your plastics `.webp`
- [ ] **G**, **Z**, lower slightly so they rest on the posts

### 5.4 Occlusion tagging

- [ ] 3D view → VLM panel → **Select Occluded** (`vlm.select_occluded_operator`). Slow; start it and
      walk away.
- [ ] With the results selected, use the Bake Options panel to flag them
      (`vlm.state_indirect_only` with `indirect_only = True`).

This is the single biggest render-time lever you have — indirect objects still influence the render
but aren't part of the exported mesh, and fewer render groups means less time.

### 5.5 Lock your work

**Do this immediately after any hand adjustment.** From `vlm_import.py`'s `get_update()`, an object
with both `import_mesh` and `import_transform` set gets fully overwritten on the next Update:

```python
import vlm_prep
vlm_prep.lock_import_flags(bpy.context.selected_objects, mesh=False, transform=False)
```

Objects whose `vpx_object` contains `;` (merged VPX objects) are never updated at all, and objects
matching multiple existings are skipped — so those are already safe.

---

## 6. Phase 5 — Preflight and bake

### 6.1 Settings

`scene.vlmSettings` — note these differ from the shipped defaults, which are tuned for speed:

| Property | Default | VPW recommendation |
| --- | --- | --- |
| `max_lighting` | `0` (no limit) | `12` |
| `remove_backface` | `0.0` (full removal) | `40` |
| `tex_size` | `'256'` | `'8192'` |
| `render_height` | `256` | Higher for final |
| `render_ratio` | `100` | `25` for test, `100` for final |
| `export_mode` | `'remove_all'` | `'hide'` — safer, keeps originals |

**Change `export_mode` off `remove_all`.** The default deletes baked items *and* purges unreferenced
images. `'hide'` keeps everything recoverable.

### 6.2 Preflight

```python
import vlm_prep
vlm_prep.preflight(bpy.context)
```

Checks: `VLM.Bake` and `VLM.Lights` exist; camera set; every light lives inside `VLM.Lights`; at
least one child collection is in `solid` mode with a `world` assigned (**no Solid collection means no
base bake** — this is the classic all-black result); every non-indirect bake object has a render
group; no `.bmp` references.

Run it **after** Groups, since `render_group` is what Groups populates.

### 6.3 Test bake at 25%

```python
bpy.context.scene.vlmSettings.render_ratio = 25
vlm_prep.run_batch_if_clean(bpy.context)
```

`vlm.batch_bake_operator` chains all five steps — Groups → Render → Meshes → Nestmaps → Export —
and calls `bpy.ops.wm.save_mainfile()` after each, bailing on the first non-`FINISHED` result. Expect
15–30 minutes.

**Review manually.** Switch the 3D view to Rendered (the table will be pink — expected), select a
bake mesh, and press **Load/Unload Renders** (`vlm.load_render_images_operator`). Look for floating
screws, clipping, lights too dark or blown, hovering plastics, anything you forgot to mark Indirect.

### 6.4 The wipe

A partial cleanup silently reuses stale cached renders. Clear all of it:

1. Delete everything inside `VLM.Result`
2. Delete the cache folder next to the `.blend` — `Renders` to force re-rendering, `Object Masks` if
   you moved anything, `Export` to regenerate packmaps
3. Delete the generated `-vlm.vpx`

### 6.5 Final bake

```python
bpy.context.scene.vlmSettings.render_ratio = 100
vlm_prep.run_batch_if_clean(bpy.context)
```

2–4 hours depending on GPU and how disciplined you were about Indirect.

---

## 7. Phase 6 — Back in VPX (manual)

### 7.1 Script sync

The exporter generates the VBScript helper that drives light map intensity from your lights' states.
**Until you integrate it, light maps are static.** This is manual and unavoidable.

### 7.2 Reconnect Blender-added lights

For each bulb you duplicated in Blender (`G_light29`):

- [ ] Copy an existing GI light in VPX
- [ ] Rename it to **exactly** the Blender name
- [ ] Place it in the collection the sync code iterates

Miss this and that area's light map never triggers.

### 7.3 Z-height fixes

- [ ] Instruction cards and apron decals often end up under the bake primitives. Raise Z until
      visible (usually ~2 units).

### 7.4 Tone mapping

- [ ] `Table > Options > Light Emission Scale` → **~0.1**. This is your new day/night control; it
      darkens unbaked movables to match the baked playfield.
- [ ] Video/Graphics Options → LUT **None**, Tone Mapping **Tony McMapface**.

---

## 8. The iteration loop

```
VPX edit
  → vpxtool extract → vlm_vpx_prep.py → vpxtool assemble
  → Blender: vlm.update_operator   (NOT Import — Update preserves collections)
  → vlm_rig.py
  → manual verification pass (§5)
  → vlm_prep.lock_import_flags on anything you touched
  → vlm_prep.run_batch_if_clean
  → script sync in VPX
  → repeat
```

`Update` (`vlm.update_operator`) matches objects by `vpx_object` identifier and preserves collection
membership; deleted objects move to `VPX.Import.Hidden`. Always Update, never re-Import, once you
have work invested.

---

## Appendix A — Confirmed API reference

**Collections** (exact names, from `get_collection` calls):
`VLM.Bake`, `VLM.Lights`, `VLM.Result`, `VPX.Import.Hidden`, `VPX.Import.Static`,
`VPX.Import.Active`, `VPX.Import.Movable`, `VPX.Import.Lights`, `VPX.Import.Temp`

**Operators:**
`vlm.new_from_vpx_operator`, `vlm.update_operator`, `vlm.compute_render_groups_operator`,
`vlm.render_all_groups_operator`, `vlm.create_bake_meshes_operator`, `vlm.render_nestmaps_operator`,
`vlm.export_vpx_operator`, `vlm.batch_bake_operator`, `vlm.select_occluded_operator`,
`vlm.select_indirect_operator`, `vlm.fitcamera`, `vlm.state_indirect_only`, `vlm.state_import_mesh`,
`vlm.state_import_transform`, `vlm.load_render_images_operator`, `vlm.blueprint`, `vlm.apply_aoi`

**`collection.vlmSettings`:** `bake_mode` (`group`/`split`), `is_opaque`, `use_static_rendering`,
`depth_bias`, `refraction_probe`, `refraction_thickness`, `reflection_probe`, `reflection_strength`,
`vpx_material`, `light_mode` (`solid`/`group`/`split`), `world`

**`object.vlmSettings`:** `vpx_object`, `vpx_subpart`, `import_mesh`, `import_transform`,
`indirect_only`, `is_movable`, `use_obj_pos`, `hide_from_others`, `bake_to`, `bake_mask`,
`is_rgb_led`, `enable_aoi`, `render_group`, `use_bake`, `bake_width`, `bake_height`,
`no_mesh_optimization`, `bake_normalmap`, `layback_offset` — and on results: `bake_lighting`,
`bake_collections`, `bake_sync_light`, `bake_sync_trans`, `is_lightmap`, `bake_hdr_range`,
`bake_nestmap`

**VPX light JSON fields** (from `vpin`'s `light.rs`, no serde renames — Rust field names are the JSON
keys): `name`, `center`, `height`, `falloff_radius`, `falloff_power`, `state_u32`, `state`, `color`,
`color2`, `blink_pattern`, `image`, `blink_interval`, `intensity`, `transmission_scale`, `surface`,
`is_backglass`, `depth_bias`, `fade_speed_up`, `fade_speed_down`, `is_bulb_light`, `is_image_mode`,
`show_bulb_mesh`, `has_static_bulb_mesh`, `show_reflection_on_ball`, `mesh_radius`,
`bulb_modulate_vs_add`, `bulb_halo_height`, `shadows`, `fader`, `visible`, `timer`, `drag_points`

---

## Appendix B — Failure symptoms

| Symptom | Cause |
| --- | --- |
| Table renders completely black | No light collection in `solid` mode with a `world` — no base bake |
| Add-on doesn't appear at all | `dependencies_installed` false; `pywin32` on non-Windows |
| Re-bake identical after changes | Cache not cleared (`Renders`, plus `Object Masks` if you moved things) |
| Lighting that never turns off | A light or emissive object outside any light collection |
| Your positioning reverted | `import_mesh`/`import_transform` still on; see §5.5 |
| Lights don't respond in VPX | Script sync not applied, or a Blender-added light has no VPX twin |
| Insert cups on GI lights | GI lights not named with a `gi` prefix |
| Inserts don't glow through | Same rule inverted, or `process_inserts` was off |
| Empty/black textures | `.bmp` images — importer logs "Unsupported bmp image file" |
| Baked items gone from the table | `export_mode` left at its `remove_all` default |
| Console checkbox does nothing (macOS) | `force_open_console` is Windows-only by design |
| Enormous bake meshes | Occluded geometry not marked Indirect |
| Doubled shadows | Pre-baked shadow objects not moved to hidden |
| Movables too bright | Light Emission Scale still default; lower toward 0.1 |

---

## Appendix C — What I could not verify

Stated plainly so you don't inherit my guesses as facts:

- **Layback modes.** The upstream README describes Disable/Deform/Camera modes and recommends
  Camera. Your fork's `VLM_OT_fit_camera` exposes only an `inclination` float. I have not read
  `vlm_camera.py`, so I don't know whether layback modes exist here at all.
- **`Fader` enum ordinals.** I confirmed `None = 0`, `Linear = 1` and that JSON serializes as
  lowercase strings. `vlm_vpx_prep.py` writes the string `"incandescent"` rather than an integer
  specifically to sidestep this.
- **Unit-scale constants** in `vlm_rig.py` — see the warning in §4.
- **Light shader node graph.** `add_blackbody()` assumes a standard Emission→Output setup. It prints
  a warning and skips rather than silently misconfiguring, but confirm against one light by hand.
- **Table-level options** (AO, SSR, Bloom) are not automated. `vpin` almost certainly has a
  table-level record module that would allow it; I haven't opened it.
