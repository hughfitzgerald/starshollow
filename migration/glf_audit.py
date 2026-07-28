# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
glf_audit.py - read-only analysis of a vpxtool-extracted VPX table being
migrated from the VPW example-table structure to the GLF framework.

Reports:
  1. GLF hard-requirement checks (collections, timers, trough, globals)
  2. Object inventory by type
  3. Event-handler cross-reference (dead handlers, unhandled objects)
  4. Duplicate-handler risk (handlers GLF will auto-generate)
  5. Proposed GLF collection membership
  6. Script section map with line ranges

Nothing is modified. Run this before each migration step and again after.

Usage:
    uv run glf_audit.py --table ./MyTable
    uv run glf_audit.py --script ./script.vbs
    uv run glf_audit.py --table ./MyTable --json report.json
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

# --------------------------------------------------------------------------
# VBScript lexing helpers
# --------------------------------------------------------------------------

# Event suffixes VPX dispatches to script subs.
VPX_EVENTS = (
    "Hit", "UnHit", "Slingshot", "Spin", "Timer", "Collide",
    "Init", "Exit", "Paused", "UnPaused", "OptionEvent", "KeyDown", "KeyUp",
    "Animate", "MotionEvent", "LimitEOS", "LimitBOS",
)

_SUB_RE = re.compile(
    r"^[ \t]*(?:Public[ \t]+|Private[ \t]+)?(Sub|Function)[ \t]+"
    r"([A-Za-z_][A-Za-z0-9_]*)",
    re.IGNORECASE,
)
_END_RE = re.compile(r"^[ \t]*End[ \t]+(Sub|Function)\b", re.IGNORECASE)

# A section banner: a comment line of repeated punctuation, then the tag line.
_TAG_RE = re.compile(r"^[ \t]*'[ \t=]*\**[ \t]*(Z[A-Z]{3})[ \t]*:[ \t]*(.*?)[ \t=*]*$")
_RULE_RE = re.compile(r"^[ \t]*'[ \t]*[*\-=/#]{5,}")


def strip_comment(line: str) -> str:
    """Remove a trailing VBScript comment, respecting double-quoted strings."""
    out = []
    in_str = False
    i = 0
    while i < len(line):
        ch = line[i]
        if ch == '"':
            # "" inside a string is an escaped quote
            if in_str and i + 1 < len(line) and line[i + 1] == '"':
                out.append('""')
                i += 2
                continue
            in_str = not in_str
            out.append(ch)
        elif ch == "'" and not in_str:
            break
        else:
            out.append(ch)
        i += 1
    return "".join(out)


def string_spans(line: str) -> list[tuple[int, int]]:
    """Character spans of double-quoted string literals in a line."""
    spans: list[tuple[int, int]] = []
    start = None
    i = 0
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


@dataclass
class Procedure:
    kind: str          # "Sub" or "Function"
    name: str
    start: int         # 1-based
    end: int           # 1-based, inclusive
    one_line: bool


def find_procedures(lines: list[str]) -> list[Procedure]:
    """Locate every Sub/Function in a VBScript source. VBScript forbids nesting."""
    procs: list[Procedure] = []
    open_proc: Procedure | None = None
    for idx, raw in enumerate(lines, start=1):
        code = strip_comment(raw)
        if not code.strip():
            continue
        m = _SUB_RE.match(code)
        if m and open_proc is None:
            kind, name = m.group(1), m.group(2)
            # Single-line form: Sub X: ... : End Sub
            if _END_RE.search(code) or re.search(r":[ \t]*End[ \t]+(Sub|Function)\b",
                                                 code, re.IGNORECASE):
                procs.append(Procedure(kind, name, idx, idx, True))
            else:
                open_proc = Procedure(kind, name, idx, idx, False)
            continue
        if open_proc is not None and _END_RE.match(code):
            open_proc.end = idx
            procs.append(open_proc)
            open_proc = None
    if open_proc is not None:
        open_proc.end = len(lines)
        procs.append(open_proc)
    return procs


@dataclass
class Section:
    tag: str
    title: str
    start: int   # 1-based, first line of the banner
    end: int     # 1-based, inclusive


