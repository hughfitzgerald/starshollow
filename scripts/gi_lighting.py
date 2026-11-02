#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "pillow",
# ]
# ///
"""
GI lighting experiments for the vpinball table pack in ../starshollow.

Each subcommand rewrites the pack's JSON in place; reload the table in
vpinball to pick the change up (and don't save over it from a session opened
before). Every subcommand is idempotent: running it twice gives the same result.

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
import struct
import sys
from decimal import Decimal

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_TABLE = os.path.normpath(os.path.join(HERE, "..", "starshollow"))

TABLE_W = 952.0  # table right  (table.json)
TABLE_H = 2162.0  # table bottom (table.json)

# ---- tuning -----------------------------------------------------------------
# The bulb halo blends as  dst' = dst*(1 + m*L) + L*(1 - m)   (m = modulate vs
# add, L = intensity * falloff).  The transmitted light that reaches a
# translucent material is  sqrt(albedo) * blur(intensity * transmission).
# Keep intensity * transmission around TRANSMIT_PRODUCT so that strategy 1 looks
# the same whether or not strategy 2 has raised the intensity.
TRANSMIT_PRODUCT = 1.0
PLASTIC_OPACITY = 0.9999  # < 1.0 is what unlocks the transmission term

HALO = dict(intensity=3.0, radius=150.0, falloff_power=2.0,
            modulate_vs_add=0.9, color2="#ff8c3a")

PLASTIC_HALO = dict(intensity=2.5, radius=90.0, falloff_power=2.0,
                    modulate_vs_add=0.9)
PLASTIC_HALO_REACH = 100.0  # a bulb this close to a plastic gets a halo on it

LIGHTMAP_FLASHER = dict(alpha=100, modulate_vs_add=0.3)
LIGHTMAP_MIN_PIXELS = 2000  # skip bulbs whose glow touches almost no plastic
LIGHTMAP_MARGIN_PX = 6

GI_NAME = re.compile(r"^gi\d+$")
GROUP = "GI_Layer"


# ---- json helpers -----------------------------------------------------------
class Number(float):
    """A float that remembers how vpinball wrote it. vpinball doesn't print the
    shortest round-trip form Python does (518.7351684570313, not ...312), so
    re-saving would otherwise churn digits on every untouched number."""

    def __new__(cls, text):
        number = super().__new__(cls, text)
        number.text = text
        return number


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f, parse_float=Number)


def vp_float(value):
    """A new float the way vpinball saves it: rounded to float32, shortest text
    that reads back, and a tie in the last digit rounded away from zero
    (Python rounds it to even)."""
    f = struct.unpack("f", struct.pack("f", value))[0]
    text = repr(f)
    if "e" in text or not text[-1].isdigit():
        return text
    shown = Decimal(text)
    unit = Decimal(1).scaleb(shown.as_tuple().exponent)
    if abs(Decimal(f)) - abs(shown) == unit / 2:
        bumped = str(shown + unit.copy_sign(shown))
        if float(bumped) == f:
            return bumped
    return text


def dump(data, indent=""):
    """vpinball's format: 2-space indent, non-ASCII kept, no trailing newline."""
    inner = indent + "  "
    if isinstance(data, dict):
        if not data:
            return "{}"
        items = (f"{inner}{json.dumps(k, ensure_ascii=False)}: {dump(v, inner)}" for k, v in data.items())
        return "{\n" + ",\n".join(items) + f"\n{indent}}}"
    if isinstance(data, list):
        if not data:
            return "[]"
        return "[\n" + ",\n".join(f"{inner}{dump(v, inner)}" for v in data) + f"\n{indent}]"
    if isinstance(data, Number):
        return data.text
    if isinstance(data, float):
        return vp_float(data)
    return json.dumps(data, ensure_ascii=False)


def save(path, data):
    # match vpinball's own output so a round trip through this script and a
    # vpinball save stays diff-clean
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(dump(data))


def colorref(hex_rgb):
    """vpinball stores colors as a Windows COLORREF (0x00BBGGRR)."""
    rgb = int(hex_rgb.lstrip("#"), 16)
    return ((rgb >> 16) & 0xff) | (rgb & 0xff00) | ((rgb & 0xff) << 16)


