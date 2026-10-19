#!/usr/bin/env python3
# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "shapely",
# ]
# ///
"""Regenerate the plastic outlines in playfield.svg from the VPX table.

Every Wall in PartGroup "Plastics" becomes two paths:

  * "plastic outlines" (top-level layer, locked): the exact top outline, as
    cubic beziers, for use as a guide. Not part of the plastics.webp export.
  * "vpx plastic fills" (sublayer at the bottom of "plastics"): the outline
    grown by --bleed mm and filled, so it ends up in plastics.webp.

Both layers belong to this script and are replaced wholesale on every run;
make changes in VPX (then `npm run extract-vpx`) rather than in Inkscape.

Only those two layers are spliced into the file text, so the rest of the
Inkscape-formatted SVG is left byte-for-byte untouched.

Curve math mirrors VPX (src/math/dragpoint.h, src/math/MeshUtils.h): each
drag point pair is a centripetal Catmull-Rom segment, and a non-smooth point
uses itself as its outer neighbour. Each segment is a single cubic, so it
converts to an SVG bezier exactly.
"""

import argparse
import glob
import json
import math
import os
import re

from shapely import make_valid
from shapely.geometry import MultiPolygon, Polygon

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
SVG_PATH = os.path.join(SCRIPT_DIR, "playfield.svg")

PART_GROUP = "Plastics"
FILL_LAYER_ID = "vpx_plastic_fills"
OUTLINE_LAYER_ID = "vpx_plastic_outlines"
FILL_STYLE = "fill:#d5c2e7;fill-opacity:1;stroke:none"
OUTLINE_STYLE = "fill:none;stroke:#ff00ff;stroke-width:0.25;stroke-opacity:1"


def read_game_name():
    with open(os.path.join(PROJECT_ROOT, "gamename.txt")) as f:
        return f.readline().strip()


def read_table(table_dir):
    with open(os.path.join(table_dir, "gamedata.json")) as f:
        gamedata = json.load(f)
    walls = []
    for path in sorted(glob.glob(os.path.join(table_dir, "gameitems", "Wall.*.json"))):
        with open(path) as f:
            wall = json.load(f)["Wall"]
        if wall.get("part_group_name") == PART_GROUP:
            walls.append(wall)
    return gamedata, walls