def find_sections(lines: list[str]) -> list[Section]:
    """Find ZXXX section banners, skipping the table-of-contents block."""
    hits: list[tuple[int, str, str]] = []
    for idx, raw in enumerate(lines, start=1):
        m = _TAG_RE.match(raw)
        if not m:
            continue
        # A real banner is preceded (within 2 lines, skipping blanks) by a rule
        # line, or is itself wrapped in '=== ... ===' style.
        prev = idx - 2
        is_banner = "===" in raw
        steps = 0
        while prev >= 0 and steps < 3:
            cand = lines[prev]
            if cand.strip():
                if _RULE_RE.match(cand):
                    is_banner = True
                break
            prev -= 1
            steps += 1
        if is_banner:
            hits.append((idx, m.group(1), m.group(2).strip()))

    sections: list[Section] = []
    for i, (line_no, tag, title) in enumerate(hits):
        # Back up over the banner's own rule/blank lines.
        start = line_no
        j = line_no - 2
        while j >= 0 and (_RULE_RE.match(lines[j]) or not lines[j].strip()):
            if _RULE_RE.match(lines[j]):
                start = j + 1
            j -= 1
        end = (hits[i + 1][0] - 1) if i + 1 < len(hits) else len(lines)
        # Trim to just before the next banner's rule line.
        if i + 1 < len(hits):
            k = hits[i + 1][0] - 2
            while k >= 0 and (_RULE_RE.match(lines[k]) or not lines[k].strip()):
                if _RULE_RE.match(lines[k]):
                    end = k
                k -= 1
        sections.append(Section(tag, title, start, end))
    return sections


# --------------------------------------------------------------------------
# Table loading
# --------------------------------------------------------------------------

@dataclass
class Table:
    root: Path | None = None
    objects: dict[str, str] = field(default_factory=dict)   # name -> type
    collections: dict[str, list[str]] = field(default_factory=dict)
    script_path: Path | None = None
    lines: list[str] = field(default_factory=list)


def load_table(table_dir: Path | None, script_path: Path | None) -> Table:
    t = Table(root=table_dir)

    if table_dir is not None:
        gi_dir = table_dir / "gameitems"
        if gi_dir.is_dir():
            for f in sorted(gi_dir.glob("*.json")):
                stem = f.stem                      # "Trigger.TriggerLF"
                if "." not in stem:
                    continue
                typ, name = stem.split(".", 1)
                t.objects[name] = typ
        else:
            print(f"warning: no gameitems/ under {table_dir}", file=sys.stderr)

        coll = table_dir / "collections.json"
        if not coll.is_file():
            print(f"warning: no collections.json under {table_dir} — collection-bound "
                  "handlers will be reported as dead", file=sys.stderr)
        if coll.is_file():
            for entry in json.loads(coll.read_text(encoding="utf-8")):
                t.collections[entry["name"]] = list(entry.get("items", []))

        if script_path is None:
            cand = table_dir / "script.vbs"
            if cand.is_file():
                script_path = cand

    if script_path is not None and script_path.is_file():
        t.script_path = script_path
        text = script_path.read_text(encoding="utf-8", errors="replace")
        t.lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")

    return t


# --------------------------------------------------------------------------
# Analysis
# --------------------------------------------------------------------------

# Objects GLF hardcodes by name; never rename, never put in collections.
GLF_RESERVED = {"Drain"} | {f"swTrough{i}" for i in range(1, 8)}

# Types that become GLF devices rather than plain collection switches.
DEVICE_TYPES = {"HitTarget", "Flipper", "Plunger"}

# Collections GLF iterates unconditionally at Glf_Init.
REQUIRED_COLLECTIONS = ["glf_lights", "glf_switches", "glf_slingshots", "glf_spinners"]

REQUIRED_TIMERS = {
    "Glf_GameTimer": "Enabled, Interval -1  (GLF's main dispatch loop)",
    "UpdateTroughTimer": "Interval 100, initially disabled (GLF trough)",
}


