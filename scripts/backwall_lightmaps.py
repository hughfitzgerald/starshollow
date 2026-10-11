#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "lxml",
#   "pillow",
# ]
# ///
"""
Hand-made lightmaps for the backwall (Wall028), the same idea as strategy 4 in
gi-lighting-notes.md but for a vertical wall lit from behind.

backwall.svg gets a hidden layer called "light glow" holding one soft radial
blob per backwall light (Light001..Light012). For each light, everything that
is visible in the SVG is masked by that light's blob and exported on its own,
so the result is the backwall art where the light would shine through it and
transparent everywhere else. `build` crops each render and turns it into an
additive flasher standing just in front of the wall's front face.

    backwall_lightmaps.py init      # add the gradient + "light glow" layer, one
                                    #   blob per light that has none yet
    backwall_lightmaps.py render    # write lightmaps/LM_LightNNN_backwall.png
    backwall_lightmaps.py build     # webp + images.json + flasher per light
    backwall_lightmaps.py all       # init, render, build
    backwall_lightmaps.py adjust --alpha 60    # dim/brighten existing flashers
    backwall_lightmaps.py remove

Move, scale or restyle the blobs in Inkscape however you like (any element in
the layer whose label contains LightNNN counts), then render + build again.

Mapping: the wall's side image wraps the wall outline once starting at drag
point 0, so with auto texture the SVG x is the distance along the outline and
the SVG y runs from height_top (y = 0) down to height_bottom.
"""

import argparse
import copy
import os
import re
import shutil
import subprocess
import sys
import tempfile

from lxml import etree

from gi_lighting import Table, load, save

HERE = os.path.dirname(os.path.abspath(__file__))
SVG_PATH = os.path.join(HERE, "backwall.svg")
TABLE_DIR = os.path.normpath(os.path.join(HERE, "..", "starshollow"))
OUT_DIR = os.path.join(HERE, "lightmaps")
INKSCAPE = "/Applications/Inkscape.app/Contents/MacOS/inkscape"

WALL = "Wall028"
LIGHT_NAME = re.compile(r"Light\d{3}")

SVG_NS = "http://www.w3.org/2000/svg"
INK_NS = "http://www.inkscape.org/namespaces/inkscape"
NS = {"svg": SVG_NS, "inkscape": INK_NS}

GLOW_LAYER_LABEL = "light glow"
GLOW_LAYER_ID = "layer_light_glow"
GRADIENT_ID = "backwall_glow_gradient"
GLOW_DEFS_ID = "backwall_glow_defs"
MASK_ID = "backwall_lightmap_mask"

# Blob radius in table units. The lights are about 60 apart and sit a few
# units behind the plastic, so neighbours overlap a little.
GLOW_RADIUS_UNITS = 45.0
GLOW_STOPS = [(0.0, 1.0), (0.35, 0.85), (0.65, 0.4), (0.85, 0.12), (1.0, 0.0)]

FLASHER = dict(alpha=100, modulate_vs_add=0.3)
FRONT_OFFSET = 0.5  # flasher distance in front of the wall's front face
MARGIN_PX = 6
GROUP = "GI_Layer"
TEMPLATE_FLASHER = "LM_gi027_plastics"


def q(tag, ns=SVG_NS):
    return f"{{{ns}}}{tag}"


def lightmap_name(light):
    return f"LM_{light}_backwall"


# ---- wall <-> svg mapping ---------------------------------------------------
class WallMap:
    def __init__(self, t, root):
        wall = load(t.item_path("Wall", WALL))["Wall"]
        pts = [(p["x"], p["y"]) for p in wall["drag_points"]]
        self.top, self.bottom = wall["height_top"], wall["height_bottom"]
        self.segs = []  # (start distance, p0, p1, length)
        s = 0.0
        for i, p0 in enumerate(pts):
            p1 = pts[(i + 1) % len(pts)]
            n = ((p1[0] - p0[0]) ** 2 + (p1[1] - p0[1]) ** 2) ** 0.5
            self.segs.append((s, p0, p1, n))
            s += n
        self.perimeter = s
        # the face the texture's first long run is on, which is the one facing the player
        self.front = max(self.segs, key=lambda seg: (seg[3], -seg[0]))
        vb = [float(v) for v in root.get("viewBox").split()]
        self.vb_w, self.vb_h = vb[2], vb[3]

    def table_to_svg(self, x, z):
        s0, p0, p1, n = self.front
        u = s0 + (x - p0[0]) / (p1[0] - p0[0]) * n
        return u / self.perimeter * self.vb_w, (self.top - z) / (self.top - self.bottom) * self.vb_h

    def svg_to_table(self, sx, sy):
        s0, p0, p1, n = self.front
        x = p0[0] + (sx / self.vb_w * self.perimeter - s0) / n * (p1[0] - p0[0])
        return x, self.top - sy / self.vb_h * (self.top - self.bottom)

    @property
    def front_y(self):
        return self.front[1][1]


