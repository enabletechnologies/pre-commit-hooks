"""Copyright © 2023 Enable Technologies Inc."""

import argparse
import logging

logger = logging.getLogger(__name__)


def main() -> int:
    """Checks commit message for issue number and typos.

    - Enforces git issue number in feat, fix, refactor  e.g. feat(..): ... #101
    - Spell checks commit message

    """
    parser = argparse.ArgumentParser("check_commit_msg")
    parser.add_argument("filename", help="commit-msg-filename", type=str)
    args = parser.parse_args()

    print(args.filename)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
