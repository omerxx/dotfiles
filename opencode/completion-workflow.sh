#!/usr/bin/env bash
set -e

# Colors (use these exact variables)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

workflow_log_file=""
salvage_main_worktree=""
salvage_stash_oid=""

log_line() {
  [[ -n "${workflow_log_file:-}" ]] || return 0

  local level="${1:-INFO}"
  shift || true
  local msg="$*"

  local ts=""
  ts="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || true)"

  printf '%s [%s] %s\n' "${ts:-}" "$level" "$msg" >>"$workflow_log_file" 2>/dev/null || true
}

ok() {
  echo -e "${GREEN}✓${NC} $1"
  log_line INFO "$1"
}

warn() {
  echo -e "${YELLOW}!${NC} $1"
  log_line WARN "$1"
}

err() {
  echo -e "${RED}✗${NC} $1" >&2
  log_line ERROR "$1"
}

die() {
  err "$1"
  exit 1
}

usage() {
  cat <<'EOF'
Usage: completion-workflow.sh --repo <path> [--remote origin] [--base main]

Runs a worktree-safe "commit → rebase → push → PR → merge → verify → cleanup" workflow.

Notes:
- Does NOT use `gh pr merge --delete-branch` to avoid git-worktree checkout issues.
- If the worktree lives under `.opencode/worktrees/`, it removes the worktree and deletes the local branch after merge.
EOF
}

remote="origin"
base_branch=""
repo_dir=""

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

command -v git >/dev/null 2>&1 || die "git is required"

if [[ -z "$repo_dir" ]]; then
  repo_dir="$(pwd)"
fi

if ! repo_root="$(git -C "$repo_dir" rev-parse --show-toplevel 2>/dev/null)"; then
  warn "Not a git repository; skipping completion workflow"
  exit 0
fi

current_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
[[ -n "$current_branch" && "$current_branch" != "HEAD" ]] || die "Detached HEAD; cannot create PR workflow"

if [[ -z "$base_branch" ]]; then
  origin_head_ref="$(git -C "$repo_root" symbolic-ref --quiet "refs/remotes/${remote}/HEAD" 2>/dev/null || true)"
  base_branch="${origin_head_ref##*/}"
  [[ -n "$base_branch" ]] || base_branch="main"
fi

if [[ "$current_branch" == "$base_branch" ]]; then
  warn "On base branch ($base_branch); skipping completion workflow"
  exit 0
fi

commit_type_from_branch() {
  local branch="$1"
  case "$branch" in
    feat/*|feat-*|feat_*) echo "feat" ;;
    fix/*|fix-*|fix_*) echo "fix" ;;
    ui/*|ui-*|ui_*) echo "ui" ;;
    refactor/*|refactor-*|refactor_*) echo "refactor" ;;
    docs/*|docs-*|docs_*) echo "docs" ;;
    test/*|test-*|test_*) echo "test" ;;
    *) echo "chore" ;;
  esac
}

is_opencode_session_branch() {
  case "${1:-}" in
    oc/*|oc-*|oc_*)
      return 0
      ;;
  esac
  return 1
}

commit_type_from_files() {
  local repo="$1"
  local has_files="0"
  local all_docs="1"

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    has_files="1"

    case "$file" in
      *.md|*.txt) ;;
      *)
        all_docs="0"
        ;;
    esac
  done < <(git -C "$repo" diff --cached --name-only 2>/dev/null || true)

  [[ "$has_files" == "1" ]] || return 1
  if [[ "$all_docs" == "1" ]]; then
    echo "docs"
    return 0
  fi

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    case "$file" in
      */__tests__/*|*/test/*|*/tests/*|*/spec/*|*/specs/*|*.spec.*|*.test.*)
        echo "test"
        return 0
        ;;
    esac
  done < <(git -C "$repo" diff --cached --name-only 2>/dev/null || true)

  return 1
}

commit_desc_from_branch() {
  local branch="$1"
  local type="$2"
  local desc="$branch"

  desc="${desc#${type}/}"
  desc="${desc#${type}-}"
  desc="${desc#${type}_}"

  desc="${desc//\// }"
  desc="${desc//-/ }"
  desc="${desc//_/ }"

  desc="$(echo "$desc" | tr -s ' ' | sed 's/^ *//; s/ *$//')"
  [[ -n "$desc" ]] || desc="opencode changes"
  echo "$desc"
}

