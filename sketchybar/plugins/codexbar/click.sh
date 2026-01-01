#!/usr/bin/env bash
set -e

RELPATH="$HOME/.config/sketchybar"

open -ga "CodexBar" >/dev/null 2>&1 || true

if [[ ! -x "$RELPATH/menubar" ]]; then
  exit 0
fi

if [[ "${BUTTON:-}" == "right" ]]; then
  "$RELPATH/menubar" -s "CodexBar,Settings..." >/dev/null 2>&1 || true
  "$RELPATH/menubar" -s "CodexBar,Settings…" >/dev/null 2>&1 || true
  exit 0
fi

"$RELPATH/menubar" -s "CodexBar" >/dev/null 2>&1 || true
