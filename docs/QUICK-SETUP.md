# Quick Setup Guide

Get your full development environment running in under 1 hour.

## Prerequisites (5 min)

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart your terminal after installing Nix.

---

## Automated Install (15 min)

### 1. Clone the Repository

```bash
git clone https://github.com/Klaudioz/dotfiles.git ~/dotfiles
cd ~/dotfiles/nix-darwin
```

### 2. Configure for Your Machine

Check your hostname and update flake.nix if needed:

```bash
scutil --get ComputerName  # Shows your machine name
```

The flake.nix includes configurations for:
- `Claudios-MacBook-Pro`
- `m4-mini`

If your hostname differs, add a new configuration block or use the existing one.

### 3. Deploy

```bash
# First time setup
nix run nix-darwin -- switch --flake .

# Future updates
darwin-rebuild switch --flake ~/dotfiles/nix-darwin
```

This installs all packages automatically:
- Terminals: ghostty, wezterm
- Tools: neovim, tmux, fzf, ripgrep, bat, eza, zoxide, atuin
- Window management: aerospace, sketchybar, borders, skhd, hammerspoon
- Languages: go, rustup
- Security: nmap, gobuster, ffuf, ngrok

---

## Post-Install Setup (10 min)

### 1. Symlink Dotfiles

```bash
cd ~/dotfiles
./setup.sh
```

### 2. Install tmux Plugins

```bash
tmux
# Press Ctrl-A then Shift-I
```

### 3. Install Neovim Plugins

```bash
nvim
# Plugins auto-install, or run :Lazy install
```

### 4. Initialize Tools

```bash
# Initialize zoxide database
cd ~ && cd ~/Documents && cd ~/Downloads

# Optional: Atuin cloud sync
atuin register -u <username> -e <email>
atuin login -u <username>
atuin sync
```

### 5. Build calapp (Optional - Calendar Notifications)

```bash
git clone https://github.com/omerxx/GoMaCal.git /tmp/GoMaCal
cd /tmp/GoMaCal
go build -o calapp
mkdir -p ~/dotfiles/hammerspoon/calendar-app
cp calapp ~/dotfiles/hammerspoon/calendar-app/
```

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