def analyse_handlers(t: Table) -> dict:
    """Match every VPX event handler in the script to a table object."""
    procs = find_procedures(t.lines)
    lower_objs = {n.lower(): n for n in t.objects}
    lower_colls = {c.lower(): c for c in t.collections}

    matched, coll_handlers, dead = [], [], []
    for p in procs:
        if "_" not in p.name:
            continue
        base, _, suffix = p.name.rpartition("_")
        if suffix.lower() not in {e.lower() for e in VPX_EVENTS}:
            continue
        if base.lower() in lower_objs:
            real = lower_objs[base.lower()]
            matched.append((real, t.objects[real], suffix, p))
        elif base.lower() in lower_colls:
            coll_handlers.append((lower_colls[base.lower()], suffix, p))
        elif base.lower() in {"table1", "flex"}:
            continue
        else:
            dead.append((base, suffix, p))
    return {"matched": matched, "collection": coll_handlers, "dead": dead,
            "procedures": procs}


def classify_objects(t: Table, handlers: dict) -> dict:
    """Propose GLF collection membership / device treatment per object."""
    by_handler: dict[str, set[str]] = {}
    for name, _typ, suffix, _p in handlers["matched"]:
        by_handler.setdefault(name, set()).add(suffix.lower())

    plan: dict[str, list[tuple[str, str]]] = {
        "glf_switches": [], "glf_slingshots": [], "glf_spinners": [],
        "glf_lights": [], "device": [], "reserved": [], "ignore": [],
    }

    for name, typ in sorted(t.objects.items(), key=lambda kv: (kv[1], kv[0].lower())):
        events = by_handler.get(name, set())
        if name in GLF_RESERVED:
            plan["reserved"].append((name, "GLF trough — do not rename or collect"))
        elif "slingshot" in events:
            plan["glf_slingshots"].append((name, f"{typ} with _Slingshot handler"))
        elif "spin" in events:
            plan["glf_spinners"].append((name, f"{typ} with _Spin handler"))
        elif typ == "HitTarget":
            plan["device"].append((name, "CreateGlfDroptarget / CreateGlfStanduptarget"))
        elif typ == "Flipper":
            plan["device"].append((name, "CreateGlfFlipper or CreateGlfDiverter"))
        elif typ == "Bumper":
            plan["glf_switches"].append((name, "+ CreateGlfAutoFireDevice"))
        elif typ == "Kicker":
            plan["glf_switches"].append((name, "+ CreateGlfBallDevice"))
        elif typ == "Trigger":
            if {"hit", "unhit"} & events:
                plan["glf_switches"].append((name, "Trigger with hit handler"))
            else:
                plan["ignore"].append((name, "Trigger, no handler — physics helper?"))
        elif typ == "Light":
            low = name.lower()
            if re.match(r"(bumper(big|small)light|flasherlight)", low):
                plan["ignore"].append(
                    (name, "Light — EXCLUDE from glf_lights (Flupper ZFLD/ZFLB owns it)"))
            elif low.startswith("gi"):
                plan["glf_lights"].append((name, "GI — drive with a show"))
            else:
                plan["glf_lights"].append((name, "insert"))
        elif typ == "Plunger":
            plan["ignore"].append((name, "mechanical plunger, handled in KeyDown/KeyUp"))
        else:
            plan["ignore"].append((name, typ))
    return plan