repo_has_code_changes() {
  local repo="$1"

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    case "$file" in
      *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.py|*.go|*.rs|*.java|*.kt|*.swift|*.c|*.cc|*.cpp|*.h|*.hpp|*.rb|*.php|*.cs|*.lua|*.sh|*.sql|*.proto|*.graphql|*.gql|Dockerfile|Makefile)
        return 0
        ;;
    esac
  done < <(git -C "$repo" diff --cached --name-only 2>/dev/null || true)

  return 1
}

shorten_path_for_desc() {
  local raw="${1:-}"
  [[ -n "$raw" ]] || return 1

  local file="$raw"
  if [[ "$file" == *"=>"* ]]; then
    file="$(echo "$file" | sed 's/.*=> //')"
  fi

  local base="${file##*/}"
  local parent="${file%/*}"
  if [[ "$parent" != "$file" && -n "$parent" ]]; then
    local last_dir="${parent##*/}"
    echo "${last_dir}/${base}"
    return 0
  fi

  echo "$base"
}

primary_change_target() {
  local repo="$1"

  local top
  top="$(git -C "$repo" diff --cached --dirstat=files,0 2>/dev/null | head -n 1 | sed -E 's/^[[:space:]]*[0-9.]+%[[:space:]]+//' || true)"
  top="${top%/}"
  if [[ -n "$top" && "$top" != "." ]]; then
    echo "$top"
    return 0
  fi

  local best_file=""
  best_file="$(git -C "$repo" diff --cached --numstat 2>/dev/null | awk -F'\t' '
    $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
      score = $1 + $2
      if (score > max) { max = score; best = $3 }
    }
    END { print best }
  ' | sed 's/[[:space:]]*$//' || true)"

  if [[ -n "$best_file" ]]; then
    shorten_path_for_desc "$best_file"
    return 0
  fi

  echo "changes"
}

commit_desc_from_diff() {
  local repo="$1"

  local count="0"
  local only_file=""
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    count="$((count + 1))"
    only_file="$file"
    if [[ "$count" -gt 1 ]]; then
      break
    fi
  done < <(git -C "$repo" diff --cached --name-only 2>/dev/null || true)

  local verb="update"
  local added="0"
  local deleted="0"
  local other="0"
  while IFS=$'\t' read -r status _rest; do
    [[ -n "$status" ]] || continue
    case "$status" in
      A*) added="1" ;;
      D*) deleted="1" ;;
      *) other="1" ;;
    esac
  done < <(git -C "$repo" diff --cached --name-status 2>/dev/null || true)

  if [[ "$added" == "1" && "$deleted" == "0" && "$other" == "0" ]]; then
    verb="add"
  elif [[ "$deleted" == "1" && "$added" == "0" && "$other" == "0" ]]; then
    verb="remove"
  fi

  if [[ "$count" == "1" ]]; then
    echo "$verb $(shorten_path_for_desc "$only_file")"
    return 0
  fi

  local target
  target="$(primary_change_target "$repo")"
  echo "$verb $target"
}

