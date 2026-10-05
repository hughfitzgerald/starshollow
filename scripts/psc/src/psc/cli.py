import argparse
import sys

from .compiler import compile_all
from .config import find_config, load_config
from .errors import PscError
from .hwmap import build_map
from .sync import apply_changes, import_groups, plan_sync
from .table import Table


def cmd_sync(cfg, args) -> int:
    table = Table(cfg.table_dir)
    changes = plan_sync(cfg, table)
    if not changes:
        print("table JSON is in sync")
        return 0
    for change in changes:
        print(change.describe())
    if args.check:
        print(f"{len(changes)} change(s) pending; run `psc sync`", file=sys.stderr)
        return 1
    apply_changes(changes)
    print(f"applied {len(changes)} change(s). Run `npm run assemble-vpx` before opening the table in VPX.")
    return 0


def cmd_import_groups(cfg, args) -> int:
    print(import_groups(cfg, Table(cfg.table_dir)), end="")
    return 0


def cmd_map(cfg, args) -> int:
    hw = build_map(cfg, Table(cfg.table_dir))
    print(f"{'light':<22} {'x':>8} {'y':>8}  {'color':<8} {'from':<16} {'kind':<6} groups")
    for name in hw.order:
        l = hw.light(name)
        kind = f"bg#{l.b2s_id}" if l.proxy else "light"
        print(f"{l.name:<22} {l.x:>8.1f} {l.y:>8.1f}  {l.color:<8} {l.color_source:<16} {kind:<6} {', '.join(l.tags)}")
    print()
    for group, members in hw.groups.items():
        print(f"{group}: {', '.join(members)}")
    if hw.anchors:
        print()
        for anchor, (x, y) in hw.anchors.items():
            print(f"anchor {anchor}: ({x:g}, {y:g})")
    return 0


def cmd_compile(cfg, args) -> int:
    compiled, changed = compile_all(cfg)
    for c in compiled:
        print(f"{c.name}: {c.steps} steps, {c.lights} lights, {c.length / 1000:.2f}s")
    state = "wrote" if changed else "unchanged"
    print(f"{state} {cfg.output_file} ({len(compiled)} show(s))")
    return 0


def cmd_edit(cfg, args) -> int:
    from .editor import serve  # local import: only the editor needs the HTTP server
    return serve(cfg, args.port, not args.no_open)


def cmd_midi(cfg, args) -> int:
    from pathlib import Path

    from .midi import convert_file
    names = {}
    for item in (args.map or "").split(","):
        if item.strip():
            drum, _, group = item.partition("=")
            if not group:
                raise PscError(f"--map expects drum=group pairs, got {item!r}")
            names[drum.strip()] = group.strip()
    print(convert_file(Path(args.file), steps_per_beat=args.steps_per_beat, bars=args.bars,
                       accent_velocity=args.accent_velocity, names=names, all_channels=args.all_channels), end="")
    return 0


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="psc", description="Pinball Show Compiler")
    parser.add_argument("--config", help="path to hardware.yaml (default: search upward from cwd)")
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("sync", help="write group tags and backglass proxy lights into the table JSON")
    p.add_argument("--check", action="store_true", help="report pending changes without writing; exit 1 if any")
    p.set_defaults(func=cmd_sync)
    sub.add_parser("import-groups", help="print a groups: block built from the tags in the JSON").set_defaults(func=cmd_import_groups)
    sub.add_parser("map", help="print the hardware map").set_defaults(func=cmd_map)
    sub.add_parser("compile", help="compile show YAML to GLF VBScript").set_defaults(func=cmd_compile)
    p = sub.add_parser("edit", help="open the light group editor in a browser")
    p.add_argument("--port", type=int, default=8765, help="port on 127.0.0.1 (default 8765; 0 picks a free one)")
    p.add_argument("--no-open", action="store_true", help="don't open a browser; just print the URL")
    p.set_defaults(func=cmd_edit)
    p = sub.add_parser("midi", help="print beat-layer notation for a MIDI drum file")
    p.add_argument("file", help="a .mid file; drums are read from channel 10, or every channel if it has none")
    p.add_argument("--steps-per-beat", type=int, default=4, help="grid per quarter note (default 4 = 16ths)")
    p.add_argument("--bars", type=int, help="bars to keep (default: whole bars up to the last hit)")
    p.add_argument("--accent-velocity", type=int, default=96, help="velocity from which a hit is X (default 96)")
    p.add_argument("--map", help="rename tracks: kick=groove_lower_left,snare=groove_upper_right,...")
    p.add_argument("--all-channels", action="store_true", help="take notes from every channel, not only channel 10")
    p.set_defaults(func=cmd_midi)
    args = parser.parse_args(argv)
    try:
        cfg = None if args.command == "midi" else load_config(find_config(args.config))
        return args.func(cfg, args)
    except PscError as e:
        for message in e.messages:
            print(f"error: {message}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
