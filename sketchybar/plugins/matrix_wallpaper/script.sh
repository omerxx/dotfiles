#!/usr/bin/env bash

set -euo pipefail

APP="/Applications/CMatrixWallpaper.app"
DAEMON="$APP/Contents/MacOS/matrixdaemon"

is_running() {
  pgrep -f "$DAEMON" >/dev/null 2>&1
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

update_item() {
  if [[ -z "${NAME:-}" ]] || ! command -v sketchybar >/dev/null 2>&1; then
    return 0
  fi

  if is_running; then
    sketchybar --set "$NAME" label="ON"
  else
    sketchybar --set "$NAME" label="OFF"
  fi
}

case "${SENDER:-}" in
mouse.clicked)
  if is_running; then
    stop_daemon
  else
    start_daemon
  fi
  ;;
esac

update_item

