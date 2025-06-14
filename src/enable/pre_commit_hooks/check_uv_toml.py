"""Copyright © 2023 Enable Technologies Inc."""

import logging
import pathlib
import tomllib

logger = logging.getLogger(__name__)


def main() -> int:
    """Check for uv."""
    retval = 0
    # Load uv config and display errors, if any
    uv_file = "pyproject.toml"
    try:
        pyproject_path = pathlib.Path(uv_file)
        pyproject_text = pyproject_path.read_text()
        pyproject_data = tomllib.loads(pyproject_text)
        # check in poetry section for path dependencies
        for dep in pyproject_data["tool"]["uv"].get("sources", {}).values():
            if isinstance(dep, dict) and ("path" in dep):
                raise ValueError(f"Please remove path dependencies '{dep}' from [tool.uv.sources] in pyproject.toml before checkin ")

    except tomllib.TOMLDecodeError as exc:
        print(f"{uv_file}: {exc}")
        retval = 1
    except Exception as exc:
        logger.exception("%s:", uv_file, exc_info=exc)
        retval = 1

    return retval


if __name__ == "__main__":
    raise SystemExit(main())
