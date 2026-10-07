#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "pillow",
# ]
# ///
"""
GI lighting experiments for the vpxtool-extracted table in ../starshollow.

Each subcommand rewrites the extracted JSON in place so that a plain
`vpxtool assemble` (npm run assemble-vpx) picks the change up. Every
subcommand is idempotent: running it twice gives the same result.

    gi_lighting.py status          # print the current GI light / material values
    gi_lighting.py transmission    # strategy 1: bulb transmission onto the plastics
    gi_lighting.py halo            # strategy 2: retune the playfield halos
    gi_lighting.py plastic-halos   # strategy 3: halo lights sitting on the plastics
    gi_lighting.py lightmaps       # strategy 4: additive lightmap flashers from
                                   #   the PNGs that gi_lightmaps_render.py wrote
    gi_lighting.py lightmaps-adjust --alpha 60   # dim/brighten existing lightmaps
    gi_lighting.py add-bulb gi025 30 890 --like gi024   # new GI bulb, same treatment
    gi_lighting.py remove-plastic-halos / remove-lightmaps

See gi-lighting-notes.md for what each strategy does inside the renderer and
how the numbers below were chosen.
"""

import argparse
import copy
import glob
import json
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_TABLE = os.path.normpath(os.path.join(HERE, "..", "starshollow"))

TABLE_W = 952.0  # table right  (gamedata.json)
TABLE_H = 2162.0  # table bottom (gamedata.json)

# ---- tuning -----------------------------------------------------------------
# The bulb halo blends as  dst' = dst*(1 + m*L) + L*(1 - m)   (m = modulate vs
# add, L = intensity * falloff).  The transmitted light that reaches a
# translucent material is  sqrt(albedo) * blur(intensity * transmission).
# Keep intensity * transmission around TRANSMIT_PRODUCT so that strategy 1 looks
# the same whether or not strategy 2 has raised the intensity.
TRANSMIT_PRODUCT = 1.0
PLASTIC_OPACITY = 0.9999  # < 1.0 is what unlocks the transmission term

HALO = dict(intensity=3.0, falloff_radius=150.0, falloff_power=2.0,
            bulb_modulate_vs_add=0.9, color2="#ff8c3a")

PLASTIC_HALO = dict(intensity=2.5, falloff_radius=90.0, falloff_power=2.0,
                    bulb_modulate_vs_add=0.9)
PLASTIC_HALO_REACH = 100.0  # a bulb this close to a plastic gets a halo on it

LIGHTMAP_FLASHER = dict(alpha=100, modulate_vs_add=0.3)
LIGHTMAP_MIN_PIXELS = 2000  # skip bulbs whose glow touches almost no plastic
LIGHTMAP_MARGIN_PX = 6

GI_NAME = re.compile(r"^gi\d+$")
GROUP = "GI_Layer"


# ---- json helpers -----------------------------------------------------------
def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save(path, data):
    # vpxtool writes 2-space pretty JSON without a trailing newline; match it so
    # a round trip through this script and vpxtool stays diff-clean.
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(data, indent=2, ensure_ascii=False))


class Table:
    def __init__(self, root):
        self.root = root
        self.items_dir = os.path.join(root, "gameitems")
        self.index_path = os.path.join(root, "gameitems.json")
        self.index = load(self.index_path)

    def item_path(self, kind, name):
        return os.path.join(self.items_dir, f"{kind}.{name}.json")

    def items(self, kind):
        for path in sorted(glob.glob(os.path.join(self.items_dir, f"{kind}.*.json"))):
            yield path, load(path)[kind]

    def write_item(self, kind, data):
        path = self.item_path(kind, data["name"])
        save(path, {kind: data})
        file_name = os.path.basename(path)
        if not any(e["file_name"] == file_name for e in self.index):
            self.index.append({"file_name": file_name, "is_locked": False,
                               "editor_layer_name": "", "editor_layer_visibility": True})
        return path

    def remove_item(self, kind, name):
        path = self.item_path(kind, name)
        if os.path.exists(path):
            os.remove(path)
        file_name = os.path.basename(path)
        self.index = [e for e in self.index if e["file_name"] != file_name]

    def save_index(self):
        save(self.index_path, self.index)

    # collections.json: {"name", "items": [...], ...}
    def collection_add(self, collection, names):
        path = os.path.join(self.root, "collections.json")
        cols = load(path)
        for c in cols:
            if c["name"] == collection:
                for n in names:
                    if n not in c["items"]:
                        c["items"].append(n)
        save(path, cols)

    def collection_remove(self, names):
        path = os.path.join(self.root, "collections.json")
        cols = load(path)
        for c in cols:
            c["items"] = [n for n in c["items"] if n not in names]
        save(path, cols)

    def gi_lights(self):
        for path, light in self.items("Light"):
            if GI_NAME.match(light["name"]):
                yield path, light

    def plastics_walls(self):
        """Walls textured with the plastics sheet, i.e. the actual plastics."""
        for path, wall in self.items("Wall"):
            if wall.get("image") == "plastics" and wall.get("is_top_bottom_visible", True):
                yield path, wall

    def materials(self):
        path = os.path.join(self.root, "materials.json")
        return path, load(path)