def catmull_tangents(p0, p1, p2, p3):
    """Hermite tangents of VPX's CatmullCurve<2> for the p1->p2 segment, t in [0,1]."""
    dt0 = math.sqrt(math.dist(p0, p1))
    dt1 = math.sqrt(math.dist(p1, p2))
    dt2 = math.sqrt(math.dist(p2, p3))
    if dt1 < 1e-4:
        dt1 = 1.0
    if dt0 < 1e-4:
        dt0 = dt1
    if dt2 < 1e-4:
        dt2 = dt1

    def tangents(x0, x1, x2, x3):
        t1 = (x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1
        t2 = (x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2
        return t1 * dt1, t2 * dt1

    tx1, tx2 = tangents(p0[0], p1[0], p2[0], p3[0])
    ty1, ty2 = tangents(p0[1], p1[1], p2[1], p3[1])
    return (tx1, ty1), (tx2, ty2)


def wall_beziers(drag_points):
    """Closed loop of cubic beziers [(p1, c1, c2, p2), ...] in VPX units (IHaveDragPoints::GetRgVertex, loop=true)."""
    pts = [(p["x"], p["y"]) for p in drag_points]
    smooth = [p["smooth"] for p in drag_points]
    n = len(pts)
    segments = []
    for i in range(n):
        j = (i + 1) % n
        if pts[i] == pts[j]:
            continue  # VPX skips coincident points
        iprev = (i - 1) % n if smooth[i] else i
        inext = (i + 2) % n if smooth[j] else j
        p0, p1, p2, p3 = pts[iprev], pts[i], pts[j], pts[inext]
        t1, t2 = catmull_tangents(p0, p1, p2, p3)
        c1 = (p1[0] + t1[0] / 3, p1[1] + t1[1] / 3)
        c2 = (p2[0] - t2[0] / 3, p2[1] - t2[1] / 3)
        segments.append((p1, c1, c2, p2))
    return segments


def sample_beziers(segments, step):
    """Dense polyline along the beziers, roughly `step` apart."""
    points = []
    for p1, c1, c2, p2 in segments:
        hull = math.dist(p1, c1) + math.dist(c1, c2) + math.dist(c2, p2)
        count = max(1, math.ceil(hull / step))
        for k in range(count):
            t = k / count
            u = 1 - t
            a, b, c, d = u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t
            points.append(
                (
                    a * p1[0] + b * c1[0] + c * c2[0] + d * p2[0],
                    a * p1[1] + b * c1[1] + c * c2[1] + d * p2[1],
                )
            )
    return points


def fmt(v):
    return f"{v:.4f}".rstrip("0").rstrip(".")


def pt(p):
    return f"{fmt(p[0])},{fmt(p[1])}"


def bezier_d(segments):
    d = [f"M {pt(segments[0][0])}"]
    d += [f"C {pt(c1)} {pt(c2)} {pt(p2)}" for _, c1, c2, p2 in segments]
    return " ".join(d) + " Z"


def polygon_d(geometry):
    polygons = geometry.geoms if isinstance(geometry, MultiPolygon) else [geometry]
    d = []
    for poly in polygons:
        for ring in [poly.exterior, *poly.interiors]:
            coords = list(ring.coords)[:-1]
            d.append(f"M {pt(coords[0])} L " + " ".join(pt(c) for c in coords[1:]) + " Z")
    return " ".join(d)


def to_svg(walls, gamedata, page_w, page_h, bleed):
    sx = page_w / (gamedata["right"] - gamedata["left"])
    sy = page_h / (gamedata["bottom"] - gamedata["top"])

    def to_page(p):
        return ((p[0] - gamedata["left"]) * sx, (p[1] - gamedata["top"]) * sy)

    outlines, fills = [], []
    for wall in walls:
        name = wall["name"]
        segments = [tuple(map(to_page, seg)) for seg in wall_beziers(wall["drag_points"])]
        if not segments:
            continue
        outlines.append(path_xml(f"vpx_outline_{name}", name, OUTLINE_STYLE, bezier_d(segments)))
        shape = make_valid(Polygon(sample_beziers(segments, step=0.05)))
        grown = shape.buffer(bleed, quad_segs=16).simplify(0.005)
        fills.append(path_xml(f"vpx_fill_{name}", name, FILL_STYLE, polygon_d(grown)))
    return outlines, fills


def path_xml(path_id, label, style, d):
    return (
        f'<path\n       id="{path_id}"\n       inkscape:label="{label}"\n'
        f'       style="{style}"\n       d="{d}" />'
    )


def layer_xml(layer_id, label, children, locked):
    lock = '\n     sodipodi:insensitive="true"' if locked else ""
    return (
        f'<g\n     inkscape:groupmode="layer"\n     id="{layer_id}"\n'
        f'     inkscape:label="{label}"{lock}\n     style="display:inline">'
        + "".join(children)
        + "</g>"
    )


def find_element(svg, element_id):
    """(start, end) of the <g> with this id; the generated layers never nest groups."""
    match = re.search(rf'<g\b[^>]*?\bid="{element_id}"[^>]*>', svg)
    if not match:
        return None
    end = svg.index("</g>", match.end())
    if "<g" in svg[match.end() : end]:
        raise ValueError(f"#{element_id} contains a nested group; this script owns that layer")
    return match.start(), end + len("</g>")


def replace_or_insert(svg, element_id, new_xml, insert_at):
    span = find_element(svg, element_id)
    if span:
        return svg[: span[0]] + new_xml + svg[span[1] :]
    position = insert_at(svg)
    return svg[:position] + new_xml + svg[position:]


def after_plastics_open_tag(svg):
    match = re.search(r'<g\b[^>]*?\binkscape:label="plastics"[^>]*>', svg)
    if not match:
        raise ValueError('no layer labeled "plastics"')
    return match.end()


def before_svg_close(svg):
    return svg.rindex("</svg>")


def page_size(svg):
    match = re.search(r'<svg\b[^>]*?\bviewBox="([^"]+)"', svg)
    _, _, width, height = map(float, match.group(1).replace(",", " ").split())
    return width, height


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--bleed", type=float, default=1.0, help="fill outset in mm (default 1.0)")
    parser.add_argument("--table", default=os.path.join(PROJECT_ROOT, read_game_name()), help="extracted table directory")
    parser.add_argument("--svg", default=SVG_PATH)
    parser.add_argument("-o", "--output", help="write here instead of overwriting --svg")
    args = parser.parse_args()

    gamedata, walls = read_table(args.table)
    with open(args.svg, encoding="utf-8") as f:
        svg = f.read()

    page_w, page_h = page_size(svg)
    outlines, fills = to_svg(walls, gamedata, page_w, page_h, args.bleed)

    svg = replace_or_insert(
        svg, FILL_LAYER_ID, layer_xml(FILL_LAYER_ID, "vpx plastic fills", fills, locked=False), after_plastics_open_tag
    )
    svg = replace_or_insert(
        svg, OUTLINE_LAYER_ID, layer_xml(OUTLINE_LAYER_ID, "plastic outlines", outlines, locked=True), before_svg_close
    )

    with open(args.output or args.svg, "w", encoding="utf-8") as f:
        f.write(svg)
    print(f"{len(outlines)} plastic walls -> {args.output or args.svg}")


if __name__ == "__main__":
    main()
