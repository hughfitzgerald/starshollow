#!/usr/bin/env python3
# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "shapely",
# ]
# ///
"""Regenerate the plastic outlines in playfield.svg from the VPX table.

Every Wall and Primitive in PartGroup "Plastics" becomes two paths:

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

Primitives are outlined by transforming their mesh the way VPX does
(Primitive::RecalculateMatrices) and taking the union of its triangles as
seen from above, which is exact since the mesh is already polygonal.

Primitives also get their table files updated so they can share
plastics.webp with the walls: the image is set to "plastics" and the mesh
UVs are rewritten to the table-space mapping VPX gives wall tops
(Surface::GenerateMesh: tu = x / table width, tv = y / table height).
Run `npm run assemble-vpx` afterwards to put them back in the .vpx.
"""

import argparse
import glob
import json
import math
import os
import re

from shapely import make_valid, unary_union
from shapely.affinity import scale, translate
from shapely.geometry import MultiPolygon, Polygon

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
SVG_PATH = os.path.join(SCRIPT_DIR, "playfield.svg")

PART_GROUP = "Plastics"
PLASTICS_IMAGE = "plastics"
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
    walls, primitives = [], []
    for path in sorted(glob.glob(os.path.join(table_dir, "gameitems", "*.json"))):
        kind = os.path.basename(path).split(".")[0]
        if kind not in ("Wall", "Primitive"):
            continue
        with open(path) as f:
            item = json.load(f)[kind]
        if item.get("part_group_name") != PART_GROUP:
            continue
        if kind == "Wall":
            walls.append(item)
        elif not item["use_3d_mesh"]:
            print(f"skipping {item['name']}: built-in primitive shapes aren't supported")
        else:
            item["mesh_path"] = path.removesuffix(".json") + ".obj"
            primitives.append(item)
    return gamedata, walls, primitives


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


def matrix_translate(x, y, z):
    return [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [x, y, z, 1]]


def matrix_scale(x, y, z):
    return [[x, 0, 0, 0], [0, y, 0, 0], [0, 0, z, 0], [0, 0, 0, 1]]


def matrix_rotate(axis, degrees):
    """Matrix3D::SetRotateX/Y/Z (row vectors, so v * M)."""
    c, s = math.cos(math.radians(degrees)), math.sin(math.radians(degrees))
    i, j = {"x": (1, 2), "y": (2, 0), "z": (0, 1)}[axis]
    m = [[float(r == k) for k in range(4)] for r in range(4)]
    m[i][i] = m[j][j] = c
    m[i][j] = s
    m[j][i] = -s
    return m


def matrix_multiply(*matrices):
    result = matrices[0]
    for m in matrices[1:]:
        result = [[sum(result[r][k] * m[k][c] for k in range(4)) for c in range(4)] for r in range(4)]
    return result


def primitive_matrix(primitive):
    """Primitive::RecalculateMatrices: scale * rotation/translation * position."""
    rt = primitive["rot_and_tra"]
    size, position = primitive["size"], primitive["position"]
    return matrix_multiply(
        matrix_scale(size["x"], size["y"], size["z"]),
        matrix_translate(rt[3], rt[4], rt[5]),
        matrix_rotate("z", rt[2]),
        matrix_rotate("y", rt[1]),
        matrix_rotate("x", rt[0]),
        matrix_rotate("z", rt[8]),
        matrix_rotate("y", rt[7]),
        matrix_rotate("x", rt[6]),
        matrix_translate(position["x"], position["y"], position["z"]),
    )


def read_obj(path):
    """Vertices (in VPX space) and triangles of a vpxtool OBJ, which stores z negated."""
    vertices, triangles = [], []
    with open(path) as f:
        for line in f:
            parts = line.split()
            if not parts:
                continue
            if parts[0] == "v":
                x, y, z = map(float, parts[1:4])
                vertices.append((x, y, -z))
            elif parts[0] == "f":
                corners = [int(p.split("/")[0]) - 1 for p in parts[1:]]
                triangles += [(corners[0], corners[k], corners[k + 1]) for k in range(1, len(corners) - 1)]
    return vertices, triangles


def table_vertices(primitive, vertices):
    """Mesh vertices placed on the table (Matrix3D::MultiplyVector), as (x, y)."""
    m = primitive_matrix(primitive)
    placed = []
    for x, y, z in vertices:
        w = x * m[0][3] + y * m[1][3] + z * m[2][3] + m[3][3]
        placed.append(
            (
                (x * m[0][0] + y * m[1][0] + z * m[2][0] + m[3][0]) / w,
                (x * m[0][1] + y * m[1][1] + z * m[2][1] + m[3][1]) / w,
            )
        )
    return placed