# ---- geometry (VPX drag points, Catmull-Rom for smooth points) ---------------
def subdivide(points, steps=8):
    """Approximate a VPX drag-point outline as a plain polygon."""
    n = len(points)
    if n < 3:
        return [(p["x"], p["y"]) for p in points]
    out = []
    for i in range(n):
        p0, p1, p2, p3 = (points[(i + k - 1) % n] for k in range(4))
        if not (p1.get("smooth") or p2.get("smooth")):
            out.append((p1["x"], p1["y"]))
            continue
        for s in range(steps):
            t = s / steps
            t2, t3 = t * t, t * t * t
            x = 0.5 * ((2 * p1["x"]) + (-p0["x"] + p2["x"]) * t
                       + (2 * p0["x"] - 5 * p1["x"] + 4 * p2["x"] - p3["x"]) * t2
                       + (-p0["x"] + 3 * p1["x"] - 3 * p2["x"] + p3["x"]) * t3)
            y = 0.5 * ((2 * p1["y"]) + (-p0["y"] + p2["y"]) * t
                       + (2 * p0["y"] - 5 * p1["y"] + 4 * p2["y"] - p3["y"]) * t2
                       + (-p0["y"] + 3 * p1["y"] - 3 * p2["y"] + p3["y"]) * t3)
            out.append((x, y))
    return out


def point_in_polygon(x, y, poly):
    inside = False
    n = len(poly)
    for i in range(n):
        x1, y1 = poly[i]
        x2, y2 = poly[(i + 1) % n]
        if (y1 > y) != (y2 > y):
            xi = (x2 - x1) * (y - y1) / (y2 - y1) + x1
            if x < xi:
                inside = not inside
    return inside


def distance_to_polygon(x, y, poly):
    best = math.inf
    n = len(poly)
    for i in range(n):
        x1, y1 = poly[i]
        x2, y2 = poly[(i + 1) % n]
        dx, dy = x2 - x1, y2 - y1
        if dx == 0 and dy == 0:
            d = math.hypot(x - x1, y - y1)
        else:
            t = max(0.0, min(1.0, ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)))
            d = math.hypot(x - (x1 + t * dx), y - (y1 + t * dy))
        best = min(best, d)
    return best


def bbox_overlaps(poly, x0, y0, x1, y1):
    xs = [p[0] for p in poly]
    ys = [p[1] for p in poly]
    return not (max(xs) < x0 or min(xs) > x1 or max(ys) < y0 or min(ys) > y1)


# ---- strategies -------------------------------------------------------------
def cmd_status(t):
    print(f"{'light':8} {'int':>5} {'fall':>6} {'pow':>4} {'mod':>5} {'trans':>6} {'halo':>5} surface")
    for _, l in t.gi_lights():
        print(f"{l['name']:8} {l['intensity']:5.2f} {l['falloff_radius']:6.1f} {l['falloff_power']:4.1f} "
              f"{l['bulb_modulate_vs_add']:5.2f} {l['transmission_scale']:6.3f} {l['bulb_halo_height']:5.1f} "
              f"{l['surface'] or '-'}")
    _, mats = t.materials()
    used = {w["top_material"] for _, w in t.plastics_walls()}
    for m in mats:
        if m["name"] in used:
            print(f"material {m['name']!r}: opacity {m['opacity']} active={m['opacity_active']}")
    lm = [os.path.basename(p) for p, _ in t.items("Flasher") if _["name"].startswith("LM_")]
    print(f"lightmap flashers: {len(lm)}")


