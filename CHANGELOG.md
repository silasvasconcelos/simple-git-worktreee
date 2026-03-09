# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-09

### Added

- `git wt add <branch> [base]` command to create worktrees with automatic fetch, default-branch detection, and `.gitignore` management.
- `git wt list` command to list all worktrees (alias `ls`).
- `git wt remove <branch>` command to remove a worktree (alias `rm`).
- `git wt prune` command to clean up stale worktree references.
- `git wt path <branch>` command to print the absolute path of a worktree.
- `git wt help` and `git wt version` commands.
- Per-command `--help` / `-h` flag with detailed usage, arguments, and examples.
- Automatic `.worktrees/` directory creation and `.gitignore` entry management.
- `install.sh` installer for Linux and macOS.
- `install.ps1` installer for Windows PowerShell.
- Homebrew formula for `brew install`.
- Scoop manifest for `scoop install`.
- CI workflow with ShellCheck linting and smoke tests on Ubuntu and macOS.
- Release workflow with automated GitHub Releases, Homebrew tap updates, and Scoop bucket updates.

[1.0.0]: https://github.com/silasvasconcelos/simple-git-worktreee/releases/tag/v1.0.0
