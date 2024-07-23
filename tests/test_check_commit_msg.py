"""Copyright © 2023 Enable Technologies Inc."""

from pathlib import Path

from enable.pre_commit_hooks.check_commit_msg import main


def test_check_gh_issue_number(tmp_path: Path) -> None:
    """Tests check_gh_issue_number."""
    filepath = tmp_path.joinpath("COMMIT_EDITMSG")
    with open(filepath, "w") as f:
        f.write("chore(model): response")
    assert main([str(filepath)]) == 0

    with open(filepath, "w") as f:
        f.write("feat(model): response")
    assert main([str(filepath)]) == 1

    with open(filepath, "w") as f:
        f.write("fix(model): response")
    assert main([str(filepath)]) == 1

    with open(filepath, "w") as f:
        f.write("refactor(model): response")
    assert main([str(filepath)]) == 1

    with open(filepath, "w") as f:
        f.write("feat(model): response #1")
    assert main([str(filepath)]) == 0

    with open(filepath, "w") as f:
        f.write("fix(model): response #2")
    assert main([str(filepath)]) == 0

    with open(filepath, "w") as f:
        f.write("refactor(model): response #3")
    assert main([str(filepath)]) == 0


def test_check_typos(tmp_path: Path) -> None:
    """Tests check_typos."""
    filepath = tmp_path.joinpath("COMMIT_EDITMSG")
    with open(filepath, "w") as f:
        f.write("chore(model): response")
    assert main([str(filepath)]) == 0

    with open(filepath, "w") as f:
        f.write("chore(model): reponse")
    assert main([str(filepath)]) == 1
