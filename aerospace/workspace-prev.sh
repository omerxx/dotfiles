#!/bin/bash
# Cycle to previous workspace, wrap to last if at the beginning

current=$(aerospace list-workspaces --focused)
# Get all non-empty workspaces, sorted
workspaces=($(aerospace list-workspaces --monitor all --empty no | sort -n))

if [ ${#workspaces[@]} -eq 0 ]; then
    exit 0
fi

# Find current index
current_idx=-1
for i in "${!workspaces[@]}"; do
    if [ "${workspaces[$i]}" = "$current" ]; then
        current_idx=$i
        break
    fi
done

# Calculate previous index with wrap
if [ $current_idx -le 0 ]; then
    prev_idx=$((${#workspaces[@]} - 1))
else
    prev_idx=$((current_idx - 1))
fi

aerospace workspace "${workspaces[$prev_idx]}"
