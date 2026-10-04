import pytest

from psc.errors import PscError
from psc.values import parse_color, parse_time, quantize


def test_colors():
    assert parse_color("FF8800", "x") == "ff8800"
    assert parse_color("#00ff00", "x") == "00ff00"
    assert parse_color("000000", "x") == "000000"  # stays text under BaseLoader
    assert parse_color("(color)", "x") == "(color)"
    with pytest.raises(PscError):
        parse_color("red", "x")


def test_times():
    assert parse_time("200ms", "x") == 200
    assert parse_time("1.5s", "x") == 1500
    assert parse_time("75", "x") == 75
    with pytest.raises(PscError):
        parse_time("soon", "x")


def test_quantize():
    assert quantize(14) == 10
    assert quantize(16) == 20
    assert quantize(333.3) == 330
