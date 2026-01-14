#!/usr/bin/env bash
set -e

export TAKOPI_NO_INTERACTIVE=1

# Keep PATH consistent with interactive shells so Takopi can find `opencode`, `git`, `gh`, etc.
path_additions=()
[[ -d /run/current-system/sw/bin ]] && path_additions+=(/run/current-system/sw/bin)
[[ -d /opt/homebrew/bin ]] && path_additions+=(/opt/homebrew/bin)
[[ -d /opt/homebrew/sbin ]] && path_additions+=(/opt/homebrew/sbin)
[[ -d "$HOME/.local/bin" ]] && path_additions+=("$HOME/.local/bin")
[[ -d "$HOME/.opencode/bin" ]] && path_additions+=("$HOME/.opencode/bin")
[[ -d "$HOME/.npm-global/bin" ]] && path_additions+=("$HOME/.npm-global/bin")
[[ -d "$HOME/.bun/bin" ]] && path_additions+=("$HOME/.bun/bin")
[[ -d "$HOME/go/bin" ]] && path_additions+=("$HOME/go/bin")
[[ -d "$HOME/.cargo/bin" ]] && path_additions+=("$HOME/.cargo/bin")
[[ -d "/opt/homebrew/opt/libpq/bin" ]] && path_additions+=("/opt/homebrew/opt/libpq/bin")
if [[ ${#path_additions[@]} -gt 0 ]]; then
  prefix="$(IFS=:; echo "${path_additions[*]}")"
  if [[ -n "${PATH:-}" ]]; then
    export PATH="${prefix}:${PATH}"
  else
    export PATH="${prefix}"
  fi
fi
unset path_additions prefix

# Optional per-machine secrets (not committed).
SECRETS_FILE="$HOME/.config/opencode/secrets.zsh"
if [[ -f "$SECRETS_FILE" ]]; then
  set +e
  # shellcheck disable=SC1090
  source "$SECRETS_FILE"
  set -e
fi

# Ensure child processes (like `opencode`) can read it even if the secrets file forgot `export`.
[[ -n "${QUOTIO_API_KEY:-}" ]] && export QUOTIO_API_KEY

# Force Quotio models even when a project has its own `opencode.json` / `.opencode/` config.
export OPENCODE_CONFIG_CONTENT='{"model":"quotio/gemini-claude-sonnet-4-5","small_model":"quotio/gemini-3-flash-preview"}'

# Stop using the old wrapper-based launcher if it's still present in the parent environment.
unset OPENCODE_BIN_PATH

# CLI Proxy API endpoint.
export CLIPROXYAPI_ENDPOINT="http://localhost:8317/v1"

CONFIG_PATH="$HOME/.takopi/takopi.toml"
if [[ ! -f "$CONFIG_PATH" ]]; then
  exit 0
fi

TAKOPI_BIN="$HOME/.local/bin/takopi"
if [[ ! -x "$TAKOPI_BIN" ]]; then
  exit 0
fi

exec "$TAKOPI_BIN" opencode