def check_requirements(t: Table) -> list[tuple[str, str, str]]:
    """Return (status, item, detail) triples. status in OK/MISSING/WARN/INFO."""
    out: list[tuple[str, str, str]] = []

    for c in REQUIRED_COLLECTIONS:
        if c in t.collections:
            out.append(("OK", c, f"{len(t.collections[c])} member(s)"))
        elif t.collections:
            out.append(("MISSING", c, "Glf_Init iterates this — create it, even if empty"))

    for timer, detail in REQUIRED_TIMERS.items():
        if not t.objects:
            break
        if timer in t.objects:
            out.append(("OK", timer, detail))
        else:
            out.append(("MISSING", timer, detail))

    if t.objects:
        troughs = sorted(n for n in t.objects if re.fullmatch(r"swTrough\d", n))
        out.append(("OK" if troughs else "MISSING", "trough kickers",
                    ", ".join(troughs) or "GLF requires swTrough1..N"))
        out.append(("OK" if "Drain" in t.objects else "MISSING", "Drain",
                    "GLF's Drain_Hit dispatches GLF_BALL_DRAIN"))

    if t.lines:
        src = "\n".join(t.lines)
        for const in ("cGameName", "BallSize", "BallMass", "tnob", "lob",
                      "tablewidth", "tableheight", "gBOT"):
            found = re.search(
                rf"^\s*(?:Const|Dim|Public|Private)\s+[^'\n]*?\b{const}\b",
                src, re.IGNORECASE | re.MULTILINE)
            out.append(("OK" if found else "MISSING", const,
                        "required global" if not found else ""))

        m = re.search(r"^\s*Const\s+tnob\s*=\s*(\d+)", src,
                      re.IGNORECASE | re.MULTILINE)
        if m and t.objects:
            n = int(m.group(1))
            troughs = [x for x in t.objects if re.fullmatch(r"swTrough\d", x)]
            if len(troughs) != n:
                out.append(("WARN", "tnob vs trough kickers",
                            f"tnob={n} but {len(troughs)} swTrough* objects; "
                            "glf_troughSize = tnob"))

        for hook, call in (("Table1_Init", "Glf_Init"),
                           ("Table1_Exit", "Glf_Exit"),
                           ("Table1_KeyDown", "Glf_KeyDown"),
                           ("Table1_KeyUp", "Glf_KeyUp"),
                           ("Table1_OptionEvent", "Glf_Options")):
            if re.search(rf"\b{call}\b", src):
                out.append(("OK", f"{hook} -> {call}", ""))
            else:
                out.append(("INFO", f"{hook} -> {call}", "not wired yet"))
        if not re.search(r"\bConfigureGlfDevices\b", src):
            out.append(("INFO", "ConfigureGlfDevices", "not defined yet"))
    return out


def duplicate_risk(t: Table, handlers: dict) -> list[tuple[str, str]]:
    """
    Handlers GLF will generate itself via ExecuteGlobal. Leaving these in the
    script causes a duplicate-procedure error at Glf_Init.
    """
    risky: list[tuple[str, str]] = []
    generated = {
        "glf_switches": ("Hit", "UnHit"),
        "glf_slingshots": ("Slingshot",),
        "glf_spinners": ("Spin",),
    }
    for coll, suffixes in generated.items():
        for member in t.collections.get(coll, []):
            for name, _typ, suffix, p in handlers["matched"]:
                if name.lower() == member.lower() and suffix in suffixes:
                    risky.append((p.name, f"in {coll}; GLF generates this "
                                          f"(line {p.start})"))
    for name in GLF_RESERVED:
        for hname, _typ, suffix, p in handlers["matched"]:
            if hname == name and suffix in ("Hit", "UnHit"):
                risky.append((p.name, f"GLF ships {name}_{suffix} "
                                      f"(line {p.start}) — delete yours"))
    return risky




# --------------------------------------------------------------------------
# Unresolved-reference check ("will this even load?")
# --------------------------------------------------------------------------

VBS_BUILTINS = set("""
abs array asc atn cbool cbyte ccur cdate cdbl chr cint clng conversion cos
createobject csng cstr date dateadd datediff datepart dateserial datevalue day
eval execute executeglobal exp filter fix formatcurrency formatdatetime
formatnumber formatpercent getlocale getobject getref hex hour inputbox instr
instrrev int isarray isdate isempty isnull isnumeric isobject join lbound lcase
left len loadpicture log ltrim mid minute month monthname msgbox now oct
randomize replace rgb right rnd round rtrim scriptengine second setlocale sgn
sin space split sqr strcomp string strreverse tan time timer timeserial
timevalue trim typename ubound ucase weekday weekdayname year vartype cdate
err scripting wscript nothing empty null true false vbcrlf vblf vbcr vbtab
vbwhite vbblack vbred vbgreen vbblue vbyellow vbmagenta vbcyan vbobjecterror
vbnewline vbnullstring pi me
""".split())

