#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_step() {
  echo ""
  echo -e "${BLUE}==>${NC} $1"
  echo ""
}

print_success() {
  echo -e "  ${GREEN}✓${NC} $1"
}

print_skip() {
  echo -e "  ${YELLOW}→${NC} $1 (already installed)"
}

print_error() {
  echo -e "  ${RED}✗${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  print_error "This script only works on macOS"
  exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     macOS Development Environment      ║${NC}"
echo -e "${GREEN}║           Bootstrap Script             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Xcode Command Line Tools
print_step "Step 1/5: Xcode Command Line Tools"

if xcode-select -p &> /dev/null; then
  print_skip "Xcode Command Line Tools"
else
  echo "Installing Xcode Command Line Tools..."
  echo "A dialog will appear. Click 'Install' and wait for completion."
  xcode-select --install

  echo ""
  echo -e "${YELLOW}Waiting for Xcode Command Line Tools installation...${NC}"
  echo "Press Enter after installation completes."
  read -r

  if xcode-select -p &> /dev/null; then
    print_success "Xcode Command Line Tools installed"
  else
    print_error "Xcode Command Line Tools installation failed"
    exit 1
  fi
fi

# Step 2: Rosetta 2 (for Apple Silicon)
print_step "Step 2/5: Rosetta 2 (Apple Silicon)"

if [[ "$(uname -m)" == "arm64" ]]; then
  if /usr/bin/pgrep -q oahd; then
    print_skip "Rosetta 2"
  else
    echo "Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license
    print_success "Rosetta 2 installed"
  fi
else
  echo "  Not needed (Intel Mac)"
fi

# Step 3: Homebrew
print_step "Step 3/5: Homebrew"

if command -v brew &> /dev/null; then
  print_skip "Homebrew"
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  print_success "Homebrew installed"
fi

# Step 4: Nix
print_step "Step 4/5: Nix Package Manager"

# Helper function to source Nix
source_nix() {
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
}

# Try sourcing Nix first in case it's installed but not in PATH
source_nix

if command -v nix &> /dev/null; then
  print_skip "Nix"
else
  echo "Installing Nix (Determinate Systems installer)..."
  echo ""
  echo -e "${YELLOW}Note: The installer may prompt for sudo password and confirmation.${NC}"
  echo ""
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # Source Nix for this session
  source_nix

  # Verify nix is now available
  if command -v nix &> /dev/null; then
    print_success "Nix installed"
  else
    echo ""
    echo -e "${YELLOW}Nix installed but not in PATH for this session.${NC}"
    echo "Please run the following command and restart the script:"
    echo ""
    echo -e "  ${GREEN}. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh${NC}"
    echo ""
    exit 1
  fi
fi

# Step 5: Nix-Darwin
print_step "Step 5/5: Nix-Darwin Configuration"

cd "$SCRIPT_DIR/nix-darwin"

# Check hostname and provide guidance
CURRENT_HOSTNAME=$(scutil --get ComputerName)
echo "Current hostname: $CURRENT_HOSTNAME"
echo ""

if grep -q "\"$CURRENT_HOSTNAME\"" flake.nix; then
  print_success "Hostname found in flake.nix"
else
  echo -e "${YELLOW}Warning:${NC} Hostname '$CURRENT_HOSTNAME' not found in flake.nix"
  echo "You may need to add a configuration for your machine."
  echo ""
fi

echo "Building and switching to nix-darwin configuration..."
echo "This may take several minutes on first run..."
echo ""

# Use full flake reference for first-time installation
if command -v darwin-rebuild &> /dev/null; then
  darwin-rebuild switch --flake .
else
  echo "Running nix-darwin for the first time..."

  # Backup existing config files that nix-darwin wants to manage
  for file in /etc/nix/nix.conf /etc/zshenv; do
    if [ -f "$file" ]; then
      echo "Backing up $file to ${file}.before-nix-darwin"
      sudo mv "$file" "${file}.before-nix-darwin"
    fi
  done

  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ".#$CURRENT_HOSTNAME"
fi

# Add nix-darwin tools to PATH for this session
export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH"

print_success "Nix-Darwin configuration applied"

# Stow dotfiles
print_step "Symlinking Dotfiles"

cd "$SCRIPT_DIR"

# Stow should be installed now via nix-darwin
if command -v stow &> /dev/null; then
  ./setup.sh
  print_success "Dotfiles symlinked"
else
  print_error "Stow not found. Restart terminal and run: ./setup.sh"
fi

# Final step: Accessibility permissions
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Installation Complete!         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Manual steps required:${NC}"
echo ""
echo "1. Start services (they will prompt for Accessibility permissions):"
echo -e "   ${GREEN}brew services start sketchybar${NC}"
echo ""
echo "2. Grant Accessibility permissions in System Settings:"
echo "   Opening System Settings > Privacy & Security > Accessibility..."
echo ""
echo "   Add these apps/binaries:"
echo "   - Aerospace (from /Applications)"
echo "   - Hammerspoon (from /Applications)"
echo "   - sketchybar: /opt/homebrew/bin/sketchybar"
echo ""

open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

echo "3. Restart your terminal, then verify installation:"
echo ""
echo -e "   ${GREEN}cd $SCRIPT_DIR && ./setup.sh --verify${NC}"
echo ""
