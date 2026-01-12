# Dotfiles

macOS development environment managed with Nix-Darwin, Home Manager, and Stow.

## Quick Start

```bash
# 1. Install Xcode Command Line Tools (required for git)
xcode-select --install

# 2. Clone this repository
git clone https://github.com/Klaudioz/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. Run bootstrap (installs Homebrew, Nix, nix-darwin, stow)
./bootstrap.sh
```

See [Quick Setup Guide](docs/QUICK-SETUP.md) for detailed instructions.

## After Installation

```bash
./setup.sh           # Symlink dotfiles
./setup.sh --update  # Pull, rebuild nix-darwin, re-stow
./setup.sh --verify  # Check installed tools
./setup.sh --github  # Set up GitHub SSH via 1Password
./setup.sh --help    # Show help
```

---

## Installed Programs

### Core CLI Tools (via Nix)

| Tool | Description |
|------|-------------|
| `nushell` | Primary shell (modern, structured data) |
| `tmux` | Terminal multiplexer |
| `vim` | Text editor |
| `fzf` | Fuzzy finder |
| `fd` | Fast find alternative |
| `ripgrep` | Fast grep alternative |
| `bat` | Cat with syntax highlighting |
| `eza` | Modern ls replacement |
| `zoxide` | Smart cd with frecency |
| `atuin` | Shell history with sync |
| `yazi` | Terminal file manager |
| `tree` | Directory tree viewer |
| `starship` | Cross-shell prompt |
| `jq` / `yq` | JSON/YAML processors |
| `xh` | HTTPie-like HTTP client |
| `glow` | Markdown renderer in terminal |
| `sshs` | SSH session manager |
| `pv` | Pipe viewer (progress for pipes) |

### Developer Tools (via Nix)

| Tool | Description |
|------|-------------|
| `go` | Go programming language |
| `nodejs` | Node.js runtime |
| `bun` | Fast JavaScript runtime |
| `pnpm` | Fast Node package manager |
| `rustup` | Rust toolchain manager |
| `uv` | Fast Python package manager |
| `lazygit` | Git TUI |
| `delta` | Git diff viewer |
| `stow` | Symlink farm manager |
| `cloc` | Count lines of code |
| `direnv` | Directory-based env vars |
| `carapace` | Shell completion |
| `cmatrix` | Matrix screen effect |
| `mactop` | macOS activity monitor |
| `yt-dlp` | YouTube downloader |

### AI/LLM Tools

| Tool | Source | Description |
|------|--------|-------------|
| `aichat` | Nix | Multi-LLM chat CLI |
| `gemini-cli` | Nix | Google Gemini CLI |
| `opencode` | Homebrew | AI coding assistant |
| `codex` | Homebrew Cask | OpenAI Codex CLI |
| `claude` | npm | Anthropic Claude Code |
| `amp` | npm | Sourcegraph AI |

### Cloud CLIs

| Tool | Source | Description |
|------|--------|-------------|
| `kubectl` | Nix | Kubernetes CLI |
| `kubectx` | Nix | Kubernetes context switcher |
| `awscli2` | Nix | AWS CLI v2 |
| `google-cloud-sdk` | Nix | Google Cloud CLI |
| `doctl` | Nix | DigitalOcean CLI |
| `flyctl` | Nix | Fly.io CLI |
| `gh` | Nix | GitHub CLI |
| `render` | Homebrew | Render.com CLI |

### Security Tools (via Nix)

| Tool | Description |
|------|-------------|
| `nmap` | Network scanner |
| `gobuster` | Directory/DNS brute-forcer |
| `ffuf` | Web fuzzer |
| `ngrok` | Secure tunnels |
| `wireshark` | Network analyzer (GUI) |

### macOS Window Management

| Tool | Source | Description |
|------|--------|-------------|
| `aerospace` | Homebrew Cask | Tiling window manager |
| `sketchybar` | Homebrew | Custom status bar |
| `borders` | Homebrew | Window borders |
| `hammerspoon` | Homebrew Cask | macOS automation |
| `linearmouse` | Homebrew Cask | Mouse customization |

### Status Bar Plugins (Sketchybar)

| Plugin | Description |
|--------|-------------|
| `spaces/aerospace` | Workspace indicators with icons |
| `calendar` | Date/time with itsycal integration |
| `system_stats` | CPU/RAM usage |
| `cpu` / `ram` | Individual CPU/RAM displays |
| `front_app` | Current app display |
| `quotio` | Quotio menu bar dashboard |
| `repobar` | GitHub repo stats |
| `portkiller` | Port manager toggle |
| `matrix_wallpaper` | Toggle cmatrix wallpaper |
| `bluetooth` | Bluetooth status |
| `wifi` | WiFi status |

