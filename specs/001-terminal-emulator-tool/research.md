# Research: Terminal Emulator

## Findings

- **Decision**: Use Ghostty as the terminal emulator.
  - **Rationale**: Fast, minimal, supports config-as-code, reliable tmux/Zellij support.
  - **Alternatives considered**: WezTerm (dropped due to user preference for Ghostty only).

- **Decision**: Color scheme: Catppuccin Mocha.
  - **Rationale**: Popular, consistent with other tools.
  - **Alternatives considered**: Other themes, but Catppuccin is preferred.

- **Decision**: Font: JetBrains Mono.
  - **Rationale**: Good ligatures and readability.
  - **Alternatives considered**: Fira Code, but JetBrains Mono chosen.

- **Decision**: Disable translucency.
  - **Rationale**: Solid backgrounds for better readability in daily work.
  - **Alternatives considered**: Translucent, but solid preferred.

- **Decision**: Update to latest release version.
  - **Rationale**: Stay current with features and fixes.
  - **Alternatives considered**: Pin version, but latest preferred for evolution.

- **Decision**: Config location: ~/.config/ghostty/config
  - **Rationale**: Standard location for Ghostty.
  - **Alternatives considered**: Other paths, but standard is best.

- **Decision**: Keymap passthrough for tmux.
  - **Rationale**: Avoid keybinding collisions.
  - **Alternatives considered**: Custom mappings, but passthrough is simpler.

- **Decision**: Support truecolor, ligatures, sixel/kitty-graphics.
  - **Rationale**: Modern terminal features.
  - **Alternatives considered**: Basic support, but full support needed.

- **Decision**: Low-latency rendering.
  - **Rationale**: Performance goal.
  - **Alternatives considered**: Standard rendering, but low-latency required.

- **Decision**: Respect $SHELL.
  - **Rationale**: Compatibility with nushell/zsh/fish.
  - **Alternatives considered**: Hardcode shell, but respect env var.

- **Decision**: Validation via render tests.
  - **Rationale**: Manual checks for truecolor, fonts, etc.
  - **Alternatives considered**: Automated tests, but manual sufficient for config.