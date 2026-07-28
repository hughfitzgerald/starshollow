# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
glf_callbacks.py - migrate VPW event-handler bodies into GLF callback
signatures, and lift the scoring out of them into EventPlayer config.

The four GLF callback shapes are not consistent with each other, and the
ActiveBall -> args(1) substitution in autofire callbacks is the one that fails
silently (wrong-ball slingshot corrections). Both are mechanical, so they are
done here rather than by hand.

This NEVER edits your sources. It reads them and writes two new files:

  --out          the migrated callbacks, ready to paste into _configuration.vbs
  --scoring-out  the EventPlayer lines replacing the Addscore calls it removed

Every migrated body is annotated with where it came from, and anything the
tool wasn't sure about is marked TODO rather than guessed at.

Usage:
    uv run glf_callbacks.py --table ./MyTable --scripts scripts/src/vpx \\
        --out scripts/src/game/_callbacks.vbs \\
        --scoring-out scripts/src/game/_scoring.suggested.vbs
"""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass, field
from pathlib import Path

_SUB_RE = re.compile(
    r"^[ \t]*(?:Public[ \t]+|Private[ \t]+)?(Sub|Function)[ \t]+"
    r"([A-Za-z_][A-Za-z0-9_]*)", re.IGNORECASE)
_END_RE = re.compile(r"^[ \t]*End[ \t]+(Sub|Function)\b", re.IGNORECASE)
_SCORE_RE = re.compile(r"^\s*Addscore\s+(\d+)\s*$", re.IGNORECASE)
_ACTIVEBALL_RE = re.compile(r"(?<![A-Za-z0-9_.])ActiveBall(?![A-Za-z0-9_])",
                            re.IGNORECASE)

TROUGH = re.compile(r"^(swTrough\d|Drain)$", re.I)


def strip_comment(line: str) -> str:
    out, in_str, i = [], False, 0
    while i < len(line):
        ch = line[i]
        if ch == '"':
            if in_str and i + 1 < len(line) and line[i + 1] == '"':
                out.append('""'); i += 2; continue
            in_str = not in_str; out.append(ch)
        elif ch == "'" and not in_str:
            break
        else:
            out.append(ch)
        i += 1
    return "".join(out)


@dataclass
class Proc:
    name: str
    start: int
    end: int
    body: list[str]
    source: Path


def find_procs(path: Path) -> dict[str, Proc]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    out: dict[str, Proc] = {}
    open_name, open_start = None, 0
    for idx, raw in enumerate(lines):
        code = strip_comment(raw)
        if not code.strip():
            continue
        m = _SUB_RE.match(code)
        if m and open_name is None:
            if _END_RE.search(code) or re.search(
                    r":[ \t]*End[ \t]+(Sub|Function)\b", code, re.I):
                out[m.group(2).lower()] = Proc(m.group(2), idx, idx, [raw], path)
            else:
                open_name, open_start = m.group(2), idx
            continue
        if open_name and _END_RE.match(code):
            out[open_name.lower()] = Proc(open_name, open_start, idx,
                                          lines[open_start + 1: idx], path)
            open_name = None
    return out


def load_all(scripts: list[Path]) -> dict[str, Proc]:
    procs: dict[str, Proc] = {}
    for spec in scripts:
        files = sorted(spec.rglob("*.vbs")) if spec.is_dir() else [spec]
        for f in files:
            for k, v in find_procs(f).items():
                procs.setdefault(k, v)
    return procs


def load_objects(table: Path) -> dict[str, str]:
    gi = table / "gameitems"
    if not gi.is_dir():
        raise SystemExit(f"no gameitems/ under {table}")
    return {f.stem.split(".", 1)[1]: f.stem.split(".", 1)[0]
            for f in sorted(gi.glob("*.json")) if "." in f.stem}


# --------------------------------------------------------------------------

@dataclass
class Migration:
    text: list[str] = field(default_factory=list)
    scoring: list[str] = field(default_factory=list)
    notes: list[str] = field(default_factory=list)


def dedent_body(body: list[str]) -> list[str]:
    """Drop one level of leading indentation so it re-indents cleanly."""
    real = [l for l in body if l.strip()]
    if not real:
        return body
    return [l[1:] if l.startswith("\t") else
            (l[4:] if l.startswith("    ") else l) for l in body]


def lift_scoring(body: list[str], event: str) -> tuple[list[str], list[str]]:
    """Remove bare `Addscore N` lines; return (body, EventPlayer suggestions)."""
    kept, awards = [], []
    for line in body:
        m = _SCORE_RE.match(strip_comment(line))
        if m:
            awards.append(int(m.group(1)))
            kept.append(f"\t' [lifted] {line.strip()}  -> score_{m.group(1)}")
        else:
            kept.append(line)
    if not awards:
        return kept, []
    events = ", ".join(f'"score_{a}"' for a in awards)
    return kept, [f'            .Add "{event}", Array({events})']


def migrate_autofire(obj: str, kind: str, proc: Proc, m: Migration) -> None:
    """Slingshots and bumpers: ActionCallback(args), args(0)=enabled, args(1)=ball."""
    base = re.sub(r"^s_", "", obj)
    cb = f"{base}Action"
    body, scoring = lift_scoring(dedent_body(proc.body), f"{obj}_active")
    m.scoring += scoring

    rewrote_ball = False
    fixed: list[str] = []
    for line in body:
        if _ACTIVEBALL_RE.search(strip_comment(line)):
            rewrote_ball = True
            indent = line[: len(line) - len(line.lstrip())]
            new = _ACTIVEBALL_RE.sub("args(1)", line).strip()
            fixed.append(f"{indent}If Not IsNull(args(1)) Then {new}"
                         "   ' was ActiveBall")
        else:
            fixed.append(line)

    m.text += [
        "",
        f"' Migrated from {proc.name} in {proc.source.name}",
        f"' GLF autofire callback: args(0) = enabled, args(1) = ball (may be Null).",
    ]
    if rewrote_ball:
        m.text.append("' ActiveBall rewritten to args(1) - ActiveBall is not "
                      "reliable inside GLF dispatch.")
    m.text += [
        f"Sub {cb}(args)",
        "\tDim enabled : enabled = args(0)",
        "\tIf enabled Then",
    ]
    m.text += ["\t" + l if l.strip() else l for l in fixed]
    m.text += ["\tEnd If", "End Sub"]

    if kind == "bumper":
        m.text += [
            "",
            f"' GLF has no other way to switch a bumper off.",
            f"Sub {base}Disabled(args) : {obj}.Threshold = 100 : End Sub",
            f"Sub {base}Enabled(args)  : {obj}.Threshold = 1.5 : End Sub",
        ]
    m.notes.append(f"{proc.name} -> {cb}(args)"
                   + ("   [ActiveBall rewritten]" if rewrote_ball else ""))


def migrate_balldevice(obj: str, hit: Proc | None, timer: Proc | None,
                       m: Migration) -> None:
    """Kickers/VUKs: EjectCallback(ball). The kick usually lives in _Timer."""
    cb = f"{re.sub(r'^s_', '', obj)}EjectCallback"
    src = timer or hit
    if src is None:
        return
    body, scoring = lift_scoring(dedent_body(src.body), f"{obj}_active")
    m.scoring += scoring
    body = [_ACTIVEBALL_RE.sub("ball", l) for l in body]

    m.text += [
        "",
        f"' Migrated from {src.name} in {src.source.name}",
        f"' GLF ball-device eject callback. The VPX TimerInterval hold is "
        f"replaced by",
        f"' the device's EjectTimeout / EjectAllEvents - delete "
        f"{obj}.TimerInterval and",
        f"' Sub {obj}_Timer from your sources.",
        f"Sub {cb}(ball)",
    ]
    m.text += ["\t" + l if l.strip() else l for l in body]
    m.text += ["End Sub"]
    if hit is not None and hit is not src:
        m.text += [
            "",
            f"' TODO: {hit.name} also had a body. Anything in it that is not "
            f"just arming",
            f"' the timer needs a home - usually an EventPlayer binding on "
            f"{obj}_active.",
        ]
        m.text += ["' " + l for l in dedent_body(hit.body) if l.strip()]
    m.notes.append(f"{src.name} -> {cb}(ball)")


def lift_target_scoring(proc: Proc, prefix: str, m: Migration) -> None:
    """Pull `Case N: Addscore X : lightN.state = 1` out of STHit / DTHit."""
    case_re = re.compile(r"^\s*Case\s+(\d+)", re.I)
    current, awards, lamps = None, {}, {}
    for line in proc.body:
        code = strip_comment(line)
        c = case_re.match(code)
        if c:
            current = int(c.group(1))
            continue
        if current is None:
            continue
        for sm in re.finditer(r"\bAddscore\s+(\d+)", code, re.I):
            awards.setdefault(current, []).append(int(sm.group(1)))
        for lm in re.finditer(r"\b(l\d+)\.state\s*=\s*1", code, re.I):
            lamps.setdefault(current, []).append(lm.group(1))
    if not awards and not lamps:
        return
    m.scoring += ["", f"        ' lifted out of {proc.name} - delete those "
                      f"Select Case bodies"]
    for sw in sorted(set(awards) | set(lamps)):
        evs = [f'"score_{a}"' for a in awards.get(sw, [])]
        evs += [f'"light_{l}"' for l in lamps.get(sw, [])]
        m.scoring.append(f'            .Add "{prefix}{sw}_active", '
                         f"Array({', '.join(evs)})")
    m.notes.append(f"{proc.name}: lifted {len(awards)} scoring case(s)")


# --------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--table", type=Path, required=True)
    ap.add_argument("--scripts", type=Path, action="append", required=True)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--scoring-out", type=Path)
    ap.add_argument("--target-prefix", default="s_ST",
                    help="switch-name prefix for standup targets (default s_ST)")
    args = ap.parse_args()

    objs = load_objects(args.table)
    procs = load_all(args.scripts)
    m = Migration()

    m.text += [
        "'*******************************************",
        "'   GLF callbacks - generated by glf_callbacks.py",
        "'*******************************************",
        "'",
        "' Bodies migrated from your VPW handlers. Review every one, then move",
        "' them into _configuration.vbs (or keep this as its own src/game file).",
        "'",
        "' The originals are still in your sources and must be deleted - GLF",
        "' generates _Hit/_UnHit/_Slingshot for collection members itself.",
    ]

    # --- flippers: VPW's SolLFlipper already matches GLF's signature --------
    for side, sol in (("left", "SolLFlipper"), ("right", "SolRFlipper")):
        p = procs.get(sol.lower())
        if p and re.search(r"\(\s*Enabled\s*\)", "".join(
                [l for l in [p.body and ""]] + [sol]) or "", re.I) is not None:
            pass
        if p:
            m.notes.append(f"{sol}: already ActionCallback-shaped - "
                           f'set .ActionCallback = "{sol}" and change nothing')
            m.text += [
                "",
                f"' {sol} already has the exact GLF flipper signature "
                f"(Enabled).",
                f"' No migration needed - in CreateGlfFlipper(\"{side}\") just set:",
                f"'     .ActionCallback = \"{sol}\"",
                f"' Then delete the `If keycode = {side.capitalize()}FlipperKey` "
                f"branch from Table1_KeyDown/KeyUp.",
            ]

    # --- autofire devices --------------------------------------------------
    for obj, typ in sorted(objs.items()):
        if TROUGH.match(obj):
            continue
        sling = procs.get(f"{obj}_slingshot".lower())
        if sling:
            migrate_autofire(obj, "sling", sling, m)
            continue
        if typ == "Bumper":
            hit = procs.get(f"{obj}_hit".lower())
            if hit:
                migrate_autofire(obj, "bumper", hit, m)

    # --- ball devices ------------------------------------------------------
    for obj, typ in sorted(objs.items()):
        if typ != "Kicker" or TROUGH.match(obj) or obj.lower().startswith("debug"):
            continue
        hit = procs.get(f"{obj}_hit".lower())
        timer = procs.get(f"{obj}_timer".lower())
        if hit or timer:
            migrate_balldevice(obj, hit, timer, m)

    # --- target scoring ----------------------------------------------------
    seen_lift = set()
    for pname, prefix in (("staction", args.target_prefix),
                          ("sthit", args.target_prefix),
                          ("dtaction", "s_DT"), ("dthit", "s_DT")):
        p = procs.get(pname)
        if p and p.name.lower() not in seen_lift:
            seen_lift.add(p.name.lower())
            lift_target_scoring(p, prefix, m)
    # Anything else that mixes Select Case with Addscore is probably scoring
    # buried in physics code too.
    for name, p in sorted(procs.items()):
        if name in seen_lift:
            continue
        joined = "\n".join(p.body)
        if re.search(r"^\s*Case\s+\d+", joined, re.M) and \
                re.search(r"\bAddscore\b", joined, re.I):
            m.notes.append(f"{p.name} in {p.source.name}: also mixes Select Case "
                           "with Addscore - check whether it needs lifting too")

    # --- write -------------------------------------------------------------
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(m.text) + "\n", encoding="utf-8")
    print(f"wrote {args.out}")

    if m.scoring:
        header = [
            "' EventPlayer bindings replacing the scoring lifted out of your",
            "' physics handlers. Paste into a mode's .EventPlayer() block.",
            "' Every score_NNNN value must exist in ScoreArray.",
            "",
            "'        With .EventPlayer()",
        ]
        footer = ["'        End With"]
        target = args.scoring_out or args.out.with_name("_scoring.suggested.vbs")
        target.write_text("\n".join(header + m.scoring + footer) + "\n",
                          encoding="utf-8")
        print(f"wrote {target}")

    print(f"\n{len(m.notes)} migration(s):")
    for n in m.notes:
        print(f"  {n}")
    print("\nNothing in your sources was modified. Delete the originals only "
          "after\nreviewing the output - glf_collections.py will block until "
          "you do.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
