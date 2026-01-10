# Keep PATH consistent for *all* zsh invocations (including non-interactive `zsh -c`).
# Codex and git hooks rely on this to find Homebrew/Nix-installed tools.

if [[ -n "${ZPROF:-}" ]]; then
  zmodload zsh/zprof
fi

# Keep zsh fully user-configured and avoid slow/variable `/etc/*` startup files.
unsetopt GLOBAL_RCS

typeset -U path

path_additions=()

# Nix (nix-darwin)
[[ -d /run/current-system/sw/bin ]] && path_additions+=(/run/current-system/sw/bin)

# Homebrew (Apple Silicon)
[[ -d /opt/homebrew/bin ]] && path_additions+=(/opt/homebrew/bin)
[[ -d /opt/homebrew/sbin ]] && path_additions+=(/opt/homebrew/sbin)

# User-level tool bins (created by setup.sh and various tool installers)
[[ -d "$HOME/.local/bin" ]] && path_additions+=("$HOME/.local/bin")
[[ -d "$HOME/.opencode/bin" ]] && path_additions+=("$HOME/.opencode/bin")
[[ -d "$HOME/.npm-global/bin" ]] && path_additions+=("$HOME/.npm-global/bin")
[[ -d "$HOME/.bun/bin" ]] && path_additions+=("$HOME/.bun/bin")
[[ -d "$HOME/go/bin" ]] && path_additions+=("$HOME/go/bin")
[[ -d "$HOME/.cargo/bin" ]] && path_additions+=("$HOME/.cargo/bin")

# libpq (PostgreSQL)
[[ -d "/opt/homebrew/opt/libpq/bin" ]] && path_additions+=("/opt/homebrew/opt/libpq/bin")

# App bundle CLIs (optional, but convenient)
[[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]] && \
  path_additions+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")
[[ -d "/Applications/Cursor.app/Contents/Resources/app/bin" ]] && \
  path_additions+=("/Applications/Cursor.app/Contents/Resources/app/bin")
[[ -d "/Applications/Windsurf.app/Contents/Resources/app/bin" ]] && \
  path_additions+=("/Applications/Windsurf.app/Contents/Resources/app/bin")

path=($path_additions $path)
export PATH

unset path_additions

# Optional per-machine secrets (not committed)
[[ -f "$HOME/.config/opencode/secrets.zsh" ]] && source "$HOME/.config/opencode/secrets.zsh"

# Ensure child processes (like `opencode`) can read it even if the secrets file forgot `export`.
[[ -n "${QUOTIO_API_KEY:-}" ]] && export QUOTIO_API_KEY

# Force Quotio models even when a project has its own `opencode.json` / `.opencode/` config.
export OPENCODE_CONFIG_CONTENT='{"model":"quotio/gemini-claude-sonnet-4-5","small_model":"quotio/gemini-3-flash-preview"}'

# Stop using the old wrapper-based launcher if it's still present in the parent environment.
unset OPENCODE_BIN_PATH

# CLI Proxy API endpoint
export CLIPROXYAPI_ENDPOINT="http://localhost:8317/v1"

# OpenCode launcher: default to isolated git worktrees (fast parallel sessions).
_opencode_run() {
  if command -v ocx >/dev/null 2>&1 && [[ -d "$HOME/.config/opencode/profiles" ]]; then
    ocx ghost opencode "$@"
    return $?
  fi

  opencode "$@"
}

_opencode_is_subcommand() {
  case "${1:-}" in
    completion|acp|attach|run|auth|agent|upgrade|uninstall|serve|web|models|stats|export|import|github|pr|session)
      return 0
      ;;
  esac
  return 1
}

o() {
  if [[ "${1:-}" == "--here" ]]; then
    shift
    _opencode_run "$@"
    return $?
  fi

  # Don't spawn worktrees for subcommands/help/version.
  if _opencode_is_subcommand "${1:-}" || [[ " $* " == *" --help "* || " $* " == *" -h "* || " $* " == *" --version "* || " $* " == *" -v "* ]]; then
    _opencode_run "$@"
    return $?
  fi

  local base_dir="$PWD"
  if [[ $# -gt 0 && "${1:-}" != -* && -d "${1:-}" ]]; then
    base_dir="${1}"
    shift
  fi

  local branch=""
  if [[ $# -gt 0 && "${1:-}" != -* && ! -d "${1:-}" ]] && ! _opencode_is_subcommand "${1:-}"; then
    branch="${1}"
    shift
  fi

  local session_script="$HOME/.config/opencode/worktree-session.sh"
  if [[ -r "$session_script" ]]; then
    local out target_dir branch_used
    out="$(bash "$session_script" "$base_dir" "$branch")" || return $?
    IFS=$'\t' read -r target_dir branch_used <<<"$out"
    if [[ -n "${target_dir:-}" && -d "${target_dir:-}" ]]; then
      cd "$target_dir" || return $?
    fi
  else
    cd "$base_dir" || return $?
  fi

  _opencode_run "$@"
}
