#!/usr/bin/env bash
set -e

# Focus the window to the right; if at the edge, switch to the next non-empty workspace.

AEROSPACE="/opt/homebrew/bin/aerospace"
if [[ ! -x "$AEROSPACE" ]]; then
  AEROSPACE="aerospace"
fi

if "$AEROSPACE" focus right --boundaries-action fail --ignore-floating >/dev/null 2>&1; then
  exit 0
fi

workspaces="$("$AEROSPACE" list-workspaces --monitor all --empty no 2>/dev/null | sort -n || true)"
if [[ -z "$workspaces" ]]; then
  exit 0
fi

printf '%s\n' "$workspaces" | "$AEROSPACE" workspace --wrap-around --stdin next

# Start at the left edge of the new workspace to keep rightward traversal consistent.
for _ in {1..50}; do
  if ! "$AEROSPACE" focus left --boundaries-action fail --ignore-floating >/dev/null 2>&1; then
    break
  fi
done
