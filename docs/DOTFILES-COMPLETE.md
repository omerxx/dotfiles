# Dotfiles Complete Reference

A complete macOS development environment configuration for https://github.com/Klaudioz/dotfiles

---

## Table of Contents

1. [Installation](#installation)
2. [Architecture](#architecture)
3. [Nix-Darwin Configuration](#nix-darwin-configuration)
4. [Terminal Emulators](#terminal-emulators)
5. [Shell Configuration](#shell-configuration)
6. [Neovim Configuration](#neovim-configuration)
7. [tmux Configuration](#tmux-configuration)
8. [Window Management](#window-management)
9. [Development Tools Integration](#development-tools-integration)
10. [Quick Reference](#quick-reference)

---

## Installation

### Method 1: Stow (Simple Symlinks)

```bash
# Prerequisites
brew install stow

# Install
git clone https://github.com/Klaudioz/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh  # or: stow .
```

This creates symlinks from repository directories to `~/.config/` based on `.stowrc`:
- Target: `~/.config`
- Ignores: `.stowrc`, `DS_Store`, `atuin/*`

After stowing, install applications manually:
```bash
# Terminal Emulators
brew install --cask ghostty wezterm

# Shells
brew install nushell zsh starship

# Tools
brew install tmux neovim stow fzf fd ripgrep bat zoxide atuin direnv

# Window Management
brew install --cask nikitabobko/tap/aerospace
```

### Method 2: Nix-Darwin (Declarative)

```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone and configure
git clone https://github.com/Klaudioz/dotfiles.git ~/dotfiles
cd ~/dotfiles/nix-darwin

# Update hostname and username in flake.nix before building
# Check your hostname: scutil --get ComputerName
# Check your username: whoami

# Initial build
nix run nix-darwin -- switch --flake .

# Subsequent rebuilds
darwin-rebuild switch --flake ~/dotfiles/nix-darwin
```

### Post-Installation Setup

```bash
# Neovim plugins (auto on first launch)
nvim
:Lazy install

# tmux plugins
tmux
# Press prefix (Ctrl-A) then Shift-I

# Initialize zoxide database
cd ~ && cd ~/Documents && cd ~/Downloads

# Atuin cloud sync (optional)
atuin register -u <username> -e <email>
atuin login -u <username>
atuin sync
```

---

## Architecture

### Layer Stack

```
Layer 6: Editing       -> Neovim + LazyVim + 50+ plugins
Layer 5: Multiplexing  -> tmux + tpm plugins
Layer 4: Shell         -> Nushell / Zsh + Starship prompt
Layer 3: Terminal      -> Ghostty / WezTerm
Layer 2: Windows       -> AeroSpace + skhd
Layer 1: System        -> nix-darwin + home-manager
```

### Configuration Files

| Component | Config Location | Purpose |
|-----------|----------------|---------|
| **Neovim** | `nvim/init.lua`, `nvim/lazy-lock.json` | Editor with LazyVim |
| **tmux** | `tmux/tmux.conf`, `tmux/tmux.reset.conf` | Terminal multiplexer |
| **Nushell** | `nushell/config.nu`, `nushell/env.nu` | Modern shell |
| **Zsh** | `zshrc/.zshrc` | Traditional shell |
| **Ghostty** | `ghostty/config` | Primary terminal |
| **WezTerm** | `wezterm/wezterm.lua` | Alternative terminal |
| **AeroSpace** | `aerospace/aerospace.toml` | Tiling window manager |
| **skhd** | `skhd/skhdrc` | Global hotkeys |
| **Starship** | `starship/starship.toml` | Cross-shell prompt |
| **Nix-Darwin** | `nix-darwin/flake.nix`, `nix-darwin/home.nix` | System config |

---

## Nix-Darwin Configuration

### System Packages (flake.nix)
- vim, direnv, sshs, glow, nushell, carapace

### Homebrew Integration
- **Casks**: wireshark, google-chrome
- **Brews**: imagemagick

### macOS System Defaults
| Setting | Value |
|---------|-------|
| `dock.autohide` | `true` |
| `dock.mru-spaces` | `false` |
| `finder.AppleShowAllExtensions` | `true` |
| `finder.FXPreferredViewStyle` | `"clmv"` (column view) |
| `screencapture.location` | `"~/Pictures/screenshots"` |
| `security.pam.enableSudoTouchIdAuth` | `true` |

### Platform
- Architecture: `aarch64-darwin` (Apple Silicon)
- Experimental features: `nix-command flakes`

### Common Commands
```bash
darwin-rebuild switch --flake ~/dotfiles/nix-darwin  # Rebuild
darwin-rebuild --rollback                             # Rollback
nix flake update                                      # Update inputs
```

---

## Terminal Emulators

### Ghostty (Primary)

**Config**: `ghostty/config`

```
font-size = 19
background-blur-radius = 20
mouse-hide-while-typing = true
window-decoration = false
macos-option-as-alt = true
```

### WezTerm (Alternative)

**Config**: `wezterm/wezterm.lua`

| Setting | Value |
|---------|-------|
| Color scheme | Catppuccin Mocha |
| Font | JetBrains Mono 16pt |
| Background blur | 30 |
| Tab bar | Disabled |
| Window decoration | RESIZE |

**Keybindings**:
| Key | Action |
|-----|--------|
| `Ctrl+q` | Toggle fullscreen |
| `Ctrl+'` | Clear scrollback |
| `Ctrl+Click` | Open links |

---

## Shell Configuration

### Nushell (Primary Shell)

**Files**: `nushell/env.nu` (environment), `nushell/config.nu` (runtime)

#### Core Settings
| Setting | Value |
|---------|-------|
| `edit_mode` | `vi` |
| `show_banner` | `false` |
| `history.max_size` | `100_000` |
| `history.sync_on_enter` | `true` |

#### Environment Variables
| Variable | Value |
|----------|-------|
| `$env.EDITOR` | `nvim` |
| `$env.STARSHIP_CONFIG` | `~/.config/starship/starship.toml` |
| `$env.NIX_CONF_DIR` | `~/.config/nix` |
| `$env.CARAPACE_BRIDGES` | `zsh,fish,bash,inshellisense` |
| `$env.GEM_HOME` | `~/.gem/ruby/3.4.0` |
| `$env.DIRENV_LOG_FORMAT` | `""` (silent) |

#### PATH (conditional, not in Nix/Devbox shells)
- `/opt/homebrew/bin`
- `/run/current-system/sw/bin`
- `~/.local/bin`
- `~/.opencode/bin`
- Ruby gem paths

#### Tool Integrations
Initialized in `env.nu`, sourced in `config.nu`:
- **Starship**: `starship init nu | save -f ~/.cache/starship/init.nu`
- **Zoxide**: `zoxide init nushell | save -f ~/.zoxide.nu`
- **Carapace**: `carapace _carapace nushell | save --force ~/.cache/carapace/init.nu`
- **Atuin**: `source ~/.local/share/atuin/init.nu`
- **Direnv**: Pre-prompt hook exports JSON and loads into env

#### Custom Commands
```nu
def --env cx [arg] { cd $arg; ls -l }  # cd + list
def ff [] { aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort' }
```

#### Nushell Keybindings
| Key | Action |
|-----|--------|
| `Tab` | Completion menu |
| `Ctrl+n` | IDE completion menu |
| `Ctrl+r` | History search |
| `F1` | Help menu |
| `Ctrl+a` | Move to line start |
| `Ctrl+e` | Move to line end |
| `Ctrl+w` | Delete word backward |
| `Ctrl+k` | Cut to end of line |
| `Ctrl+u` | Cut from start of line |
| `Ctrl+y` | Paste cut buffer |
| `Ctrl+z` | Undo |
| `Ctrl+l` | Clear screen |
| `Ctrl+o` | Open in external editor |

---

### Zsh (Alternative Shell)

**File**: `zshrc/.zshrc`

#### Completion System
- Case-insensitive matching
- Bash compatibility via `bashcompinit`
- kubectl and AWS CLI completions
- zsh-autosuggestions from Homebrew

#### Environment Variables
| Variable | Value |
|----------|-------|
| `LANG` | `en_US.UTF-8` |
| `EDITOR` | `/opt/homebrew/bin/nvim` |
| `GOPATH` | `/Users/omerxx/go` |
| `KUBECONFIG` | `~/.kube/config` |
| `FZF_DEFAULT_COMMAND` | `fd --type f --hidden --follow` |
| `NIX_CONF_DIR` | `$HOME/.config/nix` |
| `XDG_CONFIG_HOME` | `/Users/omerxx/.config` |

#### PATH Order (highest to lowest precedence)
1. Nix: `/run/current-system/sw/bin`
2. Homebrew: `/opt/homebrew/bin`
3. System directories
4. Go: `$GOPATH/bin`
5. Cargo: `~/.cargo/bin`

#### Zsh Keybindings
| Key | Action |
|-----|--------|
| `Ctrl+w` | Execute autosuggestion |
| `Ctrl+e` | Accept autosuggestion |
| `Ctrl+u` | Toggle autosuggestions |
| `Ctrl+L` | Forward word |
| `Ctrl+k` | Up in history |
| `Ctrl+j` | Down in history |
| `jj` | Enter vi command mode |

#### Custom Functions
```bash
cx() { cd "$@" && l; }                           # cd + list
fcd() { cd "$(find . -type d | fzf)" && l; }     # fuzzy cd
f() { find . | fzf | pbcopy; }                   # fuzzy find + copy path
fv() { nvim "$(find . | fzf)"; }                 # fuzzy find + nvim
```

#### Tool Integrations
```bash
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"
```

---

### Common Aliases (Both Shells)

#### Git
| Alias | Command |
|-------|---------|
| `gc` | `git commit -m` |
| `gca` | `git commit -a -m` |
| `gp` | `git push origin HEAD` |
| `gpu` | `git pull origin` |
| `gst` | `git status` |
| `glog` | `git log --graph --topo-order --pretty=format:...` |
| `gdiff` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `gba` | `git branch -a` |
| `ga` | `git add -p` |
| `gadd` | `git add` |
| `gcoall` | `git checkout -- .` |
| `gr` | `git remote` |
| `gre` | `git reset` |

#### Kubernetes
| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `ka` | `kubectl apply -f` |
| `kg` | `kubectl get` |
| `kd` | `kubectl describe` |
| `kdel` | `kubectl delete` |
| `kl` | `kubectl logs -f` |
| `ke` | `kubectl exec -it` |
| `kgpo` | `kubectl get pod` |
| `kgd` | `kubectl get deployments` |
| `kc` | `kubectx` |
| `kns` | `kubens` |

#### Docker (Zsh only)
| Alias | Command |
|-------|---------|
| `dco` | `docker compose` |
| `dps` | `docker ps` |
| `dpa` | `docker ps -a` |
| `dl` | `docker ps -l -q` |
| `dx` | `docker exec -it` |

#### Navigation
| Alias | Command |
|-------|---------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `.....` | `cd ../../../..` |
| `......` | `cd ../../../../..` |

#### Utilities
| Alias | Command |
|-------|---------|
| `v` | `nvim` |
| `c` / `cl` | `clear` |
| `l` | `eza -l --icons --git -a` |
| `lt` | `eza --tree --level=2 --long --icons --git` |
| `cat` | `bat` |
| `http` | `xh` |

---

## Neovim Configuration

### Foundation
Built on **LazyVim** distribution with lazy.nvim plugin manager. All plugins version-locked in `lazy-lock.json`.

**Entry Point**: `nvim/init.lua`
```lua
require("config.lazy")
vim.g.codeium_platform_override = "mac-arm64"  -- Apple Silicon
```

### Plugin Categories

| Category | Plugins |
|----------|---------|
| **LSP** | nvim-lspconfig, mason.nvim, mason-lspconfig.nvim |
| **Debugging** | nvim-dap, nvim-dap-ui, nvim-dap-go, mason-nvim-dap.nvim |
| **Completion** | blink.cmp, friendly-snippets |
| **AI** | copilot.lua, opencode.nvim |
| **Syntax** | nvim-treesitter, nvim-treesitter-textobjects, nvim-ts-autotag |
| **UI** | catppuccin, tokyonight.nvim, lualine.nvim, bufferline.nvim |
| **Navigation** | neo-tree.nvim, fzf-lua, harpoon |
| **Git** | gitsigns.nvim |
| **Formatting** | conform.nvim, nvim-lint |
| **Search** | grug-far.nvim, flash.nvim |
| **Session** | persistence.nvim |
| **Utilities** | which-key.nvim, mini.surround, todo-comments.nvim |
| **Markdown** | render-markdown.nvim, markdown-preview.nvim |
| **Specialized** | codesnap.nvim, vim-helm |

### Neovim Keybindings

**Leader Key**: Space

#### Insert Mode
| Key | Action |
|-----|--------|
| `jj` | Escape to normal mode |
| `jk` | Escape to normal mode |

#### Leader Key Namespaces (LazyVim defaults)
| Prefix | Category |
|--------|----------|
| `<leader>b` | Buffers |
| `<leader>c` | Code actions |
| `<leader>f` | Find/Files |
| `<leader>g` | Git |
| `<leader>s` | Search |
| `<leader>u` | UI toggles |
| `<leader>x` | Diagnostics/Quickfix |
| `<leader>w` | Windows |
| `<leader>q` | Quit/Session |

#### Common Commands
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Grep files |
| `<leader>fr` | Recent files |
| `<leader>bb` | Switch buffer |
| `<leader>bd` | Delete buffer |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cf` | Format |
| `<leader>gg` | Git status |
| `gd` | Go to definition |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

#### Copilot
| Key | Action |
|-----|--------|
| `M-]` (Alt+]) | Next suggestion |
| `M-[` (Alt+[) | Previous suggestion |

---

## tmux Configuration

### Core Settings

**Prefix Key**: `Ctrl-A` (changed from default `Ctrl-B`)

| Setting | Value |
|---------|-------|
| `base-index` | `1` |
| `history-limit` | `1,000,000` |
| `mode-keys` | `vi` |
| `default-terminal` | `screen-256color` |
| `set-clipboard` | `on` |
| `status-position` | `top` |
| `escape-time` | `0` |

### Plugins (via tpm)

| Plugin | Purpose |
|--------|---------|
| tmux-resurrect | Session persistence |
| tmux-continuum | Auto-save/restore |
| tmux-sessionx | Fuzzy session switching |
| tmux-floax | Floating panes |
| tmux-fzf | Fuzzy finding |
| tmux-fzf-url | URL extraction |
| catppuccin/tmux | Theme |

### Plugin Configuration

**Resurrect + Continuum**:
- Auto-restore: `on`
- Neovim strategy: `session`

**Floax**:
- Width/Height: `80%`
- Border color: `magenta`
- Bind key: `p`

**Sessionx**:
- Bind key: `o`
- Zoxide mode: `on`

### tmux Keybindings

All keybindings use prefix (`Ctrl-A`) first, then the action key.

#### Session Management
| Key | Action |
|-----|--------|
| `^D` | Detach |
| `^X` | Lock server |
| `S` | Choose session |
| `*` | List clients |

#### Window Management
| Key | Action |
|-----|--------|
| `^C` | New window (in home dir) |
| `H` | Previous window |
| `L` | Next window |
| `^A` | Last window |
| `r` | Rename window |
| `w` | List windows |
| `"` | Choose window |

#### Pane Creation
| Key | Action |
|-----|--------|
| `s` | Split vertically (preserve dir) |
| `v` | Split horizontally (preserve dir) |

#### Pane Navigation (vim-style)
| Key | Action |
|-----|--------|
| `h` | Select pane left |
| `j` | Select pane down |
| `k` | Select pane up |
| `l` | Select pane right |

#### Pane Resizing (repeatable)
| Key | Action |
|-----|--------|
| `,` | Resize left 20 columns |
| `.` | Resize right 20 columns |
| `-` | Resize down 7 rows |
| `=` | Resize up 7 rows |

#### Pane Manipulation
| Key | Action |
|-----|--------|
| `z` | Toggle zoom |
| `c` | Kill pane |
| `x` | Swap pane |
| `P` | Toggle pane border status |

#### Utility
| Key | Action |
|-----|--------|
| `R` | Reload config |
| `K` | Clear screen |
| `^L` | Refresh client |
| `:` | Command prompt |

#### Copy Mode (vi)
| Key | Action |
|-----|--------|
| `v` | Begin selection |

---

## Window Management

### AeroSpace (Tiling Window Manager)

**Config**: `aerospace/aerospace.toml`

#### Layout Settings
| Setting | Value |
|---------|-------|
| `default-root-container-layout` | `tiles` |
| `default-root-container-orientation` | `auto` |
| `accordion-padding` | `300` |

#### Gap Configuration
| Gap | Value |
|-----|-------|
| `inner.horizontal` | `20` |
| `inner.vertical` | `20` |
| `outer.left` | `20` |
| `outer.right` | `20` |
| `outer.top` | `10` |
| `outer.bottom` | `20` |

#### Workspace to Monitor Assignment
```toml
[workspace-to-monitor-force-assignment]
1 = '^Built-in.*$'    # MacBook screen
2 = '^DELL U.*$'      # DELL U-series
3 = '^DELL S.*$'      # DELL S-series
```

#### Floating Apps (auto-detected)
- Telegram, Finder, Safari, Discord, Mail, Camera, QuickTime, Elgato, Trello

#### Main Mode Keybindings
| Key | Action |
|-----|--------|
| `alt-h/j/k/l` | Focus left/down/up/right |
| `alt-shift-h/j/k/l` | Move window |
| `alt-1/2/3/4` | Switch to workspace |
| `alt-shift-1/2/3/4` | Move window to workspace |
| `alt-/` | Toggle tiles horizontal/vertical |
| `alt-,` | Toggle accordion layout |

#### Service Mode (`alt-shift-;`)
| Key | Action |
|-----|--------|
| `esc` | Reload config, return to main |
| `r` | Flatten workspace tree |
| `f` | Toggle floating/tiling |
| `backspace` | Close all windows but current |

#### Apps Mode (`alt-shift-enter`)
| Key | Action |
|-----|--------|
| `alt-w` | Open WezTerm |

#### External Integrations
- **Startup**: Launches Sketchybar
- **Workspace change**: Notifies Sketchybar, updates borders

### skhd (Hotkey Daemon)

**Config**: `skhd/skhdrc`

#### Application Launchers
| Key | Application |
|-----|-------------|
| `alt-s` | Safari |
| `alt-t` | Telegram |
| `alt-g` | Ghostty |

#### AppleScript Execution
| Key | Script |
|-----|--------|
| `alt-d` | Show date popup |
| `ralt-n` | Close notifications |

---

## Development Tools Integration

### Fuzzy Finding (fzf)

**Integration Points**:
- **Shell**: `FZF_DEFAULT_COMMAND` uses `fd` for file discovery
- **Neovim**: fzf-lua for files, buffers, grep, LSP symbols
- **tmux**: tmux-fzf, tmux-fzf-url, tmux-sessionx

### Smart Navigation (zoxide)

Provides frecency-based directory jumping via `z` command.

```bash
z project     # Jump to most frequent matching directory
zi            # Interactive selection with fzf
```

### Environment Management (direnv)

Automatically loads `.envrc` files when entering directories.

**Common Use Cases**:
- Project-specific tool versions
- Credential isolation
- Kubernetes context switching
- PATH modifications

### Shell History (Atuin)

Cloud-synced, searchable shell history across machines.

**Commands**:
```bash
atuin search <query>    # Search history
atuin sync              # Sync with cloud
asr <script>            # Run Atuin script (Nushell alias)
```

### AI-Assisted Development

| Tool | Plugin | Purpose |
|------|--------|---------|
| GitHub Copilot | copilot.lua | Real-time code suggestions |
| Codeium | (platform override) | Alternative AI completion |
| OpenCode | opencode.nvim | Additional AI features |

### Session Persistence

| Tool | Storage | Mechanism |
|------|---------|-----------|
| tmux | `~/.tmux/resurrect/` | resurrect + continuum (auto every 15 min) |
| Neovim | Per-directory | persistence.nvim |
| Shell history | `~/.local/share/atuin/` | Atuin cloud sync |
| Directory frecency | `~/.local/share/zoxide/db.zo` | zoxide database |
| Nix packages | `flake.lock` | Version controlled |
| Neovim plugins | `lazy-lock.json` | Version controlled |

---

## Quick Reference

### Common Workflows

**Daily startup**:
1. Open Ghostty terminal
2. `tmux` (auto-restores previous session)
3. `z project` (jump to project)
4. `v` (open Neovim)

**Git workflow**:
```bash
gst              # git status
ga               # git add -p (interactive)
gc "message"     # git commit -m "message"
gp               # git push origin HEAD
```

**Kubernetes workflow**:
```bash
kc               # switch context
kns              # switch namespace
kg pods          # get pods
kl pod-name      # follow logs
ke pod-name sh   # exec into pod
```

**Navigation**:
```bash
z project        # jump to directory
fcd              # fuzzy find directory
fv               # fuzzy find + open in nvim
cx dir           # cd + list
```

### Modifier Key Reference

| Notation | Key |
|----------|-----|
| `^` | Control |
| `M-` | Alt/Meta |
| `S-` | Shift |

### Configuration Reload

```bash
# tmux
prefix + R

# Neovim
:Lazy sync

# Nix-Darwin
darwin-rebuild switch --flake ~/dotfiles/nix-darwin

# Stow
cd ~/dotfiles && stow .

# Shell
source ~/.zshrc  # or restart terminal for Nushell
```

### Troubleshooting

**Stow conflicts**:
```bash
rm -rf ~/.config/nvim  # Remove existing config
stow .                 # Re-stow
```

**Nix flakes disabled**:
Ensure `~/.config/nix/nix.conf` contains:
```
experimental-features = nix-command flakes
```

**tmux plugins not loading**:
```bash
tmux
# prefix + I to install plugins
# prefix + U to update plugins
```

**Neovim plugins outdated**:
```bash
nvim
:Lazy update
```
