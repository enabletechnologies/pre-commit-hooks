<p align="center">
  <img width="300px" src="./logo.png">
</p>

<h1 align="center">pre-commit-hooks</h1>

Out-of-the-box hooks for pre-commit

See also: https://github.com/pre-commit/pre-commit


### Using pre-commit-hooks with pre-commit

Add this to your `.pre-commit-config.yaml`

```yaml
-   repo: https://github.com/enabletechnologies/pre-commit-hooks
    rev: v0.0.1  # Use the ref you want to point at
    hooks:
    -   id: trailing-whitespace
    # -   id: ...
```

### Hooks available

#### `check-added-large-files`
Prevent giant files from being committed.
  - Specify what is "too large" with `args: ['--maxkb=123']` (default=500kB).
  - Limits checked files to those indicated as staged for addition by git.
  - If `git-lfs` is installed, lfs files will be skipped
    (requires `git-lfs>=2.2.1`)
  - `--enforce-all` - Check all listed files not just those staged for
    addition.