### Terminal & Editor Apps (Homebrew Casks)

| App | Description |
|-----|-------------|
| `ghostty` | GPU-accelerated terminal |
| `neovim` | Text editor (LazyVim config) |
| `visual-studio-code` | VS Code editor |
| `cursor` | AI-powered code editor |
| `windsurf` | AI code editor |
| `zed` | Modern, collaborative code editor |

### Productivity Apps (Homebrew Casks)

| App | Description |
|-----|-------------|
| `obsidian` | Knowledge management |
| `devonthink` | Document management |
| `qspace-pro` | Dual-pane file manager |
| `raycast` | Launcher/productivity |
| `granola` | Meeting notes AI |
| `linear-linear` | Issue tracking |
| `itsycal` | Menu bar calendar |
| `1password` | Password manager |
| `zoom` | Video conferencing |
| `tailscale` | VPN mesh network |

### Communication Apps (Homebrew Casks)

| App | Description |
|-----|-------------|
| `slack` | Team messaging |
| `discord` | Community chat |
| `telegram` | Messaging |

### Browsers (Homebrew Casks)

| App | Description |
|-----|-------------|
| `google-chrome` | Chrome browser |
| `firefox` | Firefox browser |
| `arc` | Arc browser |

### Development Utilities (Homebrew)

| Tool | Description |
|------|-------------|
| `cmake` | Build system |
| `imagemagick` | Image manipulation |
| `blueutil` | Bluetooth CLI |
| `ical-buddy` | Calendar CLI |
| `ifstat` | Network interface stats |
| `mole` | SSH tunnel manager |
| `libpq` | PostgreSQL client library |
| `sketchybar-system-stats` | System stats provider |
| `portkiller` | Kill processes by port |

### npm Global Packages

| Package | Description |
|---------|-------------|
| `claude` | Anthropic Claude Code |
| `amp` | Sourcegraph AI |
| `openportal` | Remote access to OpenCode sessions via web portal |
| `pm2` | Process manager |

### Other Apps (Homebrew Casks)

| App | Description |
|-----|-------------|
| `setapp` | App subscription service |
| `antigravity` | Screen capture utility |
| `gitify` | GitHub notifications |
| `vial` | Keyboard configurator |
| `sf-symbols` | Apple SF Symbols |
| `qbittorrent` | Torrent client |
| `xbar` | Menu bar plugins |
| `repobar` | GitHub repo menu bar stats |

### Python Tools (via uv)

| Tool | Description |
|------|-------------|
| `sqlit-tui` | SQLite database TUI |
| `takopi` | CLI tool |

### Bun Global Packages

| Package | Description |
|---------|-------------|
| `tokscale` | Token counting utility |

### Local Homebrew Casks

| Cask | Description |
|------|-------------|
| `quotio` | Quotio (CLIProxyAPI GUI) |
| `screen-studio-legacy` | Screen Studio 2.26.0 (version-pinned) |

### Fonts (via Nix)

| Font | Description |
|------|-------------|
| `nerd-fonts.jetbrains-mono` | JetBrains Mono with Nerd Font icons |

---

## Configuration Directories

| Directory | Description |
|-----------|-------------|
| `aerospace/` | Window manager config + workspace scripts |
| `atuin/` | Shell history sync config |
| `borders/` | Window border styling |
| `chrome/` | Chrome managed policies (extension auto-install) |
| `ghostty/` | Terminal emulator config |
| `hammerspoon/` | macOS automation scripts |
| `karabiner/` | Keyboard remapping |
| `launchagents/` | macOS launchd services |
| `nix-darwin/` | Nix-Darwin + Home Manager config |
| `nushell/` | Primary shell configuration |
| `nvim/` | Neovim/LazyVim configuration |
| `opencode/` | OpenCode AI settings + agents/skills |
| `sketchybar/` | Status bar + plugins |
| `starship/` | Cross-shell prompt theme |
| `tmux/` | Terminal multiplexer config |
| `vscode/` | VS Code settings + extensions |
| `zed/` | Zed editor settings |
| `zsh/` | Zsh environment (for compatibility) |

---

## Scripts

### Main Scripts

| Script | Description |
|--------|-------------|
| `bootstrap.sh` | Initial machine setup (Homebrew, Nix, nix-darwin) |
| `setup.sh` | Symlink dotfiles, install tools, verify setup |

### Aerospace Scripts

| Script | Description |
|--------|-------------|
| `aerospace/ghostty-workspace-balance.sh` | Balance Ghostty windows across workspaces |

