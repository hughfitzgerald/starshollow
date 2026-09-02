"""
VLM auto-rig — run after every Import/Update, not as a one-off.
Confirmed against vlm_import.py / __init__.py for this fork. Two things are
NOT verified because I haven't seen the relevant source files:
  - vlm_camera.py:  whether this fork exposes layback modes at all, or just
                     the 'inclination' arg seen on VLM_OT_fit_camera.
  - Confirmed this project's scale_length == 1.0 (1 Blender Unit = 1 meter).
    Insert light size is now derived from actual insert-cup geometry rather
    than a hardcoded literal -- see the note above INSERT_SIZE_FRACTION for
    what went wrong the first time and why. snap_sockets_to_surface's
    defaults were fixed for the same reason; still confirm they suit your
    table's actual part sizes before trusting them broadly.
"""
import bpy


def get_collection(parent_col, name, create=False):
    """Standalone replacement for vlm_collections.get_collection(). Not importable
    as a bare module from outside the add-on's package (it's a relative import
    inside vpx_lightmapper), so this just does the equivalent lookup directly --
    collection names are globally unique in a .blend, so parent_col is unused."""
    col = bpy.data.collections.get(name)
    if col is None and create:
        col = bpy.data.collections.new(name)
        parent_col.children.link(col)
    return col


# ---- One-time config: fill these in for your table -------------------------

# VPX material names -> Steel. MUST be lowercase (matched against casefolded names).
# Candidates below are from this table's materials.json -- review before using.
# Deliberately excluded: 'peg' (metal-typed but dark red), 'plastic cobalt blue'
# (metal-typed but a plastic), 'opacity80' (translucent), all 'zcol_*' (collision-
# only physics materials), all 'bumperscrew*' (colour-coded, not bare steel).
STEEL_VPX_MATERIALS = {
    "metal",
    "metal0.2",
    "metal0.8",
    "metalshiny",
    "bumpermetal",      # typed 'basic' but is metal -- type is not a reliable signal
}
# The library is NOT one file. Category files (Bumpers.blend, Guides.blend, Metal
# Posts.blend, etc.) each link their materials from one shared file via a relative
# path (confirmed: "../Shared/Materials.blend" inside Guides.blend and Metal
# Posts.blend). Point append_material() at that shared file directly.
ASSET_LIBRARY_PATH = "/Users/stephenjones/Documents/pinball-parts-main/Shared/Materials.blend"

# Confirmed material names inside Materials.blend (extracted from the datablock
# names directly). "Steel" does not exist -- the real name has a "Metal - " prefix
# and there are several real neighbors worth considering instead/as well:
#   Metal - Steel
#   Metal - Steel with AO dirt
#   Metal - Chromium
#   Metal - Aluminum / Metal - Aluminum Aniso
#   Metal - Aluminium Polished / Aniso Polished / with AO dirt
#   Metal - Copper
#   Metal - Zinc / Zinc Aniso with AO dirt
STEEL_MATERIAL_NAME = "Metal - Steel"

INSERT_SIZE_FRACTION = 0.5      # disk diameter as a fraction of the insert cup's own diameter
GI_TEMP_K = 2700

# INSERT_AREA_SIZE and INSERT_Z_DROP are intentionally NOT hardcoded here anymore.
# First attempt used literals (0.5, -0.06) lifted from the VPW guide -- with this
# project's scale_length=1.0 (1 Blender Unit = 1 meter), 0.5 became a half-METER
# disk (confirmed: 0.5 * 39.37 = 19.685", matching the reported 19.7" exactly).
# The Z drop was a second instance of the same bug AND redundant: vlm_import.py's
# update_location() already multiplies insert light Z by global_scale, so it was
# never mis-placed in the first place -- adding a fixed offset on top of an
# already-correct position just re-introduced the same class of error less
# visibly. Fix: derive size from the insert cup geometry the importer already
# built correctly (it came from real VPX coordinates x global_scale), don't
# touch Z at all.


def find_insert_cups(context):
    """Objects the importer created with vpx_subpart == 'InsertCup'."""
    return [
        obj for obj in context.scene.objects
        if obj.vlmSettings.vpx_subpart == 'InsertCup'
    ]


