#!/usr/bin/env bash
set -e

# Cycle to previous workspace (including empty), wrap to last if at the beginning

AEROSPACE="/opt/homebrew/bin/aerospace"
if [[ ! -x "$AEROSPACE" ]]; then
  AEROSPACE="aerospace"
fi

current="$("$AEROSPACE" list-workspaces --focused)"

mapfile -t workspaces < <("$AEROSPACE" list-workspaces --monitor all | sort -n)
if [[ ${#workspaces[@]} -eq 0 ]]; then
  exit 0
fi

current_idx=-1
for idx in "${!workspaces[@]}"; do
  if [[ "${workspaces[$idx]}" == "$current" ]]; then
    current_idx="$idx"
    break
  fi
done

if [[ "$current_idx" -le 0 ]]; then
  prev_idx=$((${#workspaces[@]} - 1))
else
  prev_idx=$((current_idx - 1))
fi

"$AEROSPACE" workspace "${workspaces[$prev_idx]}"
