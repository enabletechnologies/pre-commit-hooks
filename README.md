<p align="center">
  <img width="300px" src="./logo.png">
</p>

<h1 align="center">pre-commit-hooks</h1>




# Using pre-commit-hooks with pre-commit

Out-of-the-box hooks for pre-commit

See also: https://github.com/pre-commit/pre-commit

Add this to your `.pre-commit-config.yaml`

```yaml
  - repo: https://github.com/enabletechnologies/pre-commit-hooks
    rev: v0.1.0 # automatically updated by Commitizen
    hooks:
      - id: commitizen
```

## Hooks available

### `commitizen`

Check all commit messages on the current branch. This is useful for checking commit messages after the fact (e.g., pre-push or in CI) since the existing hook only works at commit time.

[Commitizen](https://commitizen-tools.github.io/commitizen/) is release management tool designed for teams.

Commitizen assumes your team uses a standard way of committing rules and from that foundation, it can bump your project's version, create the changelog, and update files.

By default, commitizen uses conventional commits, but you can build your own set of rules, and publish them.
