# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
glf_collections.py - create and populate the four collections GLF requires
(glf_lights, glf_switches, glf_slingshots, glf_spinners) in a vpxtool-extracted
collections.json.

Membership is not cosmetic. At Glf_Init the framework:
  - generates <name>_Hit / <name>_UnHit for every glf_switches member
  - generates <name>_Slingshot for every glf_slingshots member
  - generates <name>_Spin for every glf_spinners member
  - forces every glf_lights member to 000000

So an object in the wrong collection either collides with a hand-written
handler, or goes permanently dark. This tool refuses to add a member that
still has a conflicting handler in your sources.

Usage:
    uv run glf_collections.py --table ./MyTable --init-plan collections.toml
    $EDITOR collections.toml
    uv run glf_collections.py --table ./MyTable --plan collections.toml \
                              --scripts scripts/src --dry-run
    uv run glf_collections.py --table ./MyTable --plan collections.toml \
                              --scripts scripts/src --apply
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
import tomllib
from pathlib import Path

GLF_COLLECTIONS = ["glf_lights", "glf_switches", "glf_slingshots", "glf_spinners"]

GENERATED_SUFFIX = {
    "glf_switches": ("Hit", "UnHit"),
    "glf_slingshots": ("Slingshot",),
    "glf_spinners": ("Spin",),
    "glf_lights": (),
}

# Never collect these: GLF hardcodes them, or another subsystem owns them.
NEVER_COLLECT = re.compile(
    r"^(swTrough\d|Drain|Table1|"
    r"bumper(big|small)light\d*|Flasherlight\d*|"          # Flupper-owned lights
    r"TriggerLF|TriggerRF|debug.*|Plunger)$",
    re.I,
)

_SUB_RE = re.compile(
    r"^[ \t]*(?:Public[ \t]+|Private[ \t]+)?(?:Sub|Function)[ \t]+"
    r"([A-Za-z_][A-Za-z0-9_]*)", re.IGNORECASE)


def load_objects(table: Path) -> dict[str, str]:
    gi = table / "gameitems"
    if not gi.is_dir():
        raise SystemExit(f"no gameitems/ under {table}")
    out = {}
    for f in sorted(gi.glob("*.json")):
        if "." in f.stem:
            typ, name = f.stem.split(".", 1)
            out[name] = typ
    return out


def script_procedures(paths: list[Path]) -> dict[str, Path]:
    found: dict[str, Path] = {}
    for p in paths:
        files = sorted(p.rglob("*.vbs")) if p.is_dir() else [p]
        for f in files:
            for line in f.read_text(encoding="utf-8", errors="replace").splitlines():
                m = _SUB_RE.match(line)
                if m:
                    found.setdefault(m.group(1).lower(), f)
    return found


