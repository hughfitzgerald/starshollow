from pathlib import Path

import yaml

from .errors import PscError


def load_yaml(path: Path):
    """Load YAML with every scalar as a string (see values.py)."""
    try:
        with open(path, encoding="utf-8") as f:
            data = yaml.load(f, Loader=yaml.BaseLoader)
    except FileNotFoundError:
        raise PscError(f"{path}: file not found") from None
    except yaml.YAMLError as e:
        raise PscError(f"{path}: invalid YAML: {e}") from None
    return {} if data is None else data
