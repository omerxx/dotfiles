# Dotfiles

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Homebrew](https://img.shields.io/badge/Homebrew-installed-brightgreen)

Welcome to my personal dotfiles repository! This repository contains my configuration files (dotfiles) to set up and customize my development environment.

## Features

- Organized and easy-to-use configuration files.
- Seamless setup for various tools and applications.
- Custom scripts and tweaks for an optimized workflow.

## 📂 Contents

This repository includes configurations for:

- **Aerospace** 🚀 – My favourite i3-like tiling window manager for macOS.
- **Zsh** 🐚 – Custom `.zshrc` file for the Zsh shell.
- **Neovim** 📝 – Configuration files for the Neovim editor.
- **Tmux** 🖥️ – Settings for the Tmux terminal multiplexer.
- **Starship** 🌟 – Configuration for the Starship prompt.
- **Lazygit** 🗂️ – Settings for the Lazygit interface.
- **Helix** 🧠 – Configuration for the Helix editor.
- **Atuin** 🐢 – Settings for the Atuin shell history manager.
- **Fastfetch** ⚡ – Configuration for the Fastfetch system information tool.
- **Spicetify** 🎶 – Customizations for the Spicetify Spotify client.
- **Raycast** 🎯 – Settings for the Raycast launcher.
- **qBittorrent** 📥 – Configuration for the qBittorrent client.
- **Flutter** 🦋 – Configuration for Flutter development.
- **GitHub Copilot** 🤖 – Settings for GitHub Copilot.
- **The Fuck** 💥 – Configuration for The Fuck command-line tool.
- **Yazi** 📂 – Settings for the Yazi file manager.
- **Zed** 🧑‍💻 – Configuration for the Zed code editor.
- **Bat** 🦇 – Settings for the Bat command-line tool.
- **Ghostty** 👻 – Configuration for the Ghostty terminal.
- **Containers** 🛢️ – Settings for containerized environments.
- **Karabiner Elements** ⌨️ – Settings for many useful keyboard modifications like capslock as esc and control at the same time...

## 🚀 Installation

Install everything with a single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/omerxx/dotfiles/master/install.sh)
```

Push only:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/omerxx/dotfiles/master/push.sh)
```

Install my homebrew casks and fomulaes (Optional):

```bash
cd ~/dotfiles
brew bundle --file=Brewfile
```

### Breakdown of the `install.sh`

1. Clone the dotfiles repository.
2. Sync the configuration files to `~/.config/` using `stow`.
3. Create a symbolic link for `.zshrc`.

### ⚠️Only remove the ~/dotfiles/ if you already move all config from ~/dotfiles/ to ~/.config/

```bash
# rm -rf ~/dotfiles
```

## 🎨 Customization

You can modify these dotfiles to suit your workflow. Each configuration file is documented with comments to help you understand and tweak settings.

## 🤝 Contributing

If you have suggestions or improvements, feel free to open a pull request or create an issue.

## 📜 License

This repository is licensed under the [MIT License](LICENSE).
