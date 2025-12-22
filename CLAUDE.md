# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Critical: Edit Files in This Repository Only

**NEVER edit files directly in `~/.config/`**. This repository is the source of truth. All configuration changes must be made to files within `~/dotfiles/`. Stow creates symlinks from `~/.config/` pointing to this repo.

Example: To modify Ghostty config, edit `~/dotfiles/ghostty/config`, NOT `~/.config/ghostty/config`.

After editing, run `./setup.sh` to ensure symlinks are current.

## Repository Overview

macOS development environment managed with Nix-Darwin, Homebrew, and GNU Stow. Configuration targets Apple Silicon Macs with a six-layer architecture: System (nix-darwin) → Window Management (AeroSpace) → Terminal (Ghostty/WezTerm) → Shell (Nushell/Zsh) → Multiplexer (tmux) → Editor (Neovim/LazyVim).

## Workflow

**After making changes, always commit and push immediately.** Then tell the user to run `./setup.sh --update`.

**Always use `setup.sh` for updates. Never run `darwin-rebuild` directly.**

## Commit Rules

- **NEVER add `Co-Authored-By` trailers to commit messages**
- Keep commit messages concise and descriptive
- Use conventional commit format: `type: description` (e.g., `feat:`, `fix:`, `docs:`)

## Key Commands

```bash
# Bootstrap new machine (installs Homebrew, Nix, nix-darwin, stow)
./bootstrap.sh

# Apply all changes (pulls, rebuilds nix-darwin, re-stows dotfiles)
./setup.sh --update

# Symlink dotfiles only
./setup.sh

# Verify all tools installed correctly
./setup.sh --verify

# Set up GitHub SSH with 1Password
./setup.sh --github
```

## Architecture

**Package Management**: Nix-Darwin (`nix-darwin/flake.nix`) manages system packages and macOS defaults. Homebrew handles GUI apps (casks) and packages not in nixpkgs. Stow symlinks config directories to `~/.config/` (controlled by `.stowrc`).

**Configuration Locations**:
- `nix-darwin/flake.nix` - System packages, Homebrew casks/brews, macOS system defaults
- `nix-darwin/home.nix` - Home Manager user configuration
- Each tool directory (nvim/, tmux/, etc.) maps to `~/.config/<tool>/`

**Multi-machine support**: flake.nix contains `darwinConfigurations` for different hostnames. Check hostname with `scutil --get ComputerName` and add new configurations as needed.

## Configuration Notes

- Neovim uses LazyVim (`nvim/lua/config/lazy.lua`) with plugins in `nvim/lua/plugins/`
- tmux prefix is `Ctrl-A` (not default `Ctrl-B`); uses tpm for plugins
- Shell integrations: Starship prompt, zoxide (directory jumping), Atuin (history sync), Carapace (completions)
- Window management: AeroSpace tiling WM with skhd for hotkeys
- After bootstrap, accessibility permissions needed for: AeroSpace, skhd, sketchybar, Hammerspoon
