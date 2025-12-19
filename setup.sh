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
    "sketchybar:sketchybar"
    "borders:borders"
    "skhd:skhd"
    "icalBuddy:ical-buddy"
    "go:go"
    "node:nodejs"
    "claude:claude-code"
    "codex:codex-cli"
    "gemini-cli:gemini-cli"
    "aichat:aichat"
    "lazygit:lazygit"
    "uv:uv"
    "delta:delta"
    "kubectl:kubectl"
    "aws:awscli"
    "gcloud:gcloud"
    "doctl:doctl"
    "flyctl:flyctl"
    "aicommit2:aicommit2"
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

show_help() {
  echo "Usage: ./setup.sh [OPTION]"
  echo ""
  echo "Options:"
  echo "  --verify    Check if all required tools are installed"
  echo "  --help      Show this help message"
  echo "  (none)      Run stow to symlink dotfiles"
}

case "$1" in
  --verify)
    check_prerequisites
    verify_tools
    ;;
  --help|-h)
    show_help
    ;;
  *)
    check_prerequisites
    echo "Symlinking dotfiles with stow..."
    stow .
    echo -e "${GREEN}Done!${NC}"
    echo ""
    echo "Run './setup.sh --verify' to check if all tools are installed."
    ;;
esac
