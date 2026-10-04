"""Surgical edits to the `groups:` block of hardware.yaml, for the editor.

The file is hand-written and full of comments, so it is never re-serialized.
Only the group entry being changed is rewritten, in the style it already
uses (inline `{ ... }`, a bare list, or a nested block). Comments above an
entry and at the end of its lines survive; comments inside a multi-line
members list of the entry being rewritten do not."""

import json
import re
from dataclasses import dataclass

import yaml

from .errors import PscError
from .values import NAME_RE

GROUPS_RE = re.compile(r"^groups:\s*(#.*)?$")
ENTRY_RE = re.compile(r"^(?P<indent>[ ]+)(?P<name>[A-Za-z_][A-Za-z0-9_]*):(?P<rest>.*)$")


def _blank_or_comment(line: str) -> bool:
    s = line.strip()
    return not s or s.startswith("#")


def _trailing_comment(line: str) -> str:
    """The ` # ...` at the end of a line, outside quotes, with the spaces
    before it, or ''."""
    quote = None
    for i, ch in enumerate(line):
        if quote:
            if ch == quote:
                quote = None
        elif ch in "\"'":
            quote = ch
        elif ch == "#" and i > 0 and line[i - 1] in " \t":
            return line[:i].rstrip(" \t")[len(line[:i].rstrip(" \t")):] + line[len(line[:i].rstrip(" \t")):].rstrip()
    return ""


def _scalar(value: str) -> str:
    return value if NAME_RE.match(value) else json.dumps(value)


def _flow(items: list[str]) -> str:
    return "[" + ", ".join(_scalar(i) for i in items) + "]"


@dataclass
class Entry:
    name: str
    header: int       # line index of `name:`
    end: int          # exclusive; stops before the blank/comment lines that lead the next entry
    indent: str


@dataclass
class Block:
    start: int        # index of the `groups:` line
    end: int          # exclusive: the next top-level line, or end of file
    indent: str | None
    entries: list[Entry]

    def entry(self, name: str) -> Entry | None:
        for e in self.entries:
            if e.name.lower() == name.lower():
                return e
        return None


def parse_block(lines: list[str]) -> Block | None:
    start = next((i for i, l in enumerate(lines) if GROUPS_RE.match(l)), None)
    if start is None:
        return None
    end = len(lines)
    for i in range(start + 1, len(lines)):
        if not _blank_or_comment(lines[i]) and not lines[i].startswith(" "):
            end = i
            break
    headers: list[tuple[int, str, str]] = []
    indent = None
    for i in range(start + 1, end):
        m = ENTRY_RE.match(lines[i])
        if not m:
            continue
        if indent is None:
            indent = m.group("indent")
        if m.group("indent") == indent:
            headers.append((i, m.group("name"), indent))
    entries = []
    for k, (header, name, ind) in enumerate(headers):
        stop = headers[k + 1][0] if k + 1 < len(headers) else end
        while stop - 1 > header and _blank_or_comment(lines[stop - 1]):
            stop -= 1
        entries.append(Entry(name, header, stop, ind))
    return Block(start, end, indent, entries)


def _spec(lines: list[str], entry: Entry) -> dict:
    text = "\n".join(lines[entry.header:entry.end])
    try:
        data = yaml.load(text, Loader=yaml.BaseLoader)
    except yaml.YAMLError as e:
        raise PscError(f"groups.{entry.name}: cannot parse this entry: {e}") from None
    value = data[entry.name] if isinstance(data, dict) else None
    if isinstance(value, list):
        return {"members": value}
    if value in (None, ""):
        return {}
    if not isinstance(value, dict):
        raise PscError(f"groups.{entry.name}: unexpected entry shape")
    return value


