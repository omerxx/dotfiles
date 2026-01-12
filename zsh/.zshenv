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
  local original_dir="$PWD"

  if [[ "${1:-}" == "--here" ]]; then
    shift

    # Respect explicit project path for `--here`.
    if [[ $# -gt 0 && "${1:-}" != -* && -d "${1:-}" ]]; then
      _opencode_run "$@"
      return $?
    fi

    # Don't treat subcommands/help/version as a project path.
    if _opencode_is_subcommand "${1:-}" || [[ " $* " == *" --help "* || " $* " == *" -h "* || " $* " == *" --version "* || " $* " == *" -v "* ]]; then
      _opencode_run "$@"
      return $?
    fi

    _opencode_run "$PWD" "$@"
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
  local branch_used=""
  if [[ -r "$session_script" ]]; then
    local out target_dir
    out="$(bash "$session_script" "$base_dir" "$branch")" || return $?
    IFS=$'\t' read -r target_dir branch_used <<<"$out"
    if [[ -n "${target_dir:-}" && -d "${target_dir:-}" ]]; then
      cd "$target_dir" || return $?
    fi
  else
    cd "$base_dir" || return $?
  fi

  local repo_root=""
  repo_root="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || true)"

  if command -v takopi >/dev/null 2>&1; then
    local takopi_proj=""
    takopi_proj="$(basename "${repo_root:-$PWD}")"
    if [[ -n "${branch_used:-}" ]]; then
      echo "takopi: /${takopi_proj} @${branch_used}" >&2
    else
      echo "takopi: /${takopi_proj}" >&2
    fi
  fi

  _opencode_run "${repo_root:-$PWD}" "$@"
  local opencode_exit="$?"

  if [[ "$opencode_exit" -ne 0 && "$opencode_exit" -ne 130 ]]; then
    return "$opencode_exit"
  fi

  if [[ -z "$branch_used" || -z "$repo_root" ]]; then
    return 0
  fi

  local start_script="$HOME/.config/opencode/completion-workflow-start.sh"
  if [[ ! -r "$start_script" ]]; then
    echo "OpenCode completion start script missing: $start_script" >&2
    return 0
  fi

  cd "$original_dir" || return 0

  bash "$start_script" --repo "$repo_root" >/dev/null
}

# Tail the latest OpenCode completion workflow log.
# Usage:
#   t                 # tails last started workflow log (or newest log file)
#   t <path/prefix>   # tails a specific log (supports prefix match in log dir)
#   t -n 200          # tails last log with options
t() {
  local log_dir="${XDG_CACHE_HOME:-$HOME/.cache}/opencode/workflows"
  local pointer_file="${log_dir}/last.logpath"
  local target=""

  local args=("$@")

  if [[ ${#args[@]} -gt 0 ]]; then
    local last_arg="${args[-1]}"
    if [[ -f "$last_arg" ]]; then
      target="$last_arg"
      args=("${args[@]:0:${#args[@]}-1}")
    elif [[ "$last_arg" != -* ]]; then
      local match=""
      match="$(ls -1t "$log_dir/${last_arg}"* 2>/dev/null | head -n 1 || true)"
      if [[ -n "$match" ]]; then
        target="$match"
        args=("${args[@]:0:${#args[@]}-1}")
      fi
    fi
  fi

  if [[ -z "$target" && -f "$pointer_file" ]]; then
    target="$(cat "$pointer_file" 2>/dev/null || true)"
  fi

  if [[ -z "$target" ]]; then
    target="$(ls -1t "$log_dir"/*.log 2>/dev/null | head -n 1 || true)"
  fi

  if [[ -z "$target" || ! -f "$target" ]]; then
    echo "No OpenCode workflow log found in: $log_dir" >&2
    return 1
  fi

  if [[ " ${args[*]} " != *" -f "* && " ${args[*]} " != *" --follow "* ]]; then
    args+=(-f)
  fi

  tail "${args[@]}" "$target"
}