def derive_insert_area_size(context):
    """Measure a real insert cup's diameter in Blender units (correctly scaled
    by the importer already) instead of hardcoding a guess. Returns None if no
    insert cups exist yet -- caller should fall back to manual measurement."""
    cups = find_insert_cups(context)
    if not cups:
        print("No InsertCup objects found -- run Import first, or set INSERT_AREA_SIZE manually.")
        return None
    diameters = [max(obj.dimensions.x, obj.dimensions.y) for obj in cups]
    diameters.sort()
    median = diameters[len(diameters) // 2]
    size = median * INSERT_SIZE_FRACTION
    print(f"Derived insert light size {size:.6f} BU from {len(cups)} cups "
          f"(median diameter {median:.6f} BU) -- sanity check this against the viewport before trusting it broadly.")
    return size

# -----------------------------------------------------------------------------


def append_material(lib_path, mat_name):
    if mat_name in bpy.data.materials:
        return bpy.data.materials[mat_name]
    with bpy.data.libraries.load(lib_path, link=False) as (data_from, data_to):
        if mat_name in data_from.materials:
            data_to.materials = [mat_name]
        else:
            print(f"WARNING: '{mat_name}' not found in {lib_path}")
            return None
    return bpy.data.materials.get(mat_name)


def matches_vpx_material(blender_mat_name, target):
    """Blender materials are named VPX.Mat.<matname>[.<image>], and <matname>
    can itself contain dots (e.g. 'Metal0.2'). So never split on '.' -- match
    the full target as either the whole suffix or a dot-delimited prefix of it."""
    if not blender_mat_name.startswith("VPX.Mat."):
        return False
    suffix = blender_mat_name[len("VPX.Mat."):]
    return suffix == target or suffix.startswith(target + ".")


def validate_targets(targets, materials_json_path=None):
    """Warn about names that don't exist in the table. Without this, a typo or a
    guessed name is a silent no-op."""
    if not materials_json_path:
        return targets
    import json
    with open(materials_json_path, "r", encoding="utf-8") as f:
        known = {m["name"].casefold() for m in json.load(f)}
    unknown = {t for t in targets if t not in known}
    for t in sorted(unknown):
        print(f"WARNING: '{t}' is not a material in this table -- will match nothing")
    return targets


def swap_steel_materials(context, materials_json_path=None):
    steel = append_material(ASSET_LIBRARY_PATH, STEEL_MATERIAL_NAME)
    if not steel:
        return
    targets = validate_targets(STEEL_VPX_MATERIALS, materials_json_path)
    # Longest first, so 'metal0.2' wins over a hypothetical 'metal0'
    ordered = sorted(targets, key=len, reverse=True)
    count = 0
    for mat in list(bpy.data.materials):
        if not any(matches_vpx_material(mat.name, t) for t in ordered):
            continue
        for obj in bpy.data.objects:
            if obj.type != 'MESH':
                continue
            for i, slot_mat in enumerate(obj.data.materials):
                if slot_mat is mat:
                    obj.data.materials[i] = steel
                    count += 1
    print(f"Swapped {count} material slots to Steel")


def find_insert_cup_names(context):
    return {
        obj.vlmSettings.vpx_object
        for obj in context.scene.objects
        if obj.vlmSettings.vpx_subpart == 'InsertCup'
    }


def classify_light(obj, insert_names):
    vpx_name = obj.vlmSettings.vpx_object
    if vpx_name.casefold().startswith('gi'):
        return 'gi'
    if vpx_name in insert_names:
        return 'insert'
    return 'other'


def link_light_data(lights):
    """Mirrors Ctrl+L > Link Object Data: all lights in the list share one datablock."""
    if len(lights) < 2:
        return
    primary = lights[0].data
    for obj in lights[1:]:
        obj.data = primary


def add_blackbody(light_data, temp_k=GI_TEMP_K):
    light_data.use_nodes = True
    nt = light_data.node_tree
    if any(n.type == 'BLACKBODY' for n in nt.nodes):
        return
    output = next((n for n in nt.nodes if n.type == 'OUTPUT_LIGHT'), None)
    emission = next((n for n in nt.nodes if n.type == 'EMISSION'), None)
    if not emission or not output:
        print(f"WARNING: unexpected node setup on '{light_data.name}', skipping")
        return
    bb = nt.nodes.new('ShaderNodeBlackbody')
    bb.inputs[0].default_value = temp_k
    nt.links.new(bb.outputs[0], emission.inputs[0])
    light_data.color = (1.0, 1.0, 1.0)


def setup_insert_light(obj, area_size):
    obj.data.type = 'AREA'
    obj.data.shape = 'DISK'
    obj.data.size = area_size
    # Power left at Blender's default; 'Normalize' (on by default for area lights)
    # makes power roughly size-independent, but check brightness visually after
    # fixing size -- don't assume the old POWER=50 guess transfers cleanly either.
    add_blackbody(obj.data)
    # No Z adjustment: vlm_import.py already places insert lights correctly via
    # global_scale. See the note above INSERT_SIZE_FRACTION for why.


def rig_lights(context):
    lights_col = get_collection(context.scene.collection, 'VLM.Lights', create=False)
    if not lights_col:
        print("No VLM.Lights collection — run Import first.")
        return
    insert_names = find_insert_cup_names(context)
    gi_lights, insert_lights = [], []
    for obj in lights_col.all_objects:
        if obj.type != 'LIGHT':
            continue
        cls = classify_light(obj, insert_names)
        if cls == 'gi':
            gi_lights.append(obj)
        elif cls == 'insert':
            insert_lights.append(obj)
    link_light_data(gi_lights)
    if gi_lights:
        add_blackbody(gi_lights[0].data)
    if insert_lights:
        area_size = derive_insert_area_size(context)
        if area_size is None:
            print("Skipping insert light sizing -- could not derive a size. "
                  "Set one manually per-light or fix InsertCup detection first.")
        else:
            for obj in insert_lights:
                setup_insert_light(obj, area_size)
    print(f"Rigged {len(gi_lights)} GI lights, {len(insert_lights)} insert lights")


def set_translucency(context, material_names, value=0.4):
    """material_names: VPX material names (e.g. bumper cap materials)."""
    count = 0
    for mat in bpy.data.materials:
        vpx_name = mat.name[len("VPX.Mat."):].split(".")[0] if mat.name.startswith("VPX.Mat.") else None
        if vpx_name in material_names and mat.node_tree and "VPX.Mat" in mat.node_tree.nodes:
            mat.node_tree.nodes["VPX.Mat"].inputs[14].default_value = value
            count += 1
    print(f"Set translucency on {count} materials")


def snap_sockets_to_surface(context, objects, start_offset=0.01, max_dist=0.05):
    """Raycast straight down from each object's current position to the first
    hit below it and set Z there. Heuristic -- verify results visually,
    this does not know 'plastic' from 'bracket' from 'playfield'.

    Defaults are scaled for scale_length=1.0 (1 BU = 1 meter) and a small
    pinball-part scale (sockets/bulbs a few mm to ~1cm) -- same category of bug
    as the insert light size: the first version used 0.5 / 5.0, which in this
    scale is 50cm / 5 meters, absurd for parts this small. Confirm these still
    look right for your table's actual object sizes before trusting broadly."""
    depsgraph = context.evaluated_depsgraph_get()
    for obj in objects:
        origin = obj.matrix_world.translation.copy()
        origin.z += start_offset
        result, loc, normal, index, hit_obj, matrix = context.scene.ray_cast(
            depsgraph, origin, (0, 0, -1), distance=max_dist
        )
        if result and hit_obj != obj:
            obj.location.z += (loc.z - obj.matrix_world.translation.z)
        else:
            print(f"No surface found under '{obj.name}' within {max_dist} units — leave for manual placement")


# Run order after each Import/Update (placeholder args below -- "bumpercap" is
# NOT a real material name, just illustrating the call shape; substitute
# confirmed names from your own materials.json):
#   rig_lights(bpy.context)
#   swap_steel_materials(bpy.context, "MyTable/materials.json")
#   set_translucency(bpy.context, {"<your bumper cap material name>"}, 0.4)
#   snap_sockets_to_surface(bpy.context, [obj for obj in ... your socket objects ...])
#   bpy.ops.vlm.fitcamera()
