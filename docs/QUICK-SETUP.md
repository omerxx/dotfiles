# Quick Setup Guide

Get your full development environment running in under 1 hour.

---

## Step 1: Install Xcode Command Line Tools

```bash
xcode-select --install
```

This provides Git and essential build tools required by Homebrew and Nix.

---

## Step 2: Clone and Bootstrap

```bash
git clone https://github.com/Klaudioz/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The bootstrap script installs everything automatically:
- Rosetta 2 (for Intel compatibility)
- Homebrew
- Nix with flakes enabled
- nix-darwin (declarative macOS configuration)
- All packages and applications via `flake.nix`
- Dotfile symlinks via stow

---

## Step 3: Configure for Your Machine

Check your hostname and update `nix-darwin/flake.nix` if needed:

```bash
scutil --get ComputerName  # Shows your machine name
```

The flake.nix includes configurations for:
- `Claudios-MacBook-Pro`
- `m4-mini`

If your hostname differs, add a new `darwinConfigurations` block.

---

## Step 4: Rebuild (after config changes)

```bash
darwin-rebuild switch --flake ~/dotfiles/nix-darwin
```

---

## Post-Install Setup (10 min)

### 1. Install tmux Plugins

```bash
tmux
# Press Ctrl-A then Shift-I
```

### 2. Install Neovim Plugins

```bash
nvim
# Plugins auto-install, or run :Lazy install
```

### 3. Initialize Tools

```bash
# Initialize zoxide database
cd ~ && cd ~/Documents && cd ~/Downloads

# Optional: Atuin cloud sync
atuin register -u <username> -e <email>
atuin login -u <username>
atuin sync
```

### 4. Build calapp (Optional - Calendar Notifications)

```bash
git clone https://github.com/omerxx/GoMaCal.git /tmp/GoMaCal
cd /tmp/GoMaCal
go build -o calapp
mkdir -p ~/dotfiles/hammerspoon/calendar-app
cp calapp ~/dotfiles/hammerspoon/calendar-app/
```

### 5. Grant Accessibility Permissions

Window management tools require Accessibility access. Run this to open settings:

```bash
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
```

Enable access for:
- aerospace
- skhd
- Hammerspoon
- sketchybar

Note: This step cannot be automated on macOS without disabling SIP.

---

## Verify Installation

Run the verification script:

```bash
cd ~/dotfiles
./setup.sh --verify
```

Or manually check:

```bash
# Core tools
nvim --version
tmux -V
fzf --version

# Status bar
sketchybar --version

# Window management
aerospace --version
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Rebuild nix config | `darwin-rebuild switch --flake ~/dotfiles/nix-darwin` |
| Update tmux plugins | `Ctrl-A` then `Shift-U` |
| Update nvim plugins | `:Lazy update` |
| Re-stow dotfiles | `cd ~/dotfiles && stow .` |

---

## Troubleshooting

### Homebrew not found after Nix install

Restart your terminal or run:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Nix flakes not enabled

Ensure `~/.config/nix/nix.conf` contains:
```
experimental-features = nix-command flakes
```

### Stow conflicts

Remove existing configs first:
```bash
rm -rf ~/.config/nvim ~/.config/tmux
cd ~/dotfiles && stow .
```
