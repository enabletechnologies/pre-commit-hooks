"""Copyright © 2023 Enable Technologies Inc."""

import argparse
import logging
import re
import subprocess
from typing import Sequence

logger = logging.getLogger(__name__)

# Default branch name pattern following conventional naming
# Allows: feat/, fix/, build/, release/, chore/, docs/, test/, refactor/ prefixes
# followed by a descriptive name with alphanumeric, hyphens, underscores, and slashes
DEFAULT_PATTERN = r"^(main|lts|develop|main-fixes|lts-fixes|develop-to-main-fixes||HEAD)$|^(feat|fix|build|refactor|release|chore|docs|test)/[a-zA-Z0-9._-]+$"  # noqa: E501


# Branches that are always allowed
ALLOWED_BRANCHES = frozenset({"main", "lts", "develop", "main-fixes", "lts-fixes", "develop-to-main-fixes", "HEAD"})


def get_current_branch() -> str:
    """Get the current git branch name."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            check=True,
            text=True,
            capture_output=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as err:
        raise ValueError(f"Failed to get current branch: {err.stderr!s}") from err


def validate_branch_name(branch_name: str, pattern: str) -> None:
    """Validate branch name against the given pattern.

    Args:
        branch_name: The git branch name to validate.
        pattern: Regex pattern the branch name must match.

    Raises:
        ValueError: If branch name doesn't match the pattern.
    """
    if not re.match(pattern, branch_name):
        raise ValueError(
            f"Invalid branch name: '{branch_name}'\n"
            f"Branch name must match pattern: {pattern}\n"
            f"Examples of valid branch names:\n"
            f"  - feat/add-user-auth\n"
            f"  - fix/fix-login-issue\n"
            f"  - build/critical-security-patch\n"
            f"  - release/v1.2.0\n"
            f"  - chore/update-dependencies\n"
            f"  - docs/update-readme\n"
            f"  - refactor/cleanup-utils"
        )


def main(argv: Sequence[str] | None = None) -> int:
    """Validate git branch name against a configurable pattern.

    Ensures branch names follow conventional naming patterns like:
    - feat/description
    - fix/description
    - build/description
    - release/version
    - chore/description
    - docs/description
    - refactor/description

    Also allows: main, master, develop, HEAD
    """
    parser = argparse.ArgumentParser(description="Validate git branch name against a pattern")
    parser.add_argument(
        "--pattern",
        type=str,
        default=DEFAULT_PATTERN,
        help=f"Regex pattern for valid branch names (default: {DEFAULT_PATTERN})",
    )
    parser.add_argument(
        "--branch",
        type=str,
        default=None,
        help="Branch name to validate (default: current branch)",
    )
    args, unknown = parser.parse_known_args(argv)  # noqa: RUF059

    try:
        branch_name = args.branch if args.branch else get_current_branch()
        validate_branch_name(branch_name, args.pattern)
        return 0
    except ValueError as err:
        print(str(err))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