def backwall_lights(t):
    surfaces = {}
    out = {}
    for _, light in t.items("Light"):
        if not LIGHT_NAME.fullmatch(light["name"]):
            continue
        surf = light["surface"]
        if surf and surf not in surfaces:
            surfaces[surf] = load(t.item_path("Wall", surf))["Wall"]["height_top"]
        z = surfaces.get(surf, 0.0) + light["height"]
        out[light["name"]] = (light["center"]["x"], z)
    return out


# ---- svg helpers ------------------------------------------------------------
def parse(path):
    return etree.parse(path, etree.XMLParser(remove_blank_text=False))


def layer(root, label):
    found = root.xpath(f'/svg:svg/svg:g[@inkscape:groupmode="layer"][@inkscape:label="{label}"]', namespaces=NS)
    return found[0] if found else None


def glow_elements(root):
    g = layer(root, GLOW_LAYER_LABEL)
    if g is None:
        sys.exit(f"no {GLOW_LAYER_LABEL!r} layer in {SVG_PATH}; run `init` first")
    out = []
    for el in g:
        if not isinstance(el.tag, str):
            continue
        m = LIGHT_NAME.search(el.get(q("label", INK_NS)) or el.get("id") or "")
        if m:
            out.append((m.group(0), el))
    return g, out


def is_hidden(el):
    return "display:none" in (el.get("style") or "").replace(" ", "")


# ---- init -------------------------------------------------------------------
def cmd_init(t):
    """Insert the gradient, the layer and the blobs as text so the rest of the
    file stays as Inkscape wrote it."""
    root = parse(SVG_PATH).getroot()
    wm = WallMap(t, root)
    with open(SVG_PATH, encoding="utf-8", newline="") as f:
        text = f.read()

    if not root.xpath(f'//svg:radialGradient[@id="{GRADIENT_ID}"]', namespaces=NS):
        stops = "".join(f'      <stop\n         offset="{o}"\n         style="stop-color:#ffffff;stop-opacity:{a}" />\n'
                        for o, a in GLOW_STOPS)
        defs = (f'<defs\n     id="{GLOW_DEFS_ID}">\n    <radialGradient\n       id="{GRADIENT_ID}"\n'
                f'       inkscape:collect="always">\n{stops}    </radialGradient>\n  </defs>\n')
        close = text.rfind("</svg>")
        text = text[:close] + defs + text[close:]
        print(f"added gradient #{GRADIENT_ID}")

    g = layer(root, GLOW_LAYER_LABEL)
    existing = {name for name, _ in glow_elements(root)[1]} if g is not None else set()
    r = GLOW_RADIUS_UNITS * wm.vb_w / wm.perimeter
    blobs = ""
    for name, (x, z) in sorted(backwall_lights(t).items()):
        if name in existing:
            continue
        sx, sy = wm.table_to_svg(x, z)
        blobs += (f'    <circle\n       id="glow_{name}"\n       inkscape:label="glow {name}"\n'
                  f'       cx="{sx:.4f}"\n       cy="{sy:.4f}"\n       r="{r:.4f}"\n'
                  f'       style="fill:url(#{GRADIENT_ID});fill-opacity:1;stroke:none" />\n')
    if g is None:
        layer_text = (f'<g\n     inkscape:groupmode="layer"\n     id="{GLOW_LAYER_ID}"\n'
                      f'     inkscape:label="{GLOW_LAYER_LABEL}"\n     style="display:none">\n{blobs}  </g>\n')
        close = text.rfind("</svg>")
        text = text[:close] + layer_text + text[close:]
        print(f"added layer {GLOW_LAYER_LABEL!r} (hidden)")
    elif blobs:
        m = re.search(r'<g\b[^>]*\bid="%s"' % re.escape(g.get("id")), text)
        close = text.find("</g>", m.end())  # the glow layer holds no groups
        text = text[:close] + blobs + "  " + text[close:]
    with open(SVG_PATH, "w", encoding="utf-8", newline="") as f:
        f.write(text)
    parse(SVG_PATH)  # still well formed
    print(f"{blobs.count('<circle')} glow blobs added, {len(existing)} already there")


