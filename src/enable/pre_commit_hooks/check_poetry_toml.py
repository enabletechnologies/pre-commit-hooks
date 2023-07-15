"""Copyright © 2023 Enable Technologies Inc."""
import logging
import pathlib

import tomllib

logger = logging.getLogger(__name__)


def main() -> int:
    """Check for poetry."""
    retval = 0
    # Load poetry config and display errors, if any
    poetry_file = "pyproject.toml"
    try:
        pyproject_path = pathlib.Path(poetry_file)
        pyproject_text = pyproject_path.read_text()
        pyproject_data = tomllib.loads(pyproject_text)
        dependencies_data = pyproject_data["tool"]["poetry"]["dependencies"]
        for dep in dependencies_data.values():
            if isinstance(dep, dict) and ("path" in dep):
                raise ValueError(f"Please remove path dependencies  {dep} from pyproject.toml before checkin ")

    except tomllib.TOMLDecodeError as exc:
        print(f"{poetry_file}: {exc}")
        retval = 1
    except Exception as exc:
        print(f"{poetry_file}: {exc}")
        retval = 1

    return retval


if __name__ == "__main__":
    raise SystemExit(main())