def cmd_transmission(t, product=TRANSMIT_PRODUCT):
    """Strategy 1. Bulb lights with transmission > 0 are drawn into a blurred
    screen-space buffer which the material shader adds to every translucent
    surface (BasicShader: `if (color.a < 1.0) color += sqrt(diffuse) * buffer`).
    Two things are needed: transmission on the GI bulbs, and a plastics material
    whose opacity is active and below 1.0 so the branch is taken at all."""
    for path, l in t.gi_lights():
        if l["intensity"] > 0:
            l["transmission_scale"] = round(product / l["intensity"], 4)
        save(path, {"Light": l})
    mpath, mats = t.materials()
    used = {w["top_material"] for _, w in t.plastics_walls()}
    for m in mats:
        if m["name"] in used:
            m["opacity_active"] = True
            if m["opacity"] >= 1.0:
                m["opacity"] = PLASTIC_OPACITY
            print(f"material {m['name']!r}: opacity {m['opacity']} (active)")
    save(mpath, mats)
    print(f"GI bulbs: transmission_scale = {product} / intensity")


def cmd_halo(t, **overrides):
    """Strategy 2. Retune the halo polygon drawn on the playfield. Intensity up,
    tighter falloff with power 2 for visible hotspots, and a little additive
    share (modulate 0.9) so the halo still reads on a dark playfield."""
    params = dict(HALO, **overrides)
    for path, l in t.gi_lights():
        old_int = l["intensity"]
        l.update(params)
        # keep the transmitted light where strategy 1 put it
        if l["transmission_scale"] > 0 and old_int > 0:
            l["transmission_scale"] = round(l["transmission_scale"] * old_int / l["intensity"], 4)
        save(path, {"Light": l})
    print(f"GI bulbs: {params}")


def cmd_add_bulb(t, name, x, y, like):
    """Add a GI bulb at (x, y) cloned from an existing one: same settings, tags,
    collections and outline (translated), so every strategy treats it alike."""
    if not GI_NAME.match(name):
        sys.exit("GI bulbs must be named giNNN")
    if os.path.exists(t.item_path("Light", name)):
        sys.exit(f"{name} already exists")
    src = load(t.item_path("Light", like))["Light"]
    l = copy.deepcopy(src)
    l["name"] = name
    dx, dy = x - src["center"]["x"], y - src["center"]["y"]
    l["center"] = {"x": x, "y": y}
    for p in l["drag_points"]:
        p["x"] += dx
        p["y"] += dy
    t.write_item("Light", l)
    cpath = os.path.join(t.root, "collections.json")
    for c in load(cpath):
        if like in c["items"]:
            t.collection_add(c["name"], [name])
    t.save_index()
    print(f"{name} at {x:.0f},{y:.0f} cloned from {like} (tags {l['blink_pattern']})")


def plastic_halo_name(gi, k):
    return f"{gi}p{k}"


def cmd_plastic_halos(t, **overrides):
    """Strategy 3. For every GI bulb close to a plastic, add a bulb light whose
    Surface is that plastic wall and whose outline is the wall outline. VPX
    draws the halo at surface height + halo height, so it lands on top of the
    plastic and modulates its texture: dst' = dst*(1 + 0.9*L) + 0.1*L."""
    params = dict(PLASTIC_HALO, **overrides)
    walls = [(w, subdivide(w["drag_points"])) for _, w in t.plastics_walls()]
    created = []
    for _, gi in t.gi_lights():
        cx, cy = gi["center"]["x"], gi["center"]["y"]
        k = 0
        for wall, poly in walls:
            if not (point_in_polygon(cx, cy, poly) or distance_to_polygon(cx, cy, poly) <= PLASTIC_HALO_REACH):
                continue
            k += 1
            l = copy.deepcopy(gi)
            l["name"] = plastic_halo_name(gi["name"], k)
            l["surface"] = wall["name"]
            l["height"] = 0.0
            l["bulb_halo_height"] = 1.0
            l["image"] = ""
            l["transmission_scale"] = 0.0
            l["show_bulb_mesh"] = False
            l["has_static_bulb_mesh"] = False
            l["show_reflection_on_ball"] = False
            l["shadows"] = "none"
            l["part_group_name"] = GROUP
            l["drag_points"] = copy.deepcopy(wall["drag_points"])
            l.update(params)
            t.write_item("Light", l)
            created.append(l["name"])
            print(f"{l['name']}: on {wall['name']} (bulb {gi['name']} at {cx:.0f},{cy:.0f})")
    t.collection_add("GI", created)
    t.collection_add("glf_lights", created)
    t.save_index()
    print(f"{len(created)} plastic halo lights")