def primitive_footprint(primitive):
    """Top-down silhouette of the transformed mesh, in VPX units."""
    vertices, triangles = read_obj(primitive["mesh_path"])
    flat = table_vertices(primitive, vertices)
    faces = [Polygon([flat[i] for i in tri]) for tri in triangles]
    footprint = unary_union([face for face in faces if face.area > 1e-9])
    # Close hairline cracks between triangles that don't quite share edges.
    return footprint.buffer(1e-4, join_style="mitre").buffer(-1e-4, join_style="mitre")


def update_primitive_files(primitive, gamedata):
    """Point the primitive at plastics.webp and give its mesh wall-style table-space UVs.

    Returns True if either file changed.
    """
    with open(primitive["mesh_path"]) as f:
        lines = f.read().split("\n")
    vertices, _ = read_obj(primitive["mesh_path"])
    for line in lines:
        if line.startswith("f "):
            for corner in line.split()[1:]:
                v, vt = corner.split("/")[:2]
                if v != vt:
                    raise ValueError(f"{primitive['mesh_path']}: face uses different v and vt indices")
        if line.startswith("# vpx "):
            raise ValueError(f"{primitive['mesh_path']}: has raw vpx vertex comments that would override new UVs")

    inv_width = 1.0 / (gamedata["right"] - gamedata["left"])
    inv_height = 1.0 / (gamedata["bottom"] - gamedata["top"])
    # vpxtool writes V flipped (obj_v = 1 - tv).
    uvs = iter(f"vt {fmt_uv(x * inv_width)} {fmt_uv(1.0 - y * inv_height)}" for x, y in table_vertices(primitive, vertices))
    new_lines = [next(uvs) if line.startswith("vt ") else line for line in lines]
    if next(uvs, None) is not None:
        raise ValueError(f"{primitive['mesh_path']}: fewer vt lines than vertices")
    changed = write_if_changed(primitive["mesh_path"], "\n".join(new_lines))

    json_path = primitive["mesh_path"].removesuffix(".obj") + ".json"
    with open(json_path) as f:
        text = f.read()
    text, count = re.subn(r'^(    "image": )"[^"]*"', rf'\1"{PLASTICS_IMAGE}"', text, count=1, flags=re.M)
    if count != 1:
        raise ValueError(f"{json_path}: no image field found")
    return write_if_changed(json_path, text) or changed


def fmt_uv(v):
    return f"{v:.7f}".rstrip("0").rstrip(".")


def write_if_changed(path, text):
    with open(path) as f:
        if f.read() == text:
            return False
    with open(path, "w") as f:
        f.write(text)
    return True


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


def to_svg(walls, primitives, gamedata, page_w, page_h, bleed):
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
    for primitive in primitives:
        name = primitive["name"]
        footprint = primitive_footprint(primitive)
        if footprint.is_empty:
            continue
        shape = scale(footprint, sx, sy, origin=(0, 0))
        shape = translate(shape, -gamedata["left"] * sx, -gamedata["top"] * sy)
        outlines.append(path_xml(f"vpx_outline_{name}", name, OUTLINE_STYLE, polygon_d(shape)))
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

    gamedata, walls, primitives = read_table(args.table)
    with open(args.svg, encoding="utf-8") as f:
        svg = f.read()

    page_w, page_h = page_size(svg)
    outlines, fills = to_svg(walls, primitives, gamedata, page_w, page_h, args.bleed)

    svg = replace_or_insert(
        svg, FILL_LAYER_ID, layer_xml(FILL_LAYER_ID, "vpx plastic fills", fills, locked=False), after_plastics_open_tag
    )
    svg = replace_or_insert(
        svg, OUTLINE_LAYER_ID, layer_xml(OUTLINE_LAYER_ID, "plastic outlines", outlines, locked=True), before_svg_close
    )

    with open(args.output or args.svg, "w", encoding="utf-8") as f:
        f.write(svg)
    print(f"{len(walls)} walls, {len(primitives)} primitives -> {args.output or args.svg}")

    for primitive in primitives:
        if update_primitive_files(primitive, gamedata):
            print(f"updated {primitive['name']}: image and table-space UVs (run `npm run assemble-vpx`)")


if __name__ == "__main__":
    main()
