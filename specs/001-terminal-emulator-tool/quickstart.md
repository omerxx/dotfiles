# Quickstart: Terminal Emulator Setup

## Prerequisites

- macOS
- Ghostty installed (latest release)

## Setup Steps

1. Install Ghostty from latest release.
2. Use stow to install config: `stow ghostty` (this symlinks the config to ~/.config/ghostty/config via the repo's structure).
3. Test rendering: Open Ghostty, check truecolor, ligatures, emoji.
4. Test tmux: Run tmux in Ghostty, check keybindings.
5. Test shell: Ensure $SHELL is respected.

## Validation

- Truecolor: Run `curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash`
- Emoji/nerd fonts: Display emoji and nerd font icons.
- Split panes: Create splits, check stability.
- Input latency: Type quickly, check responsiveness.