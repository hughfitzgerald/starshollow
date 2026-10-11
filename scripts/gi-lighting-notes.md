# GI lighting without VLM — notes and experiment branches

Research notes from reading the VPX 10.8 renderer source
(`src/parts/light.cpp`, `src/shaders/hlsl_glsl/{LightShader,BasicShader,FlasherShader}.hlsl`,
`Material.fxh`, `docs/Lights.md`) against this table's extracted JSON, plus
the usual forum numbers. The goal: minimal ambient, GI doing the work, and a
Space-Station-style "GI off" drop, before the table goes through VLM.

## What the engine actually does

**Materials are lit by exactly three things**, all multiplied by
*Global Emission Scale*: the two table lights (`light0_emission`, same value
for both), the ambient colour, and the environment map
(`env_image` × *Env Emission Scale*). Table `Light` objects never light a wall
or a primitive directly. On this table ambient and light0 are black, so every
plastic and primitive sees only the env map at `2.0 × 0.15`.

**Inserts, flashers, bulb halos and lightmaps are not scaled** by Global
Emission Scale. That is why turning it down made the flashers and inserts
pop while the GI seemed to do nothing: the scale only darkened the base.

**A bulb-mode light draws a flat halo polygon** (its drag-point outline) at
`surface height + halo height`, blended over whatever is already in the frame:

    dst' = dst × (1 + m·L) + L × (1 − m)        m = Modulate vs Add
    L    = intensity × (1 − d/falloff)^power × colour

With `m = 1.0` (what all 21 `gi0xx` lights had) the halo can only multiply
the pixels under it. On a playfield already at 15 % that is `0.15 × (1+2) ≈
0.45` at the bulb and nothing a short way out. The halo sits at z = 1 and is
depth tested, so it never touches a plastic at z = 50–58.

**The only built-in path from a bulb to another object is "transmission".**
Every bulb with `transmission_scale > 0` is drawn into a quarter-res buffer,
blurred, and added to any *translucent* material pixel:

    if (color.a < 1.0)
        color.rgb += sqrt(diffuse) × buffer × color.a × (1 − disable_lighting_below)

Two switches have to be on: transmission on the bulb, and a material with
*Opacity active* and opacity strictly below 1.0 (the `Playfield` material's
0.9999 is this trick). `Plastic Lavender White` was active at exactly 1.0, so
the branch was skipped.

**Lightmaps.** A Flasher or Primitive whose *Light Map* property names a
light has its alpha scaled by that light's intensity ratio and gets raytraced
ball shadows from it (`docs/Lights.md`). That is the mechanism VLM exports
into; nothing stops you feeding it hand-made images. GLF does not use it: GLF
keeps `State = 1` and fades `Color`, and separately copies a light's colour
onto any Flasher/Primitive whose underscore-separated name contains the
light's name (`glf.vbs` `Glf_RegisterLights`, e.g. `LM_gi010_plastics`).
So name the flasher for GLF and still set *Light Map* for the shadows.

## The four strategies

| # | Strategy | What changes | Script |
|---|----------|--------------|--------|
| 1 | Transmission | `transmission_scale = 1.0 / intensity` on every `gi*` light; plastics material opacity `0.9999` | `gi_lighting.py transmission` |
| 2 | Halo retune | `intensity 3`, `falloff 150`, `power 2`, `modulate 0.9`, outer colour `#ff8c3a`; transmission rescaled so `intensity × transmission` stays 1.0 | `gi_lighting.py halo` |
| 3 | Plastic halos | One extra bulb light per (bulb, plastic wall within 100 units): `Surface = wall`, outline = wall outline, `intensity 2.5`, `falloff 90`, `modulate 0.9`, halo height 1. Added to the `GI` and `glf_lights` collections with the same tags | `gi_lighting.py plastic-halos` |
| 4 | Lightmaps | Hidden `GI glow` layer in `playfield.svg` (one radial blob per bulb). Each blob masks the plastics layer, renders to `scripts/lightmaps/LM_giNNN.png`, is cropped to `starshollow/images/LM_giNNN_plastics.webp`, and becomes an additive flasher `LM_giNNN_plastics` at `plastic top + 0.5`, `alpha 100`, `modulate 0.3`, `Light Map = giNNN` | `gi_lightmaps_render.py` then `gi_lighting.py lightmaps` |