def cmd_remove_plastic_halos(t):
    names = [l["name"] for _, l in t.items("Light") if re.match(r"^gi\d+p\d+$", l["name"])]
    for n in names:
        t.remove_item("Light", n)
    t.collection_remove(names)
    t.save_index()
    print(f"removed {len(names)} plastic halo lights")


def lightmap_image_name(gi):
    return f"LM_{gi}_plastics"


def cmd_lightmaps(t, render_dir, **overrides):
    """Strategy 4. Hand-made lightmaps: one additive flasher per GI bulb, carrying
    the plastics art masked to that bulb's glow (rendered from playfield.svg by
    gi_lightmaps_render.py). The flasher sits just above the plastic, its Light
    Map points at the bulb (ball shadows, and intensity if State is ever used),
    and its name contains _giNNN_ so GLF copies the bulb's colour to it every
    time the bulb fades (GLF fades by Color with State fixed at 1)."""
    from PIL import Image

    params = dict(LIGHTMAP_FLASHER, **overrides)
    pngs = sorted(glob.glob(os.path.join(render_dir, "LM_gi*.png")))
    if not pngs:
        sys.exit(f"no LM_gi*.png in {render_dir}; run gi_lightmaps_render.py first")
    walls = [(w, subdivide(w["drag_points"])) for _, w in t.plastics_walls()]
    images_path = os.path.join(t.root, "images.json")
    images = load(images_path)
    template = None
    for _, fl in t.items("Flasher"):
        template = fl
        break
    made = []
    for png in pngs:
        gi = re.search(r"(gi\d+)", os.path.basename(png)).group(1)
        name = lightmap_image_name(gi)
        im = Image.open(png).convert("RGBA")
        W, H = im.size
        alpha = im.getchannel("A")
        bbox = alpha.getbbox()
        count = sum(alpha.histogram()[1:]) if bbox else 0
        if not bbox or count < LIGHTMAP_MIN_PIXELS:
            print(f"{gi}: glow touches no plastic ({count} px), skipped")
            cmd_remove_lightmaps(t, only=[gi], quiet=True)
            continue
        x0 = max(0, bbox[0] - LIGHTMAP_MARGIN_PX)
        y0 = max(0, bbox[1] - LIGHTMAP_MARGIN_PX)
        x1 = min(W, bbox[2] + LIGHTMAP_MARGIN_PX)
        y1 = min(H, bbox[3] + LIGHTMAP_MARGIN_PX)
        crop = im.crop((x0, y0, x1, y1))
        out = os.path.join(t.root, "images", f"{name}.webp")
        crop.save(out, lossless=True)
        if not any(i["name"] == name for i in images):
            images.append({"name": name, "path": f"{name}.webp",
                           "alpha_test_value": 1.0, "is_opaque": False, "is_signed": False})
        # pixel -> table units, the same mapping the plastics sheet uses on the walls
        sx, sy = TABLE_W / W, TABLE_H / H
        tx0, ty0, tx1, ty1 = x0 * sx, y0 * sy, x1 * sx, y1 * sy
        tops = [w["height_top"] for w, poly in walls if bbox_overlaps(poly, tx0, ty0, tx1, ty1)]
        height = (max(tops) if tops else 58.0) + 0.5
        fl = copy.deepcopy(template)
        fl.update({
            "name": name, "height": height,
            "pos_x": (tx0 + tx1) / 2, "pos_y": (ty0 + ty1) / 2,
            "rot_x": 0.0, "rot_y": 0.0, "rot_z": 0.0,
            "color": "#ffffff", "is_timer_enabled": False, "timer_interval": 100,
            "image_a": name, "image_b": "",
            "is_visible": True, "add_blend": "add", "is_dmd": False,
            "display_texture": True, "depth_bias": 0.0,
            "image_alignment": "wrap", "filter": "none", "filter_amount": 100,
            "light_map": gi, "part_group_name": GROUP,
        })
        fl.update(params)
        fl["drag_points"] = []
        for (x, y) in ((tx0, ty0), (tx0, ty1), (tx1, ty1), (tx1, ty0)):
            fl["drag_points"].append({
                "x": round(x, 3), "y": round(y, 3), "z": 0.0, "smooth": False,
                "is_slingshot": False, "has_auto_texture": True, "tex_coord": 0.0,
                "is_locked": False, "editor_layer": 0, "editor_layer_name": "",
                "editor_layer_visibility": True})
        t.write_item("Flasher", fl)
        made.append(name)
        print(f"{name}: {crop.size[0]}x{crop.size[1]} px at z={height}, table box "
              f"{tx0:.0f},{ty0:.0f}-{tx1:.0f},{ty1:.0f}")
    save(images_path, images)
    t.save_index()
    print(f"{len(made)} lightmap flashers")


