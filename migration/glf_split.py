# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
glf_split.py - split a monolithic VPW-style script.vbs into the GLF example
project layout (scripts/src/vpx/NN_ZXXX_Name.vbs), driven by a TOML plan.

Also strips dead Subs/Functions before splitting, so you delete once rather
than hunting the same handler across several output files.

Workflow:
    uv run glf_audit.py --table ./MyTable --sections-only   # see what's there
    uv run glf_split.py --init-plan migration.toml \
                        --script ./MyTable/script.vbs       # generate a draft plan
    $EDITOR migration.toml                                   # set keep/delete
    uv run glf_split.py --plan migration.toml --script ./MyTable/script.vbs \
                        --out scripts/src/vpx --dry-run
    uv run glf_split.py --plan migration.toml --script ./MyTable/script.vbs \
                        --out scripts/src/vpx

The plan is the record of what you decided and why. Keep it in git.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

# --------------------------------------------------------------------------
# Shared lexing (kept in sync with glf_audit.py)
# --------------------------------------------------------------------------

_SUB_RE = re.compile(
    r"^[ \t]*(?:Public[ \t]+|Private[ \t]+)?(Sub|Function)[ \t]+"
    r"([A-Za-z_][A-Za-z0-9_]*)",
    re.IGNORECASE,
)
_END_RE = re.compile(r"^[ \t]*End[ \t]+(Sub|Function)\b", re.IGNORECASE)
_TAG_RE = re.compile(r"^[ \t]*'[ \t=]*\**[ \t]*(Z[A-Z]{3})[ \t]*:[ \t]*(.*?)[ \t=*]*$")
_RULE_RE = re.compile(r"^[ \t]*'[ \t]*[*\-=/#]{5,}")


def strip_comment(line: str) -> str:
    out, in_str, i = [], False, 0
    while i < len(line):
        ch = line[i]
        if ch == '"':
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


@dataclass
class Procedure:
    kind: str
    name: str
    start: int
    end: int


def find_procedures(lines: list[str]) -> list[Procedure]:
    procs: list[Procedure] = []
    open_proc: Procedure | None = None
    for idx, raw in enumerate(lines, start=1):
        code = strip_comment(raw)
        if not code.strip():
            continue
        m = _SUB_RE.match(code)
        if m and open_proc is None:
            kind, name = m.group(1), m.group(2)
            if _END_RE.search(code) or re.search(
                    r":[ \t]*End[ \t]+(Sub|Function)\b", code, re.IGNORECASE):
                procs.append(Procedure(kind, name, idx, idx))
            else:
                open_proc = Procedure(kind, name, idx, idx)
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
    start: int
    end: int


def find_sections(lines: list[str]) -> list[Section]:
    hits: list[tuple[int, str, str]] = []
    for idx, raw in enumerate(lines, start=1):
        m = _TAG_RE.match(raw)
        if not m:
            continue
        is_banner = "===" in raw
        prev, steps = idx - 2, 0
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
        start, j = line_no, line_no - 2
        while j >= 0 and (_RULE_RE.match(lines[j]) or not lines[j].strip()):
            if _RULE_RE.match(lines[j]):
                start = j + 1
            j -= 1
        end = (hits[i + 1][0] - 1) if i + 1 < len(hits) else len(lines)
        if i + 1 < len(hits):
            k = hits[i + 1][0] - 2
            while k >= 0 and (_RULE_RE.match(lines[k]) or not lines[k].strip()):
                if _RULE_RE.match(lines[k]):
                    end = k
                k -= 1
        sections.append(Section(tag, title, start, end))
    return sections


# --------------------------------------------------------------------------
# Default plan for a VPW-example-derived, non-ROM table moving to GLF
# --------------------------------------------------------------------------

