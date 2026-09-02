"""
Run on the output of `vpxtool extract MyTable.vpx`, before `vpxtool assemble`.

Field names and semantics confirmed against vpin's src/vpx/gameitem/light.rs
(BiffRead/BiffWrite impls + the module doc comment on render modes/fading).

Key facts that correct the earlier VPX-editor-click version of this guide:
  - There is no separate "Render Mode" field. Halo vs. Classic is derived from
    two booleans: is_bulb_light=True + visible=True -> Halo.
                  is_bulb_light=False + visible=True -> Classic.
  - Fader is an enum: None=0, Linear=1, Incandescent=2 (see Fader::from(u32)
    in light.rs if you want to double check the ordinal -- not fully shown
    in what I read, cross-check before trusting the literal `2` below).
  - fade_speed_up / fade_speed_down are separate float fields (FASP/FASD),
    not a single "120ms" value -- set both if you want a symmetric fade.
  - GI vs insert classification lives ONLY in the object's `name` (the `gi`
    prefix check happens on import into Blender, not stored on the light
    itself) -- so classification here also has to be done by name.
"""
import json
import glob
import os
import sys

FADER_INCANDESCENT = 2          # cross-check against Fader enum ordinals before trusting
GI_FADE_MS = 120.0
GI_COLOR = "#ffb478"            # warm peach/orange, hex string -- matches vpin's color format
GI_HALO_HEIGHT = 28.0            # VP units above playfield; matches ball-shadow guidance
INSERT_FADE_MS = 120.0


def is_gi(light):
    return light["name"].casefold().startswith("gi")


def normalize_gi(light):
    light["fader"] = "incandescent"          # vpin's Fader serializes as lowercase string (see test_fader_json)
    light["fade_speed_up"] = GI_FADE_MS
    light["fade_speed_down"] = GI_FADE_MS
    light["is_bulb_light"] = True            # Halo
    light["visible"] = True
    light["show_bulb_mesh"] = True
    light["mesh_radius"] = 20.0
    light["show_reflection_on_ball"] = True
    light["shadows"] = "raytraced_ball_shadows"
    light["bulb_halo_height"] = GI_HALO_HEIGHT
    light["color"] = GI_COLOR


def normalize_insert(light):
    light["fader"] = "incandescent"
    light["fade_speed_up"] = INSERT_FADE_MS
    light["fade_speed_down"] = INSERT_FADE_MS
    light["is_bulb_light"] = False           # Classic
    light["visible"] = True
    light["show_bulb_mesh"] = False
    light["image"] = ""                      # clear any decal
    light["bulb_halo_height"] = 0.0
    light["color"] = GI_COLOR


def process_file(path, dry_run):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if "Light" not in data:
        return None
    light = data["Light"]
    role = "gi" if is_gi(light) else "insert"
    before = json.dumps(light, sort_keys=True)
    (normalize_gi if role == "gi" else normalize_insert)(light)
    after = json.dumps(light, sort_keys=True)
    if before != after and not dry_run:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
    return role if before != after else None


def main():
    if len(sys.argv) < 2:
        print("Usage: vlm_vpx_prep.py <extracted_table_dir> [--dry-run]")
        sys.exit(1)
    root = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    pattern = os.path.join(root, "gameitems", "Light.*.json")
    counts = {"gi": 0, "insert": 0}
    for path in glob.glob(pattern):
        role = process_file(path, dry_run)
        if role:
            counts[role] += 1
    print(f"{'[dry run] ' if dry_run else ''}Normalized {counts['gi']} GI lights, {counts['insert']} insert lights")


if __name__ == "__main__":
    main()
