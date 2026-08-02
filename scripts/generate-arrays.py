#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = [
# ]
# ///

import json

with open("../starshollow/gameitems.json", "r") as f:
    gameitems = json.load(f)

insert_lights = [
    item["file_name"].split(".")[1]
    for item in gameitems
    if item["file_name"].startswith("Light.l")
]

insert_primitives = [
    item["file_name"].split(".")[1]
    for item in gameitems
    if item["file_name"].startswith("Primitive.p")
    and not item["file_name"].startswith("Primitive.ps")
    and item["file_name"][11].isdigit()
]

insert_primitive_ons = [item for item in insert_primitives if "off" not in item]
insert_primitive_offs = [item for item in insert_primitives if "off" in item]

lights_not_in_primitive_ons = [
    light for light in insert_lights if "p" + light[1:] not in insert_primitive_ons
]
lights_not_in_primitive_offs = [
    light
    for light in insert_lights
    if "p" + light[1:] + "off" not in insert_primitive_offs
]
primitive_ons_not_in_lights = [
    primitive
    for primitive in insert_primitive_ons
    if "l" + primitive[1:] not in insert_lights
]
primitive_offs_not_in_lights = [
    primitive
    for primitive in insert_primitive_offs
    if "l" + primitive[1:-3] not in insert_lights
]
primitive_ons_not_in_primitive_offs = [
    primitive
    for primitive in insert_primitive_ons
    if primitive + "off" not in insert_primitive_offs
]
primitive_offs_not_in_primitive_ons = [
    primitive
    for primitive in insert_primitive_offs
    if primitive[:-3] not in insert_primitive_ons
]
print(
    "Lights not in primitive ons:", lights_not_in_primitive_ons
) if lights_not_in_primitive_ons else None
print(
    "Lights not in primitive offs:", lights_not_in_primitive_offs
) if lights_not_in_primitive_offs else None
print(
    "Primitive ons not in lights:", primitive_ons_not_in_lights
) if primitive_ons_not_in_lights else None
print(
    "Primitive offs not in lights:", primitive_offs_not_in_lights
) if primitive_offs_not_in_lights else None
print(
    "Primitive ons not in primitive offs:", primitive_ons_not_in_primitive_offs
) if primitive_ons_not_in_primitive_offs else None
print(
    "Primitive offs not in primitive ons:", primitive_offs_not_in_primitive_ons
) if primitive_offs_not_in_primitive_ons else None

if (
    len(lights_not_in_primitive_ons) == 0
    and len(lights_not_in_primitive_offs) == 0
    and len(primitive_ons_not_in_lights) == 0
    and len(primitive_offs_not_in_lights) == 0
    and len(primitive_ons_not_in_primitive_offs) == 0
    and len(primitive_offs_not_in_primitive_ons) == 0
):
    print(f"GlfInsertLights = Array({', '.join([light for light in insert_lights])})")
    print(
        f"GlfInsertPrims  = Array({', '.join(['p' + light[1:] for light in insert_lights])})"
    )