# action: keep | delete | rewrite   (rewrite == keep, but flagged as needing work)
DEFAULT_ACTIONS: dict[str, tuple[str, str]] = {
    "ZTUT": ("rewrite", "mostly tutorial links, BUT in most VPW tables this block "
             "also holds Option Explicit / Randomize / the controller.vbs load — "
             "keep those, delete the link list"),
    "ZOPT": ("rewrite", "add Glf_Options(eventId) inside Table1_OptionEvent"),
    "ZCON": ("rewrite", "drop BIP/BIPL/PlayerScore/queue; keep GLF-required globals"),
    "ZDMD": ("rewrite", "GLF has no FlexDMD scene support — rewire data sources"),
    "ZTIM": ("rewrite", "drop queue.Tick; keep FrameTimer/CorTimer"),
    "ZINI": ("rewrite", "ConfigureGlfDevices() + Glf_Init(Table1); drop trough ball creation"),
    "ZMAT": ("keep", ""),
    "ZANI": ("keep", ""),
    "ZDRN": ("delete", "GLF ships the trough (swTrough*_Hit, Drain_Hit, UpdateTrough)"),
    "ZSCR": ("delete", "GLF player vars + score_NNNN events"),
    "ZKEY": ("rewrite", "Glf_KeyDown/Glf_KeyUp own flippers and nudge"),
    "ZFLP": ("rewrite", "bodies keep; entry points become ActionCallback(Enabled)"),
    "ZBMP": ("rewrite", "KEEP the Bumper*_Timer animation subs (they become "
             "ActionCallback bodies); delete Bumper*_Hit — GLF generates those"),
    "ZGII": ("rewrite", "GI moves to glf_lights + a show; check GITimer_Timer first"),
    "ZSLG": ("rewrite", "callbacks take args(); use args(1) not ActiveBall"),
    "ZKIC": ("rewrite", "CreateGlfBallDevice + EjectCallback(ball)"),
    "ZTRI": ("rewrite", "KEEP leftInlaneSpeedLimit/rightInlaneSpeedLimit and any ramp "
             "sound helpers; delete the _Hit subs — GLF generates those"),
    "ZTAR": ("rewrite", "KEEP the sw##o_Hit TargetBouncer subs; delete sw##_Hit — "
             "GLF generates those from the target device config"),
    "ZSOL": ("rewrite", "diverter/knocker become ActionCallback(Enabled)"),
    "ZLIS": ("delete", "ROM listener — GLF is the ROM"),
    "ZSHA": ("keep", ""),
    "ZPHY": ("delete", "comments only"),
    "ZNFF": ("keep", "merge into the ZFLP output file"),
    "ZDMP": ("keep", ""),
    "ZBOU": ("keep", "merge into the ZDMP output file"),
    "ZSSC": ("keep", "merge into the ZSLG output file"),
    "ZRDT": ("delete", "no drop targets on this table; restore from GLF example if added"),
    "ZRST": ("rewrite", "keep Roth code; strip scoring out of STHit"),
    "ZBRL": ("keep", ""),
    "ZRRL": ("keep", ""),
    "ZFLE": ("keep", ""),
    "ZFLD": ("keep", ""),
    "ZFLB": ("keep", "GLF example dropped this; no conflict, keep it"),
    "ZTST": ("delete", "debug shot tester"),
    "ZQUE": ("delete", "GLF SetDelay / GlfTimer replace vpwQueueManager"),
    "ZLOG": ("delete", "glf_debugLog"),
    "ZCRD": ("delete", "instruction card zoom"),
    "ZVRR": ("rewrite", "restructure as InitVR() + SetupRoom() per the GLF example"),
    "ZVRS": ("keep", ""),
}

# Sections merged into another section's output file.
DEFAULT_MERGE = {"ZNFF": "ZFLP", "ZBOU": "ZDMP", "ZSSC": "ZSLG"}

# Output ordering mirrors the GLF example table.
DEFAULT_ORDER = ["ZPRE", "ZTUT", "ZCON", "ZOPT", "ZTIM", "ZINI", "ZKEY", "ZMAT", "ZANI", "ZFLP",
                 "ZSLG", "ZBMP", "ZDMP", "ZSOL", "ZKIC", "ZTRI", "ZTAR", "ZRDT",
                 "ZRST", "ZSHA", "ZBRL", "ZRRL", "ZFLE", "ZFLD", "ZFLB", "ZGII",
                 "ZVRS", "ZVRR", "ZDMD"]

