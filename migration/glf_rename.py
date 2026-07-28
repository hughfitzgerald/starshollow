# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
glf_rename.py - rename VPX objects consistently across a vpxtool-extracted
table and its scripts.

A rename touches five places, and missing any one of them produces a table
that loads but silently misbehaves:

  1. gameitems/<Type>.<Old>.json          -> gameitems/<Type>.<New>.json
  2. the "name" field inside that file
  3. gameitems.json                        (the ordered file index)
  4. collections.json                       (membership lists)
  5. cross-references in other gameitems    (e.g. a primitive's "surface")
  6. every identifier in the .vbs sources

Identifier matching is case-insensitive (VBScript is) and boundary-aware:
renaming `sw11` will not touch `sw11o`, `psw11`, or `sw110`. By default it
will rewrite `sw11_Timer` -> `s_ST11_Timer` (a trailing underscore is treated
as part of the same identifier); pass --no-suffix to disable that.

String literals are reported but NOT rewritten unless you pass --strings.

Usage:
    uv run glf_rename.py --init-map renames.toml --table ./MyTable
    $EDITOR renames.toml
    uv run glf_rename.py --map renames.toml --table ./MyTable \
                         --scripts scripts/src --dry-run
    uv run glf_rename.py --map renames.toml --table ./MyTable \
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

# GLF hardcodes these names in vpx-glf.vbs. Renaming them breaks the trough.
PROTECTED = {"Drain", "Table1"} | {f"swTrough{i}" for i in range(1, 8)}

# Suggested prefix conventions, matching the GLF example table.
SUGGEST = [
    (re.compile(r"^Bumper(\d+)$", re.I), r"s_Bumper\1"),
    (re.compile(r"^(Left|Right)SlingShot$", re.I), r"s_\1Slingshot"),
    (re.compile(r"^(Left|Right)Inlane$", re.I), r"s_\1Inlane"),
    (re.compile(r"^VUK(\d*)$", re.I), r"s_VUK\1"),
    (re.compile(r"^Kicker(\d+)$", re.I), r"s_Kicker\1"),
]


def ident_pattern(name: str, allow_suffix: bool) -> re.Pattern[str]:
    tail = r"(?![A-Za-z0-9])" if allow_suffix else r"(?![A-Za-z0-9_])"
    return re.compile(r"(?<![A-Za-z0-9_])" + re.escape(name) + tail, re.IGNORECASE)


def string_spans(line: str) -> list[tuple[int, int]]:
    spans, start, i = [], None, 0
    while i < len(line):
        if line[i] == '"':
            if start is None:
                start = i
            elif i + 1 < len(line) and line[i + 1] == '"':
                i += 2
                continue
            else:
                spans.append((start, i + 1))
                start = None
        i += 1
    if start is not None:
        spans.append((start, len(line)))
    return spans


def in_string(pos: int, spans: list[tuple[int, int]]) -> bool:
    return any(a <= pos < b for a, b in spans)


# --------------------------------------------------------------------------

def load_objects(table: Path) -> dict[str, str]:
    objs: dict[str, str] = {}
    gi = table / "gameitems"
    if not gi.is_dir():
        raise SystemExit(f"no gameitems/ under {table}")
    for f in sorted(gi.glob("*.json")):
        if "." in f.stem:
            typ, name = f.stem.split(".", 1)
            objs[name] = typ
    return objs


def write_init_map(path: Path, objs: dict[str, str]) -> None:
    lines = [
        "# VPX object renames for the GLF migration.",
        "# Left = current name, right = new name. Delete lines you don't want.",
        "# Names GLF hardcodes (Drain, swTrough1..7) are omitted deliberately.",
        "#",
        "# Convention from the GLF example table: switch-bearing objects get an",
        "# `s_` prefix, because their names become event-name string literals",
        "# throughout your mode configs (s_Bumper1 -> \"s_Bumper1_active\").",
        "",
        "[renames]",
    ]
    suggested, other = [], []
    for name, typ in sorted(objs.items(), key=lambda kv: (kv[1], kv[0].lower())):
        if name in PROTECTED:
            continue
        for pat, repl in SUGGEST:
            if pat.match(name):
                suggested.append(f'{name} = "{pat.sub(repl, name)}"   # {typ}')
                break
        else:
            if typ in ("HitTarget",):
                other.append(f'# {name} = "s_ST{name.lstrip("swST")}"   # {typ}')
            elif typ in ("Trigger", "Kicker"):
                other.append(f'# {name} = "s_{name}"   # {typ}')
    lines += suggested
    if other:
        lines += ["", "# Candidates — uncomment and adjust:"] + other
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


# --------------------------------------------------------------------------

def rewrite_json_value(obj, old: str, new: str, counter: list[int]):
    """Replace exact-match string values (case-insensitive) throughout a JSON tree."""
    if isinstance(obj, dict):
        return {k: rewrite_json_value(v, old, new, counter) for k, v in obj.items()}
    if isinstance(obj, list):
        return [rewrite_json_value(v, old, new, counter) for v in obj]
    if isinstance(obj, str) and obj.lower() == old.lower():
        counter[0] += 1
        return new
    return obj


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--table", type=Path, required=True)
    ap.add_argument("--map", type=Path, help="TOML rename map")
    ap.add_argument("--init-map", type=Path, help="write a suggested map and exit")
    ap.add_argument("--scripts", type=Path, action="append", default=[],
                    help="a .vbs file or a directory to recurse (repeatable)")
    ap.add_argument("--strings", action="store_true",
                    help="also rewrite matches inside string literals")
    ap.add_argument("--no-suffix", action="store_true",
                    help="do not match Old_Something (default: do)")
    ap.add_argument("--apply", action="store_true", help="write changes")
    ap.add_argument("--dry-run", action="store_true", help="explicit no-op (default)")
    args = ap.parse_args()

    objs = load_objects(args.table)

    if args.init_map:
        write_init_map(args.init_map, objs)
        print(f"wrote {args.init_map}  ({len(objs)} objects scanned)")
        return 0
    if not args.map:
        ap.error("give --map (or --init-map to generate one)")

    renames: dict[str, str] = tomllib.loads(
        args.map.read_text(encoding="utf-8")).get("renames", {})
    if not renames:
        print("rename map is empty", file=sys.stderr)
        return 1

    # ---- validate --------------------------------------------------------
    problems = []
    lower_objs = {n.lower(): n for n in objs}
    for old, new in renames.items():
        if old in PROTECTED:
            problems.append(f"{old}: GLF hardcodes this name — do not rename")
        if old.lower() not in lower_objs:
            problems.append(f"{old}: no such object in {args.table}/gameitems")
        if new.lower() in lower_objs and new.lower() != old.lower():
            problems.append(f"{new}: an object with this name already exists")
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", new):
            problems.append(f"{new}: not a valid VBScript identifier")
    seen: dict[str, str] = {}
    for old, new in renames.items():
        if new.lower() in seen:
            problems.append(f"{new}: target used twice ({seen[new.lower()]}, {old})")
        seen[new.lower()] = old
    if problems:
        print("REFUSING TO RUN:", file=sys.stderr)
        for p in problems:
            print(f"  {p}", file=sys.stderr)
        return 2

    apply = args.apply and not args.dry_run
    mode = "APPLYING" if apply else "DRY RUN"
    print(f"[{mode}] {len(renames)} rename(s)\n")

    # ---- 1/2. gameitem files --------------------------------------------
    gi = args.table / "gameitems"
    file_moves: list[tuple[Path, Path]] = []
    for old, new in renames.items():
        typ = objs[lower_objs[old.lower()]]
        src = gi / f"{typ}.{lower_objs[old.lower()]}.json"
        dst = gi / f"{typ}.{new}.json"
        if not src.is_file():
            print(f"  ! missing {src}", file=sys.stderr)
            continue
        file_moves.append((src, dst))
        data = json.loads(src.read_text(encoding="utf-8"))
        if typ in data and isinstance(data[typ], dict):
            data[typ]["name"] = new
        print(f"  gameitem  {src.name} -> {dst.name}  (name field updated)")
        if apply:
            dst.write_text(json.dumps(data, indent=2), encoding="utf-8")
            if dst != src:
                src.unlink()

    # ---- 3. gameitems.json index ----------------------------------------
    idx_path = args.table / "gameitems.json"
    if idx_path.is_file():
        idx = json.loads(idx_path.read_text(encoding="utf-8"))
        changed = 0
        for entry in idx:
            fn = entry.get("file_name", "")
            if "." not in fn:
                continue
            typ, rest = fn.split(".", 1)
            name = rest.removesuffix(".json")
            for old, new in renames.items():
                if name.lower() == old.lower():
                    entry["file_name"] = f"{typ}.{new}.json"
                    changed += 1
        print(f"\n  gameitems.json: {changed} index entr(ies) updated")
        if apply and changed:
            idx_path.write_text(json.dumps(idx, indent=2), encoding="utf-8")

    # ---- 4. collections.json --------------------------------------------
    coll_path = args.table / "collections.json"
    if coll_path.is_file():
        colls = json.loads(coll_path.read_text(encoding="utf-8"))
        changed = 0
        for c in colls:
            items = c.get("items", [])
            for i, item in enumerate(items):
                for old, new in renames.items():
                    if item.lower() == old.lower():
                        items[i] = new
                        changed += 1
                        print(f"  collection {c['name']}: {old} -> {new}")
        if apply and changed:
            coll_path.write_text(json.dumps(colls, indent=2), encoding="utf-8")
        print(f"  collections.json: {changed} membership entr(ies) updated")

    # ---- 5. cross-references in other gameitems -------------------------
    xref_total = 0
    for f in sorted(gi.glob("*.json")):
        if any(f == src for src, _ in file_moves):
            continue
        raw = f.read_text(encoding="utf-8")
        data = json.loads(raw)
        counter = [0]
        for old, new in renames.items():
            data = rewrite_json_value(data, old, new, counter)
        if counter[0]:
            xref_total += counter[0]
            print(f"  xref      {f.name}: {counter[0]} reference(s)")
            if apply:
                f.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(f"  gameitem cross-references: {xref_total}")

    # ---- 6. scripts ------------------------------------------------------
    targets: list[Path] = []
    for s in args.scripts:
        if s.is_dir():
            targets += sorted(s.rglob("*.vbs"))
        elif s.is_file():
            targets.append(s)
    if not targets:
        print("\n  (no --scripts given; source not touched)")

    pats = {old: (ident_pattern(old, not args.no_suffix), new)
            for old, new in renames.items()}
    total_code = total_str = 0
    for path in targets:
        text = path.read_text(encoding="utf-8", errors="replace")
        newline = "\r\n" if "\r\n" in text else "\n"
        lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")
        code_hits = str_hits = 0
        out_lines = []
        for lineno, line in enumerate(lines, 1):
            spans = string_spans(line)
            def sub(m: re.Match, _new=None):
                nonlocal code_hits, str_hits
                if in_string(m.start(), spans):
                    str_hits += 1
                    if not args.strings:
                        return m.group(0)
                else:
                    code_hits += 1
                return _new
            for old, (pat, new) in pats.items():
                line = pat.sub(lambda m, n=new: sub(m, n), line)
            out_lines.append(line)
        if code_hits or str_hits:
            total_code += code_hits
            total_str += str_hits
            note = "" if args.strings else " (strings left alone)"
            print(f"  script    {path}: {code_hits} in code, "
                  f"{str_hits} in strings{note}")
            if apply:
                backup = path.with_suffix(path.suffix + ".bak")
                if not backup.exists():
                    shutil.copy2(path, backup)
                path.write_text(newline.join(out_lines), encoding="utf-8", newline="")
    if targets:
        print(f"  script identifiers: {total_code} in code, {total_str} in strings")

    if not apply:
        print("\nDry run — nothing written. Re-run with --apply.")
    else:
        print("\nApplied. Run `vpxtool assemble` and then glf_audit.py to verify.")
        if total_str and not args.strings:
            print("Note: string-literal occurrences were left alone. If those are "
                  "event names or config keys, re-run with --strings.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
