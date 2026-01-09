<p align="center">
  <img width="300px" src="./logo.png">
</p>

<h1 align="center">pre-commit-hooks</h1>

# Using pre-commit-hooks with pre-commit

Out-of-the-box hooks for pre-commit

See also: https://github.com/pre-commit/pre-commit

## Hooks available

### `commitizen`

Check all commit messages on the current branch. This is useful for checking commit messages after the fact (e.g., pre-push or in CI) since the existing hook only works at commit time.

[Commitizen](https://commitizen-tools.github.io/commitizen/) is release management tool designed for teams.

Commitizen assumes your team uses a standard way of committing rules and from that foundation, it can bump your project's version, create the changelog, and update files.

By default, commitizen uses conventional commits, but you can build your own set of rules, and publish them.

Add this to your `.pre-commit-config.yaml`

```yaml
- repo: https://github.com/enabletechnologies/pre-commit-hooks
  rev: v0.2.0
  hooks:
    - id: commitizen
```

### `lint`

A [pre-commit](https://pre-commit.com/) hook for Linting. It runs local makefile lint

Add this to your `.pre-commit-config.yaml`

```yaml
- repo: https://github.com/enabletechnologies/pre-commit-hooks
  rev: v0.2.0
  hooks:
    - id: lint
```

### `check_uv_toml`

A [pre-commit](https://pre-commit.com/) hook for Linting uv config and prevents path dependencies from being checked in

Add this to your `.pre-commit-config.yaml`

```yaml
- repo: https://github.com/enabletechnologies/pre-commit-hooks
  rev: v0.7.1
  hooks:
    - id: check_uv_toml
```

### `check_commit_msg`

A [pre-commit](https://pre-commit.com/) hook for checking commit message for issue number and typos.

Add this to your `.pre-commit-config.yaml`

```yaml
- repo: https://github.com/enabletechnologies/pre-commit-hooks
  rev: v0.7.1
  hooks:
    - id: check_commit_msg
```

### `check_branch_name`

A [pre-commit](https://pre-commit.com/) hook for checks if the current git branch name follows the naming convention.

Add this to your `.pre-commit-config.yaml`

```yaml
- repo: https://github.com/enabletechnologies/pre-commit-hooks
  rev: v0.7.1
  hooks:
    - id: check_branch_name
```

### `out of box pre-commit hooks`

In addition to above list you can add standard [pre-commit-hooks](https://pre-commit.com/hooks.html) provided by pre-commit itself.

Applicable languages are `python,golang,rust`

```yaml
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.4.0
  hooks:
    - id: check-toml
      stages: [pre-commit]
    - id: check-yaml
      args:
        - --unsafe
      stages: [pre-commit]
    - id: check-json
      stages: [pre-commit]
```
