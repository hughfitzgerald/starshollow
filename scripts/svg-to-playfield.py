#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = [
#   "lxml",
#   "pillow",
# ]
# ///

import argparse
import os
import shutil
import struct
import subprocess
import tempfile

from lxml import etree
from PIL import Image

filename = "playfield.svg"
output_path = "../starshollow/images/playfield.webp"
insert_overlay_output_path = "../starshollow/images/playfield-insert-overlay.webp"
plastics_output_path = "../starshollow/images/plastics.webp"
apron_output_path = "../starshollow/images/ApronStarsHollow.webp"
NS = {
    "svg": "http://www.w3.org/2000/svg",
    "inkscape": "http://www.inkscape.org/namespaces/inkscape",
}

parser = etree.XMLParser(huge_tree=True)
tree = etree.parse(filename, parser=parser)


def layer_id(tree, label):
    xpath = f'//svg:g[@inkscape:groupmode="layer"][@inkscape:label="{label}"]'
    matches = tree.xpath(xpath, namespaces=NS)
    if not matches:
        raise ValueError(f"no layer labeled {label!r}")
    return matches[0].get("id")


def show_only_actions(*labels):
    ids = ",".join(layer_id(tree, label) for label in labels)
    return (
        f"select-all:layers;selection-hide;"
        f"select-clear;select-by-id:{ids};selection-unhide"
    )


def inkscape(*args):
    subprocess.run(
        [
            "/Applications/Inkscape.app/Contents/MacOS/inkscape",
            *args,
        ],
        check=True,
        env={"LC_ALL": "C.utf8", "LANG": "C.utf8"},
    )


def export(actions, output_path, grain_aging=False):
    """Render the page to a PNG with Inkscape, then save it as a lossless WebP."""
    with tempfile.TemporaryDirectory() as tmp:
        png_path = os.path.join(tmp, "export.png")
        inkscape(
            filename,
            f"--actions={actions}",
            "--export-type=png",
            f"--export-filename={png_path}",
            "--export-area-page",
            "--export-overwrite",
        )
        if grain_aging:
            apply_grain_aging(png_path)
        Image.open(png_path).save(output_path, lossless=True)


def png_size(path):
    """Pixel dimensions straight out of the PNG IHDR chunk."""
    with open(path, "rb") as f:
        header = f.read(24)
    if header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path} is not a PNG")
    return struct.unpack(">II", header[16:24])


# Print grain (fine noise, multiplied over the art) + warm aged-clearcoat tint.
# baseFrequency is in user units, and the wrapper below uses one user unit per
# exported pixel, so the grain stays the same size no matter the export scale.
GRAIN_AGING_SVG = """<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <filter id="photoGrainAging" x="-5%" y="-5%" width="110%" height="110%">
      <feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="3" seed="7" stitchTiles="stitch" result="noise"/>
      <feColorMatrix in="noise" type="matrix"
        values="0 0 0 0 0
                0 0 0 0 0
                0 0 0 0 0
                0.33 0.33 0.33 0 0" result="noiseAlpha"/>
      <feComponentTransfer in="noiseAlpha" result="grainAlpha">
        <feFuncA type="linear" slope="0.28" intercept="0"/>
      </feComponentTransfer>
      <feComposite in="grainAlpha" in2="SourceGraphic" operator="in" result="grainOnShape"/>
      <feBlend in="SourceGraphic" in2="grainOnShape" mode="multiply" result="grained"/>
      <feColorMatrix in="grained" type="matrix"
        values="1.08 0 0 0 0.04
                0 0.99 0 0 0.015
                0 0 0.82 0 -0.015
                0 0 0 1 0"/>
    </filter>
  </defs>
  <image xlink:href="{href}" x="0" y="0" width="{w}" height="{h}"
         image-rendering="optimizeQuality" filter="url(#photoGrainAging)"/>
</svg>
"""


def apply_grain_aging(png_path):
    """Re-render an exported PNG through the grain + aging filter, in place."""
    width, height = png_size(png_path)
    with tempfile.TemporaryDirectory() as tmp:
        source = os.path.join(tmp, "source.png")
        shutil.copyfile(png_path, source)
        wrapper = os.path.join(tmp, "grain.svg")
        with open(wrapper, "w") as f:
            f.write(GRAIN_AGING_SVG.format(w=width, h=height, href=source))
        inkscape(
            wrapper,
            "--export-type=png",
            f"--export-filename={png_path}",
            "--export-area-page",
            f"--export-width={width}",
            f"--export-height={height}",
            "--export-overwrite",
        )


# The apron layer holds ApronGenericWilliams.webp (1024x1024) placed as
# <image x=APRON_X y=APRON_Y width=height=APRON_SIZE transform="rotate(-90)">,
# i.e. turned 90 degrees counter-clockwise onto the page. Exporting that square
# and turning it back clockwise reproduces the texture layout VPX expects.
APRON_X = -1287.3503
APRON_Y = -7.7104774
APRON_SIZE = 446.35031
APRON_PIXELS = 1024
PX_PER_MM = 96 / 25.4  # --export-area takes px at 96 dpi, not document mm


def export_apron(output_path):
    area = (
        APRON_Y,
        -APRON_X - APRON_SIZE,
        APRON_Y + APRON_SIZE,
        -APRON_X,
    )
    with tempfile.TemporaryDirectory() as tmp:
        raw = os.path.join(tmp, "apron.png")
        inkscape(
            filename,
            f"--actions={show_only_actions('apron')}",
            "--export-type=png",
            f"--export-filename={raw}",
            "--export-area=" + ":".join(str(v * PX_PER_MM) for v in area),
            f"--export-width={APRON_PIXELS}",
            f"--export-height={APRON_PIXELS}",
            "--export-overwrite",
        )
        art = Image.open(raw).convert("RGBA").transpose(Image.Transpose.ROTATE_270)
    image = Image.new("RGBA", art.size, (0, 0, 0, 255))
    image.alpha_composite(art)
    image.convert("RGB").save(output_path, lossless=True)


parser_cli = argparse.ArgumentParser()
parser_cli.add_argument(
    "--no-mask",
    action="store_true",
    help="export playfield.webp without clipping targets to the masks layer",
)
args = parser_cli.parse_args()

masks_id = layer_id(tree, "masks")
targets_id = layer_id(tree, "targets")

masking_actions = (
    f"select-clear;select-by-id:{masks_id};duplicate;"
    f"select-clear;select-by-id:{masks_id};object-to-path;"
    f"select-clear;select-by-selector:#{masks_id} > *;path-union;"
    f"object-set-attribute:inkscape:label,masks;object-set-attribute:id,masks_path;"
    f"select-clear;select-by-id:masks_path,{targets_id};object-set-inverse-clip"
)

playfield_actions = show_only_actions("table decals", "targets")
if not args.no_mask:
    playfield_actions = f"{masking_actions};{playfield_actions}"

export(playfield_actions, output_path, grain_aging=True)

export(
    show_only_actions("insert text", "masks"),
    insert_overlay_output_path,
)

export(
    show_only_actions("plastics"),
    plastics_output_path,
)

export_apron(apron_output_path)