# Names VPX itself injects into script scope.
VPX_GLOBALS = set("""
gametime activeball table1 controller renderingmode disablestaticprerendering
nightday getplayer getballs getelements playsound stopsound playmusic
endmusic musicvolume nudge stopsound updatematerial updatematerialphysics
getmaterial getcustomparam getballs getelementbyname savevalue loadvalue
showdt showfss editormode version versionmajor versionminor versionrevision
userdirectory tablesdirectory musicdirectory pinmamedirectory
dof dofpulse dofon dofoff dofoff2 dofoff3 dofoff4 dofon2 dofoff5
leftflipperkey rightflipperkey leftmagnasave rightmagnasave plungerkey
startgamekey addcreditkey addcreditkey2 lefttiltkey righttiltkey centertiltkey
mechanicaltilt frameskey plungekey exitgamekey volumeupkey volumedownkey
lockbarkey stagedflipperkey lefttiltkey pausekey tweakkey
keyframe cor gbot
""".split())

_ASSIGN_RE = re.compile(r"^[ \t]*(?:Set[ \t]+)?([A-Za-z_][A-Za-z0-9_]*)[ \t]*=", re.I)
_DECL_RE = re.compile(
    r"^[ \t]*(?:Public[ \t]+|Private[ \t]+)?"
    r"(?:Dim|Const|ReDim(?:[ \t]+Preserve)?|Public|Private)[ \t]+(.+)$", re.I)
_CLASS_RE = re.compile(r"^[ \t]*Class[ \t]+([A-Za-z_][A-Za-z0-9_]*)", re.I)
_PROP_RE = re.compile(
    r"^[ \t]*(?:Public[ \t]+|Private[ \t]+)?Property[ \t]+"
    r"(?:Get|Let|Set)[ \t]+([A-Za-z_][A-Za-z0-9_]*)", re.I)
_IDENT_RE = re.compile(r"(?<![A-Za-z0-9_.])([A-Za-z_][A-Za-z0-9_]*)")


def collect_definitions(sources: list[tuple[str, list[str]]]) -> set[str]:
    """Every name a VBScript source brings into scope."""
    defined: set[str] = set()
    param_re = re.compile(
        r"^[ \t]*(?:Public[ \t]+|Private[ \t]+)?(?:Sub|Function|Property"
        r"[ \t]+(?:Get|Let|Set))[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*\(([^)]*)\)",
        re.IGNORECASE)
    for _label, lines in sources:
        for p in find_procedures(lines):
            defined.add(p.name.lower())
        # Procedure parameters are locals, not unresolved globals.
        for raw in lines:
            m = param_re.match(strip_comment(raw))
            if m:
                for part in m.group(1).split(","):
                    part = re.sub(r"\b(ByRef|ByVal)\b", "", part,
                                  flags=re.I).split("(")[0].strip()
                    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", part):
                        defined.add(part.lower())
        for raw in lines:
            code = strip_comment(raw)
            if not code.strip():
                continue
            m = _CLASS_RE.match(code)
            if m:
                defined.add(m.group(1).lower())
                continue
            m = _PROP_RE.match(code)
            if m:
                defined.add(m.group(1).lower())
                continue
            m = _DECL_RE.match(code)
            if m:
                rest = m.group(1)
                # Dim a, b(4), c : strip subscripts and initialisers
                rest = re.split(r"\bAs\b", rest, flags=re.I)[0]
                for part in rest.split(","):
                    # `Dim X : X = 1` and `Dim X(4)` and `Const Y = 2`
                    part = part.split(":")[0].split("=")[0].split("(")[0].strip()
                    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", part):
                        defined.add(part.lower())
    return defined


def collect_references(lines: list[str]) -> dict[str, int]:
    """Identifiers used in code, excluding member access and string literals."""
    refs: dict[str, int] = {}
    for raw in lines:
        code = strip_comment(raw)
        if not code.strip():
            continue
        spans = string_spans(code)
        # Skip declaration keywords' own operands - they are definitions.
        if _DECL_RE.match(code) or _CLASS_RE.match(code):
            continue
        for m in _IDENT_RE.finditer(code):
            if any(a <= m.start() < b for a, b in spans):
                continue
            name = m.group(1)
            refs[name.lower()] = refs.get(name.lower(), 0) + 1
    return refs