### Sketchybar Scripts

| Script | Description |
|--------|-------------|
| `sketchybar/plugins/bluetooth/` | Bluetooth toggle |
| `sketchybar/plugins/calendar/` | Calendar events integration |
| `sketchybar/plugins/quotio/` | Quotio menu bar dashboard |
| `sketchybar/plugins/cpu/` | CPU usage display |
| `sketchybar/plugins/front_app/` | Current app display |
| `sketchybar/plugins/icon_map.sh` | App icon mapping |
| `sketchybar/plugins/matrix_wallpaper/` | cmatrix wallpaper toggle |
| `sketchybar/plugins/portkiller/` | PortKiller integration |
| `sketchybar/plugins/ram/` | RAM usage display |
| `sketchybar/plugins/repobar/` | GitHub repo stats |
| `sketchybar/plugins/spaces/aerospace/` | Workspace indicators |
| `sketchybar/plugins/system_stats/` | CPU/RAM stats |
| `sketchybar/plugins/wifi/` | WiFi toggle |

### Tmux Scripts

| Script | Description |
|--------|-------------|
| `tmux/scripts/cal.sh` | Calendar widget |

---

## Launchd Services

| Service | Description |
|---------|-------------|
| `com.klaudioz.cmatrix-wallpaper` | Matrix wallpaper background service |
| `com.klaudioz.openportal-dashboard` | OpenPortal dashboard service (Tailscale remote access) |

---

## OpenPortal (Remote OpenCode Access)

OpenPortal enables remote access to OpenCode sessions from any device via Tailscale.

### How It Works

1. **Dashboard Service**: Runs at startup via launchd, accessible at `http://m4-mini.tail09133d.ts.net:3010`
2. **Session Management**: Each project directory gets a unique port pair (web + OpenCode)
3. **Session Persistence**: Sessions tracked in `~/.local/share/openportal/sessions.json`

### Usage

Start a remote-accessible OpenCode session from any directory:

```bash
oo    # Nushell command - starts OpenPortal + attaches OpenCode
```

The `oo` command:
- Calculates unique ports based on directory hash
- Launches `openportal --no-browser --port <web> --opencode-port <oc> --directory <dir>`
- Registers session with dashboard
- Attaches to the OpenCode session
- Cleans up on exit (Ctrl+C)

### Configuration Files

| File | Description |
|------|-------------|
| `launchagents/com.klaudioz.openportal-dashboard.plist` | Dashboard service definition |
| `nushell/config.nu` (`oo` function) | Session launcher command |

---

## External Repositories (Auto-Updated)

| Repo | Location | Description |
|------|----------|-------------|
| `oh-my-opencode` | `~/.local/share/oh-my-opencode` | OpenCode prompt customization |
| `openportal` | `~/.local/share/openportal` | OpenPortal dashboard and session data |

---

## GitHub Extensions (Auto-Installed)

| Extension | Description |
|-----------|-------------|
| `gh-dash` | GitHub dashboard TUI |

---

## macOS System Settings

Configured via `nix-darwin/flake.nix`:

- **Dock**: Auto-hide, left orientation, no persistent apps, group windows by app
- **Menu Bar**: Auto-hide (preserves notifications)
- **Finder**: Show extensions, column view, hide desktop icons
- **Keyboard**: Fast key repeat (2), short initial delay (15)
- **Screenshots**: Save to `~/Pictures/screenshots`, copy to clipboard
- **Security**: Touch ID + Apple Watch for sudo
- **Wallpaper**: Auto-set on rebuild
- **File Limits**: Increased maxfiles to 61440 (fixes Ghostty SystemResources error)

---

## Documentation

- [Quick Setup Guide](docs/QUICK-SETUP.md) - Get running in under 1 hour
- [Complete Reference](docs/DOTFILES-COMPLETE.md) - Full configuration details
- [AeroSpace Guide](docs/AEROSPACE-GUIDE.md) - Window management
- [Apps Setup](docs/APPS-SETUP.md) - Application configuration

---

## Multi-Machine Support

Configured for:
- `Claudios-MacBook-Pro` - MacBook Pro
- `m4-mini` - Mac mini M4

Check hostname: `scutil --get ComputerName`

## Troubleshooting

### Ghostty: `error starting IO thread: error.SystemResources`

This is commonly caused by a low `maxfiles` limit (file descriptors) in your user launchd session.

- Check: `launchctl limit maxfiles`
- Fix: run `./setup.sh --update` (installs a system launchd daemon and applies the limit via sudo)
- If it still shows `256`, log out/in or reboot
