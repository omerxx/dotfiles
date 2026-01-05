#!/usr/bin/env bash
set -e

# Focus the previous window; if at the edge, switch to the previous workspace and focus the last window there.
#
# Tunables (optional):
# - AEROSPACE_THUMBWHEEL_WORKSPACES: whitespace-separated allowlist (default: "1 2 3 4")
# - AEROSPACE_THUMBWHEEL_COOLDOWN_MS: debounce window (default: 0)

AEROSPACE="/opt/homebrew/bin/aerospace"
if [[ ! -x "$AEROSPACE" ]]; then
  AEROSPACE="aerospace"
fi

cooldown_ms="${AEROSPACE_THUMBWHEEL_COOLDOWN_MS:-0}"
if [[ "$cooldown_ms" =~ ^[0-9]+$ ]] && ((cooldown_ms > 0)); then
  lock_dir="${TMPDIR:-/tmp}/aerospace-thumbwheel-prev.lock"
  if ! mkdir "$lock_dir" 2>/dev/null; then
    exit 0
  fi
  trap 'rmdir "$lock_dir" 2>/dev/null || true' EXIT

  ts_file="${TMPDIR:-/tmp}/aerospace-thumbwheel-prev.ts"
  now_ms="$(/usr/bin/perl -MTime::HiRes=time -e 'print int(time()*1000)')"
  last_ms="0"
  if [[ -f "$ts_file" ]]; then
    last_ms="$(cat "$ts_file" 2>/dev/null || echo 0)"
  fi
  if [[ "$last_ms" =~ ^[0-9]+$ ]] && ((now_ms - last_ms < cooldown_ms)); then
    exit 0
  fi
  printf '%s' "$now_ms" > "$ts_file"
fi

focused_window_id="$("$AEROSPACE" list-windows --focused --format '%{window-id}' 2>/dev/null || true)"
if [[ -z "$focused_window_id" ]]; then
  window_count="$("$AEROSPACE" list-windows --workspace focused --count 2>/dev/null || echo 0)"
  if ! [[ "$window_count" =~ ^[0-9]+$ ]] || ((window_count < 1)); then
    exit 0
  fi
  "$AEROSPACE" focus --dfs-index $((window_count - 1)) >/dev/null 2>&1 || exit 0
fi

if "$AEROSPACE" focus dfs-prev --boundaries-action fail >/dev/null 2>&1; then
  exit 0
fi

current_workspace="$("$AEROSPACE" list-workspaces --focused 2>/dev/null || true)"
non_empty_workspaces="$("$AEROSPACE" list-workspaces --monitor focused --empty no 2>/dev/null || true)"
if [[ -z "$non_empty_workspaces" ]]; then
  exit 0
fi

allowed_workspaces="${AEROSPACE_THUMBWHEEL_WORKSPACES:-1 2 3 4}"

candidate_workspaces=()
for ws in $allowed_workspaces; do
  if printf '%s\n' "$non_empty_workspaces" | grep -Fxq "$ws"; then
    candidate_workspaces+=("$ws")
  fi
done

if ((${#candidate_workspaces[@]} == 0)); then
  while IFS= read -r ws; do
    [[ -n "$ws" ]] || continue
    candidate_workspaces+=("$ws")
  done <<<"$non_empty_workspaces"
fi

if ((${#candidate_workspaces[@]} == 0)); then
  exit 0
fi

target_workspace=""
for i in "${!candidate_workspaces[@]}"; do
  if [[ "${candidate_workspaces[$i]}" == "$current_workspace" ]]; then
    prev_index=$(((i - 1 + ${#candidate_workspaces[@]}) % ${#candidate_workspaces[@]}))
    target_workspace="${candidate_workspaces[$prev_index]}"
    break
  fi
done

if [[ -z "$target_workspace" ]]; then
  target_workspace="${candidate_workspaces[${#candidate_workspaces[@]} - 1]}"
fi

"$AEROSPACE" workspace "$target_workspace" >/dev/null 2>&1 || exit 0

window_count="$("$AEROSPACE" list-windows --workspace focused --count 2>/dev/null || echo 0)"
if ! [[ "$window_count" =~ ^[0-9]+$ ]] || ((window_count < 1)); then
  exit 0
fi

"$AEROSPACE" focus --dfs-index $((window_count - 1)) >/dev/null 2>&1 || exit 0
