# My Dotfiles

Hey there! Welcome to my dotfiles repository—a collection of configurations I use to set up and personalize my development environment across different machines. Here's a quick rundown of what's inside and how you can get it up and running.

## What's Included

This repo organizes configurations for various tools and applications, each in its own directory:

- **aerospace**: Configuration for [AeroSpace](https://github.com/nikitabobko/AeroSpace), an i3-like tiling window manager for macOS.
- **atuin**: Configurations for [Atuin](https://github.com/ellie/atuin), a shell history replacement tool.
- **ghostty**: Settings for the Ghostty theme or tool.
- **karabiner**: Key remapping configurations using [Karabiner-Elements](https://karabiner-elements.pqrs.org/).
- **nix**: [Nix](https://nixos.org/) package manager configurations.
- **nix-darwin**: Settings for [nix-darwin](https://github.com/LnL7/nix-darwin), which brings Nix to macOS.
- **nushell**: Configurations for [Nushell](https://www.nushell.sh/), a modern shell.
- **nvim**: [Neovim](https://neovim.io/) setup, including plugins and key mappings.
- **sketchybar**: Settings for [SketchyBar](https://github.com/FelixKratz/SketchyBar), a customizable status bar for macOS.
- **skhd**: Configurations for [skhd](https://github.com/koekeishiya/skhd), a simple hotkey daemon for macOS.
- **ssh**: SSH client configurations.
- **starship**: Setup for [Starship](https://starship.rs/), a cross-shell prompt.
- **tmux**: [Tmux](https://github.com/tmux/tmux) configurations, including plugins and key bindings.
- **wezterm**: Settings for [WezTerm](https://wezfurlong.org/wezterm/), a GPU-accelerated terminal emulator.
- **zellij**: Configurations for [Zellij](https://zellij.dev/), a terminal workspace.
- **zshrc**: [Zsh](https://www.zsh.org/) shell configurations.

## Installation

### Using GNU Stow

To symlink these dotfiles to their appropriate locations, use [GNU Stow](https://www.gnu.org/software/stow/):

```sh
stow .
```
This command will create symlinks from the files in this repository to their corresponding locations in your home directory.

### Homebrew Packages

If you're using [Homebrew](https://brew.sh/) for package management, you can export your installed packages before leaving a machine and reinstall them on a new one:

```sh
# Export installed packages
brew leaves > leaves.txt

# Install packages on a new machine
xargs brew install < leaves.txt
```

This will save a list of your installed packages to `leaves.txt` and then reinstall them on a new machine.

## Additional Setup

Some configurations may require additional setup or dependencies. Please refer to the individual directories and their respective configuration files for more details.

Feel free to explore and modify these configurations to suit your needs. Enjoy your personalized setup!
