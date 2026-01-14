#!/usr/bin/env bash
set -e

export TAKOPI_NO_INTERACTIVE=1

CONFIG_PATH="$HOME/.takopi/takopi.toml"
if [[ ! -f "$CONFIG_PATH" ]]; then
  exit 0
fi

TAKOPI_BIN="$HOME/.local/bin/takopi"
if [[ ! -x "$TAKOPI_BIN" ]]; then
  exit 0
fi

exec "$TAKOPI_BIN"