def _render(lines: list[str], entry: Entry, spec: dict) -> list[str]:
    """Re-emit one entry with the given spec, keeping its style."""
    header = lines[entry.header]
    rest = ENTRY_RE.match(header).group("rest").strip()
    comment = _trailing_comment(header)
    keys = [k for k in spec if k in ("color", "members", "exclude")]
    for k in ("color", "members", "exclude"):  # new keys go in canonical order
        if k in spec and k not in keys:
            keys.append(k)
    ordered = ["color"] * ("color" in keys) + ["members"] * ("members" in keys) + ["exclude"] * ("exclude" in keys)
    if not spec.get("exclude"):
        ordered = [k for k in ordered if k != "exclude"]

    def value(k):
        return _flow(spec[k]) if k in ("members", "exclude") else _scalar(str(spec[k]))

    if rest.startswith("{"):
        body = ", ".join(f"{k}: {value(k)}" for k in ordered)
        line = f"{entry.indent}{entry.name}: {{ {body} }}"
        return [line + comment]
    if rest.startswith("[") and ordered == ["members"]:
        line = f"{entry.indent}{entry.name}: {value('members')}"
        return [line + comment]
    # block style: keep lines of keys we don't touch, rewrite members/exclude
    out = [f"{entry.indent}{entry.name}:" + (comment if not rest.startswith("[") else "")]
    body_lines = lines[entry.header + 1:entry.end] if not rest.startswith("[") else []
    child = None
    sections: list[tuple[str | None, int, int]] = []  # (key, start, end) within body_lines
    for i, l in enumerate(body_lines):
        m = ENTRY_RE.match(l)
        if m and (child is None or m.group("indent") == child):
            child = child or m.group("indent")
            sections.append((m.group("name"), i, i))
        elif sections:
            sections[-1] = (sections[-1][0], sections[-1][1], i)
    child = child or entry.indent + "  "
    seen = []
    for key, s, e in sections:
        if key in ("members", "exclude"):
            if key not in ordered:
                continue
            c = _trailing_comment(body_lines[s])
            out.append(f"{child}{key}: {value(key)}" + c)
            seen.append(key)
        else:
            out.extend(body_lines[s:e + 1])
            seen.append(key)
    for key in ordered:
        if key not in seen:
            out.append(f"{child}{key}: {value(key)}")
    return out


def _lines(text: str) -> list[str]:
    return text.split("\n")


def _join(lines: list[str]) -> str:
    return "\n".join(lines)


def _require_block(lines: list[str]) -> Block:
    block = parse_block(lines)
    if block is None:
        if lines and lines[-1] != "":
            lines.append("")
        lines.extend(["groups:", ""])
        block = parse_block(lines)
    return block


def update_group(text: str, name: str, members: list[str], exclude: list[str] | None = None,
                 color: str | None = None) -> str:
    """Rewrite one group's members (and exclude). Creates the group if it is
    missing. `color` is only used for a new group."""
    if not NAME_RE.match(name):
        raise PscError(f"{name!r} is not a valid group name (letters, digits, underscore)")
    if not members and not exclude:
        raise PscError(f"group {name}: a group needs at least one member")
    lines = _lines(text)
    block = _require_block(lines)
    entry = block.entry(name)
    if entry is None:
        indent = block.indent or "  "
        new = [f"{indent}{name}:"]
        if color:
            new.append(f"{indent}  color: {color}")
        new.append(f"{indent}  members: {_flow(members)}")
        if exclude:
            new.append(f"{indent}  exclude: {_flow(exclude)}")
        at = block.entries[-1].end if block.entries else block.start + 1
        lines[at:at] = new
        return _join(lines)
    spec = dict(_spec(lines, entry))
    spec["members"] = list(members)
    if exclude:
        spec["exclude"] = list(exclude)
    else:
        spec.pop("exclude", None)
    lines[entry.header:entry.end] = _render(lines, entry, spec)
    return _join(lines)


def delete_group(text: str, name: str) -> str:
    lines = _lines(text)
    block = parse_block(lines)
    entry = block.entry(name) if block else None
    if entry is None:
        raise PscError(f"group {name}: not found")
    del lines[entry.header:entry.end]
    return _join(lines)


def declared(text: str, name: str) -> tuple[list[str], list[str]]:
    """The members and exclude lists as written for one group."""
    lines = _lines(text)
    block = parse_block(lines)
    entry = block.entry(name) if block else None
    if entry is None:
        raise PscError(f"group {name}: not found")
    spec = _spec(lines, entry)
    members = spec.get("members", [])
    exclude = spec.get("exclude", [])
    return (list(members) if isinstance(members, list) else [], list(exclude) if isinstance(exclude, list) else [])