make_commit_message() {
  local repo="$1"
  local branch="$2"

  local type=""
  type="$(commit_type_from_files "$repo" || true)"
  if [[ -z "$type" ]]; then
    if is_opencode_session_branch "$branch"; then
      if repo_has_code_changes "$repo"; then
        type="feat"
      else
        type="chore"
      fi
    else
      type="$(commit_type_from_branch "$branch")"
    fi
  fi

  local desc
  if is_opencode_session_branch "$branch"; then
    desc="$(commit_desc_from_diff "$repo")"
  else
    desc="$(commit_desc_from_branch "$branch" "$type")"
  fi

  local msg="${type}: ${desc}"
  msg="${msg%.}"
  msg="$(echo "$msg" | tr -s ' ' | sed 's/^ *//; s/ *$//')"
  if ((${#msg} > 72)); then
    msg="${msg:0:72}"
    msg="${msg% }"
  fi

  echo "$msg"
}

sanitize_title() {
  local title="${1:-}"
  title="$(printf '%s' "$title" | tr '\r\n' '  ' | tr -s ' ' | sed 's/^ *//; s/ *$//')"
  printf '%s' "$title"
}

is_default_session_title() {
  local title="${1:-}"
  case "$title" in
    "New session - "*) return 0 ;;
  esac
  return 1
}

opencode_session_title_for_dir() {
  local directory="${1:-}"
  [[ -n "$directory" ]] || return 1

  local session_dir="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/storage/session"
  [[ -d "$session_dir" ]] || return 1

  command -v python3 >/dev/null 2>&1 || return 1

  python3 - "$session_dir" "$directory" <<'PY' || return 1
import json
import os
import sys

session_dir = sys.argv[1]
wanted_dir = sys.argv[2]

best_title = ""
best_updated = -1

try:
    project_dirs = os.listdir(session_dir)
except Exception:
    sys.exit(0)

for project_id in project_dirs:
    project_path = os.path.join(session_dir, project_id)
    if not os.path.isdir(project_path):
        continue

    try:
        session_files = os.listdir(project_path)
    except Exception:
        continue

    for name in session_files:
        if not name.endswith(".json"):
            continue
        path = os.path.join(project_path, name)
        try:
            with open(path, "r", encoding="utf-8") as f:
                meta = json.load(f)
        except Exception:
            continue

        if meta.get("directory") != wanted_dir:
            continue

        title = meta.get("title") or ""
        updated = (meta.get("time") or {}).get("updated") or 0
        if title and updated >= best_updated:
            best_title = title
            best_updated = updated

if best_title:
    print(best_title)
PY
}

preferred_pr_title() {
  local repo="$1"
  local git_title=""
  git_title="$(git -C "$repo" log -1 --pretty=%s 2>/dev/null || true)"

  local title_override=""
  title_override="$(sanitize_title "${OPENCODE_PR_TITLE:-}")"
  if [[ -n "$title_override" ]]; then
    echo "$title_override"
    return 0
  fi

  local title_env=""
  title_env="$(sanitize_title "${OPENCODE_SESSION_TITLE:-}")"
  if [[ -n "$title_env" ]] && ! is_default_session_title "$title_env"; then
    echo "$title_env"
    return 0
  fi

  local session_title=""
  session_title="$(sanitize_title "$(opencode_session_title_for_dir "$repo" 2>/dev/null || true)")"
  if [[ -n "$session_title" ]] && ! is_default_session_title "$session_title"; then
    echo "$session_title"
    return 0
  fi

  echo "$(sanitize_title "$git_title")"
}

workflow_log_enabled="${OPENCODE_WORKFLOW_LOG:-1}"
workflow_log_dir_default="${XDG_CACHE_HOME:-$HOME/.cache}/opencode/workflows"
workflow_log_dir="${OPENCODE_WORKFLOW_LOG_DIR:-$workflow_log_dir_default}"
workflow_log_file_override="${OPENCODE_WORKFLOW_LOG_FILE:-}"

case "$workflow_log_enabled" in
  0|false|no|off)
    workflow_log_file=""
    ;;
  *)
    ts="$(date +%Y%m%d-%H%M%S)"
    safe_repo="$(basename "$repo_root")"
    safe_branch="$current_branch"
    safe_branch="${safe_branch//\//_}"
    safe_branch="${safe_branch//:/_}"
    safe_branch="${safe_branch// /_}"
    workflow_log_file="${workflow_log_file_override:-$workflow_log_dir/${safe_repo}-${safe_branch}-${ts}.log}"
    mkdir -p "$(dirname "$workflow_log_file")" 2>/dev/null || workflow_log_file=""
    ;;
esac

if [[ -n "$workflow_log_file" ]]; then
  ok "Log: $workflow_log_file"
fi

ok "Repo: $repo_root"
ok "Branch: $current_branch (base: $base_branch)"
ok "Workflow: stage → commit → rebase → push → PR → merge(wait) → cleanup"

merge_wait_timeout="${OPENCODE_MERGE_WAIT_TIMEOUT:-7200}"
merge_poll_interval="${OPENCODE_MERGE_POLL_INTERVAL:-10}"
merge_heartbeat_interval="${OPENCODE_MERGE_HEARTBEAT_INTERVAL:-60}"
merge_method_preference="${OPENCODE_MERGE_METHOD:-}"

format_duration() {
  local total="${1:-0}"
  local h=$((total / 3600))
  local m=$(((total % 3600) / 60))
  local s=$((total % 60))
  if (( h > 0 )); then
    printf "%dh%02dm%02ds" "$h" "$m" "$s"
    return 0
  fi
  if (( m > 0 )); then
    printf "%dm%02ds" "$m" "$s"
    return 0
  fi
  printf "%ds" "$s"
}

