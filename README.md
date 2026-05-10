# Dotfiles Overview
This repository is organized around explicit GNU Stow package roots so home-level and XDG config files are linked to the correct destinations.

## Layout
- `home/`
  - Files that should land directly in `~` (for example `.zshrc`, `.bashrc`, `.ssh/config`, `.tmux.conf`).
- `config/`
  - Directories that should land under `~/.config` (for example `nvim`, `ghostty`, `starship`, `zellij`).
- `disabled/`
  - Packages kept in-repo but not automatically stowed by `setup.sh` (platform-specific or legacy content).

## Setup

Use `setup.sh` instead of running `stow .` manually:

```bash
./setup.sh [apply|dry-run|restow|delete]
```

Modes:
- `apply` (default): create links
- `dry-run`: preview only
- `restow`: recreate links
- `delete`: remove links created by stow

What `setup.sh` does:
- stows `home` into `~`
- stows `config` into `~/.config`

## `.stowrc`
Global Stow ignores live in `.stowrc`:

- `--ignore=.stowrc`
- `--ignore=DS_Store`
- `--ignore=disabled/*`

## Adding dotfiles

1. Place the file/directory in the correct package root:
   - `home/` for `~`
   - `config/` for `~/.config`
2. Run `./setup.sh dry-run` and resolve conflicts.
3. Run `./setup.sh apply`.

## Conflict handling

If `dry-run` reports conflicts:
- Back up existing files/directories.
- Remove or move the conflicting target.
- Re-run `./setup.sh dry-run` until clean.
- Apply with `./setup.sh apply`.

Avoid running `stow .` at repo root, since this layout is designed to be managed through `setup.sh`.