def dragpoint(x, y):
    return {"center": {"x": round(x, 3), "y": round(y, 3)}, "ui_locked": False, "ui_visible": True,
            "position_z": 0.0, "smooth": False, "slingshot": False, "auto_texture": True,
            "texture_coordinate": 0.0}


class Table:
    """The vpinball table pack folder. Parts, collections and materials are one
    JSON file each, named after the element; table.json lists them in order.
    Parts are handed out with their "name" filled in from the file name, and
    written back without it."""

    def __init__(self, root):
        self.root = root
        self.parts_dir = os.path.join(root, "parts")
        self.table_path = os.path.join(root, "table.json")
        self.table = load(self.table_path)

    def item_path(self, name):
        return os.path.join(self.parts_dir, f"{name}.json")

    def item(self, name):
        return dict(load(self.item_path(name)), name=name)

    def items(self, kind):
        for path in sorted(glob.glob(os.path.join(self.parts_dir, "*.json"))):
            data = load(path)
            if data.get("$type") == kind:
                yield path, dict(data, name=os.path.splitext(os.path.basename(path))[0])

    def write_item(self, kind, data):
        data = dict(data)
        name = data.pop("name")
        path = self.item_path(name)
        save(path, {"$type": kind, **{k: v for k, v in data.items() if k != "$type"}})
        if name not in self.table["parts"]:
            self.table["parts"].append(name)
        return path

    def remove_item(self, name):
        path = self.item_path(name)
        if os.path.exists(path):
            os.remove(path)
        self.table["parts"] = [n for n in self.table["parts"] if n != name]

    def save_table(self):
        save(self.table_path, self.table)

    # collections/<name>.json: {"$type": "collection", "parts": [...], ...}
    def collections(self):
        for path in sorted(glob.glob(os.path.join(self.root, "collections", "*.json"))):
            yield path, load(path)

    def collection_add(self, collection, names):
        path = os.path.join(self.root, "collections", f"{collection}.json")
        col = load(path)
        parts = col.setdefault("parts", [])  # vpinball leaves it out of an empty collection
        for n in names:
            if n not in parts:
                parts.append(n)
        save(path, col)

    def collection_remove(self, names):
        for path, col in self.collections():
            kept = [n for n in col.get("parts", []) if n not in names]
            if kept != col.get("parts", []):
                col["parts"] = kept
                save(path, col)

    # images/<name>.json sits next to the image file it describes
    def add_image(self, name, file_name, width, height):
        save(os.path.join(self.root, "images", f"{name}.json"),
             {"$type": "image", "import_path": file_name, "width": width, "height": height,
              "alpha_test": 1.0, "opaque": False})

    def remove_image(self, name):
        for path in glob.glob(os.path.join(self.root, "images", glob.escape(name) + ".*")):
            os.remove(path)

    def gi_lights(self):
        for path, light in self.items("light"):
            if GI_NAME.match(light["name"]):
                yield path, light

    def plastics_walls(self):
        """Walls textured with the plastics sheet, i.e. the actual plastics."""
        for path, wall in self.items("surface"):
            if wall.get("image") == "plastics" and wall.get("visible", True):
                yield path, wall

    def materials(self):
        for path in sorted(glob.glob(os.path.join(self.root, "materials", "*.json"))):
            yield path, dict(load(path), name=os.path.splitext(os.path.basename(path))[0])


