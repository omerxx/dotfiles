#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_prerequisites() {
  echo "Checking prerequisites..."
  echo ""

  missing_prereqs=()

  # Check Xcode Command Line Tools
  if ! xcode-select -p &> /dev/null; then
    missing_prereqs+=("xcode-select --install")
  else
    echo -e "  ${GREEN}✓${NC} Xcode Command Line Tools"
  fi

  # Check Stow
  if ! command -v stow &> /dev/null; then
    missing_prereqs+=("brew install stow")
  else
    echo -e "  ${GREEN}✓${NC} stow"
  fi

  if [ ${#missing_prereqs[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Missing prerequisites:${NC}"
    for prereq in "${missing_prereqs[@]}"; do
      echo -e "  ${YELLOW}Run:${NC} $prereq"
    done
    exit 1
  fi

  echo ""
}

verify_tools() {
  echo "Verifying installed tools..."
  echo ""

  tools=(
    # Core tools (nix)
    "nvim:neovim"
    "tmux:tmux"
    "fzf:fzf"
    "fd:fd"
    "rg:ripgrep"
    "bat:bat"
    "zoxide:zoxide"
    "atuin:atuin"
    "eza:eza"
    "starship:starship"
    "go:go"
    "node:nodejs"
    "stow:stow"
    "jq:jq"
    # Homebrew tools
    "sketchybar:sketchybar"
    "borders:borders"
    "skhd:skhd"
    "icalBuddy:ical-buddy"
    # Developer utilities (nix)
    "aichat:aichat"
    "lazygit:lazygit"
    "uv:uv"
    "delta:delta"
    # Cloud CLIs (nix)
    "kubectl:kubectl"
    "aws:awscli"
    "gcloud:gcloud"
    "doctl:doctl"
    "flyctl:flyctl"
    # npm global packages
    "claude:claude-code"
    "amp:@sourcegraph/amp"
    # GUI apps with CLI (manual setup required)
    "code:vscode (run 'Install code command' from VS Code)"
  )

  missing=()
  installed=()

  for tool_entry in "${tools[@]}"; do
    cmd="${tool_entry%%:*}"
    name="${tool_entry##*:}"
    if command -v "$cmd" &> /dev/null; then
      installed+=("$name")
    else
      missing+=("$name")
    fi
  done

  echo -e "${GREEN}Installed (${#installed[@]}):${NC}"
  for tool in "${installed[@]}"; do
    echo -e "  ${GREEN}✓${NC} $tool"
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Missing (${#missing[@]}):${NC}"
    for tool in "${missing[@]}"; do
      echo -e "  ${RED}✗${NC} $tool"
    done
    echo ""
    echo -e "${YELLOW}Run: darwin-rebuild switch --flake ~/dotfiles/nix-darwin${NC}"
    exit 1
  fi

  echo ""
  echo -e "${GREEN}All tools verified!${NC}"
}

setup_github_ssh() {
  echo -e "${YELLOW}Setting up GitHub SSH authentication...${NC}"
  echo ""

  # Check if 1Password SSH agent socket exists
  OP_AGENT="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  if [ ! -S "$OP_AGENT" ]; then
    echo -e "${RED}1Password SSH agent not found.${NC}"
    echo ""
    echo "To enable it:"
    echo "  1. Open 1Password → Settings → Developer"
    echo "  2. Enable 'Use the SSH agent'"
    echo "  3. Enable 'Integrate with 1Password CLI'"
    echo ""
    echo "Then add an SSH key in 1Password:"
    echo "  1. Create new item → SSH Key"
    echo "  2. Generate a new key or import existing"
    echo "  3. Add the public key to GitHub: https://github.com/settings/ssh/new"
    exit 1
  fi

  echo -e "${GREEN}✓${NC} 1Password SSH agent detected"

  # Stow ssh config if not already done
  if [ ! -L "$HOME/.ssh/config" ]; then
    echo "Symlinking SSH config..."
    cd "$SCRIPT_DIR"
    stow ssh
  fi
  echo -e "${GREEN}✓${NC} SSH config linked"

  # Test GitHub connection
  echo ""
  echo "Testing GitHub SSH connection..."
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo -e "${GREEN}✓${NC} GitHub SSH authentication successful!"
  else
    echo -e "${YELLOW}!${NC} GitHub connection test (this is normal if key is new):"
    ssh -T git@github.com 2>&1 || true
    echo ""
    echo "If you see 'Permission denied', add your SSH public key to GitHub:"
    echo "  https://github.com/settings/ssh/new"
    echo ""
    echo "To get your public key from 1Password:"
    echo "  1. Open 1Password → find your SSH Key item"
    echo "  2. Click 'public key' to copy it"
  fi

  # Switch this repo to SSH
  echo ""
  CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ "$CURRENT_REMOTE" == https://github.com/* ]]; then
    SSH_REMOTE=$(echo "$CURRENT_REMOTE" | sed 's|https://github.com/|git@github.com:|')
    echo "Switching dotfiles remote to SSH..."
    git remote set-url origin "$SSH_REMOTE"
    echo -e "${GREEN}✓${NC} Remote updated: $SSH_REMOTE"
  elif [[ "$CURRENT_REMOTE" == git@github.com:* ]]; then
    echo -e "${GREEN}✓${NC} Remote already using SSH: $CURRENT_REMOTE"
  fi

  echo ""
  echo -e "${GREEN}GitHub SSH setup complete!${NC}"
}

show_help() {
  echo "Usage: ./setup.sh [OPTION]"
  echo ""
  echo "Options:"
  echo "  --update    Pull latest, rebuild nix-darwin, and stow dotfiles"
  echo "  --github    Set up GitHub SSH authentication via 1Password"
  echo "  --verify    Check if all required tools are installed"
  echo "  --help      Show this help message"
  echo "  (none)      Run stow to symlink dotfiles"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_macos_configs() {
  # Nushell on macOS uses ~/Library/Application Support/nushell/ instead of ~/.config/nushell/
  NUSHELL_MACOS_DIR="$HOME/Library/Application Support/nushell"
  NUSHELL_TARGET="$SCRIPT_DIR/nushell"

  if [ -d "$NUSHELL_MACOS_DIR" ] && [ ! -L "$NUSHELL_MACOS_DIR" ]; then
    echo "Setting up nushell config for macOS..."
    rm -rf "$NUSHELL_MACOS_DIR"
    ln -s "$NUSHELL_TARGET" "$NUSHELL_MACOS_DIR"
    echo -e "  ${GREEN}✓${NC} nushell config linked"
  elif [ ! -e "$NUSHELL_MACOS_DIR" ]; then
    echo "Setting up nushell config for macOS..."
    ln -s "$NUSHELL_TARGET" "$NUSHELL_MACOS_DIR"
    echo -e "  ${GREEN}✓${NC} nushell config linked"
  fi
}

setup_vscode_configs() {
  echo -e "${YELLOW}Setting up VS Code configuration...${NC}"

  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
  VSCODE_SETTINGS_SOURCE="$SCRIPT_DIR/vscode/settings.json"
  VSCODE_EXTENSIONS_FILE="$SCRIPT_DIR/vscode/extensions.txt"
  WINDSURF_VSIX_URL="https://github.com/berrydev-ai/windsurf-color-theme/raw/main/windsurf-color-theme-0.0.1.vsix"
  WINDSURF_VSIX_PATH="/tmp/windsurf-color-theme.vsix"

  mkdir -p "$VSCODE_USER_DIR"

  VSCODE_SETTINGS_TARGET="$VSCODE_USER_DIR/settings.json"
  if [ -L "$VSCODE_SETTINGS_TARGET" ]; then
    echo -e "  ${GREEN}✓${NC} VS Code settings already linked"
  elif [ -f "$VSCODE_SETTINGS_TARGET" ]; then
    echo "  Backing up existing VS Code settings..."
    mv "$VSCODE_SETTINGS_TARGET" "$VSCODE_SETTINGS_TARGET.backup"
    ln -s "$VSCODE_SETTINGS_SOURCE" "$VSCODE_SETTINGS_TARGET"
    echo -e "  ${GREEN}✓${NC} VS Code settings linked (backup created)"
  else
    ln -s "$VSCODE_SETTINGS_SOURCE" "$VSCODE_SETTINGS_TARGET"
    echo -e "  ${GREEN}✓${NC} VS Code settings linked"
  fi

  if command -v code &> /dev/null; then
    echo "  Installing VS Code extensions..."

    echo "  Downloading Windsurf theme..."
    curl -sL "$WINDSURF_VSIX_URL" -o "$WINDSURF_VSIX_PATH" && \
      code --install-extension "$WINDSURF_VSIX_PATH" --force 2>/dev/null && \
      echo -e "    ${GREEN}✓${NC} Windsurf theme" || \
      echo -e "    ${YELLOW}!${NC} Windsurf theme (download or install failed)"
    rm -f "$WINDSURF_VSIX_PATH"

    while IFS= read -r extension || [ -n "$extension" ]; do
      [[ "$extension" =~ ^#.*$ || -z "$extension" ]] && continue
      extension=$(echo "$extension" | xargs)
      if [ -n "$extension" ]; then
        code --install-extension "$extension" --force 2>/dev/null && \
          echo -e "    ${GREEN}✓${NC} $extension" || \
          echo -e "    ${YELLOW}!${NC} $extension (may already be installed)"
      fi
    done < "$VSCODE_EXTENSIONS_FILE"
  else
    echo -e "  ${YELLOW}!${NC} 'code' command not found. Open VS Code and run:"
    echo "      Command Palette > 'Shell Command: Install code command in PATH'"
    echo "      Then run './setup.sh' again to install extensions."
  fi

  echo ""
}

start_services() {
  echo -e "${YELLOW}Restarting brew services...${NC}"

  for service in sketchybar skhd borders; do
    brew services restart "$service" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} $service restarted"
  done

  echo ""
}

update_external_repos() {
  echo -e "${YELLOW}Updating external repositories...${NC}"

  OH_MY_OPENCODE_DIR="$HOME/.local/share/oh-my-opencode"
  OH_MY_OPENCODE_REPO="https://github.com/code-yeongyu/oh-my-opencode.git"

  if [ ! -d "$OH_MY_OPENCODE_DIR" ]; then
    echo "Cloning oh-my-opencode..."
    mkdir -p "$(dirname "$OH_MY_OPENCODE_DIR")"
    git clone "$OH_MY_OPENCODE_REPO" "$OH_MY_OPENCODE_DIR"
    echo -e "  ${GREEN}✓${NC} oh-my-opencode cloned"
  else
    echo "Updating oh-my-opencode..."
    git -C "$OH_MY_OPENCODE_DIR" pull
    echo -e "  ${GREEN}✓${NC} oh-my-opencode updated"
  fi

  echo ""
}

run_update() {
  echo -e "${YELLOW}Pulling latest changes...${NC}"
  git pull

  echo ""
  update_external_repos

  echo -e "${YELLOW}Rebuilding nix-darwin configuration...${NC}"
  # Use full path to darwin-rebuild in case PATH isn't configured yet
  DARWIN_REBUILD="/run/current-system/sw/bin/darwin-rebuild"
  if [ ! -x "$DARWIN_REBUILD" ]; then
    DARWIN_REBUILD="darwin-rebuild"
  fi
  sudo "$DARWIN_REBUILD" switch --flake "$SCRIPT_DIR/nix-darwin"

  echo ""
  echo -e "${YELLOW}Symlinking dotfiles...${NC}"
  cd "$SCRIPT_DIR"
  STOW="/run/current-system/sw/bin/stow"
  if [ ! -x "$STOW" ]; then
    STOW="stow"
  fi
  "$STOW" .
  setup_macos_configs
  setup_vscode_configs

  echo ""
  start_services

  echo -e "${GREEN}Update complete! Restart your terminal for PATH changes.${NC}"
}

case "$1" in
  --update)
    run_update
    ;;
  --github)
    setup_github_ssh
    ;;
  --verify)
    check_prerequisites
    verify_tools
    ;;
  --help|-h)
    show_help
    ;;
  *)
    check_prerequisites
    update_external_repos
    echo "Symlinking dotfiles with stow..."
    stow .
    setup_macos_configs
    setup_vscode_configs
    echo -e "${GREEN}Done!${NC}"
    echo ""
    echo "Run './setup.sh --verify' to check if all tools are installed."
    ;;
esac
