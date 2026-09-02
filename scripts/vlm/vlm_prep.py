"""
VLM prep helpers — run inside Blender's Python console/Text Editor.
Targets the confirmed API: vlmSettings on Scene/Collection/Object,
'VLM.Bake' / 'VLM.Lights' / 'VLM.Result' as real collection names.
"""
import bpy


def get_collection(parent_col, name, create=False):
    """See vlm_rig.py for why this doesn't import from vlm_collections directly."""
    col = bpy.data.collections.get(name)
    if col is None and create:
        col = bpy.data.collections.new(name)
        parent_col.children.link(col)
    return col


def lock_import_flags(objects, mesh=False, transform=False):
    """Call after hand-adjusting sockets/lights so the next Update doesn't revert you.
    Pass the objects you just touched."""
    for obj in objects:
        obj.vlmSettings.import_mesh = mesh
        obj.vlmSettings.import_transform = transform
    print(f"Locked import flags on {len(objects)} objects (mesh={mesh}, transform={transform})")


def preflight(context):
    """Mirrors the checklist in the guide, using real property paths."""
    problems = []
    scene = context.scene

    bake_col = get_collection(scene.collection, 'VLM.Bake', create=False)
    lights_col = get_collection(scene.collection, 'VLM.Lights', create=False)
    if not bake_col:
        problems.append("No 'VLM.Bake' collection found.")
    if not lights_col:
        problems.append("No 'VLM.Lights' collection found.")
    if not scene.camera:
        problems.append("No active scene camera set.")

    if lights_col:
        # every light/emissive object should sit in some sub-collection of VLM.Lights
        light_objs = {o.name for o in lights_col.all_objects}
        for obj in scene.collection.all_objects:
            if obj.type == 'LIGHT' and obj.name not in light_objs:
                problems.append(f"Light '{obj.name}' is outside VLM.Lights.")

        world_present = any(
            c.vlmSettings.light_mode == 'solid' and c.vlmSettings.world
            for c in lights_col.children
        )
        if not world_present:
            problems.append("No child of VLM.Lights is in Solid mode with a World assigned — no base bake will be produced.")

    if bake_col:
        for obj in bake_col.all_objects:
            if not obj.vlmSettings.indirect_only and not obj.vlmSettings.use_bake and obj.vlmSettings.render_group < 0:
                problems.append(f"'{obj.name}' has no render group — run Groups (compute_render_groups) first.")

    # .bmp leftovers (Blender import chokes on these upstream; harmless check here)
    for img in bpy.data.images:
        if img.filepath.lower().endswith('.bmp'):
            problems.append(f"Image '{img.name}' still references a .bmp source.")

    if problems:
        print("VLM preflight FAILED:")
        for p in problems:
            print(f"  - {p}")
    else:
        print("VLM preflight OK.")
    return problems


def run_batch_if_clean(context):
    problems = preflight(context)
    if problems:
        print("Aborting — fix preflight issues first.")
        return {'CANCELLED'}
    return bpy.ops.vlm.batch_bake_operator()


# Example usage from the Blender Python console:
#   import vlm_prep
#   vlm_prep.preflight(bpy.context)
#   vlm_prep.lock_import_flags(bpy.context.selected_objects, mesh=False, transform=False)
#   vlm_prep.run_batch_if_clean(bpy.context)
