# Dotfiles Summary

A complete macOS development environment configuration managing system settings, terminals, shells, editors, window management, and development tools through declarative configuration files.

**Repository**: https://github.com/Klaudioz/dotfiles

---

## Installation

### Method 1: Stow (Simple Symlinks)

```bash
git clone https://github.com/Klaudioz/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh  # or: stow .
```

Symlinks configuration directories to `~/.config/`. Requires manual app installation via Homebrew.

### Method 2: Nix-Darwin (Declarative)

```bash
git clone https://github.com/Klaudioz/dotfiles.git ~/dotfiles
cd ~/dotfiles/nix-darwin
# Edit flake.nix: update hostname and username
nix run nix-darwin -- switch --flake .
```

Subsequent rebuilds: `darwin-rebuild switch --flake ~/dotfiles/nix-darwin`

**Prerequisites**: Nix with flakes enabled via `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`

---

## Architecture Overview

```
Layer 6: Editing       -> Neovim + LazyVim + 50+ plugins
Layer 5: Multiplexing  -> tmux + tpm plugins
Layer 4: Shell         -> Nushell / Zsh + Starship prompt
Layer 3: Terminal      -> Ghostty / WezTerm
Layer 2: Windows       -> AeroSpace + skhd
Layer 1: System        -> nix-darwin + home-manager
```

---

## Configuration Files

| Component | Config Location | Purpose |
|-----------|----------------|---------|
| **Neovim** | `nvim/init.lua`, `nvim/lazy-lock.json` | Editor with LazyVim distribution |
| **tmux** | `tmux/tmux.conf`, `tmux/tmux.reset.conf` | Terminal multiplexer |
| **Nushell** | `nushell/config.nu`, `nushell/env.nu` | Modern structured shell |
| **Zsh** | `zshrc/.zshrc` | Traditional shell |
| **Ghostty** | `ghostty/config` | Primary terminal emulator |
| **WezTerm** | `wezterm/wezterm.lua` | Alternative terminal emulator |
| **AeroSpace** | `aerospace/aerospace.toml` | Tiling window manager |
| **skhd** | `skhd/skhdrc` | Global hotkey daemon |
| **Starship** | `starship/starship.toml` | Cross-shell prompt |
| **Nix-Darwin** | `nix-darwin/flake.nix`, `nix-darwin/home.nix` | System configuration |

---

## Neovim Configuration

Built on **LazyVim** distribution with lazy.nvim plugin manager. Plugins version-locked in `lazy-lock.json`.

### Key Plugin Categories

| Category | Plugins |
|----------|---------|
| **LSP** | nvim-lspconfig, mason.nvim, mason-lspconfig.nvim |
| **Debugging** | nvim-dap, nvim-dap-ui, nvim-dap-go |
| **Completion** | blink.cmp, friendly-snippets |
| **AI** | copilot.lua, opencode.nvim |
| **Syntax** | nvim-treesitter, nvim-treesitter-textobjects |
| **UI** | catppuccin, tokyonight.nvim, lualine.nvim, bufferline.nvim |
| **Navigation** | neo-tree.nvim, fzf-lua, harpoon |
| **Git** | gitsigns.nvim |
| **Formatting** | conform.nvim, nvim-lint |
| **Search** | grug-far.nvim, flash.nvim |
| **Session** | persistence.nvim |

### Platform Override
```lua
vim.g.codeium_platform_override = "mac-arm64"  -- Apple Silicon support
```

---

## tmux Configuration

**Prefix**: `Ctrl-A`

### Core Settings
- Vi mode keys enabled
- History limit: 1,000,000 lines
- Status bar at top
- Zero escape delay
- System clipboard integration

### Key Plugins
- **tmux-resurrect** + **tmux-continuum**: Session persistence with auto-restore
- **tmux-sessionx**: Fuzzy session switching with zoxide integration
- **tmux-floax**: Floating panes (80% width/height, magenta border)
- **tmux-fzf-url**: URL extraction from pane content
- **catppuccin**: Theme

### Keybindings (tmux.reset.conf)

| Key | Action |
|-----|--------|
| `^D` | Detach |
| `H/L` | Previous/next window |
| `h/j/k/l` | Vim-style pane navigation |
| `s/v` | Split horizontal/vertical |
| `S` | Choose session |
| `,/./-/=` | Resize panes |

---

## Shell Configuration

### Nushell (Primary)
- Vi editing mode
- Structured data pipelines
- Custom themes (dark/light)
- 50+ custom keybindings

### Zsh (Alternative)
- Case-insensitive completion
- Auto-suggestions plugin
- kubectl and AWS CLI completions

### Common Aliases (Both Shells)

**Git:**
| Alias | Command |
|-------|---------|
| `gc` | `git commit -m` |
| `gca` | `git commit -a -m` |
| `gp` | `git push origin HEAD` |
| `gpu` | `git pull origin` |
| `gst` | `git status` |
| `glog` | `git log --graph` |
| `gco` | `git checkout` |
| `ga` | `git add -p` |

**Kubernetes:**
| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `ka` | `kubectl apply -f` |
| `kg` | `kubectl get` |
| `kd` | `kubectl describe` |
| `kdel` | `kubectl delete` |
| `kl` | `kubectl logs -f` |
| `ke` | `kubectl exec -it` |
| `kc` | `kubectx` |
| `kns` | `kubens` |

