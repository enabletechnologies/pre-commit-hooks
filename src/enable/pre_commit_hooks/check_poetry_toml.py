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
        # check in poetry section for path dependencies
        for dep in pyproject_data["tool"]["poetry"].get("dependencies", {}).values():
            if isinstance(dep, dict) and ("path" in dep):
                raise ValueError(
                    f"Please remove path dependencies '{dep}' from [tool.poetry.dependencies] in pyproject.toml before checkin "
                )
        # check in project section for path dependencies
        for dep in pyproject_data["project"].get("dependencies", []):
            if isinstance(dep, str) and "file://" in dep:
                raise ValueError(f"Please remove path dependencies '{dep}' from [project] in pyproject.toml before checkin ")

    except tomllib.TOMLDecodeError as exc:
        print(f"{poetry_file}: {exc}")
        retval = 1
    except Exception as exc:
        logger.exception("%s:", poetry_file, exc_info=exc)
        retval = 1

    return retval


if __name__ == "__main__":
    raise SystemExit(main())
