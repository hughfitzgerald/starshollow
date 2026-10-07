#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "lxml",
#   "pillow",
# ]
# ///
"""
Hand-made GI lightmaps straight out of playfield.svg (strategy 4).

The SVG gets a hidden layer called "GI glow" holding one soft radial blob per
GI bulb (a <circle> filled with the gi_glow_gradient). To render a lightmap
for a bulb, the plastics layer is masked by that bulb's blob and exported on
its own, so the result is the plastics art where the bulb would light it and
transparent everywhere else. gi_lighting.py lightmaps then crops each render
and turns it into an additive flasher in the table.

    gi_lightmaps_render.py init      # add the gradient + "GI glow" layer, one
                                     #   blob per giNNN light that has none yet
    gi_lightmaps_render.py render    # write lightmaps/LM_giNNN.png (Inkscape)
    gi_lightmaps_render.py render --renderer cairosvg   # no Inkscape needed

Move, scale or restyle the blobs in Inkscape however you like (the layer is
hidden by default; show it to see them over the art); `render` copies each
element verbatim into the mask, so ellipses, paths and transforms all work.
"""

import argparse
import copy
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

from lxml import etree

HERE = os.path.dirname(os.path.abspath(__file__))
SVG_PATH = os.path.join(HERE, "playfield.svg")
TABLE_DIR = os.path.normpath(os.path.join(HERE, "..", "starshollow"))
OUT_DIR = os.path.join(HERE, "lightmaps")
INKSCAPE = "/Applications/Inkscape.app/Contents/MacOS/inkscape"  # same as svg-to-playfield.py

TABLE_W, TABLE_H = 952.0, 2162.0  # gamedata.json right/bottom

SVG_NS = "http://www.w3.org/2000/svg"
INK_NS = "http://www.inkscape.org/namespaces/inkscape"
NS = {"svg": SVG_NS, "inkscape": INK_NS}

GLOW_LAYER_LABEL = "GI glow"
GLOW_LAYER_ID = "layer_gi_glow"
GRADIENT_ID = "gi_glow_gradient"
PLASTICS_LAYER_LABEL = "plastics"
MASK_ID = "gi_lightmap_mask"

# Blob radius in table units (VPX units, 50 per inch). The plastics sit an inch
# or two above the bulbs, so the hotspot is fairly tight.
GLOW_RADIUS_UNITS = 115.0
# Luminance falloff from the bulb outwards: (offset, opacity)
GLOW_STOPS = [(0.0, 1.0), (0.35, 0.85), (0.65, 0.4), (0.85, 0.12), (1.0, 0.0)]

GI_NAME = re.compile(r"gi\d+")


def q(tag, ns=SVG_NS):
    return f"{{{ns}}}{tag}"


def parse(path):
    return etree.parse(path, etree.XMLParser(huge_tree=True, remove_blank_text=False))


def write(tree, path):
    tree.write(path, xml_declaration=True, encoding="UTF-8", standalone=False)


def page_size(root):
    vb = [float(v) for v in root.get("viewBox").split()]
    return vb[2], vb[3]  # user units (mm in this document)


def export_pixels(root):
    """Inkscape's --export-area-page at the default 96 dpi."""
    def mm(v):
        v = v.strip()
        return float(v[:-2]) if v.endswith("mm") else float(v)
    w, h = mm(root.get("width")), mm(root.get("height"))
    return round(w / 25.4 * 96), round(h / 25.4 * 96)


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
        label = el.get(q("label", INK_NS)) or el.get("id") or ""
        m = GI_NAME.search(label)
        if m:
            out.append((m.group(0), el))
    return g, out


# ---- init -------------------------------------------------------------------
def gi_light_centers():
    centers = {}
    for path in sorted(glob.glob(os.path.join(TABLE_DIR, "gameitems", "Light.gi*.json"))):
        with open(path, encoding="utf-8") as f:
            light = json.load(f)["Light"]
        if re.fullmatch(r"gi\d+", light["name"]):
            centers[light["name"]] = (light["center"]["x"], light["center"]["y"])
    return centers


GLOW_DEFS_ID = "gi_glow_defs"


def blob_markup(name, x, y, r):
    return (f'    <circle\n       id="glow_{name}"\n       inkscape:label="glow {name}"\n'
            f'       cx="{x:.4f}"\n       cy="{y:.4f}"\n       r="{r:.4f}"\n'
            f'       style="fill:url(#{GRADIENT_ID});fill-opacity:1;stroke:none" />\n')


def find_group_span(text, start):
    """(start, end) of the <g ...>...</g> whose opening tag begins at `start`."""
    depth = 0
    for m in re.finditer(r"<g\b[^>]*?(/?)>|</g>", text[start:]):
        tag = m.group(0)
        if tag.startswith("</g"):
            depth -= 1
            if depth == 0:
                return start, start + m.end()
        elif not m.group(1):
            depth += 1
    raise ValueError("unbalanced <g>")