VBS_KEYWORDS = set("""
and byref byval call case class const dim do each else elseif end eqv erase
error execute exit explicit false for function get if imp in is let like loop
mod new next not nothing null on option or preserve private property public
redim rem resume select set step sub then to true until wend while with xor
goto by option
""".split())


def unresolved_report(sources: list[tuple[str, list[str]]],
                      objects: dict[str, str],
                      collections: dict[str, list[str]]) -> list[tuple[str, int]]:
    defined = collect_definitions(sources)
    known = (defined | VBS_BUILTINS | VBS_KEYWORDS | VPX_GLOBALS
             | {o.lower() for o in objects}
             | {c.lower() for c in collections})
    counts: dict[str, int] = {}
    for _label, lines in sources:
        for name, n in collect_references(lines).items():
            counts[name] = counts.get(name, 0) + n
    missing = {k: v for k, v in counts.items() if k not in known}
    return sorted(missing.items(), key=lambda kv: (-kv[1], kv[0]))


# --------------------------------------------------------------------------
# Reporting
# --------------------------------------------------------------------------

def hr(title: str) -> None:
    print(f"\n{'=' * 72}\n  {title}\n{'=' * 72}")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--table", type=Path, help="vpxtool-extracted table directory")
    ap.add_argument("--script", type=Path, help="script.vbs (defaults to <table>/script.vbs)")
    ap.add_argument("--json", type=Path, help="also write a machine-readable report")
    ap.add_argument("--scripts", type=Path, action="append", default=[],
                    help="split source tree (repeatable); enables the "
                         "unresolved-reference check")
    ap.add_argument("--glf", type=Path,
                    help="path to vpx-glf.vbs, so names it provides count as defined")
    ap.add_argument("--sections-only", action="store_true",
                    help="print just the section map (useful for building a split plan)")
    args = ap.parse_args()

    if not args.table and not args.script:
        ap.error("give --table and/or --script")

    t = load_table(args.table, args.script)
    if not t.lines and not t.objects:
        print("nothing loaded — check your paths", file=sys.stderr)
        return 2

    sections = find_sections(t.lines) if t.lines else []

    if args.sections_only:
        for s in sections:
            print(f"{s.tag}  {s.start:>6}-{s.end:<6} ({s.end - s.start + 1:>5} lines)  {s.title}")
        return 0

    handlers = analyse_handlers(t) if t.lines else {"matched": [], "collection": [],
                                                    "dead": [], "procedures": []}

    # 1. requirements
    hr("1. GLF hard-requirement checks")
    checks = check_requirements(t)
    if not checks:
        print("  (need --table for collection/object checks)")
    for status, item, detail in checks:
        mark = {"OK": "  ok  ", "MISSING": " MISS ", "WARN": " WARN ", "INFO": " info "}[status]
        print(f"[{mark}] {item:<34} {detail}")

    # 2. inventory
    if t.objects:
        hr("2. Object inventory")
        by_type: dict[str, list[str]] = {}
        for name, typ in t.objects.items():
            by_type.setdefault(typ, []).append(name)
        for typ in sorted(by_type, key=lambda k: (-len(by_type[k]), k)):
            names = sorted(by_type[typ], key=str.lower)
            shown = ", ".join(names) if len(names) <= 24 else \
                ", ".join(names[:24]) + f", ... (+{len(names) - 24})"
            print(f"{typ:<12} {len(names):>4}  {shown}")

    # 3. handler cross-reference
    if t.lines:
        hr("3. Event handlers")
        print(f"{len(handlers['procedures'])} procedures total, "
              f"{len(handlers['matched'])} bound to objects, "
              f"{len(handlers['collection'])} bound to collections, "
              f"{len(handlers['dead'])} unmatched")

        if handlers["dead"]:
            print("\n  DEAD HANDLERS (no such object or collection) — safe to delete:")
            for base, suffix, p in sorted(handlers["dead"], key=lambda x: x[2].start):
                print(f"    line {p.start:>5}-{p.end:<5}  {p.name}")

        if t.objects:
            handled = {n for n, _, _, _ in handlers["matched"]}
            interesting = {"Kicker", "Trigger", "HitTarget", "Bumper", "Flipper"}
            silent = sorted(n for n, typ in t.objects.items()
                            if typ in interesting and n not in handled)
            if silent:
                print("\n  OBJECTS WITH NO HANDLER (may need one under GLF):")
                for n in silent:
                    print(f"    {t.objects[n]:<10} {n}")

    # 4. duplicate risk
    if t.collections and t.lines:
        hr("4. Duplicate-handler risk")
        risky = duplicate_risk(t, handlers)
        if risky:
            print("  These will collide with GLF's ExecuteGlobal-generated subs:")
            for name, why in risky:
                print(f"    {name:<28} {why}")
        else:
            print("  none detected")

    # 5. collection plan
    if t.objects:
        hr("5. Proposed GLF classification")
        labels = {
            "glf_switches": "glf_switches   (GLF generates _Hit/_UnHit)",
            "glf_slingshots": "glf_slingshots (GLF generates _Slingshot)",
            "glf_spinners": "glf_spinners   (GLF generates _Spin)",
            "glf_lights": "glf_lights     (GLF blanks these at init!)",
            "device": "devices        (NOT in any collection)",
            "reserved": "reserved       (GLF-hardcoded names)",
        }
        plan = classify_objects(t, handlers)
        for key, label in labels.items():
            items = plan[key]
            if not items:
                continue
            print(f"\n  {label}  [{len(items)}]")
            for name, note in items[:40]:
                print(f"    {name:<26} {note}")
            if len(items) > 40:
                print(f"    ... (+{len(items) - 40} more)")

    # 6. section map
    if sections:
        hr("6. Script section map")
        for s in sections:
            print(f"  {s.tag}  {s.start:>6}-{s.end:<6} "
                  f"({s.end - s.start + 1:>5} lines)  {s.title}")

    # 7. unresolved references
    if args.scripts or t.lines:
        hr("7. Unresolved references (would this even load?)")
        sources: list[tuple[str, list[str]]] = []
        for spec in args.scripts:
            files = sorted(spec.rglob("*.vbs")) if spec.is_dir() else [spec]
            for f in files:
                sources.append((str(f), f.read_text(encoding="utf-8",
                                                    errors="replace")
                                .replace("\r\n", "\n").split("\n")))
        if not sources and t.lines:
            sources = [(str(t.script_path), t.lines)]
        if args.glf and args.glf.is_file():
            sources.append(("glf", args.glf.read_text(encoding="utf-8",
                                                      errors="replace")
                            .replace("\r\n", "\n").split("\n")))
            print(f"  (including {args.glf})")
        else:
            print("  (no --glf given: GLF-provided names will show as unresolved)")

        missing = unresolved_report(sources, t.objects, t.collections)
        if not missing:
            print("  nothing unresolved")
        else:
            print(f"  {len(missing)} name(s) referenced but never defined.")
            print("  VBScript resolves at runtime, so these are the things that")
            print("  will blow up at load or on first use, not at edit time.\n")
            for name, n in missing[:60]:
                print(f"    {n:>5}x  {name}")
            if len(missing) > 60:
                print(f"    ... (+{len(missing) - 60} more)")
            print("\n  Heuristic: VPX object properties, With-block members and")
            print("  late-bound COM members can produce false positives. Treat the")
            print("  high-count names as real.")

    if args.json:
        payload = {
            "objects": t.objects,
            "collections": {k: v for k, v in t.collections.items()},
            "sections": [{"tag": s.tag, "title": s.title,
                          "start": s.start, "end": s.end} for s in sections],
            "dead_handlers": [{"name": p.name, "start": p.start, "end": p.end}
                              for _b, _s, p in handlers["dead"]],
            "procedures": [{"name": p.name, "kind": p.kind,
                            "start": p.start, "end": p.end}
                           for p in handlers["procedures"]],
            "checks": [{"status": s, "item": i, "detail": d} for s, i, d in checks],
        }
        args.json.write_text(json.dumps(payload, indent=2), encoding="utf-8")
        print(f"\nwrote {args.json}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
