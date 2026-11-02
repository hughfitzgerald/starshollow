"""
Run on a vpinball table pack folder (or `vpxtool convert MyTable.vpx MyTable`
first), then `vpxtool convert MyTable` back to a .vpx for VLM.

Field semantics confirmed against vpin's src/vpx/gameitem/light.rs
(BiffRead/BiffWrite impls + the module doc comment on render modes/fading);
names and enum ordinals are the pack's, confirmed against this table.

Key facts that correct the earlier VPX-editor-click version of this guide:
  - There is no separate "Render Mode" field. Halo vs. Classic is derived from
    two booleans: bulb_light=True + visible=True -> Halo.
                  bulb_light=False + visible=True -> Classic.
  - Fader is an enum: None=0, Linear=1, Incandescent=2 (the pack stores the
    ordinal; checked against this table's lights).
  - fade_speed_up / fade_speed_down are separate float fields (FASP/FASD),
    not a single "120ms" value -- set both if you want a symmetric fade.
  - GI vs insert classification lives ONLY in the object's name (the `gi`
    prefix check happens on import into Blender, not stored on the light
    itself) -- so classification here also has to be done by name, which in
    the pack is the part's file name.
"""
import json
import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from gi_lighting import colorref, load, save  # vpinball's JSON formatting

FADER_INCANDESCENT = 2
GI_FADE_MS = 120.0
GI_COLOR = colorref("#ffb478")  # warm peach/orange; the pack stores a BGR COLORREF
GI_HALO_HEIGHT = 28.0            # VP units above playfield; matches ball-shadow guidance
INSERT_FADE_MS = 120.0


def is_gi(light):
    return light["name"].casefold().startswith("gi")


def normalize_gi(light):
    light["fader"] = FADER_INCANDESCENT
    light["fade_speed_up"] = GI_FADE_MS
    light["fade_speed_down"] = GI_FADE_MS
    light["bulb_light"] = True               # Halo
    light["visible"] = True
    light["show_bulb_mesh"] = True
    light["mesh_radius"] = 20.0
    light["show_reflection_on_ball"] = True
    light["shadows"] = 1                     # raytraced ball shadows
    light["bulb_halo_height"] = GI_HALO_HEIGHT
    light["color"] = GI_COLOR


def normalize_insert(light):
    light["fader"] = FADER_INCANDESCENT
    light["fade_speed_up"] = INSERT_FADE_MS
    light["fade_speed_down"] = INSERT_FADE_MS
    light["bulb_light"] = False              # Classic
    light["visible"] = True
    light["show_bulb_mesh"] = False
    light["image"] = ""                      # clear any decal
    light["bulb_halo_height"] = 0.0
    light["color"] = GI_COLOR


def process_file(path, dry_run):
    light = load(path)
    if light.get("$type") != "light":
        return None
    light["name"] = os.path.splitext(os.path.basename(path))[0]
    role = "gi" if is_gi(light) else "insert"
    before = json.dumps(light, sort_keys=True)
    (normalize_gi if role == "gi" else normalize_insert)(light)
    after = json.dumps(light, sort_keys=True)
    if before != after and not dry_run:
        del light["name"]
        save(path, light)
    return role if before != after else None


def main():
    if len(sys.argv) < 2:
        print("Usage: vlm_vpx_prep.py <table_pack_dir> [--dry-run]")
        sys.exit(1)
    root = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    pattern = os.path.join(root, "parts", "*.json")
    counts = {"gi": 0, "insert": 0}
    for path in glob.glob(pattern):
        role = process_file(path, dry_run)
        if role:
            counts[role] += 1
    print(f"{'[dry run] ' if dry_run else ''}Normalized {counts['gi']} GI lights, {counts['insert']} insert lights")


if __name__ == "__main__":
    main()
