# AeroSpace Window Manager Guide

AeroSpace is a tiling window manager for macOS, inspired by i3. This guide covers your configured shortcuts.

---

## Concepts

### Workspaces
Virtual desktops where windows live. You have 4 workspaces configured (1-4).

### Tiling vs Floating
- **Tiling:** Windows automatically arrange in a grid
- **Floating:** Windows can be freely positioned (like normal macOS)

### Layouts
- **Tiles:** Windows split horizontally or vertically
- **Accordion:** Windows stack with padding (like tabs)

---

## Keyboard Shortcuts

All shortcuts use **Alt (Option)** as the main modifier.

### Focus (Navigate Between Windows)

| Shortcut | Action |
|----------|--------|
| `Alt + H` | Focus window to the left |
| `Alt + J` | Focus window below |
| `Alt + K` | Focus window above |
| `Alt + L` | Focus window to the right |

### Move Windows

| Shortcut | Action |
|----------|--------|
| `Alt + Shift + H` | Move window left |
| `Alt + Shift + J` | Move window down |
| `Alt + Shift + K` | Move window up |
| `Alt + Shift + L` | Move window right |

### Join Windows (Nest Containers)

| Shortcut | Action |
|----------|--------|
| `Alt + Shift + Left` | Join with window on left |
| `Alt + Shift + Down` | Join with window below |
| `Alt + Shift + Up` | Join with window above |
| `Alt + Shift + Right` | Join with window on right |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Alt + 1` | Switch to workspace 1 |
| `Alt + 2` | Switch to workspace 2 |
| `Alt + 3` | Switch to workspace 3 |
| `Alt + 4` | Switch to workspace 4 |
| `Alt + Tab` | Toggle between last two workspaces |

### Move Windows to Workspaces

| Shortcut | Action |
|----------|--------|
| `Alt + Shift + 1` | Move window to workspace 1 |
| `Alt + Shift + 2` | Move window to workspace 2 |
| `Alt + Shift + 3` | Move window to workspace 3 |
| `Alt + Shift + 4` | Move window to workspace 4 |
| `Alt + Shift + Tab` | Move workspace to next monitor |

### Resize Windows

| Shortcut | Action |
|----------|--------|
| `Alt + Shift + -` | Shrink window by 50px |
| `Alt + Shift + =` | Grow window by 50px |

### Layout

| Shortcut | Action |
|----------|--------|
| `Alt + /` | Toggle between horizontal/vertical tiles |
| `Alt + ,` | Toggle accordion layout |
| `Alt + Ctrl + F` | Toggle floating/tiling for window |
| `Alt + Ctrl + Shift + F` | Toggle fullscreen |

### Quick Launch Apps

| Shortcut | Action |
|----------|--------|
| `Alt + O` | Open Obsidian |
| `Alt + S` | Open Slack |
| `Alt + W` | Open WezTerm |
| `Alt + F` | Open Finder |
| `Alt + Q` | Open QuickTime |

### Service Mode

Press `Alt + Shift + ;` to enter service mode, then:

| Key | Action |
|-----|--------|
| `Esc` | Reload config and exit |
| `R` | Reset/flatten workspace layout |
| `F` | Toggle floating/tiling |
| `Backspace` | Close all windows except current |

---

## Auto-Floating Apps

These apps automatically open in floating mode:
- Telegram
- Finder
- Safari
- Camera
- Mail
- QuickTime
- Discord

---

## Monitor Assignment

Workspaces are assigned to monitors:

| Workspace | Monitor |
|-----------|---------|
| 1 | Built-in display |
| 2 | Dell U series |
| 3 | Dell S series |

---

## Configuration

Config file: `~/.aerospace.toml` (symlinked from dotfiles)

### Gaps
- Inner gaps: 20px
- Outer gaps: 20px (10px top)

### Behavior
- Mouse follows focus when changing monitors
- Accordion padding: 300px

---

## Tips

### Common Workflows

**Split windows horizontally:**
1. Open first app
2. Open second app (auto-tiles)
3. Press `Alt + /` to toggle orientation

**Move window to another workspace:**
1. Focus the window
2. Press `Alt + Shift + [1-4]`

**Create nested layout:**
1. Focus target window
2. Press `Alt + Shift + [Arrow]` to join

**Quick workspace switch:**
- Use `Alt + Tab` to toggle between last two workspaces

### Troubleshooting

**Windows not tiling:**
- Check if app is in floating list
- Press `Alt + Ctrl + F` to toggle tiling

**Reset layout:**
1. Press `Alt + Shift + ;` (service mode)
2. Press `R` to flatten

**Reload config after changes:**
1. Press `Alt + Shift + ;` (service mode)
2. Press `Esc` to reload