SLUG = {
    "ZPRE": "Preamble", "ZTUT": "Header",
    "ZCON": "Constants_and_Global_Variables", "ZOPT": "User_Options",
    "ZTIM": "Timers", "ZINI": "Table_Initialization_and_Exiting",
    "ZKEY": "Key_Press_Handling", "ZMAT": "General_Math_Functions",
    "ZANI": "Misc_Animations", "ZFLP": "Flippers", "ZSLG": "Slingshots",
    "ZDMP": "Rubber_Dampeners", "ZSOL": "Other_Solenoids", "ZKIC": "Kickers",
    "ZRDT": "Drop_Targets", "ZRST": "Standup_Targets",
    "ZSHA": "Ambient_Ball_Shadows", "ZBRL": "Ball_Rolling_Sounds",
    "ZRRL": "Ramp_Rolling_Sounds", "ZFLE": "Fleep_Mechanical_Sounds",
    "ZFLD": "Flupper_Domes", "ZFLB": "Flupper_Bumpers", "ZVRS": "VR_Stuff",
    "ZVRR": "VR_Room", "ZDMD": "FlexDMD", "ZBMP": "Bumpers", "ZGII": "GI",
    "ZTRI": "Triggers", "ZTAR": "Targets",
}


def toml_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def write_draft_plan(path: Path, sections: list[Section], dead: list[str]) -> None:
    lines = [
        "# GLF migration plan.  Edit, then run glf_split.py --plan this-file.",
        "#",
        "# action = keep | rewrite | delete",
        "#   keep    -> copied verbatim into its output file",
        "#   rewrite -> copied, with a TODO banner prepended",
        "#   delete  -> dropped (kept in scripts/src/_deleted/ for reference)",
        "#",
        "# merge_into = another tag; this section's body is appended to that file",
        "# order      = position in the output filename prefix (NN_)",
        "",
        "[options]",
        "# Subs/Functions removed before splitting, wherever they appear.",
        "strip_procedures = [",
    ]
    for name in dead:
        lines.append(f"    {toml_str(name)},")
    lines += [
        "]",
        "# Names that look dead but are collection handlers — never strip these.",
        "keep_procedures = []",
        "",
    ]
    for s in sections:
        action, note = DEFAULT_ACTIONS.get(s.tag, ("rewrite", "unrecognised section"))
        lines.append(f"[sections.{s.tag}]")
        lines.append(f"title  = {toml_str(s.title)}")
        lines.append(f"action = {toml_str(action)}")
        if note:
            lines.append(f"note   = {toml_str(note)}")
        if s.tag in DEFAULT_MERGE:
            lines.append(f"merge_into = {toml_str(DEFAULT_MERGE[s.tag])}")
        elif action != "delete":
            if s.tag in DEFAULT_ORDER:
                lines.append(f"order = {DEFAULT_ORDER.index(s.tag) + 1}")
            lines.append(f"slug  = {toml_str(SLUG.get(s.tag, s.tag))}")
        lines.append(f"# source lines {s.start}-{s.end} ({s.end - s.start + 1})")
        lines.append("")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


# --------------------------------------------------------------------------
# Stripping
# --------------------------------------------------------------------------

