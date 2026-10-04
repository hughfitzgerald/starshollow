"""Scalar parsing. YAML is loaded with BaseLoader, so every scalar arrives as a
string and is converted here. This avoids YAML 1.1 surprises such as an
unquoted color `000000` becoming the integer 0, or `010000` becoming octal."""

import math
import re
from dataclasses import dataclass

from .errors import PscError

HEX_RE = re.compile(r"^#?([0-9a-fA-F]{6})$")
TOKEN_RE = re.compile(r"^\([A-Za-z_][A-Za-z0-9_]*\)$")
TIME_RE = re.compile(r"^\s*(-?\d+(?:\.\d+)?)\s*(ms|s|steps?|beats?|bars?)?\s*$")
NAME_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")

GRID_MS = 10


def quantize(ms: float, grid: int = GRID_MS) -> int:
    """Snap a time to a grid (GLF's step resolution is 10ms)."""
    return int(math.floor(ms / grid + 0.5)) * grid


def is_token(value: str) -> bool:
    return bool(TOKEN_RE.match(value))


def parse_color(value, where: str) -> str:
    if not isinstance(value, str):
        raise PscError(f"{where}: color must be a hex string like ff8800, got {value!r}")
    text = value.strip()
    if is_token(text):
        return text
    m = HEX_RE.match(text)
    if not m:
        raise PscError(f"{where}: color must be 6 hex digits like ff8800 or a token like (color), got {value!r}")
    return m.group(1).lower()


@dataclass(frozen=True)
class Tempo:
    bpm: float
    steps_per_beat: int = 4
    beats_per_bar: int = 4

    @property
    def beat_ms(self) -> float:
        return 60000 / self.bpm

    @property
    def step_ms(self) -> float:
        return self.beat_ms / self.steps_per_beat

    @property
    def bar_ms(self) -> float:
        return self.beat_ms * self.beats_per_bar


def parse_time(value, where: str, tempo: Tempo | None = None) -> float:
    """Return milliseconds. Accepts `200ms`, `1.5s`, a bare number (ms), and
    with a show tempo, `3 steps`, `2 beats` or `1 bar`."""
    if not isinstance(value, str):
        raise PscError(f"{where}: expected a time like 200ms or 1.5s, got {value!r}")
    m = TIME_RE.match(value)
    if not m:
        raise PscError(f"{where}: expected a time like 200ms, 1.5s or 2 beats, got {value!r}")
    amount = float(m.group(1))
    if amount < 0:
        raise PscError(f"{where}: time cannot be negative ({value})")
    unit = m.group(2) or "ms"
    if unit == "ms":
        return amount
    if unit == "s":
        return amount * 1000
    if tempo is None:
        raise PscError(f"{where}: {value!r} uses musical time; add a tempo: to the show")
    musical = {"step": tempo.step_ms, "beat": tempo.beat_ms, "bar": tempo.bar_ms}
    return amount * musical[unit.rstrip("s")]


def parse_number(value, where: str, minimum=None, maximum=None) -> float:
    if not isinstance(value, str):
        raise PscError(f"{where}: expected a number, got {value!r}")
    try:
        number = float(value)
    except ValueError:
        raise PscError(f"{where}: expected a number, got {value!r}") from None
    if minimum is not None and number < minimum:
        raise PscError(f"{where}: must be at least {minimum}, got {value}")
    if maximum is not None and number > maximum:
        raise PscError(f"{where}: must be at most {maximum}, got {value}")
    return number


def parse_int(value, where: str, minimum=None, maximum=None) -> int:
    number = parse_number(value, where, minimum, maximum)
    if number != int(number):
        raise PscError(f"{where}: expected a whole number, got {value}")
    return int(number)


def parse_point(value, where: str) -> tuple[float, float]:
    if not isinstance(value, list) or len(value) != 2:
        raise PscError(f"{where}: expected a point like [x, y], got {value!r}")
    return (parse_number(value[0], where), parse_number(value[1], where))


def parse_name(value, where: str) -> str:
    if not isinstance(value, str) or not NAME_RE.match(value):
        raise PscError(f"{where}: {value!r} is not a valid name (letters, digits, underscore)")
    return value


def expect_mapping(value, where: str) -> dict:
    if value == "" or value is None:
        return {}
    if not isinstance(value, dict):
        raise PscError(f"{where}: expected a mapping")
    return value


def check_keys(mapping: dict, allowed, where: str):
    unknown = [k for k in mapping if k not in allowed]
    if unknown:
        raise PscError(f"{where}: unknown key(s) {', '.join(map(str, unknown))}; allowed: {', '.join(sorted(allowed))}")
