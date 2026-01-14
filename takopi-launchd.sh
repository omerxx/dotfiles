#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_warn() {
  echo -e "${YELLOW}!${NC} $1" >&2
}

log_error() {
  echo -e "${RED}✗${NC} $1" >&2
}

HOME_DIR="${HOME:-/Users/klaudioz}"
TAKOPI_CONFIG="${HOME_DIR}/.takopi/takopi.toml"
TAKOPI_BIN="${HOME_DIR}/.local/bin/takopi"
OPENCODE_SECRETS="${HOME_DIR}/.config/opencode/secrets.zsh"

if [[ ! -f "$TAKOPI_CONFIG" ]]; then
  log_warn "takopi config not found: $TAKOPI_CONFIG"
  log_warn "Run: takopi --onboard"
  exit 0
fi

export TAKOPI_NO_INTERACTIVE=1

# launchd does not inherit the interactive shell PATH. Ensure Nix + Homebrew + uv tools are visible.
path_additions=(
  /run/current-system/sw/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  "$HOME_DIR/.local/bin"
  "$HOME_DIR/.opencode/bin"
  "$HOME_DIR/.npm-global/bin"
  "$HOME_DIR/.bun/bin"
  "$HOME_DIR/go/bin"
  "$HOME_DIR/.cargo/bin"
)

for dir in "${path_additions[@]}"; do
  [[ -d "$dir" ]] && PATH="${dir}:${PATH}"
done

export PATH

if [[ -f "$OPENCODE_SECRETS" ]]; then
  # shellcheck source=/dev/null
  source "$OPENCODE_SECRETS"
fi

[[ -n "${QUOTIO_API_KEY:-}" ]] && export QUOTIO_API_KEY
export CLIPROXYAPI_ENDPOINT="http://localhost:8317/v1"
export OPENCODE_CONFIG_CONTENT='{"model":"quotio/gemini-claude-sonnet-4-5","small_model":"quotio/gemini-3-flash-preview"}'
unset OPENCODE_BIN_PATH

if [[ ! -x "$TAKOPI_BIN" ]]; then
  log_warn "takopi not found at: $TAKOPI_BIN"
  exit 0
fi

if ! command -v opencode >/dev/null 2>&1 && ! command -v codex >/dev/null 2>&1 && ! command -v claude >/dev/null 2>&1 && \
  ! command -v pi >/dev/null 2>&1; then
  log_warn "no engine found on PATH (need one of: opencode, codex, claude, pi)"
  exit 0
fi

# If Takopi has no projects configured, it runs in the startup working directory.
# Keep that contained to ~/.takopi to avoid polluting $HOME.
cd "${HOME_DIR}/.takopi" 2>/dev/null || cd "$HOME_DIR"

exec "$TAKOPI_BIN" opencode
