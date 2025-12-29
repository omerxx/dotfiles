#!/usr/bin/env bash

set -euo pipefail

APP="/Applications/CMatrixWallpaper.app"
DAEMON="$APP/Contents/MacOS/matrixdaemon"

STATE_DOMAIN="com.klaudioz.dotfiles"
STATE_KEY="MatrixWallpaperEnabled"

ACTION="${1:-update}"
ITEM_NAME="${NAME:-matrix_wallpaper}"

find_sketchybar_bin() {
  if [[ -x "/opt/homebrew/bin/sketchybar" ]]; then
    echo "/opt/homebrew/bin/sketchybar"
    return 0
  fi

  command -v sketchybar 2>/dev/null || true
}

is_running() {
  pgrep -f "$DAEMON" >/dev/null 2>&1
}

get_enabled() {
  local value
  value="$(defaults read "$STATE_DOMAIN" "$STATE_KEY" 2>/dev/null || true)"
  case "$value" in
  "" | 1 | true | TRUE | YES | yes) return 0 ;;
  *) return 1 ;;
  esac
}

set_enabled() {
  local enabled="$1"
  defaults write "$STATE_DOMAIN" "$STATE_KEY" -bool "$enabled" 2>/dev/null || true
}

get_display_ids() {
  /usr/bin/swift -e '
import CoreGraphics
var count: UInt32 = 0
CGGetActiveDisplayList(0, nil, &count)
var displays = [CGDirectDisplayID](repeating: 0, count: Int(count))
CGGetActiveDisplayList(count, &displays, &count)
print(displays.map(String.init).joined(separator: " "))
' 2>/dev/null || true
}

get_config_json() {
  defaults export com.cmatrix.wallpaper - 2>/dev/null | plutil -convert json -o - - 2>/dev/null || true
}

start_daemon() {
  if [[ ! -x "$DAEMON" ]]; then
    return 0
  fi

  local display_ids config_json
  display_ids="$(get_display_ids)"
  if [[ -z "$display_ids" ]]; then
    display_ids="$(/usr/bin/swift -e 'import CoreGraphics; print(CGMainDisplayID())' 2>/dev/null || true)"
  fi

  config_json="$(get_config_json)"

  for did in $display_ids; do
    if [[ -n "$config_json" ]]; then
      nohup "$DAEMON" "$did" "$config_json" >/dev/null 2>&1 &
    else
      nohup "$DAEMON" "$did" >/dev/null 2>&1 &
    fi
  done

  defaults write com.cmatrix.wallpaper MatrixLastEnabled -bool true 2>/dev/null || true
}

stop_daemon() {
  pkill -f "$DAEMON" 2>/dev/null || true
  defaults write com.cmatrix.wallpaper MatrixLastEnabled -bool false 2>/dev/null || true
}

ensure_state() {
  if get_enabled; then
    if ! is_running; then
      start_daemon
    fi
  else
    if is_running; then
      stop_daemon
    fi
  fi
}

update_item() {
  ensure_state

  local sketchybar_bin
  sketchybar_bin="$(find_sketchybar_bin)"
  if [[ -z "$sketchybar_bin" ]]; then
    return 0
  fi

if is_running; then
    "$sketchybar_bin" --set "$ITEM_NAME" label="ON" 2>/dev/null || true
  else
    "$sketchybar_bin" --set "$ITEM_NAME" label="OFF" 2>/dev/null || true
  fi
}

case "$ACTION" in
toggle)
  if get_enabled; then
    set_enabled false
  else
    set_enabled true
  fi
  ;;
esac

update_item
