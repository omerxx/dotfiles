# Dotfiles

macOS development environment managed with Nix-Darwin and Stow.

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
./setup.sh --verify  # Check installed tools
./setup.sh --help    # Show help
```

## Documentation

- [Quick Setup Guide](docs/QUICK-SETUP.md) - Get running in under 1 hour
- [Complete Reference](docs/DOTFILES-COMPLETE.md) - Full configuration details
