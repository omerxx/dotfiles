# AGENTS.md

Guidelines for AI agents working in this dotfiles repository.

## Core Purpose

**This repository is a REPEATABLE AUTOMATION SYSTEM.**

When the user asks to "install X" or "add tool Y", they mean:
- Add it to `nix-darwin/flake.nix` so it's automatically installed on ANY machine
- NOT run an install command that only affects the current machine

Every tool, package, and configuration must be declaratively defined here so that running `./setup.sh --update` on a fresh machine produces an identical environment.

**WRONG**: `brew install tool` / `bun add -g package` / any imperative install
**RIGHT**: Add to `flake.nix` → commit → push → `./setup.sh --update`

## Environment

- **Primary shell**: Nushell (`nushell/config.nu`, `nushell/env.nu`)
- Zsh is available as fallback (`zshrc/.zshrc`)

## Critical Rules

### 1. This Repo is the Single Source of Truth

**NEVER edit files outside `~/dotfiles/`**. All configuration lives here for full reproducibility across machines.

```
WRONG: ~/.config/ghostty/config
WRONG: ~/Library/Application Support/nushell/config.nu
WRONG: Any path outside ~/dotfiles/

RIGHT: ~/dotfiles/ghostty/config
RIGHT: ~/dotfiles/nushell/config.nu
```

Stow creates symlinks from `~/.config/` → this directory. The `setup.sh` script handles special cases (Nushell, VS Code).

### 2. Commit and Push After EVERY Change

**Every modification must be committed and pushed immediately.** This ensures:
- Full reproducibility on any new machine
- No configuration drift between machines
- Complete history of all changes

```bash
# After ANY edit:
git add -A && git commit -m "type: description" && git push
```

Then tell user to run `./setup.sh --update` on other machines.

## Commands

### Primary Commands

```bash
./setup.sh                    # Symlink dotfiles with stow
./setup.sh --update           # Pull, rebuild nix-darwin, re-stow (MAIN COMMAND)
./setup.sh --verify           # Check all tools installed
./setup.sh --github           # Set up GitHub SSH via 1Password
./bootstrap.sh                # Initial setup on new machine
```

### Nix-Darwin

```bash
# NEVER run darwin-rebuild directly. Use ./setup.sh --update instead.
# For debugging only:
darwin-rebuild switch --flake ~/dotfiles/nix-darwin
```

### Verification

```bash
./setup.sh --verify           # Verify all tools are installed
stow -n .                     # Dry-run stow (check for conflicts)
```

## Repository Structure

```
dotfiles/
├── nix-darwin/               # Nix-Darwin config (flake.nix, home.nix)
├── nvim/lua/                 # Neovim/LazyVim (Lua files)
├── tmux/                     # tmux config
├── ghostty/                  # Ghostty terminal config
├── aerospace/                # AeroSpace window manager (TOML)
├── sketchybar/               # Status bar (shell scripts)
├── homebrew-tap/Casks/       # Local Homebrew casks (version pinning)
└── setup.sh                  # Main setup script
```

Each directory maps to `~/.config/<tool>/` via stow (except those in `.stowrc` ignore).

## Code Style

### Shell Scripts (Bash)

```bash
#!/usr/bin/env bash
set -e                        # Exit on error (required)

# Colors (use these exact variables)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Print helpers
echo -e "${GREEN}✓${NC} Success message"
echo -e "${RED}✗${NC} Error message"
echo -e "${YELLOW}!${NC} Warning message"
```

- Use `command -v` to check if tools exist, not `which`
- Quote all variable expansions: `"$VAR"` not `$VAR`
- Use `[[ ]]` for conditionals in bash, `[ ]` for POSIX sh
- Prefer `$()` over backticks for command substitution

### Lua (Neovim)

LazyVim plugin pattern - always return a table:

```lua
return {
  "plugin/name",
  opts = {
    setting = value,
  },
}
```

Formatting (enforced by stylua.toml):
- 2-space indentation
- 120 character line width
- Spaces for indent (not tabs)

### Nix

```nix
{
  environment.systemPackages = [
    pkgs.tool-name           # Lowercase, hyphenated
  ];

  homebrew.casks = [
    "app-name"               # Strings for casks/brews
  ];
}
```

- Add new packages to `environment.systemPackages` (nix) or `homebrew.brews`/`homebrew.casks`
- For version-pinned apps, create local cask in `homebrew-tap/Casks/`

### TOML (AeroSpace, Starship)

```toml
# Section headers
[section]
key = 'value'               # Single quotes for strings
number = 100

[[array-of-tables]]
key = 'value'
```

## Configuration Locations

| Config Type | Location | Notes |
|-------------|----------|-------|
| System packages | `nix-darwin/flake.nix` | `environment.systemPackages` |
| Homebrew casks | `nix-darwin/flake.nix` | `homebrew.casks` |
| Homebrew brews | `nix-darwin/flake.nix` | `homebrew.brews` |
| macOS defaults | `nix-darwin/flake.nix` | `system.defaults` |
| User home config | `nix-darwin/home.nix` | Home Manager |
| Neovim plugins | `nvim/lua/plugins/` | One file per plugin/group |
| Stow ignores | `.stowrc` | Patterns to skip |

## Adding New Configurations

### New Tool Config

1. Create directory: `toolname/` (matches `~/.config/toolname/`)
2. Add config files inside
3. Run `./setup.sh` to symlink
4. If tool needs special handling, add to `.stowrc` ignore and handle in `setup.sh`

### New Package

1. Add to `nix-darwin/flake.nix`:
   - Nix package: `pkgs.package-name` in `environment.systemPackages`
   - Homebrew: String in `homebrew.brews` or `homebrew.casks`
2. Run `./setup.sh --update`

### Version-Pinned Homebrew Cask

1. Create `homebrew-tap/Casks/<app>.rb` with cask definition
2. Remove from `nix-darwin/flake.nix` if present
3. Run `./setup.sh --update`

## Multi-Machine Support

`flake.nix` contains `darwinConfigurations` for different hostnames.

```bash
scutil --get ComputerName    # Check current hostname
```

If hostname not in flake.nix, add new configuration block.

## Post-Edit Workflow

1. Make changes in this repo
2. Commit and push immediately
3. Tell user to run `./setup.sh --update`

## Commit Style

```
type: concise description

# Types: feat, fix, docs, chore, refactor
# Examples:
feat: add obsidian to homebrew casks
fix: correct tmux prefix key documentation
docs: update AGENTS.md with nix patterns
```

- NEVER add `Co-Authored-By` trailers
- Keep messages under 72 characters
- No period at end of subject line

## Common Gotchas

- **Nushell config**: Lives in `~/Library/Application Support/nushell/` on macOS, not `~/.config/`. Handled by `setup.sh`.
- **VS Code config**: Special path handling in `setup.sh`, not stow-managed
- **Accessibility permissions**: AeroSpace, sketchybar, Hammerspoon need manual permission grants
- **tmux prefix**: `Ctrl-A` (not default `Ctrl-B`)
- **TPM (tmux plugins)**: Must be installed separately: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