def cmd_init(args):
    """Insert the gradient, the layer and the blobs as text so the rest of the
    52 MB file stays byte-identical (re-serialising through lxml would reflow
    every tag Inkscape wrote and make the diff useless)."""
    tree = parse(SVG_PATH)
    root = tree.getroot()
    pw, ph = page_size(root)
    sx, sy = pw / TABLE_W, ph / TABLE_H
    with open(SVG_PATH, encoding="utf-8", newline="") as f:
        text = f.read()
    closing = text.rfind("</svg>")
    if closing < 0:
        sys.exit("no </svg>")

    if not root.xpath(f'//svg:radialGradient[@id="{GRADIENT_ID}"]', namespaces=NS):
        stops = "".join(f'      <stop\n         offset="{o}"\n         style="stop-color:#ffffff;stop-opacity:{a}" />\n'
                        for o, a in GLOW_STOPS)
        defs = (f'<defs\n     id="{GLOW_DEFS_ID}">\n    <radialGradient\n       id="{GRADIENT_ID}"\n'
                f'       inkscape:collect="always">\n{stops}    </radialGradient>\n  </defs>')
        text = text[:closing] + defs + text[closing:]
        closing = text.rfind("</svg>")
        print(f"added gradient #{GRADIENT_ID}")

    g = layer(root, GLOW_LAYER_LABEL)
    existing = {name for name, _ in glow_elements(root)[1]} if g is not None else set()
    new_blobs = "".join(blob_markup(name, x * sx, y * sy, GLOW_RADIUS_UNITS * sx)
                        for name, (x, y) in gi_light_centers().items() if name not in existing)
    added = new_blobs.count("<circle")
    if g is None:
        layer_text = (f'<g\n     inkscape:groupmode="layer"\n     id="{GLOW_LAYER_ID}"\n'
                      f'     inkscape:label="{GLOW_LAYER_LABEL}"\n     style="display:none">\n{new_blobs}  </g>')
        text = text[:closing] + layer_text + text[closing:]
        print(f"added layer {GLOW_LAYER_LABEL!r} (hidden)")
    elif new_blobs:
        m = re.search(r'<g\b[^>]*\bid="%s"[^>]*>' % re.escape(g.get("id")), text)
        if not m:
            sys.exit("could not find the GI glow layer in the file text")
        start, end = find_group_span(text, m.start())
        close = text.rfind("</g>", start, end)
        text = text[:close] + new_blobs + "  " + text[close:]
    with open(SVG_PATH, "w", encoding="utf-8", newline="") as f:
        f.write(text)
    parse(SVG_PATH)  # make sure it is still well formed
    print(f"{added} glow blobs added, {len(existing)} already there")


# ---- render -----------------------------------------------------------------
def masked_copy(tree, glow_layer, element):
    t = copy.deepcopy(tree)
    root = t.getroot()
    pw, ph = page_size(root)
    for g in root.xpath('/svg:svg/svg:g[@inkscape:groupmode="layer"]', namespaces=NS):
        label = g.get(q("label", INK_NS))
        g.set("style", "display:inline" if label == PLASTICS_LAYER_LABEL else "display:none")
    plastics = layer(root, PLASTICS_LAYER_LABEL)
    if plastics is None:
        sys.exit(f"no {PLASTICS_LAYER_LABEL!r} layer")
    defs = root.find(q("defs"))
    mask = etree.SubElement(defs, q("mask"), id=MASK_ID, maskUnits="userSpaceOnUse",
                            x="0", y="0", width=str(pw), height=str(ph))
    holder = etree.SubElement(mask, q("g"))
    if glow_layer.get("transform"):
        holder.set("transform", glow_layer.get("transform"))
    blob = copy.deepcopy(element)
    style = blob.get("style") or ""
    blob.set("style", re.sub(r"display:[^;]*;?", "", style) + ";display:inline")
    holder.append(blob)
    plastics.set("mask", f"url(#{MASK_ID})")
    return t


def render_inkscape(svg, png, inkscape):
    subprocess.run([inkscape, svg, "--export-type=png", f"--export-filename={png}",
                    "--export-area-page", "--export-overwrite"],
                   check=True, env={**os.environ, "LC_ALL": "C.utf8", "LANG": "C.utf8"})


def render_cairosvg(svg, png, size):
    import cairosvg  # pip install cairosvg
    cairosvg.svg2png(url=svg, write_to=png, output_width=size[0], output_height=size[1], unsafe=True)


def cmd_render(args):
    tree = parse(SVG_PATH)
    root = tree.getroot()
    glow_layer, blobs = glow_elements(root)
    if args.only:
        blobs = [(n, e) for n, e in blobs if n in args.only]
    os.makedirs(args.out, exist_ok=True)
    size = export_pixels(root)
    inkscape = args.inkscape or (INKSCAPE if os.path.exists(INKSCAPE) else shutil.which("inkscape"))
    if args.renderer == "inkscape" and not inkscape:
        sys.exit("Inkscape not found; pass --inkscape PATH or --renderer cairosvg")
    with tempfile.TemporaryDirectory() as tmp:
        for name, el in blobs:
            svg = os.path.join(tmp, f"{name}.svg")
            write(masked_copy(tree, glow_layer, el), svg)
            png = os.path.join(args.out, f"LM_{name}.png")
            if args.renderer == "inkscape":
                render_inkscape(svg, png, inkscape)
            else:
                render_cairosvg(svg, png, size)
            print(f"{png} ({size[0]}x{size[1]})")
    print(f"{len(blobs)} lightmaps rendered; next: gi_lighting.py lightmaps")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("init")
    p = sub.add_parser("render")
    p.add_argument("--renderer", choices=["inkscape", "cairosvg"], default="inkscape")
    p.add_argument("--inkscape", help="path to the inkscape binary")
    p.add_argument("--out", default=OUT_DIR)
    p.add_argument("--only", nargs="*", help="only these bulbs, e.g. gi010 gi012")
    args = ap.parse_args()
    if args.cmd == "init":
        cmd_init(args)
    else:
        cmd_render(args)


if __name__ == "__main__":
    main()
