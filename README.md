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
    rev: v0.1.0 
    hooks:
      - id: commitizen
```

### `ruff`

A [pre-commit](https://pre-commit.com/) hook for [Ruff](https://beta.ruff.rs/docs/).

Ruff's pre-commit hook should be placed after other formatting tools, such as Black , unless you enable autofix, in which case, Ruff's pre-commit hook should run before Black, isort, and other formatting tools, as Ruff's autofix behavior can output code changes that require reformatting.

Add this to your `.pre-commit-config.yaml`

```yaml
  - repo: https://github.com/enabletechnologies/pre-commit-hooks
    rev: v0.1.0 
    hooks:
    -   id: ruff
        args: [--fix, --exit-non-zero-on-fix]
```

### `black`

A [pre-commit](https://pre-commit.com/) hook for [black](https://black.readthedocs.io/en/stable/).
pyupgrade is a tool to automatically upgrade syntax for newer versions of the language.

Add this to your `.pre-commit-config.yaml`

```yaml
  - repo: https://github.com/enabletechnologies/pre-commit-hooks
    rev: v0.1.0 
    hooks:
    -   id: black
```

### `typos`

A [pre-commit](https://pre-commit.com/) hook for [typos](https://github.com/crate-ci/typos).
typos is a  Source code spell checker

Add this to your `.pre-commit-config.yaml`

```yaml
  - repo: https://github.com/enabletechnologies/pre-commit-hooks
    rev: v0.1.0 
    hooks:
    -   id: typos
```
### `markdownlint-fix`

A [pre-commit](https://pre-commit.com/) hook for [markdownlint](https://github.com/DavidAnson/markdownlint).
typos is a  Source code spell checker

Add this to your `.pre-commit-config.yaml`

```yaml
  - repo: https://github.com/enabletechnologies/pre-commit-hooks
    rev: v0.1.0 
    hooks:
    -   id: markdownlint-fix
```



### `out of box pre-commit hooks`

In addition to above list you can add standard [pre-commit-hooks](https://pre-commit.com/hooks.html) provided by pre-commit itself. 

Applicable languages are `python,golang,rust`

```yaml
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
    -   id: check-toml
    -   id: check-yaml
        args:
        -   --unsafe
    - id: check-json
```