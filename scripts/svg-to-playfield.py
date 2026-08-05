#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = [
#   "lxml",
# ]
# ///

import subprocess

from lxml import etree

filename = "playfield.svg"
output_path = "../starshollow/images/playfield.png"
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


masks_id = layer_id(tree, "masks")
targets_id = layer_id(tree, "targets")

actions = (
    f"select-clear;select-by-id:{masks_id};duplicate;"
    f"select-clear;select-by-id:{masks_id};object-to-path;"
    f"select-clear;select-by-selector:#{masks_id} > *;path-union;"
    f"object-set-attribute:inkscape:label,masks;object-set-attribute:id,masks_path;"
    f"select-clear;select-by-id:masks_path,{targets_id};object-set-inverse-clip"
)

subprocess.run(
    [
        "/Applications/Inkscape.app/Contents/MacOS/inkscape",
        filename,
        f"--actions={actions}",
        "--export-type=png",
        f"--export-filename={output_path}",
        "--export-area-page",
        "--export-overwrite",
    ],
    check=True,
    env={"LC_ALL": "C.utf8", "LANG": "C.utf8"},
)