# ---- geometry (VPX drag points, Catmull-Rom for smooth points) ---------------
def subdivide(points, steps=8):
    """Approximate a VPX drag-point outline as a plain polygon."""
    points = [dict(p["center"], smooth=p.get("smooth")) for p in points]
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
        print(f"{l['name']:8} {l['intensity']:5.2f} {l['radius']:6.1f} {l['falloff_power']:4.1f} "
              f"{l['modulate_vs_add']:5.2f} {l['transmission_scale']:6.3f} {l['bulb_halo_height']:5.1f} "
              f"{l['surface'] or '-'}")
    used = {w["top_material"] for _, w in t.plastics_walls()}
    for _, m in t.materials():
        if m["name"] in used:
            print(f"material {m['name']!r}: opacity {m['opacity']} active={m['is_opacity_active']}")
    lm = [os.path.basename(p) for p, _ in t.items("flasher") if _["name"].startswith("LM_")]
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
        t.write_item("light", l)
    used = {w["top_material"] for _, w in t.plastics_walls()}
    for mpath, m in t.materials():
        if m["name"] in used:
            m["is_opacity_active"] = True
            if m["opacity"] >= 1.0:
                m["opacity"] = PLASTIC_OPACITY
            print(f"material {m['name']!r}: opacity {m['opacity']} (active)")
            save(mpath, {k: v for k, v in m.items() if k != "name"})
    print(f"GI bulbs: transmission_scale = {product} / intensity")


def cmd_halo(t, **overrides):
    """Strategy 2. Retune the halo polygon drawn on the playfield. Intensity up,
    tighter falloff with power 2 for visible hotspots, and a little additive
    share (modulate 0.9) so the halo still reads on a dark playfield."""
    params = dict(HALO, **overrides)
    params["color2"] = colorref(params["color2"])
    for path, l in t.gi_lights():
        old_int = l["intensity"]
        l.update(params)
        # keep the transmitted light where strategy 1 put it
        if l["transmission_scale"] > 0 and old_int > 0:
            l["transmission_scale"] = round(l["transmission_scale"] * old_int / l["intensity"], 4)
        t.write_item("light", l)
    print(f"GI bulbs: {params}")


def cmd_add_bulb(t, name, x, y, like):
    """Add a GI bulb at (x, y) cloned from an existing one: same settings, tags,
    collections and outline (translated), so every strategy treats it alike."""
    if not GI_NAME.match(name):
        sys.exit("GI bulbs must be named giNNN")
    if os.path.exists(t.item_path(name)):
        sys.exit(f"{name} already exists")
    src = t.item(like)
    l = copy.deepcopy(src)
    l["name"] = name
    dx, dy = x - src["center"]["x"], y - src["center"]["y"]
    l["center"] = dict(src["center"], x=x, y=y)
    for p in l["dragpoints"]:
        p["center"]["x"] += dx
        p["center"]["y"] += dy
    t.write_item("light", l)
    for cpath, c in t.collections():
        if like in c.get("parts", []):
            t.collection_add(os.path.splitext(os.path.basename(cpath))[0], [name])
    t.save_table()
    print(f"{name} at {x:.0f},{y:.0f} cloned from {like} (tags {l['blink_pattern']})")


def plastic_halo_name(gi, k):
    return f"{gi}p{k}"


def cmd_plastic_halos(t, **overrides):
    """Strategy 3. For every GI bulb close to a plastic, add a bulb light whose
    Surface is that plastic wall and whose outline is the wall outline. VPX
    draws the halo at surface height + halo height, so it lands on top of the
    plastic and modulates its texture: dst' = dst*(1 + 0.9*L) + 0.1*L."""
    params = dict(PLASTIC_HALO, **overrides)
    walls = [(w, subdivide(w["dragpoints"])) for _, w in t.plastics_walls()]
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
            l["static_bulb_mesh"] = False
            l["show_reflection_on_ball"] = False
            l["shadows"] = 0  # none
            l["part_group"] = GROUP
            l["dragpoints"] = copy.deepcopy(wall["dragpoints"])
            l.update(params)
            t.write_item("light", l)
            created.append(l["name"])
            print(f"{l['name']}: on {wall['name']} (bulb {gi['name']} at {cx:.0f},{cy:.0f})")
    t.collection_add("GI", created)
    t.collection_add("glf_lights", created)
    t.save_table()
    print(f"{len(created)} plastic halo lights")