def strip_procedures(lines: list[str], names: set[str],
                     comment_out: bool) -> tuple[list[str], list[str]]:
    """Remove (or comment out) the named Subs/Functions. Returns (lines, removed)."""
    procs = find_procedures(lines)
    wanted = {n.lower() for n in names}
    targets = [p for p in procs if p.name.lower() in wanted]
    removed = [f"{p.name} (lines {p.start}-{p.end})" for p in targets]

    kill = set()
    for p in targets:
        kill.update(range(p.start, p.end + 1))
        # Swallow a directly-preceding comment block, which is almost always
        # the doc comment for the procedure being removed.
        j = p.start - 2
        while j >= 0 and lines[j].lstrip().startswith("'") \
                and not _RULE_RE.match(lines[j]) and not _TAG_RE.match(lines[j]):
            kill.add(j + 1)
            j -= 1

    out: list[str] = []
    for idx, raw in enumerate(lines, start=1):
        if idx in kill:
            if comment_out:
                out.append("' [glf-strip] " + raw)
            continue
        out.append(raw)
    return out, removed


# --------------------------------------------------------------------------
# Splitting
# --------------------------------------------------------------------------

BANNER = ("'{rule}\n"
          "'   {tag}: {title}\n"
          "'{rule}\n\n")

TODO = """'
' ============================ TODO: GLF REWRITE ============================
' {note}
' ==========================================================================
'
"""


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--script", type=Path, required=True)
    ap.add_argument("--plan", type=Path, help="TOML plan file")
    ap.add_argument("--init-plan", type=Path,
                    help="write a draft plan from the script and exit")
    ap.add_argument("--out", type=Path, default=Path("scripts/src/vpx"))
    ap.add_argument("--deleted-dir", type=Path, default=None,
                    help="where to park deleted sections (default <out>/../_deleted)")
    ap.add_argument("--comment-strip", action="store_true",
                    help="comment stripped procedures out instead of deleting")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--force", action="store_true", help="overwrite a non-empty --out")
    ap.add_argument("--allow-delete-code", action="store_true",
                    help="proceed even though `delete` sections contain "
                         "executable lines (review them first)")
    args = ap.parse_args()

    text = args.script.read_text(encoding="utf-8", errors="replace")
    newline = "\r\n" if "\r\n" in text else "\n"
    lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    sections = find_sections(lines)
    if not sections:
        print("no ZXXX section banners found — is this a VPW-style script?",
              file=sys.stderr)
        return 2

    if args.init_plan:
        procs = find_procedures(lines)
        known = {p.name.lower() for p in procs}
        # Best-effort dead-handler guess: <base>_<event> where base is never
        # otherwise mentioned. The audit script does this properly with the
        # object list; here we just leave the array for the user to fill.
        write_draft_plan(args.init_plan, sections, [])
        print(f"wrote draft plan: {args.init_plan}")
        print(f"  {len(sections)} sections, {len(known)} procedures")
        print("  fill in strip_procedures[] from `glf_audit.py` output, then run "
              "with --plan")
        return 0

    if not args.plan:
        ap.error("give --plan (or --init-plan to generate one)")

    plan = tomllib.loads(args.plan.read_text(encoding="utf-8"))
    opts = plan.get("options", {})
    sec_plan: dict = plan.get("sections", {})

    strip_names = set(opts.get("strip_procedures", [])) - set(opts.get("keep_procedures", []))
    if strip_names:
        lines, removed = strip_procedures(lines, strip_names, args.comment_strip)
        print(f"stripped {len(removed)} procedure(s):")
        for r in removed:
            print(f"    {r}")
        found = {r.split(" ", 1)[0].lower() for r in removed}
        for n in sorted(strip_names):
            if n.lower() not in found:
                print(f"    ! not found in script: {n}", file=sys.stderr)
        # Line numbers have shifted; re-scan.
        sections = find_sections(lines)

    # Anything before the first section banner (Option Explicit, Randomize,
    # the controller.vbs load, the changelog header) belongs in its own file.
    bodies: dict[str, list[str]] = {}
    first = sections[0].start
    if first > 1:
        preamble = lines[: first - 1]
        pre_code = [l for l in preamble
                    if l.strip() and not l.strip().startswith("'")]
        print(f"preamble: {first - 1} line(s) before the first section banner "
              f"({len(pre_code)} executable) -> 00_ZPRE_Preamble.vbs")
        bodies["ZPRE"] = preamble + ["", ""]
        meta_pre = True
    else:
        meta_pre = False
    meta: dict[str, dict] = {}
    deleted: list[tuple[str, list[str]]] = []
    delete_with_code: list[tuple[str, list]] = []

    for s in sections:
        cfg = sec_plan.get(s.tag, {})
        action = cfg.get("action", "rewrite")
        body = lines[s.start - 1: s.end]
        if action == "delete":
            code = [(s.start + i, l) for i, l in enumerate(body)
                    if l.strip() and not l.strip().startswith("'")]
            if code:
                delete_with_code.append((s.tag, code))
            deleted.append((s.tag, body))
            continue
        target = cfg.get("merge_into", s.tag)
        if action == "rewrite" and cfg.get("note"):
            body = TODO.format(note=cfg["note"]).split("\n") + body
        bodies.setdefault(target, []).extend(body + ["", ""])
        if target == s.tag:
            meta[s.tag] = cfg

    # Filenames.
    files: dict[Path, str] = {}
    for tag, body in bodies.items():
        cfg = meta.get(tag, sec_plan.get(tag, {}))
        if tag == "ZPRE":
            cfg = {"order": 0, "slug": "Preamble",
                   "title": "Preamble - Option Explicit, controller.vbs, header"}
        order = cfg.get("order", DEFAULT_ORDER.index(tag) + 1
                        if tag in DEFAULT_ORDER else 99)
        slug = cfg.get("slug", SLUG.get(tag, tag))
        title = cfg.get("title", tag)
        name = f"{order:02d}_{tag}_{slug}.vbs"
        header = BANNER.format(rule="*" * 60, tag=tag, title=title)
        header = header.replace("\n", newline)
        files[args.out / name] = header + newline.join(body).rstrip() + newline

    deleted_dir = args.deleted_dir or (args.out.parent / "_deleted")
    for tag, body in deleted:
        cfg = sec_plan.get(tag, {})
        note = cfg.get("note", "")
        header = (f"' DELETED during GLF migration.{newline}"
                  f"' Reason: {note}{newline}"
                  f"' Kept for reference only - not part of the build.{newline}{newline}")
        files[deleted_dir / f"{tag}.vbs.deleted"] = header + newline.join(body)

    if delete_with_code:
        print("\nSections marked `delete` that still contain executable code:")
        for tag, code in delete_with_code:
            print(f"  {tag}: {len(code)} executable line(s)")
            for n, l in code[:6]:
                print(f"      {n}: {l.strip()[:72]}")
            if len(code) > 6:
                print(f"      ... (+{len(code) - 6} more)")
        print("\nThis is expected for sections GLF replaces outright (ZDRN, ZSCR,\n"
              "ZLIS, ZQUE...). It is NOT expected for a section that also holds\n"
              "something you need — check each one against src/_deleted/ before\n"
              "you trust the build.")
        if not args.allow_delete_code:
            print("\nRefusing to write. Re-run with --allow-delete-code once you have\n"
                  "reviewed the list above, or change those sections to `rewrite`.",
                  file=sys.stderr)
            return 3

    total_kept = sum(len(b) for b in bodies.values())
    total_del = sum(len(b) for _t, b in deleted)
    print(f"\n{len(bodies)} output file(s), {total_kept} lines kept, "
          f"{total_del} lines deleted, {len(lines)} lines in")

    if args.dry_run:
        for p in sorted(files):
            print(f"  would write {p}  ({files[p].count(chr(10)) + 1} lines)")
        return 0

    if args.out.exists() and any(args.out.iterdir()) and not args.force:
        print(f"{args.out} is not empty — pass --force to overwrite", file=sys.stderr)
        return 1

    for p, content in sorted(files.items()):
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content, encoding="utf-8", newline="")
        print(f"  wrote {p}")

    backup = args.script.with_suffix(args.script.suffix + ".pre-glf")
    if not backup.exists():
        shutil.copy2(args.script, backup)
        print(f"\nbackup of the original: {backup}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