# ---- render -----------------------------------------------------------------
def masked_copy(tree, glow_layer, element):
    """Every layer that is visible now, masked by one blob."""
    t = copy.deepcopy(tree)
    root = t.getroot()
    vb = [float(v) for v in root.get("viewBox").split()]
    defs = root.find(q("defs"))
    if defs is None:
        defs = etree.SubElement(root, q("defs"))
    mask = etree.SubElement(defs, q("mask"), id=MASK_ID, maskUnits="userSpaceOnUse",
                            x=str(vb[0]), y=str(vb[1]), width=str(vb[2]), height=str(vb[3]))
    holder = etree.SubElement(mask, q("g"))
    if glow_layer.get("transform"):
        holder.set("transform", glow_layer.get("transform"))
    blob = copy.deepcopy(element)
    blob.set("style", re.sub(r"display:[^;]*;?", "", blob.get("style") or "") + ";display:inline")
    holder.append(blob)
    art = etree.Element(q("g"), mask=f"url(#{MASK_ID})")
    for g in root.xpath('/svg:svg/svg:g[@inkscape:groupmode="layer"]', namespaces=NS):
        if g.get(q("label", INK_NS)) == GLOW_LAYER_LABEL or is_hidden(g):
            root.remove(g)
        else:
            root.remove(g)
            art.append(g)
    root.append(art)
    return t


