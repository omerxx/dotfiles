#!/usr/bin/env bash
set -e

# Cycle to next workspace (including empty), wrap to first if at the end

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

if [[ "$current_idx" -eq -1 ]] || [[ "$current_idx" -eq $((${#workspaces[@]} - 1)) ]]; then
  next_idx=0
else
  next_idx=$((current_idx + 1))
fi

"$AEROSPACE" workspace "${workspaces[$next_idx]}"