def write_init_plan(path: Path, objs: dict[str, str]) -> None:
    """Draft membership from object types. Everything is reviewable."""
    switches, slings, spinners, lights, excluded = [], [], [], [], []
    for name, typ in sorted(objs.items(), key=lambda kv: (kv[1], kv[0].lower())):
        if NEVER_COLLECT.match(name):
            excluded.append(f"# {name}  ({typ}) — excluded by default")
            continue
        if typ == "Light":
            lights.append(name)
        elif typ == "Bumper":
            switches.append(name)
        elif typ == "Kicker":
            switches.append(name)
        elif typ == "Trigger":
            switches.append(name)
        elif typ == "Wall" and re.search(r"sling", name, re.I):
            slings.append(name)

    def block(title: str, names: list[str], note: str) -> list[str]:
        out = [f"# {note}", f"{title} = ["]
        out += [f'    "{n}",' for n in names]
        out += ["]", ""]
        return out

    lines = [
        "# GLF collection membership.",
        "# Review every line. Getting these wrong is the single most common",
        "# source of confusing GLF behaviour.",
        "",
        "[collections]",
        "",
    ]
    lines += block("glf_switches", switches,
                   "GLF generates <name>_Hit and <name>_UnHit for each of these. "
                   "Delete your own handlers first.")
    lines += block("glf_slingshots", slings,
                   "GLF generates <name>_Slingshot for each of these.")
    lines += block("glf_spinners", spinners,
                   "GLF generates <name>_Spin. Must exist even when empty.")
    lines += block("glf_lights", lights,
                   "GLF forces each of these to 000000 at init and drives them "
                   "via shows. Do NOT add Flupper dome/bumper lights.")
    if excluded:
        lines += ["", "# Excluded by default (uncomment to override):"] + excluded
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--table", type=Path, required=True)
    ap.add_argument("--plan", type=Path)
    ap.add_argument("--init-plan", type=Path)
    ap.add_argument("--scripts", type=Path, action="append", default=[],
                    help="source tree to check for conflicting handlers")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    objs = load_objects(args.table)

    if args.init_plan:
        write_init_plan(args.init_plan, objs)
        print(f"wrote {args.init_plan}")
        print("  review it carefully, then run with --plan")
        return 0
    if not args.plan:
        ap.error("give --plan (or --init-plan)")

    plan = tomllib.loads(args.plan.read_text(encoding="utf-8")).get("collections", {})
    procs = script_procedures(args.scripts) if args.scripts else {}

    # ---- validate --------------------------------------------------------
    errors, warnings = [], []
    lower_objs = {n.lower(): n for n in objs}
    for coll in GLF_COLLECTIONS:
        for member in plan.get(coll, []):
            if member.lower() not in lower_objs:
                errors.append(f"{coll}: no object named {member}")
                continue
            if NEVER_COLLECT.match(member):
                warnings.append(f"{coll}: {member} is normally excluded — "
                                "GLF or Flupper owns it")
            for suffix in GENERATED_SUFFIX[coll]:
                key = f"{member}_{suffix}".lower()
                if key in procs:
                    errors.append(
                        f"{coll}: {member} still has {member}_{suffix} in "
                        f"{procs[key]} — GLF generates that sub, so this would "
                        "be a duplicate-procedure error at Glf_Init")
    # membership overlap
    seen: dict[str, str] = {}
    for coll in GLF_COLLECTIONS:
        for member in plan.get(coll, []):
            if member.lower() in seen and seen[member.lower()] != coll:
                errors.append(f"{member} is in both {seen[member.lower()]} "
                              f"and {coll}")
            seen[member.lower()] = coll

    for w in warnings:
        print(f"  warn: {w}", file=sys.stderr)
    if errors:
        print("\nREFUSING TO RUN:", file=sys.stderr)
        for e in errors:
            print(f"  {e}", file=sys.stderr)
        return 2

    # ---- merge into collections.json ------------------------------------
    coll_path = args.table / "collections.json"
    colls = json.loads(coll_path.read_text(encoding="utf-8")) \
        if coll_path.is_file() else []
    by_name = {c["name"]: c for c in colls}

    apply = args.apply and not args.dry_run
    print(f"[{'APPLYING' if apply else 'DRY RUN'}]\n")

    for coll in GLF_COLLECTIONS:
        members = list(dict.fromkeys(plan.get(coll, [])))   # de-dup, keep order
        members = [lower_objs[m.lower()] for m in members]
        if coll in by_name:
            before = by_name[coll].get("items", [])
            action = "update" if before != members else "unchanged"
            by_name[coll]["items"] = members
        else:
            action = "create"
            entry = {"name": coll, "items": members,
                     "fire_events": False, "stop_single_events": False,
                     "group_elements": False}
            colls.append(entry)
            by_name[coll] = entry
        print(f"  {action:<9} {coll:<16} {len(members):>3} member(s)")
        if members and len(members) <= 12:
            print(f"            {', '.join(members)}")

    if apply:
        if coll_path.is_file():
            backup = coll_path.with_suffix(".json.bak")
            if not backup.exists():
                shutil.copy2(coll_path, backup)
        coll_path.write_text(json.dumps(colls, indent=2), encoding="utf-8")
        print(f"\nwrote {coll_path}")
        print("Now run `vpxtool assemble` and re-run glf_audit.py.")
    else:
        print("\nDry run — nothing written. Re-run with --apply.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
