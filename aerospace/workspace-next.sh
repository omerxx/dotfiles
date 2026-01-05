#!/usr/bin/env bash
set -e

# Focus next window; if at the edge, switch to next workspace.

AEROSPACE="/opt/homebrew/bin/aerospace"
if [[ ! -x "$AEROSPACE" ]]; then
  AEROSPACE="aerospace"
fi

if "$AEROSPACE" focus dfs-next --boundaries-action fail --ignore-floating >/dev/null 2>&1; then
  exit 0
fi

"$AEROSPACE" list-workspaces --monitor all | sort -n | "$AEROSPACE" workspace --wrap-around --stdin next
