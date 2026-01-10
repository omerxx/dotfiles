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

### 6. Configure AI Coding Tools

#### OpenCode with oh-my-opencode (Primary AI Tool)

OpenCode is installed via Homebrew (included in flake.nix). The oh-my-opencode plugin is automatically cloned by `setup.sh` to `~/.local/share/oh-my-opencode`.

**Required: Set your OpenAI API key** (oh-my-opencode uses OpenAI models by default):

```bash
export OPENAI_API_KEY="your-openai-api-key"
```

Add this to your shell profile (`~/.zshrc` or nushell config) for persistence.

**Verify installation:**

```bash
opencode --version
```

**Configuration files:**
- Global config: `~/.config/opencode/opencode.json` (managed by this repo)
- User overrides: `~/.config/opencode/oh-my-opencode.json` (optional)
- Project config: `.opencode/oh-my-opencode.json` (optional, per-project)

#### OpenCode extensions (OCX)

`ocx` is installed via `nix-darwin/flake.nix`. Use it to install project extensions like `opencode-worktree`:

```bash
ocx init
ocx registry add --name kdco https://registry.kdco.dev
ocx add kdco/worktree
```

#### Other AI CLI Tools (Optional)

```bash
# Configure npm global directory (one-time setup)
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Install Claude Code (Anthropic)
npm install -g @anthropic-ai/claude-code

# Install Codex CLI (OpenAI)
npm install -g @openai/codex

# Install aicommit2 (AI commit messages)
npm install -g aicommit2

# Install Gemini CLI (Google)
go install github.com/eliben/gemini-cli@latest
```

**Configure delta for git diffs:**

```bash
git config --global core.pager delta
```

**API Keys for other tools:**

```bash
export ANTHROPIC_API_KEY="your-key-here"
export GEMINI_API_KEY="your-key-here"
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

# AI CLI tools
opencode --version      # Primary (installed via brew)
claude --version        # Optional
codex --version         # Optional
gemini-cli --version    # Optional
aichat --version
aicommit2 --version     # Optional

# Developer utilities
lazygit --version
uv --version
delta --version

# Cloud CLIs
kubectl version --client
aws --version
gcloud --version
doctl version
flyctl version
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

### Nix command not found after installation

The Nix daemon needs to be sourced in your current shell:
```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Then retry the bootstrap script or run nix-darwin manually:
```bash
nix run nix-darwin/master#darwin-rebuild -- switch --flake ./nix-darwin#<your-hostname>
```

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

### Unfree package errors (ngrok, etc.)

If you see errors about unfree licenses, the `nixpkgs.config.allowUnfree = true;` setting should be in your flake.nix configuration block.

### Stow conflicts

Remove existing configs first:
```bash
rm -rf ~/.config/nvim ~/.config/tmux
cd ~/dotfiles && stow .
```

### $HOME ownership warning with sudo

If you see `warning: $HOME is not owned by you`, this happens when running nix commands with sudo. Run without sudo when possible:
```bash
nix run nix-darwin/master#darwin-rebuild -- switch --flake ./nix-darwin#<hostname>
```
