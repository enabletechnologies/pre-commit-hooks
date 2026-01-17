"""Copyright © 2023 Enable Technologies Inc."""

from unittest.mock import patch

import pytest

from enable.pre_commit_hooks.check_branch_name import (
    DEFAULT_PATTERN,
    get_current_branch,
    main,
    validate_branch_name,
)


class TestValidateBranchName:
    """Tests for validate_branch_name function."""

    @pytest.mark.parametrize(
        "branch_name",
        [
            "main",
            "lts",
            "develop",
            "HEAD",
            "feat/add-user-auth",
            "feat/add-user-auth/auth",
            "dependabot/add-user-auth/auth",
            "copilot/add-user-auth/auth",
            "feat/add_user_auth",
            "feat/JIRA-123",
            "fix/fix-login-issue",
            "build/critical-security-patch",
            "release/v1.2.0",
            "release/1.0.0",
            "chore/update-dependencies",
            "docs/update-readme",
            "test/add-unit-tests",
            "refactor/cleanup-utils",
        ],
    )
    def test_valid_branch_names(self, branch_name: str) -> None:
        """Tests that valid branch names pass validation."""
        # Should not raise
        validate_branch_name(branch_name, DEFAULT_PATTERN)

    @pytest.mark.parametrize(
        "branch_name",
        [
            "my-feature",
            "add-something",
            "feat1/something",  # feat is not a valid prefix, use feature
            "bug/fix-issue",  # bug is not valid, use bugfix
            "feature/",  # missing description
            "feature",  # missing slash and description
            "FEATURE/something",  # wrong case
            "feature/some thing",  # space not allowed
            "feature/some@thing",  # @ not allowed
        ],
    )
    def test_invalid_branch_names(self, branch_name: str) -> None:
        """Tests that invalid branch names fail validation."""
        with pytest.raises(ValueError, match="Invalid branch name"):
            validate_branch_name(branch_name, DEFAULT_PATTERN)


class TestMain:
    """Tests for main function."""

    def test_main_with_valid_branch_arg(self) -> None:
        """Tests main with valid branch name argument."""
        assert main(["--branch", "feat/new-feature"]) == 0

    def test_main_with_invalid_branch_arg(self) -> None:
        """Tests main with invalid branch name argument."""
        assert main(["--branch", "invalid-branch"]) == 1

    def test_main_with_custom_pattern(self) -> None:
        """Tests main with custom pattern."""
        # Custom pattern only allows branches starting with 'dev-'
        assert main(["--branch", "dev-something", "--pattern", r"^dev-.*$"]) == 0
        assert main(["--branch", "feat/something", "--pattern", r"^dev-.*$"]) == 1

    @patch("enable.pre_commit_hooks.check_branch_name.get_current_branch")
    def test_main_uses_current_branch(self, mock_get_branch: pytest.fixture) -> None:  # ty:ignore[invalid-type-form]
        """Tests main uses current branch when no --branch arg."""
        mock_get_branch.return_value = "feat/test-branch"
        assert main([]) == 0
        mock_get_branch.assert_called_once()

    @patch("enable.pre_commit_hooks.check_branch_name.get_current_branch")
    def test_main_current_branch_invalid(self, mock_get_branch: pytest.fixture) -> None:  # ty:ignore[invalid-type-form]
        """Tests main fails when current branch is invalid."""
        mock_get_branch.return_value = "bad-branch-name"
        assert main([]) == 1


class TestGetCurrentBranch:
    """Tests for get_current_branch function."""

    @patch("subprocess.run")
    def test_get_current_branch_success(self, mock_run: pytest.fixture) -> None:  # ty:ignore[invalid-type-form]
        """Tests successful branch retrieval."""
        mock_run.return_value.stdout = "feature/my-branch\n"
        mock_run.return_value.returncode = 0
        result = get_current_branch()
        assert result == "feature/my-branch"

    @patch("subprocess.run")
    def test_get_current_branch_failure(self, mock_run: pytest.fixture) -> None:  # ty:ignore[invalid-type-form]
        """Tests branch retrieval failure."""
        from subprocess import CalledProcessError

        mock_run.side_effect = CalledProcessError(1, "git", stderr="not a git repo")
        with pytest.raises(ValueError, match="Failed to get current branch"):
            get_current_branch()
