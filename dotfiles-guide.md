# Working with Dotfiles and Stow
GNU Stow is used here with two package roots so home-level files and XDG config files go to different targets cleanly.

## Repository layout

- `home/` → stowed to `~`
- `config/` → stowed to `~/.config`
- `disabled/` → packages kept in-repo but not auto-stowed

## Use `setup.sh` (recommended)

Run from repo root:

```sh
./setup.sh [apply|dry-run|restow|delete]
```

Modes:
- `apply` (default): create links
- `dry-run`: simulate only
- `restow`: remove and recreate links
- `delete`: remove links

`setup.sh` runs:
- `stow ... --target="$HOME" home`
- `stow ... --target="$HOME/.config" config`

## Conflict workflow

Preview first:

```sh
./setup.sh dry-run
```

If conflicts are reported:
1. Back up existing files/directories.
2. Remove or move conflicting targets.
3. Re-run `./setup.sh dry-run`.
4. Apply with `./setup.sh apply`.

## Adding new files

- For files that belong directly in home (like `.zshrc`), add them under `home/`.
- For app config directories (like `nvim`, `ghostty`), add them under `config/`.
- For platform-specific or archived packages, place them under `disabled/`.

## Notes

- `.stowrc` contains global ignore rules (including `disabled/*`).
- Avoid `stow .` at repo root; use `setup.sh` so both targets are handled correctly.