Every command is idempotent and prints what it touched; `gi_lighting.py
status` shows the current numbers. All of them take `--flag value` overrides
for the numbers above.

### Why those numbers

* `intensity × transmission ≈ 1.0` puts roughly `sqrt(albedo)` of extra light
  on the plastic right over a bulb (albedo ≈ 0.9 → +0.95), fading with the
  blur. Halve `--product` if it blows out.
* Halo `3 / 150 / 2 / 0.9` on a 0.12-ish playfield: `0.12 × 3.7 + 0.3 ≈ 0.74`
  at the bulb, `≈ 0.28` at half radius, 0 at the edge: hotspots, not a
  wash. Power 3 and 230 was one soft blob.
* Plastic halo `2.5 / 90` on a lavender plastic at ≈ 0.27: `≈ 1.3` at the
  bulb, `≈ 0.5` at half radius.
* Additive flasher: `dst' = dst + L × (1 − m × (1 − dst))`. On a dark base a
  high *Modulate* throws most of the light away, so the lightmap flashers use
  0.3 (the Flupper flare flashers in this table use 0.2).

## Branches

| Branch | Contains |
|--------|----------|
| `ccr-df9f12d7-d9dioy` | these notes, the scripts, the `GI glow` layer in the SVG; table untouched |
| `gi-1-transmission` | 1 |
| `gi-2-transmission-halo` | 1 + 2 |
| `gi-3-plastic-halos` | 1 + 2 + 3 |
| `gi-4-lightmaps` | 1 + 2 + 4 |

Branches 3 and 4 both start from 2, so `git diff gi-2-transmission-halo
gi-3-plastic-halos` is exactly strategy 3, and likewise for 4. Check one out,
`npm run assemble-vpx`, play. Mixing is just running the other script on top.

## Workflow for the lightmaps (strategy 4)

1. `npm run gi-lightmaps-init` once (already done on these branches). It adds
   `gi_glow_gradient` and the hidden `GI glow` layer with a `glow giNNN`
   circle per bulb, inserted as text so nothing else in the SVG moves.
2. In Inkscape, show `GI glow`, drag or scale the blobs, change a blob's
   gradient, add a second blob for a bulb (any element whose label contains
   the bulb name counts). Hide the layer again; the exports use
   show-only anyway.
3. `npm run gi-lightmaps-render` (Inkscape, same binary as
   `svg-to-playfield.py`) or `... -- --renderer cairosvg`. Each bulb's blob is
   copied into an SVG `<mask>` on the plastics layer in a temp copy and
   exported page-size at 96 dpi, the same 1804×4096 as `plastics.webp`.
4. `npm run gi-lighting lightmaps` crops, writes the webp, the `images.json`
   entry, and the flasher. Bulbs whose glow touches no plastic are skipped.
5. Too bright or too dim overall: `npm run gi-lighting lightmaps-adjust --
   --alpha 60` rewrites the existing flashers (alpha is the editor's Opacity,
   100 = 1.0, linear). No re-render needed. The shape of each glow lives in
   the SVG blobs, so a tighter or softer hotspot is steps 2 to 4 again.

Table coordinates to SVG millimetres: `x_mm = x × 477.30832 / 952`,
`y_mm = y × 1083.7333 / 2162` (about 0.5 mm per unit).

## Things to watch

* Transmission is screen space: anything translucent drawn over a GI zone
  (ramps, bumper caps, the playfield itself through its 0.9999 material)
  receives it too. *Disable lighting from below = 1* on an object opts it out.
* The GI fader is `linear` at 0.2/ms up, 0.4/ms down, i.e. instant; GLF's own
  300 ms colour fade is what you see. `incandescent` gives the reddish
  filament tail if you want the relay feel.
* The `l100a` / `l100b` VLM naming convention and the `gi` prefix still hold:
  the plastic halos are `giNNNp1`, so `vlm_import.py` will classify them as GI.
  Delete them (`gi_lighting.py remove-plastic-halos`) before a VLM bake,
  since VLM bakes that light itself.
* `cached-functions.vbs`: GLF discovers the `_giNNN_` lightmap flashers at
  start in non-production mode and writes the cache; regenerate it before a
  production concat.
