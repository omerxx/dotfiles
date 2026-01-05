#!/bin/bash
# Cycle to next workspace, wrap to first if at the end

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

# Calculate next index with wrap
if [ $current_idx -eq -1 ] || [ $current_idx -eq $((${#workspaces[@]} - 1)) ]; then
    next_idx=0
else
    next_idx=$((current_idx + 1))
fi

aerospace workspace "${workspaces[$next_idx]}"