def cmd_lightmaps_adjust(t, **params):
    """Change alpha / modulate on the existing lightmap flashers without
    re-rendering. alpha is the flasher Opacity (100 = 1.0) and scales the added
    light linearly; modulate_vs_add shifts it from plain additive (0) towards
    only brightening what is already lit (1)."""
    n = 0
    for _, fl in list(t.items("Flasher")):
        if re.match(r"^LM_gi\d+_plastics$", fl["name"]):
            fl.update({k: v for k, v in params.items() if v is not None})
            t.write_item("Flasher", fl)
            n += 1
    print(f"{n} lightmap flashers: " + ", ".join(f"{k}={v}" for k, v in params.items() if v is not None))


def cmd_remove_lightmaps(t, only=None, quiet=False):
    images_path = os.path.join(t.root, "images.json")
    images = load(images_path)
    removed = []
    for _, fl in list(t.items("Flasher")):
        m = re.match(r"^LM_(gi\d+)_plastics$", fl["name"])
        if not m or (only and m.group(1) not in only):
            continue
        t.remove_item("Flasher", fl["name"])
        images = [i for i in images if i["name"] != fl["name"]]
        img = os.path.join(t.root, "images", f"{fl['name']}.webp")
        if os.path.exists(img):
            os.remove(img)
        removed.append(fl["name"])
    save(images_path, images)
    t.save_index()
    if not quiet:
        print(f"removed {len(removed)} lightmap flashers")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--table", default=DEFAULT_TABLE, help="vpxtool extract directory")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status")
    p = sub.add_parser("transmission")
    p.add_argument("--product", type=float, default=TRANSMIT_PRODUCT,
                   help="intensity * transmission_scale to aim for")
    p = sub.add_parser("halo")
    for k, v in HALO.items():
        p.add_argument(f"--{k}", type=type(v), default=v)
    p = sub.add_parser("add-bulb")
    p.add_argument("name")
    p.add_argument("x", type=float)
    p.add_argument("y", type=float)
    p.add_argument("--like", required=True, help="existing giNNN light to clone")
    p = sub.add_parser("plastic-halos")
    for k, v in PLASTIC_HALO.items():
        p.add_argument(f"--{k}", type=type(v), default=v)
    sub.add_parser("remove-plastic-halos")
    p = sub.add_parser("lightmaps")
    p.add_argument("--render-dir", default=os.path.join(HERE, "lightmaps"))
    for k, v in LIGHTMAP_FLASHER.items():
        p.add_argument(f"--{k}", type=type(v), default=v)
    p = sub.add_parser("lightmaps-adjust")
    p.add_argument("--alpha", type=int)
    p.add_argument("--modulate_vs_add", type=float)
    sub.add_parser("remove-lightmaps")
    args = vars(ap.parse_args())

    t = Table(args.pop("table"))
    cmd = args.pop("cmd")
    if cmd == "status":
        cmd_status(t)
    elif cmd == "transmission":
        cmd_transmission(t, **args)
    elif cmd == "halo":
        cmd_halo(t, **args)
    elif cmd == "add-bulb":
        cmd_add_bulb(t, **args)
    elif cmd == "plastic-halos":
        cmd_plastic_halos(t, **args)
    elif cmd == "remove-plastic-halos":
        cmd_remove_plastic_halos(t)
    elif cmd == "lightmaps":
        cmd_lightmaps(t, **args)
    elif cmd == "lightmaps-adjust":
        cmd_lightmaps_adjust(t, **args)
    elif cmd == "remove-lightmaps":
        cmd_remove_lightmaps(t)


if __name__ == "__main__":
    main()
