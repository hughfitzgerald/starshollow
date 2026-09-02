#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = [
#   "lxml",
# ]
# ///

import argparse
import os
import shutil
import struct
import subprocess
import tempfile

from lxml import etree

filename = "playfield.svg"
output_path = "../starshollow/images/playfield.png"
insert_overlay_output_path = "../starshollow/images/playfield-insert-overlay.png"
plastics_output_path = "../starshollow/images/plastics.png"
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


def export(actions, output_path):
    inkscape(
        filename,
        f"--actions={actions}",
        "--export-type=png",
        f"--export-filename={output_path}",
        "--export-area-page",
        "--export-overwrite",
    )


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


parser_cli = argparse.ArgumentParser()
parser_cli.add_argument(
    "--no-mask",
    action="store_true",
    help="export playfield.png without clipping targets to the masks layer",
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

export(playfield_actions, output_path)
apply_grain_aging(output_path)

export(
    show_only_actions("insert text", "masks"),
    insert_overlay_output_path,
)

export(
    show_only_actions("plastics"),
    plastics_output_path,
)
