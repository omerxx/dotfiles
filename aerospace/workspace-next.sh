#!/usr/bin/env bash
set -e

# Focus the window to the right; if at the edge, switch to the next non-empty workspace.

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

if "$AEROSPACE" focus right --boundaries-action fail >/dev/null 2>&1; then
  exit 0
fi

workspaces="$("$AEROSPACE" list-workspaces --monitor all --empty no 2>/dev/null | sort -n || true)"
if [[ -z "$workspaces" ]]; then
  exit 0
fi

printf '%s\n' "$workspaces" | "$AEROSPACE" workspace --wrap-around --stdin next

focused_window_id="$("$AEROSPACE" list-windows --focused --format '%{window-id}' 2>/dev/null || true)"
if [[ -z "$focused_window_id" ]]; then
  first_window_id="$("$AEROSPACE" list-windows --workspace focused --format '%{window-id}' 2>/dev/null | head -n 1 || true)"
  if [[ -z "$first_window_id" ]]; then
    exit 0
  fi
  "$AEROSPACE" focus --window-id "$first_window_id" >/dev/null 2>&1 || exit 0
fi

# Start at the left edge of the new workspace to keep rightward traversal consistent.
for _ in {1..20}; do
  if ! "$AEROSPACE" focus left --boundaries-action fail >/dev/null 2>&1; then
    break
  fi
done