wait_for_pr_merge() {
  local pr="$1"
  local start_ts
  start_ts="$(date +%s)"
  local last_heartbeat_ts="$start_ts"

  local last_status=""
  local status_line=""
  local merge_state_norm=""

  while true; do
    local pr_info=""
    pr_info="$(gh_in_repo pr view "$pr" --json state,mergedAt,mergeStateStatus,reviewDecision,isDraft,url --jq '[.state, (.mergedAt // ""), (.mergeStateStatus // ""), (.reviewDecision // ""), (.isDraft|tostring), .url] | @tsv' 2>/dev/null || true)"
    if [[ -z "$pr_info" ]]; then
      warn "Unable to fetch PR state; retrying..."
      sleep "$merge_poll_interval"
      continue
    fi

    local pr_state pr_merged_at pr_merge_state pr_review_decision pr_is_draft pr_url
    IFS=$'\t' read -r pr_state pr_merged_at pr_merge_state pr_review_decision pr_is_draft pr_url <<<"$pr_info"

    if [[ "$pr_is_draft" == "true" ]]; then
      die "PR is a draft; cannot merge: ${pr_url:-#$pr}"
    fi

    merge_state_norm="$(echo "${pr_merge_state:-}" | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]' || true)"
    if [[ "$merge_state_norm" == "DIRTY" ]]; then
      die "PR has merge conflicts; cannot auto-merge: ${pr_url:-#$pr}"
    fi

    if [[ "$pr_state" == "MERGED" && -n "$pr_merged_at" ]]; then
      ok "Merge verified (state=$pr_state mergedAt=$pr_merged_at)"
      return 0
    fi

    if [[ "$pr_state" == "CLOSED" ]]; then
      die "PR closed without merge: ${pr_url:-#$pr}"
    fi

    status_line="state=$pr_state mergeState=${pr_merge_state:-?} review=${pr_review_decision:-?}"
    if [[ "$status_line" != "$last_status" ]]; then
      warn "Waiting for merge ($status_line) ${pr_url:-}"
      last_status="$status_line"
    fi

    local now_ts
    now_ts="$(date +%s)"

    if (( merge_heartbeat_interval > 0 && now_ts - last_heartbeat_ts >= merge_heartbeat_interval )); then
      local elapsed
      elapsed="$(format_duration $((now_ts - start_ts)))"
      warn "Still waiting for merge (${elapsed} elapsed) ${pr_url:-}"
      last_heartbeat_ts="$now_ts"
    fi

    if [[ "$merge_wait_timeout" != "0" ]]; then
      if (( now_ts - start_ts > merge_wait_timeout )); then
        die "Timed out waiting for merge after ${merge_wait_timeout}s: ${pr_url:-#$pr}"
      fi
    fi

    sleep "$merge_poll_interval"
  done
}