def cmd_remove_plastic_halos(t):
    names = [l["name"] for _, l in t.items("light") if re.match(r"^gi\d+p\d+$", l["name"])]
    for n in names:
        t.remove_item(n)
    t.collection_remove(names)
    t.save_table()
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
    from PIL import Image, ImageChops, ImageDraw

    params = dict(LIGHTMAP_FLASHER, **overrides)
    pngs = sorted(glob.glob(os.path.join(render_dir, "LM_gi*.png")))
    if not pngs:
        sys.exit(f"no LM_gi*.png in {render_dir}; run gi_lightmaps_render.py first")
    walls = [(w, subdivide(w["dragpoints"])) for _, w in t.plastics_walls()]
    wall_mask = None  # the plastics sheet has art outside the walls; only show what a wall shows
    template = None
    for _, fl in t.items("flasher"):
        template = fl
        break
    made = []
    for png in pngs:
        gi = re.search(r"(gi\d+)", os.path.basename(png)).group(1)
        name = lightmap_image_name(gi)
        im = Image.open(png).convert("RGBA")
        W, H = im.size
        if wall_mask is None or wall_mask.size != im.size:
            wall_mask = Image.new("L", im.size, 0)
            draw = ImageDraw.Draw(wall_mask)
            for _, poly in walls:
                draw.polygon([(x * W / TABLE_W, y * H / TABLE_H) for x, y in poly], fill=255)
        im.putalpha(ImageChops.multiply(im.getchannel("A"), wall_mask))
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
        t.add_image(name, f"{name}.webp", *crop.size)
        # pixel -> table units, the same mapping the plastics sheet uses on the walls
        sx, sy = TABLE_W / W, TABLE_H / H
        tx0, ty0, tx1, ty1 = x0 * sx, y0 * sy, x1 * sx, y1 * sy
        tops = [w["height_top"] for w, poly in walls if bbox_overlaps(poly, tx0, ty0, tx1, ty1)]
        height = (max(tops) if tops else 58.0) + 0.5
        fl = copy.deepcopy(template)
        # the pack stores no flasher position; vpinball takes it from the drag points
        fl.update({
            "name": name, "height": height,
            "rotation_x": 0.0, "rotation_y": 0.0, "rotation_z": 0.0,
            "color": 0xffffff, "timer_enabled": False, "timer_interval": 100,
            "image": name, "image_b": "",
            "visible": True, "add_blend": 1, "dmd": False,  # add_blend 1: additive
            "ui_show_texture": True, "depth_bias": 0.0,
            "alignment": 1, "filter_type": 0, "filter_amount": 100,  # wrap, no filter
            "lightmap": gi, "part_group": GROUP, "ui_locked": False,
        })
        fl.update(params)
        fl["dragpoints"] = [dragpoint(x, y) for (x, y) in ((tx0, ty0), (tx0, ty1), (tx1, ty1), (tx1, ty0))]
        t.write_item("flasher", fl)
        made.append(name)
        print(f"{name}: {crop.size[0]}x{crop.size[1]} px at z={height}, table box "
              f"{tx0:.0f},{ty0:.0f}-{tx1:.0f},{ty1:.0f}")
    t.save_table()
    print(f"{len(made)} lightmap flashers")


def cmd_lightmaps_adjust(t, **params):
    """Change alpha / modulate on the existing lightmap flashers without
    re-rendering. alpha is the flasher Opacity (100 = 1.0) and scales the added
    light linearly; modulate_vs_add shifts it from plain additive (0) towards
    only brightening what is already lit (1)."""
    n = 0
    for _, fl in list(t.items("flasher")):
        if re.match(r"^LM_gi\d+_plastics$", fl["name"]):
            fl.update({k: v for k, v in params.items() if v is not None})
            t.write_item("flasher", fl)
            n += 1
    print(f"{n} lightmap flashers: " + ", ".join(f"{k}={v}" for k, v in params.items() if v is not None))


def cmd_remove_lightmaps(t, only=None, quiet=False):
    removed = []
    for _, fl in list(t.items("flasher")):
        m = re.match(r"^LM_(gi\d+)_plastics$", fl["name"])
        if not m or (only and m.group(1) not in only):
            continue
        t.remove_item(fl["name"])
        t.remove_image(fl["name"])
        removed.append(fl["name"])
    t.save_table()
    if not quiet:
        print(f"removed {len(removed)} lightmap flashers")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--table", default=DEFAULT_TABLE, help="vpinball table pack folder")
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
