# Dotfiles symlinked on my machine

Forked from [omerxx/dotfiles](https://github.com/omerxx/dotfiles) with
cross-platform adaptations for Windows (Git Bash).

### Install with stow (macOS/Linux):
```bash
stow .
```

### Install on Windows (Git Bash):
```bash
./setup.sh
```

`setup.sh` detects the platform, installs `stow` if missing (via choco, winget,
brew, or apt), and skips macOS-only directories (aerospace, hammerspoon,
karabiner, sketchybar, skhd) on Windows.

### macOS-only directories
| Directory | Tool |
|-----------|------|
| aerospace | Window manager |
| hammerspoon | Automation |
| karabiner | Keyboard remapper |
| sketchybar | Menu bar |
| skhd | Hotkey daemon |

### Cross-platform changes (vs upstream)
- `nvim/lua/config/options.lua`: runtime platform detection for Codeium
  (was hardcoded `Darwin`/`arm64`).
- `ghostty/config`: theme renamed `catppuccin-mocha` → `Catppuccin Mocha`
  (Ghostty v1.1.0 breaking change, issue #43 upstream).
- `tmux/tmux.conf`: replaced hardcoded `/Users/omerxx/dotfiles` path.
- `zellij/config.kdl`: replaced hardcoded theme_dir path.
- `zshrc/.zshrc`: replaced all `/Users/omerxx/` and `/opt/homebrew/bin`
  paths with `$HOME` equivalents and conditional PATH additions.
- `setup.sh`: cross-platform install script with stow auto-install.
