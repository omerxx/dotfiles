#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-apply}"

stow_flags=(--verbose)
case "$MODE" in
  apply)
    ;;
  dry-run)
    stow_flags+=(--no)
    ;;
  restow)
    stow_flags+=(--restow)
    ;;
  delete|unstow)
    stow_flags+=(--delete)
    ;;
  *)
    echo "Usage: $0 [apply|dry-run|restow|delete]"
    exit 1
    ;;
esac

mkdir -p "$HOME/.config"

stow "${stow_flags[@]}" --dir="$ROOT" --target="$HOME" home
stow "${stow_flags[@]}" --dir="$ROOT" --target="$HOME/.config" config