def cmd_render(args):
    tree = parse(SVG_PATH)
    glow_layer, blobs = glow_elements(tree.getroot())
    if args.only:
        blobs = [(n, e) for n, e in blobs if n in args.only]
    inkscape = args.inkscape or (INKSCAPE if os.path.exists(INKSCAPE) else shutil.which("inkscape"))
    if not inkscape:
        sys.exit("Inkscape not found; pass --inkscape PATH")
    os.makedirs(args.out, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for name, el in blobs:
            svg = os.path.join(tmp, f"{name}.svg")
            masked_copy(tree, glow_layer, el).write(svg, xml_declaration=True, encoding="UTF-8")
            png = os.path.join(args.out, f"{lightmap_name(name)}.png")
            subprocess.run([inkscape, svg, "--export-type=png", f"--export-filename={png}",
                            "--export-area-page", "--export-overwrite"],
                           check=True, capture_output=True,
                           env={**os.environ, "LC_ALL": "C.utf8", "LANG": "C.utf8"})
            print(png)
    print(f"{len(blobs)} lightmaps rendered; next: backwall_lightmaps.py build")


# ---- build ------------------------------------------------------------------
def cmd_build(t, args):
    """One additive flasher per light, stood upright (rot_x -90, like the DMD
    and backglass flashers) just in front of the wall. Light Map points at the
    light, and the name contains _LightNNN_ so GLF copies the light's colour to
    it as it fades."""
    from PIL import Image

    wm = WallMap(t, parse(SVG_PATH).getroot())
    images_path = os.path.join(t.root, "images.json")
    images = load(images_path)
    template = load(t.item_path("Flasher", TEMPLATE_FLASHER))["Flasher"]
    made = []
    for light in sorted(backwall_lights(t)):
        name = lightmap_name(light)
        png = os.path.join(args.render_dir, f"{name}.png")
        if not os.path.exists(png):
            print(f"{light}: no {png}, skipped")
            continue
        im = Image.open(png).convert("RGBA")
        W, H = im.size
        # only the part of the image that lands on the front face
        s0, _, _, n = wm.front
        fx0 = round(s0 / wm.perimeter * W)
        fx1 = round((s0 + n) / wm.perimeter * W)
        alpha = im.getchannel("A")
        alpha.paste(0, (0, 0, fx0, H))
        alpha.paste(0, (fx1, 0, W, H))
        im.putalpha(alpha)
        bbox = alpha.getbbox()
        if not bbox:
            print(f"{light}: empty render, skipped")
            continue
        x0, y0 = max(fx0, bbox[0] - MARGIN_PX), max(0, bbox[1] - MARGIN_PX)
        x1, y1 = min(fx1, bbox[2] + MARGIN_PX), min(H, bbox[3] + MARGIN_PX)
        crop = im.crop((x0, y0, x1, y1))
        crop.save(os.path.join(t.root, "images", f"{name}.webp"), lossless=True)
        if not any(i["name"] == name for i in images):
            images.append({"name": name, "path": f"{name}.webp",
                           "alpha_test_value": 1.0, "is_opaque": False, "is_signed": False})

        # pixels -> svg units -> table x / z
        tx0, tz_top = wm.svg_to_table(x0 * wm.vb_w / W, y0 * wm.vb_h / H)
        tx1, tz_bot = wm.svg_to_table(x1 * wm.vb_w / W, y1 * wm.vb_h / H)
        pos_x, pos_y = (tx0 + tx1) / 2, wm.front_y + FRONT_OFFSET
        half = (tz_top - tz_bot) / 2
        fl = copy.deepcopy(template)
        fl.update({
            "name": name, "height": round((tz_top + tz_bot) / 2, 4),
            "pos_x": round(pos_x, 4), "pos_y": round(pos_y, 4),
            # rot_x -90 turns the flasher's -y edge (the image top) straight up
            "rot_x": -90.0, "rot_y": 0.0, "rot_z": 0.0,
            "color": "#ffffff", "is_timer_enabled": False, "timer_interval": 100,
            "image_a": name, "image_b": "",
            "is_visible": True, "add_blend": "add", "is_dmd": False,
            "display_texture": True, "depth_bias": 0.0,
            "image_alignment": "wrap", "filter": "none", "filter_amount": 100,
            "light_map": light, "part_group_name": GROUP,
        })
        fl.update(FLASHER)
        fl["drag_points"] = []
        for (x, y) in ((tx0, pos_y - half), (tx0, pos_y + half), (tx1, pos_y + half), (tx1, pos_y - half)):
            fl["drag_points"].append({
                "x": round(x, 3), "y": round(y, 3), "z": 0.0, "smooth": False,
                "is_slingshot": False, "has_auto_texture": True, "tex_coord": 0.0,
                "is_locked": False, "editor_layer": 0, "editor_layer_name": "",
                "editor_layer_visibility": True})
        t.write_item("Flasher", fl)
        made.append(name)
        print(f"{name}: {crop.size[0]}x{crop.size[1]} px, x {tx0:.1f}-{tx1:.1f}, "
              f"z {tz_bot:.1f}-{tz_top:.1f}, y {pos_y}")
    save(images_path, images)
    t.save_index()
    print(f"{len(made)} backwall lightmap flashers")


def cmd_adjust(t, args):
    n = 0
    for _, fl in list(t.items("Flasher")):
        if re.fullmatch(r"LM_Light\d{3}_backwall", fl["name"]):
            fl.update({k: v for k, v in (("alpha", args.alpha), ("modulate_vs_add", args.modulate_vs_add))
                       if v is not None})
            t.write_item("Flasher", fl)
            n += 1
    print(f"{n} backwall lightmap flashers adjusted")


def cmd_remove(t):
    images_path = os.path.join(t.root, "images.json")
    images = load(images_path)
    removed = []
    for _, fl in list(t.items("Flasher")):
        if not re.fullmatch(r"LM_Light\d{3}_backwall", fl["name"]):
            continue
        t.remove_item("Flasher", fl["name"])
        images = [i for i in images if i["name"] != fl["name"]]
        img = os.path.join(t.root, "images", f"{fl['name']}.webp")
        if os.path.exists(img):
            os.remove(img)
        removed.append(fl["name"])
    save(images_path, images)
    t.save_index()
    print(f"removed {len(removed)} backwall lightmap flashers")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--table", default=TABLE_DIR)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("init")
    for name in ("render", "all"):
        p = sub.add_parser(name)
        p.add_argument("--inkscape", help="path to the inkscape binary")
        p.add_argument("--out", default=OUT_DIR)
        p.add_argument("--only", nargs="*", help="only these lights, e.g. Light001 Light004")
    for name in ("build", "all"):
        p = sub.choices[name] if name in sub.choices else sub.add_parser(name)
        p.add_argument("--render-dir", default=OUT_DIR)
    p = sub.add_parser("adjust")
    p.add_argument("--alpha", type=float)
    p.add_argument("--modulate-vs-add", type=float)
    sub.add_parser("remove")
    args = ap.parse_args()
    t = Table(args.table)
    if args.cmd in ("init", "all"):
        cmd_init(t)
    if args.cmd in ("render", "all"):
        cmd_render(args)
    if args.cmd in ("build", "all"):
        cmd_build(t, args)
    if args.cmd == "adjust":
        cmd_adjust(t, args)
    if args.cmd == "remove":
        cmd_remove(t)


if __name__ == "__main__":
    main()