**Navigation:**
| Alias | Command |
|-------|---------|
| `v` | `nvim` |
| `c` / `cl` | `clear` |
| `l` | `eza` listing |
| `cx` | `cd` + list contents |

**Docker (Zsh):**
| Alias | Command |
|-------|---------|
| `dco` | `docker compose` |
| `dps` | `docker ps` |
| `dx` | `docker exec -it` |

### Tool Integrations (Both Shells)
- **Starship**: Cross-shell prompt
- **zoxide**: Smart `cd` via `z` command
- **atuin**: Cloud-synced shell history
- **direnv**: Per-directory environment variables
- **carapace** (Nushell): Multi-shell completion engine

---

## Window Management

### AeroSpace (Tiling WM)
- i3-inspired tiling on macOS
- Alt-based keybindings
- 4 workspaces with monitor assignments

**Main Mode Keybindings:**
| Key | Action |
|-----|--------|
| `alt-h/j/k/l` | Focus left/down/up/right |
| `alt-shift-h/j/k/l` | Move window |
| `alt-1/2/3/4` | Switch workspace |
| `alt-shift-1/2/3/4` | Move window to workspace |
| `alt-/` | Toggle tiles horizontal/vertical |
| `alt-,` | Toggle accordion layout |

**Service Mode** (`alt-shift-;`):
- `esc`: Reload config
- `r`: Reset workspace layout
- `f`: Toggle floating/tiling

**Floating Apps**: Telegram, Finder, Safari, Discord, Mail, Camera, QuickTime

**Gap Configuration**: 20px inner, 20px outer (10px top for menu bar)

### skhd (Hotkey Daemon)
Application launchers:
- `alt-s`: Safari
- `alt-t`: Telegram
- `alt-g`: Ghostty

---

## Terminal Emulators

### Ghostty (Primary)
```
font-size = 19
background-blur-radius = 20
window-decoration = false
macos-option-as-alt = true
```

### WezTerm (Alternative)
- Color scheme: Catppuccin Mocha
- Font: JetBrains Mono 16pt
- `Ctrl+q`: Toggle fullscreen
- `Ctrl+'`: Clear scrollback
- `Ctrl+Click`: Open links

---

## Nix-Darwin Configuration

### System Packages
vim, direnv, sshs, glow, nushell, carapace

### Homebrew Integration
- **Casks**: wireshark, google-chrome
- **Brews**: imagemagick

### macOS System Defaults
- Dock auto-hide enabled
- Finder: show all extensions, column view
- Screenshots: `~/Pictures/screenshots`
- Touch ID for sudo enabled

### Platform
- Architecture: `aarch64-darwin` (Apple Silicon)
- Nix experimental features: `nix-command flakes`

---

## Development Workflow Integration

### fzf Integration Points
- **Shell**: `FZF_DEFAULT_COMMAND` uses `fd` for file discovery
- **Neovim**: fzf-lua for file finding, buffer switching, grep
- **tmux**: tmux-fzf, tmux-fzf-url, tmux-sessionx

### Custom Navigation Functions
- `cx [dir]`: Change directory and list contents
- `fcd`: Fuzzy find and cd
- `fv`: Fuzzy find and open in nvim
- `f`: Fuzzy find and copy path to clipboard
- `ff` (Nushell): Fuzzy find AeroSpace windows

### AI-Assisted Development
- **GitHub Copilot**: Real-time code suggestions via copilot.lua
- **Codeium**: Alternative AI completion
- **opencode.nvim**: Additional AI features

### Session Persistence
- **tmux**: resurrect + continuum (auto-save every 15 min, auto-restore)
- **Neovim**: persistence.nvim for editor sessions
- **Shell history**: Atuin cloud sync
- **Directory frecency**: zoxide database
- **Plugin versions**: lazy-lock.json, flake.lock

---

## Environment Variables

| Variable | Value | Location |
|----------|-------|----------|
| `EDITOR` | `nvim` | env.nu, .zshrc |
| `STARSHIP_CONFIG` | `~/.config/starship/starship.toml` | env.nu |
| `NIX_CONF_DIR` | `~/.config/nix` | env.nu |
| `CARAPACE_BRIDGES` | `zsh,fish,bash,inshellisense` | env.nu |
| `DIRENV_LOG_FORMAT` | `""` (silent) | config.nu |

### PATH Additions (Nushell)
Conditional (not in Nix shell or Devbox):
- `/opt/homebrew/bin`
- `/run/current-system/sw/bin`
- `~/.local/bin`
- Ruby gem paths

---

## Quick Reference

### Initialize After Installation

```bash
# Neovim plugins (auto on first launch)
nvim
:Lazy install

# tmux plugins (prefix + I)
tmux
# Press Ctrl-A then Shift-I

# zoxide database
cd ~ && cd ~/Documents && cd ~/Downloads

# atuin (optional cloud sync)
atuin register -u <username> -e <email>
atuin login -u <username>
atuin sync
```

### Common Commands

```bash
# Rebuild nix-darwin config
darwin-rebuild switch --flake ~/dotfiles/nix-darwin

# Update nix flake inputs
nix flake update

# Re-stow dotfiles
cd ~/dotfiles && stow .

# Update neovim plugins
nvim
:Lazy update
```