find_main_worktree() {
  local repo="$1"
  local base="$2"
  local current="$3"

  local main=""
  local wt_path=""
  local wt_branch=""

  while IFS= read -r line; do
    case "$line" in
      worktree\ *)
        wt_path="${line#worktree }"
        wt_branch=""
        ;;
      branch\ refs/heads/*)
        wt_branch="${line#branch refs/heads/}"
        if [[ "$wt_branch" == "$base" && "$wt_path" != "$current" ]]; then
          main="$wt_path"
        fi
        ;;
    esac
  done < <(git -C "$repo" worktree list --porcelain)

  if [[ -n "$main" ]]; then
    echo "$main"
    return 0
  fi

  while IFS= read -r line; do
    case "$line" in
      worktree\ *)
        wt_path="${line#worktree }"
        if [[ "$wt_path" != "$current" && "$wt_path" != *"/.opencode/worktrees/"* ]]; then
          echo "$wt_path"
          return 0
        fi
        ;;
    esac
  done < <(git -C "$repo" worktree list --porcelain)

  return 1
}

cleanup_opencode_worktree() {
  local repo="$1"
  local remote_name="$2"
  local base="$3"
  local branch_to_delete="$4"

  if [[ "$repo" != *"/.opencode/worktrees/"* ]]; then
    return 0
  fi

  local main_worktree=""
  main_worktree="$(find_main_worktree "$repo" "$base" "$repo" || true)"
  if [[ -z "$main_worktree" ]]; then
    warn "Could not find main worktree; skipping local cleanup"
    return 0
  fi

  ok "Removing worktree: $repo"
  git -C "$main_worktree" worktree remove "$repo" --force

  if git -C "$main_worktree" show-ref --verify --quiet "refs/heads/$branch_to_delete" 2>/dev/null; then
    ok "Deleting local branch: $branch_to_delete"
    git -C "$main_worktree" branch -D "$branch_to_delete" >/dev/null
  fi

  local main_branch=""
  main_branch="$(git -C "$main_worktree" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ "$main_branch" != "$base" ]]; then
    warn "Main worktree is on '$main_branch' (expected '$base'); skipping auto-pull"
    return 0
  fi

  if [[ -n "$(git -C "$main_worktree" status --porcelain 2>/dev/null)" ]]; then
    warn "Main worktree has uncommitted changes; skipping auto-pull"
    return 0
  fi

  if ! git -C "$main_worktree" remote get-url "$remote_name" >/dev/null 2>&1; then
    warn "Remote '$remote_name' not found in main worktree; skipping auto-pull"
    return 0
  fi

  ok "Updating main worktree: $main_worktree"
  if git -C "$main_worktree" pull --ff-only "$remote_name" "$base" >/dev/null 2>&1; then
    ok "Main worktree updated"
  else
    warn "Main worktree auto-pull failed; run git pull manually in: $main_worktree"
  fi
}

find_stash_ref_by_oid() {
  local repo="$1"
  local oid="$2"
  [[ -n "${repo:-}" && -n "${oid:-}" ]] || return 1

  git -C "$repo" stash list --format='%gd%x09%H' 2>/dev/null | awk -F'\t' -v oid="$oid" '$2==oid {print $1; exit}'
}

maybe_salvage_main_worktree_changes() {
  local session_repo="$1"
  local base="$2"
  local branch="$3"

  [[ "$session_repo" == *"/.opencode/worktrees/"* ]] || return 0

  local main_worktree=""
  main_worktree="$(find_main_worktree "$session_repo" "$base" "$session_repo" || true)"
  [[ -n "$main_worktree" ]] || return 0

  local main_dirty=""
  main_dirty="$(git -C "$main_worktree" status --porcelain 2>/dev/null || true)"
  [[ -n "$main_dirty" ]] || return 0

  warn "Session worktree is clean, but main worktree has changes; salvaging into $branch"
  warn "Main worktree: $main_worktree"

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    echo "  $line"
  done <<<"$main_dirty"

  ok "Stashing main worktree changes"
  if ! git -C "$main_worktree" stash push -u -m "opencode salvage: $branch" >/dev/null 2>&1; then
    die "Failed to stash main worktree changes: $main_worktree"
  fi

  local stash_oid=""
  stash_oid="$(git -C "$main_worktree" rev-parse -q --verify stash@{0} 2>/dev/null || true)"
  [[ -n "$stash_oid" ]] || die "Stashed changes but failed to resolve stash@{0}"

  local stash_ref=""
  stash_ref="$(find_stash_ref_by_oid "$main_worktree" "$stash_oid" 2>/dev/null || true)"
  [[ -n "$stash_ref" ]] || stash_ref="stash@{0}"

  ok "Main worktree changes stashed: $stash_ref"

  ok "Applying stash to session worktree"
  if ! git -C "$session_repo" stash apply "$stash_ref" >/dev/null 2>&1; then
    warn "Failed to apply salvage stash to session worktree; resetting session worktree"
    git -C "$session_repo" reset --hard >/dev/null 2>&1 || true
    git -C "$session_repo" clean -fd >/dev/null 2>&1 || true
    warn "Recover changes with: git -C \"$main_worktree\" stash apply \"$stash_ref\""
    die "Salvage failed; aborting completion workflow"
  fi

  salvage_main_worktree="$main_worktree"
  salvage_stash_oid="$stash_oid"
  ok "Salvage applied to session worktree"
}

drop_salvage_stash() {
  [[ -n "${salvage_main_worktree:-}" && -n "${salvage_stash_oid:-}" ]] || return 0

  local stash_ref=""
  stash_ref="$(find_stash_ref_by_oid "$salvage_main_worktree" "$salvage_stash_oid" 2>/dev/null || true)"
  if [[ -z "$stash_ref" ]]; then
    warn "Salvage stash not found; leaving it in place (oid=$salvage_stash_oid)"
    return 0
  fi

  ok "Dropping salvage stash: $stash_ref"
  if ! git -C "$salvage_main_worktree" stash drop "$stash_ref" >/dev/null 2>&1; then
    warn "Failed to drop salvage stash: $stash_ref"
  fi
}

dirty="$(git -C "$repo_root" status --porcelain)"
if [[ -z "$dirty" ]]; then
  maybe_salvage_main_worktree_changes "$repo_root" "$base_branch" "$current_branch"
  dirty="$(git -C "$repo_root" status --porcelain)"
fi
if [[ -n "$dirty" ]]; then
  ok "Staging changes"
  git -C "$repo_root" add -A

  if git -C "$repo_root" diff --cached --quiet; then
    warn "No staged changes after add; skipping commit"
  else
    commit_msg="$(make_commit_message "$repo_root" "$current_branch")"
    ok "Committing: $commit_msg"
    git -C "$repo_root" commit -m "$commit_msg"
  fi
else
  warn "Working tree clean; skipping commit"
fi

if git -C "$repo_root" remote get-url "$remote" >/dev/null 2>&1; then
  ok "Fetching $remote/$base_branch"
  git -C "$repo_root" fetch "$remote" "$base_branch"

  ok "Rebasing onto $remote/$base_branch"
  if ! git -C "$repo_root" rebase "$remote/$base_branch"; then
    warn "Rebase failed; aborting rebase and continuing without rebase"

    if ! git -C "$repo_root" rebase --abort; then
      die "Failed to abort rebase; manual intervention required in: $repo_root"
    fi

    actual_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    if [[ -z "$actual_branch" || "$actual_branch" == "HEAD" || "$actual_branch" != "$current_branch" ]]; then
      warn "Returning to branch: $current_branch"
      git -C "$repo_root" checkout "$current_branch" >/dev/null 2>&1 || die "Failed to return to branch: $current_branch"
    fi
  fi
else
  warn "Remote '$remote' not found; skipping fetch/rebase"
fi

ahead_count="0"
if git -C "$repo_root" show-ref --verify --quiet "refs/remotes/${remote}/${base_branch}" 2>/dev/null; then
  ahead_count="$(git -C "$repo_root" rev-list --count "${remote}/${base_branch}..HEAD" 2>/dev/null || echo "0")"
fi

if [[ "$ahead_count" == "0" && -z "$(git -C "$repo_root" status --porcelain)" ]]; then
  warn "No commits ahead of $remote/$base_branch; nothing to PR/merge"
  cleanup_opencode_worktree "$repo_root" "$remote" "$base_branch" "$current_branch"
  exit 0
fi

if git -C "$repo_root" remote get-url "$remote" >/dev/null 2>&1; then
  ok "Pushing branch to $remote"
  if git -C "$repo_root" push -u "$remote" HEAD; then
    ok "Pushed"
  else
    warn "Push failed; retrying with --force-with-lease"
    git -C "$repo_root" push -u "$remote" HEAD --force-with-lease
    ok "Force-pushed with lease"
  fi
else
  warn "Remote '$remote' not found; skipping push"
fi

command -v gh >/dev/null 2>&1 || die "gh is required for PR create/merge"

gh_in_repo() {
  (cd "$repo_root" && gh "$@")
}

repo_merge_settings() {
  gh_in_repo repo view --json rebaseMergeAllowed,squashMergeAllowed,mergeCommitAllowed,viewerDefaultMergeMethod --jq \
    '[.rebaseMergeAllowed, .squashMergeAllowed, .mergeCommitAllowed, (.viewerDefaultMergeMethod // "")] | @tsv' 2>/dev/null || true
}

normalize_merge_method() {
  local method="${1:-}"
  method="$(echo "$method" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  case "$method" in
    rebase|squash|merge|"") echo "$method" ;;
    default) echo "" ;;
    *)
      return 1
      ;;
  esac
}

select_merge_method() {
  local requested_raw="${1:-}"
  local requested=""
  requested="$(normalize_merge_method "$requested_raw" 2>/dev/null || true)"
  if [[ -n "$requested_raw" && -z "$requested" && "$requested_raw" != "default" ]]; then
    die "Invalid OPENCODE_MERGE_METHOD: $requested_raw (use rebase|squash|merge|default)"
  fi

  local settings
  settings="$(repo_merge_settings)"
  if [[ -z "$settings" ]]; then
    if [[ -n "$requested" ]]; then
      echo "$requested"
      return 0
    fi
    echo "rebase"
    return 0
  fi

  local rebase_allowed squash_allowed merge_allowed viewer_default
  IFS=$'\t' read -r rebase_allowed squash_allowed merge_allowed viewer_default <<<"$settings"

  local default_norm=""
  case "${viewer_default:-}" in
    REBASE) default_norm="rebase" ;;
    SQUASH) default_norm="squash" ;;
    MERGE) default_norm="merge" ;;
    *) default_norm="" ;;
  esac

  method_allowed() {
    case "$1" in
      rebase) [[ "$rebase_allowed" == "true" ]] ;;
      squash) [[ "$squash_allowed" == "true" ]] ;;
      merge) [[ "$merge_allowed" == "true" ]] ;;
      *) return 1 ;;
    esac
  }

  if [[ -n "$requested" ]]; then
    method_allowed "$requested" || die "Merge method '$requested' is not allowed for this repo"
    echo "$requested"
    return 0
  fi

  if method_allowed "rebase"; then
    echo "rebase"
    return 0
  fi

  if [[ -n "$default_norm" ]] && method_allowed "$default_norm"; then
    echo "$default_norm"
    return 0
  fi

  if method_allowed "squash"; then
    echo "squash"
    return 0
  fi

  if method_allowed "merge"; then
    echo "merge"
    return 0
  fi

  die "No GitHub merge methods are allowed for this repo"
}

pr_number="$(gh_in_repo pr view --json number --jq '.number' 2>/dev/null || true)"
if [[ -z "$pr_number" ]]; then
  pr_number="$(gh_in_repo pr list --head "$current_branch" --state open --json number --jq '.[0].number' 2>/dev/null || true)"
fi

if [[ -z "$pr_number" ]]; then
  title="$(preferred_pr_title "$repo_root")"

  body_commits="$(git -C "$repo_root" log --format='- %s' "${remote}/${base_branch}..HEAD" 2>/dev/null || git -C "$repo_root" log -1 --format='- %s')"
  body="$(cat <<EOF
## Summary
$body_commits
EOF
)"

  ok "Creating PR: $title"
  gh_in_repo pr create --title "$title" --body "$body" --base "$base_branch" --head "$current_branch" >/dev/null
  pr_number="$(gh_in_repo pr view --json number --jq '.number' 2>/dev/null || true)"
fi

[[ -n "$pr_number" ]] || die "Failed to determine PR number"
pr_url="$(gh_in_repo pr view "$pr_number" --json url --jq '.url' 2>/dev/null || true)"
ok "PR: #$pr_number ${pr_url:-}"

merge_method="$(select_merge_method "$merge_method_preference")"
ok "Merge method: $merge_method"

merge_args=(--auto)
case "$merge_method" in
  rebase) merge_args+=(--rebase) ;;
  squash) merge_args+=(--squash) ;;
  merge) merge_args+=(--merge) ;;
esac

merge_output=""
merge_exit="0"
if ! merge_output="$(gh_in_repo pr merge "$pr_number" "${merge_args[@]}" 2>&1)"; then
  merge_exit="$?"
fi

if [[ -n "$merge_output" ]]; then
  echo "$merge_output"
fi

if [[ "$merge_exit" != "0" ]]; then
  warn "gh pr merge returned exit $merge_exit; continuing to verify via PR status"
fi

wait_for_pr_merge "$pr_number"

head_ref="$(gh_in_repo pr view "$pr_number" --json headRefName --jq '.headRefName' 2>/dev/null || true)"
[[ -n "$head_ref" ]] || head_ref="$current_branch"

if git -C "$repo_root" remote get-url "$remote" >/dev/null 2>&1; then
  ok "Deleting remote branch: $head_ref"
  git -C "$repo_root" push "$remote" --delete "$head_ref" >/dev/null 2>&1 || warn "Remote branch already deleted (or no permission)"
fi

if [[ "$repo_root" == *"/.opencode/worktrees/"* ]]; then
  cleanup_opencode_worktree "$repo_root" "$remote" "$base_branch" "$head_ref"
fi

drop_salvage_stash

ok "COMPLETION WORKFLOW FINISHED"
