"""
Run on a `vpxtool extract` of the source table, then `vpxtool assemble` and
bring into Blender via Update.

Every field change below is confirmed against the actual Space Station (1987
VPW) extraction -- direct field comparison, not inference from a Blender
reimport. See conversation for the full side-by-side table.

STRUCTURAL fixes (applied unconditionally -- confirmed, don't interact with
anything already done in Blender tonight):
  - GI:      fader -> 'none', show_bulb_mesh -> False, visible -> False
  - Flashers (FL1-4 + bumper lights): fader -> 'none', visible -> False
  - Inserts: fader -> 'linear'  (only field that was wrong; everything else
             already matched Space Station's convention)

INTENSITY changes are OPT-IN, not automatic -- see APPLY_INTENSITY_CHANGES
below. Reasoning:
  - GI and inserts: raw `intensity` was never touched by anything tonight,
    so a change here is a single, clean correction. Space Station's GI runs
    at intensity=6.0; yours is 2.0 (3x lower). Worth trying.
  - Flashers (FL1-4, bumper lights): a Blender-side /7.5 correction was
    ALREADY applied tonight to compensate for the insert->bulb
    reclassification jump. Also rewriting raw intensity here would be a
    second correction on the same problem with no clean way to know if the
    two compound sensibly. Left off by default -- turn on deliberately, and
    if you do, consider whether the Blender-side /7.5 is still appropriate
    afterward.
  - bumpersmalllight specifically sits at intensity=50.0 in your table --
    5-8x higher than anything in Space Station's entire light system (max
    was 10.0 for feature lights). Flagged, not auto-changed.
"""
import json
import glob
import os
import sys

GI_NAMES_ARE_PREFIX = "gi"  # matches vlm_import.py's is_gi check: name.casefold().startswith("gi")

FLASHER_LIGHT_NAMES = {
    "fl1", "fl2", "fl3", "fl4",
    "bumperbiglight1", "bumperbiglight3", "bumperbiglight5",
    "bumpersmalllight1", "bumpersmalllight3", "bumpersmalllight5",
}

# From gamedata.json's "image" field -- confirm this matches YOUR table before
# running, it's not a universal constant.
PLAYFIELD_IMAGE = "playfield"

# Opt-in intensity targets. None = leave alone. Fill in to apply.
APPLY_INTENSITY_CHANGES = False
GI_INTENSITY_TARGET = 6.0        # Space Station's confirmed GI value (yours: 2.0)
INSERT_INTENSITY_TARGET = None   # Space Station's was 3.0; yours (4-10) already
                                  # shows real per-fixture variation from the
                                  # original author -- less clear-cut that a
                                  # single target is an improvement. Left off.
FLASHER_INTENSITY_TARGET = None  # Deliberately left off -- see docstring.


def classify(light):
    """Mirrors vlm_import.py's actual is_insert formula in full (all four
    clauses), not just the is_bulb_light/halo_height shortcut -- that
    shortcut produced a false positive on 'SkillshotLight' (a wall-mounted
    indicator bulb, surface='Wall010'), which the real formula correctly
    excludes via the surface clause. A light excluded here isn't an error --
    it may fall through to vlm_import.py's flat-emitter-mesh branch, which
    isn't a Light object at all and isn't something this script should
    touch. Handle those individually in Blender (e.g. move to
    VPX.Import.Hidden) rather than adding a name-based patch here."""
    name = light.get("name", "")
    if name.casefold().startswith(GI_NAMES_ARE_PREFIX):
        return "gi"
    if name.casefold() in FLASHER_LIGHT_NAMES:
        return "flasher"

    is_gi = name.casefold().startswith(GI_NAMES_ARE_PREFIX)
    bulb = light.get("is_bulb_light", False)
    image = light.get("image", "")
    halo = light.get("bulb_halo_height", 0)
    surface = light.get("surface", "")
    is_insert = (
        not is_gi
        and (bulb or image == PLAYFIELD_IMAGE or image == "")
        and (not bulb or halo == 0)
        and (surface == "" or surface == "<None>")
    )
    return "insert" if is_insert else None


def apply_fix(light, role):
    changed = False

    if role == "gi":
        if light.get("fader") != "none":
            light["fader"] = "none"; changed = True
        if light.get("show_bulb_mesh") is not False:
            light["show_bulb_mesh"] = False; changed = True
        if light.get("visible") is not False:
            light["visible"] = False; changed = True
        if APPLY_INTENSITY_CHANGES and GI_INTENSITY_TARGET is not None:
            if light.get("intensity") != GI_INTENSITY_TARGET:
                light["intensity"] = GI_INTENSITY_TARGET; changed = True

    elif role == "flasher":
        if light.get("fader") != "none":
            light["fader"] = "none"; changed = True
        if light.get("visible") is not False:
            light["visible"] = False; changed = True
        if APPLY_INTENSITY_CHANGES and FLASHER_INTENSITY_TARGET is not None:
            if light.get("intensity") != FLASHER_INTENSITY_TARGET:
                light["intensity"] = FLASHER_INTENSITY_TARGET; changed = True

    elif role == "insert":
        if light.get("fader") != "linear":
            light["fader"] = "linear"; changed = True
        if APPLY_INTENSITY_CHANGES and INSERT_INTENSITY_TARGET is not None:
            if light.get("intensity") != INSERT_INTENSITY_TARGET:
                light["intensity"] = INSERT_INTENSITY_TARGET; changed = True

    return changed


def process_file(path, dry_run):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if "Light" not in data:
        return None
    light = data["Light"]
    role = classify(light)
    if role is None:
        return None
    before = json.dumps(light, sort_keys=True)
    changed = apply_fix(light, role)
    after = json.dumps(light, sort_keys=True)
    if changed and not dry_run:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
    return (light.get("name"), role) if changed else None


def main():
    if len(sys.argv) < 2:
        print("Usage: fix_gi_flasher_insert_properties.py <extracted_table_dir> [--dry-run]")
        sys.exit(1)
    root = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    pattern = os.path.join(root, "gameitems", "Light.*.json")
    counts = {"gi": [], "flasher": [], "insert": []}
    for path in glob.glob(pattern):
        result = process_file(path, dry_run)
        if result:
            name, role = result
            counts[role].append(name)

    label = "[dry run] " if dry_run else ""
    print(f"{label}GI fixed: {len(counts['gi'])} -> {sorted(counts['gi'])}")
    print(f"{label}Flasher fixed: {len(counts['flasher'])} -> {sorted(counts['flasher'])}")
    print(f"{label}Insert fixed: {len(counts['insert'])} -> {sorted(counts['insert'])}")
    if APPLY_INTENSITY_CHANGES:
        print("Intensity changes were APPLIED where targets are set above.")
    else:
        print("Intensity changes were NOT applied (APPLY_INTENSITY_CHANGES=False). "
              "Structural fields only.")


if __name__ == "__main__":
    main()
