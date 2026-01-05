#!/usr/bin/env bash
set -e

# Reset the focused workspace to a sane tiling layout:
# - Force all windows to tiling (no accidental floating)
# - Flatten the workspace tree
# - Set layout to horizontal tiles

AEROSPACE="/opt/homebrew/bin/aerospace"
if [[ ! -x "$AEROSPACE" ]]; then
  AEROSPACE="aerospace"
fi

focused_window_id="$("$AEROSPACE" list-windows --focused --format '%{window-id}' 2>/dev/null || true)"
if [[ -z "$focused_window_id" ]]; then
  first_window_id="$("$AEROSPACE" list-windows --workspace focused --format '%{window-id}' 2>/dev/null | head -n 1 || true)"
  if [[ -z "$first_window_id" ]]; then
    exit 0
  fi
  "$AEROSPACE" focus --window-id "$first_window_id" >/dev/null 2>&1 || exit 0
fi

while IFS= read -r window_id; do
  [[ -n "$window_id" ]] || continue
  "$AEROSPACE" layout --window-id "$window_id" tiling >/dev/null 2>&1 || true
done < <("$AEROSPACE" list-windows --workspace focused --format '%{window-id}' 2>/dev/null || true)

"$AEROSPACE" flatten-workspace-tree >/dev/null 2>&1 || true
"$AEROSPACE" layout tiles horizontal >/dev/null 2>&1 || true
