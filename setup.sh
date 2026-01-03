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
    "stats_provider:sketchybar-system-stats"
    "icalBuddy:ical-buddy"
    "bd:bd"
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
    "openportal:openportal"
    "pm2:pm2"
    # Bun tools
    "tokscale:tokscale"
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
    echo -e "${YELLOW}Run: ./setup.sh --update${NC}"
    exit 1
  fi

  echo ""
  echo -e "${GREEN}All tools verified!${NC}"
}

verify_system_limits() {
  echo "Checking launchd resource limits..."
  echo ""

  if ! command -v launchctl &> /dev/null; then
    echo -e "  ${YELLOW}!${NC} launchctl not found, skipping limits check"
    echo ""
    return
  fi

  maxfiles_soft=$(launchctl limit maxfiles 2>/dev/null | awk '{print $2}')
  if [[ -z "$maxfiles_soft" ]]; then
    echo -e "  ${YELLOW}!${NC} unable to read maxfiles via launchctl"
    echo ""
    return
  fi

  echo "  maxfiles (soft): $maxfiles_soft"

  if [[ "$maxfiles_soft" != "unlimited" ]] && [[ "$maxfiles_soft" -lt 10240 ]]; then
    echo -e "  ${YELLOW}!${NC} maxfiles is low; Ghostty may fail with 'error.SystemResources'"
    echo -e "    Fix: ./setup.sh --update (installs and applies a system launchd limit via sudo)"
    echo -e "    If it still shows 256, log out/in or reboot after updating"
  else
    echo -e "  ${GREEN}✓${NC} maxfiles looks good"
  fi

  echo ""
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

cleanup_legacy_launchctl_limits_agent() {
  LEGACY_LIMITS_PLIST="$HOME/Library/LaunchAgents/com.klaudioz.launchctl-limits.plist"
  LEGACY_LIMITS_OUT="/tmp/com.klaudioz.launchctl-limits.out"
  LEGACY_LIMITS_ERR="/tmp/com.klaudioz.launchctl-limits.err"

  if [ ! -f "$LEGACY_LIMITS_PLIST" ]; then
    return
  fi

  echo "Cleaning up legacy launchctl limits LaunchAgent..."

  launchctl bootout "gui/$(id -u)" "$LEGACY_LIMITS_PLIST" 2>/dev/null || true
  launchctl unload "$LEGACY_LIMITS_PLIST" 2>/dev/null || true
  rm -f "$LEGACY_LIMITS_PLIST" "$LEGACY_LIMITS_OUT" "$LEGACY_LIMITS_ERR"

  echo -e "  ${GREEN}✓${NC} legacy limits LaunchAgent removed"
  echo ""
}

apply_launchd_resource_limits() {
  echo "Applying launchd resource limits..."
  echo ""

  if ! command -v launchctl &> /dev/null; then
    echo -e "  ${YELLOW}!${NC} launchctl not found, skipping limits apply"
    echo ""
    return
  fi

  sudo /bin/launchctl limit maxfiles 61440 61440 2>/dev/null && \
    echo -e "  ${GREEN}✓${NC} launchd maxfiles set" || \
    echo -e "  ${YELLOW}!${NC} failed to set launchd maxfiles"

  echo ""
}

setup_zsh_configs() {
  echo "Setting up zsh config..."

  ZSHENV_SOURCE="$SCRIPT_DIR/zsh/.zshenv"
  ZSHENV_TARGET="$HOME/.zshenv"

  ZSHRC_SOURCE="$SCRIPT_DIR/zsh/.zshrc"
  ZSHRC_TARGET="$HOME/.zshrc"

  if [ ! -f "$ZSHENV_SOURCE" ]; then
    echo -e "  ${YELLOW}!${NC} zsh config source not found: $ZSHENV_SOURCE"
    echo ""
    return
  fi

  if [ ! -f "$ZSHRC_SOURCE" ]; then
    echo -e "  ${YELLOW}!${NC} zsh config source not found: $ZSHRC_SOURCE"
    echo ""
    return
  fi

  if [ -L "$ZSHENV_TARGET" ]; then
    CURRENT_TARGET=$(readlink "$ZSHENV_TARGET" 2>/dev/null || echo "")
    if [ "$CURRENT_TARGET" != "$ZSHENV_SOURCE" ]; then
      ln -sf "$ZSHENV_SOURCE" "$ZSHENV_TARGET"
    fi
    echo -e "  ${GREEN}✓${NC} .zshenv linked"
  elif [ -e "$ZSHENV_TARGET" ]; then
    echo "  Backing up existing .zshenv..."
    mv "$ZSHENV_TARGET" "$ZSHENV_TARGET.backup"
    ln -s "$ZSHENV_SOURCE" "$ZSHENV_TARGET"
    echo -e "  ${GREEN}✓${NC} .zshenv linked (backup created)"
  else
    ln -s "$ZSHENV_SOURCE" "$ZSHENV_TARGET"
    echo -e "  ${GREEN}✓${NC} .zshenv linked"
  fi

  if [ -L "$ZSHRC_TARGET" ]; then
    CURRENT_TARGET=$(readlink "$ZSHRC_TARGET" 2>/dev/null || echo "")
    if [ "$CURRENT_TARGET" != "$ZSHRC_SOURCE" ]; then
      ln -sf "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    fi
    echo -e "  ${GREEN}✓${NC} .zshrc linked"
  elif [ -e "$ZSHRC_TARGET" ]; then
    echo "  Backing up existing .zshrc..."
    mv "$ZSHRC_TARGET" "$ZSHRC_TARGET.backup"
    ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    echo -e "  ${GREEN}✓${NC} .zshrc linked (backup created)"
  else
    ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    echo -e "  ${GREEN}✓${NC} .zshrc linked"
  fi

  echo ""
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

install_uv_tools() {
  echo -e "${YELLOW}Installing Python CLI tools via uv...${NC}"

  UV="/run/current-system/sw/bin/uv"
  if [ ! -x "$UV" ]; then
    UV="uv"
  fi

  if ! command -v "$UV" &> /dev/null; then
    echo -e "  ${YELLOW}!${NC} uv not found, skipping Python tools"
    return
  fi

  tools=(
    "sqlit-tui"
  )

  for tool in "${tools[@]}"; do
    "$UV" tool install "$tool" 2>/dev/null && \
      echo -e "  ${GREEN}✓${NC} $tool" || \
      echo -e "  ${YELLOW}!${NC} $tool (may already be installed)"
  done

  echo ""
}

install_go_tools() {
  echo -e "${YELLOW}Installing Go CLI tools...${NC}"

  GO="/run/current-system/sw/bin/go"
  if [ ! -x "$GO" ]; then
    GO="go"
  fi

  if ! command -v "$GO" &> /dev/null; then
    echo -e "  ${YELLOW}!${NC} go not found, skipping Go tools"
    return
  fi

  echo ""
}

install_bun_tools() {
  echo -e "${YELLOW}Installing Bun global packages...${NC}"

  BUN="/run/current-system/sw/bin/bun"
  if [ ! -x "$BUN" ]; then
    BUN="bun"
  fi

  if ! command -v "$BUN" &> /dev/null; then
    echo -e "  ${YELLOW}!${NC} bun not found, skipping Bun tools"
    return
  fi

  tools=(
    "tokscale"
  )

  for tool in "${tools[@]}"; do
    "$BUN" add -g "$tool" 2>/dev/null && \
      echo -e "  ${GREEN}✓${NC} $tool" || \
      echo -e "  ${YELLOW}!${NC} $tool (may already be installed)"
  done

  echo ""
}

install_npm_tools() {
  echo -e "${YELLOW}Installing npm global packages...${NC}"

  NPM="/run/current-system/sw/bin/npm"
  if [ ! -x "$NPM" ]; then
    NPM="npm"
  fi

  if ! command -v "$NPM" &> /dev/null; then
    echo -e "  ${YELLOW}!${NC} npm not found, skipping npm tools"
    return
  fi

  tools=(
    "openportal"
    "pm2"
    "@anthropic-ai/claude-code"
    "@sourcegraph/amp"
  )

  for tool in "${tools[@]}"; do
    "$NPM" install -g "$tool" 2>/dev/null && \
      echo -e "  ${GREEN}✓${NC} $tool" || \
      echo -e "  ${YELLOW}!${NC} $tool (may already be installed)"
  done

  echo ""
}

setup_pm2_startup() {
  echo -e "${YELLOW}Setting up PM2 startup service...${NC}"

  PM2="$HOME/.npm-global/bin/pm2"
  if [ ! -x "$PM2" ]; then
    PM2="pm2"
  fi

  if ! command -v "$PM2" &> /dev/null; then
    echo -e "  ${YELLOW}!${NC} pm2 not found, skipping startup setup"
    return
  fi

  LAUNCHD_PLIST="$HOME/Library/LaunchAgents/pm2.$USER.plist"
  if [ -f "$LAUNCHD_PLIST" ]; then
    echo -e "  ${GREEN}✓${NC} PM2 startup already configured"
    return
  fi

  NODE_PATH=$(dirname "$(command -v node)")
  sudo env PATH="$PATH:$NODE_PATH" "$PM2" startup launchd -u "$USER" --hp "$HOME" && \
    echo -e "  ${GREEN}✓${NC} PM2 startup configured" || \
    echo -e "  ${YELLOW}!${NC} PM2 startup setup failed"

  echo ""
}

setup_openportal_dashboard() {
  echo -e "${YELLOW}Setting up OpenPortal Dashboard...${NC}"

  OPENPORTAL_DIR="$HOME/.local/share/openportal"
  DASHBOARD_SOURCE="$SCRIPT_DIR/openportal/dashboard.js"
  DASHBOARD_DEST="$OPENPORTAL_DIR/dashboard.js"
  LAUNCHAGENT_SOURCE="$SCRIPT_DIR/launchagents/com.klaudioz.openportal-dashboard.plist"
  LAUNCHAGENT_DEST="$HOME/Library/LaunchAgents/com.klaudioz.openportal-dashboard.plist"

  mkdir -p "$OPENPORTAL_DIR"

  if [ ! -f "$OPENPORTAL_DIR/sessions.json" ]; then
    echo '{}' > "$OPENPORTAL_DIR/sessions.json"
    echo -e "  ${GREEN}✓${NC} sessions.json created"
  fi

  if [ -f "$DASHBOARD_SOURCE" ]; then
    ln -sf "$DASHBOARD_SOURCE" "$DASHBOARD_DEST"
    echo -e "  ${GREEN}✓${NC} dashboard.js linked"
  else
    echo -e "  ${YELLOW}!${NC} dashboard.js source not found"
  fi

  if [ -f "$LAUNCHAGENT_SOURCE" ]; then
    mkdir -p "$HOME/Library/LaunchAgents"
    cp "$LAUNCHAGENT_SOURCE" "$LAUNCHAGENT_DEST"
    launchctl unload "$LAUNCHAGENT_DEST" 2>/dev/null || true
    launchctl load "$LAUNCHAGENT_DEST"
    echo -e "  ${GREEN}✓${NC} Dashboard LaunchAgent loaded (port 3000)"
  else
    echo -e "  ${YELLOW}!${NC} LaunchAgent plist not found"
  fi

  echo ""
}

install_cmatrix_wallpaper() {
  echo -e "${YELLOW}Setting up CMatrix Wallpaper LaunchAgent...${NC}"

  CMATRIX_SOURCE="$SCRIPT_DIR/launchagents/com.klaudioz.cmatrix-wallpaper.plist"
  CMATRIX_DEST="$HOME/Library/LaunchAgents/com.klaudioz.cmatrix-wallpaper.plist"

  if [ ! -x "/Applications/CMatrixWallpaper.app/Contents/MacOS/matrixdaemon" ]; then
    echo -e "  ${YELLOW}!${NC} CMatrixWallpaper.app not installed, skipping"
    echo ""
    return
  fi

  if [ -f "$CMATRIX_SOURCE" ]; then
    mkdir -p "$HOME/Library/LaunchAgents"
    cp "$CMATRIX_SOURCE" "$CMATRIX_DEST"
    echo -e "  ${GREEN}✓${NC} LaunchAgent installed"

    launchctl unload "$CMATRIX_DEST" 2>/dev/null || true
    launchctl load "$CMATRIX_DEST"
    echo -e "  ${GREEN}✓${NC} LaunchAgent loaded (CMatrix Wallpaper starting)"
  else
    echo -e "  ${YELLOW}!${NC} LaunchAgent plist not found"
  fi

  echo ""
}

install_local_casks() {
  echo -e "${YELLOW}Installing local casks...${NC}"

  LOCAL_TAP_DIR="$SCRIPT_DIR/homebrew-tap"
  HOMEBREW_TAP_DIR="$(brew --prefix)/Library/Taps/local"
  HOMEBREW_TAP_LINK="$HOMEBREW_TAP_DIR/homebrew-casks"

  if [ -d "$LOCAL_TAP_DIR/Casks" ]; then
    if [ ! -L "$HOMEBREW_TAP_LINK" ]; then
      echo "  Linking local tap..."
      mkdir -p "$HOMEBREW_TAP_DIR"
      ln -sf "$LOCAL_TAP_DIR" "$HOMEBREW_TAP_LINK"
    fi

    for cask_file in "$LOCAL_TAP_DIR/Casks"/*.rb; do
      [ -f "$cask_file" ] || continue
      cask_name=$(basename "$cask_file" .rb)
      if brew list --cask "$cask_name" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $cask_name already installed"
      else
        echo "  Installing $cask_name..."
        brew install --cask --force "local/casks/$cask_name" && \
          echo -e "  ${GREEN}✓${NC} $cask_name installed" || \
          echo -e "  ${RED}✗${NC} $cask_name failed"
      fi
    done
  fi

  echo ""
}

start_services() {
  echo -e "${YELLOW}Restarting brew services...${NC}"

  for service in sketchybar borders; do
    brew services restart "$service" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} $service restarted"
  done

  if command -v aerospace &> /dev/null; then
    aerospace reload-config 2>/dev/null && \
      echo -e "  ${GREEN}✓${NC} aerospace config reloaded" || \
      echo -e "  ${YELLOW}!${NC} aerospace not running (config will load on next start)"
  fi

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
    git -C "$OH_MY_OPENCODE_DIR" fetch origin
    git -C "$OH_MY_OPENCODE_DIR" reset --hard origin/dev
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
  cleanup_legacy_launchctl_limits_agent
  apply_launchd_resource_limits

  echo ""
  install_local_casks

  echo -e "${YELLOW}Symlinking dotfiles...${NC}"
  cd "$SCRIPT_DIR"
  STOW="/run/current-system/sw/bin/stow"
  if [ ! -x "$STOW" ]; then
    STOW="stow"
  fi
  "$STOW" .
  setup_macos_configs
  setup_zsh_configs
  setup_vscode_configs
  install_uv_tools
  install_go_tools
  install_bun_tools
  install_npm_tools
  setup_pm2_startup
  install_cmatrix_wallpaper
  setup_openportal_dashboard

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
    verify_system_limits
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
    cleanup_legacy_launchctl_limits_agent
    setup_zsh_configs
    setup_vscode_configs
    echo -e "${GREEN}Done!${NC}"
    echo ""
    echo "Run './setup.sh --verify' to check if all tools are installed."
    ;;
esac
