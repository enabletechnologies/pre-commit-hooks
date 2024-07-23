"""Copyright © 2023 Enable Technologies Inc."""

import argparse
import logging
import re
import subprocess
from typing import Sequence

logger = logging.getLogger(__name__)


def check_gh_issue_number(filename: str) -> None:
    """Checks if issue number is provided in commit message.

    The rule applied to feat, fix and refactor commit message types.
    """
    with open(filename) as f:
        commit_msg = f.read()
        if re.match(r"^(feat|fix|refactor)", commit_msg) and re.search(r"#\d+", commit_msg) is None:
            raise ValueError("Bad commit message: missing github issue number e.g. #101")


def check_typos(filename: str) -> None:
    """Checks for typos (spelling errors) in commit message."""
    try:
        subprocess.run(["typos", filename], check=True, text=True, capture_output=True)
    except subprocess.CalledProcessError as err:
        raise ValueError(f"Bad commit message: {err.output!s}") from err


def main(argv: Sequence[str] | None = None) -> int:
    """Checks commit message for issue number and typos.

    - Enforces git issue number in feat, fix, refactor  e.g. feat(..): ... #101
    - Spell checks commit message

    """
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="Commit message filename", type=str)
    args = parser.parse_args(argv)

    try:
        check_gh_issue_number(args.filename)
        check_typos(args.filename)
        return 0
    except ValueError as err:
        print(str(err))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
