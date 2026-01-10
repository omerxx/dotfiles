#!/usr/bin/env bash
set -e

# Colors (use these exact variables)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok() {
  echo -e "${GREEN}✓${NC} $1" >&2
}

warn() {
  echo -e "${YELLOW}!${NC} $1" >&2
}

err() {
  echo -e "${RED}✗${NC} $1" >&2
}

die() {
  err "$1"
  exit 1
}

usage() {
  cat <<'EOF'
Usage: completion-workflow-start.sh --repo <path> [--remote origin] [--base main]

Starts `completion-workflow.sh` detached in the background and prints the log file path.

Environment:
  OPENCODE_WORKFLOW_LOG_DIR   Override log directory (default: ~/.cache/opencode/workflows)
  OPENCODE_WORKFLOW_LOG_FILE  Override log file path

EOF
}

repo_dir=""
remote="origin"
base_branch=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo_dir="${2:-}"
      shift 2
      ;;
    --remote)
      remote="${2:-}"
      shift 2
      ;;
    --base)
      base_branch="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

command -v bash >/dev/null 2>&1 || die "bash is required"
command -v git >/dev/null 2>&1 || die "git is required"
command -v nohup >/dev/null 2>&1 || die "nohup is required"

if [[ -z "$repo_dir" ]]; then
  repo_dir="$(pwd)"
fi

if ! repo_root="$(git -C "$repo_dir" rev-parse --show-toplevel 2>/dev/null)"; then
  die "Not a git repository: $repo_dir"
fi

current_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
[[ -n "$current_branch" && "$current_branch" != "HEAD" ]] || die "Detached HEAD; cannot start workflow"

cache_dir_default="${XDG_CACHE_HOME:-$HOME/.cache}/opencode/workflows"
log_dir="${OPENCODE_WORKFLOW_LOG_DIR:-$cache_dir_default}"
ts="$(date +%Y%m%d-%H%M%S)"
safe_repo="$(basename "$repo_root")"
safe_branch="$current_branch"
safe_branch="${safe_branch//\//_}"
safe_branch="${safe_branch//:/_}"
safe_branch="${safe_branch// /_}"
log_file_default="$log_dir/${safe_repo}-${safe_branch}-${ts}.log"
log_file="${OPENCODE_WORKFLOW_LOG_FILE:-$log_file_default}"

mkdir -p "$(dirname "$log_file")" 2>/dev/null || die "Failed to create log dir: $(dirname "$log_file")"

completion_script="$HOME/.config/opencode/completion-workflow.sh"
[[ -r "$completion_script" ]] || die "Missing completion script: $completion_script"

ok "Starting completion workflow in background"
ok "Log: $log_file"

cmd=(bash "$completion_script" --repo "$repo_root" --remote "$remote")
if [[ -n "$base_branch" ]]; then
  cmd+=(--base "$base_branch")
fi

nohup env \
  OPENCODE_WORKFLOW_LOG=0 \
  GIT_TERMINAL_PROMPT=0 \
  "${cmd[@]}" >"$log_file" 2>&1 < /dev/null &
pid="$!"

echo "$pid" >"${log_file}.pid" 2>/dev/null || true

ok "PID: $pid"

echo "$log_file"
