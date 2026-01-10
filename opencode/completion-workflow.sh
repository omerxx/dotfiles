#!/usr/bin/env bash
set -e

# Colors (use these exact variables)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok() {
  echo -e "${GREEN}✓${NC} $1"
}

warn() {
  echo -e "${YELLOW}!${NC} $1"
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

commit_type_from_files() {
  local repo="$1"
  local files
  files="$(git -C "$repo" diff --cached --name-only | tr '\n' ' ')"
  [[ -n "$files" ]] || return 1

  if [[ "$files" == *".md "* || "$files" == *".md" || "$files" == *".txt "* || "$files" == *".txt" ]]; then
    if git -C "$repo" diff --cached --name-only | rg -qv '\.(md|txt)$'; then
      return 1
    fi
    echo "docs"
    return 0
  fi

  if git -C "$repo" diff --cached --name-only | rg -qi '(^|/)(__tests__|tests?|specs?)(/|$)|(\.spec\.|\.test\.)'; then
    echo "test"
    return 0
  fi

  return 1
}

commit_desc_from_branch() {
  local branch="$1"
  local type="$2"
  local desc="$branch"

  desc="${desc#${type}/}"
  desc="${desc#${type}-}"
  desc="${desc#${type}_}"

  if [[ "$branch" == oc/* || "$branch" == oc-* || "$branch" == oc_* ]]; then
    echo "opencode session"
    return 0
  fi

  desc="${desc//\// }"
  desc="${desc//-/ }"
  desc="${desc//_/ }"

  desc="$(echo "$desc" | tr -s ' ' | sed 's/^ *//; s/ *$//')"
  [[ -n "$desc" ]] || desc="opencode changes"
  echo "$desc"
}

ensure_rg() {
  if command -v rg >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

make_commit_message() {
  local repo="$1"
  local branch="$2"

  local type=""
  if ensure_rg; then
    type="$(commit_type_from_files "$repo" || true)"
  fi
  [[ -n "$type" ]] || type="$(commit_type_from_branch "$branch")"

  local desc
  desc="$(commit_desc_from_branch "$branch" "$type")"

  echo "${type}: ${desc}"
}

ok "Repo: $repo_root"
ok "Branch: $current_branch (base: $base_branch)"

merge_wait_timeout="${OPENCODE_MERGE_WAIT_TIMEOUT:-7200}"
merge_poll_interval="${OPENCODE_MERGE_POLL_INTERVAL:-10}"

wait_for_pr_merge() {
  local pr="$1"
  local start_ts
  start_ts="$(date +%s)"

  local last_status=""
  local status_line=""

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

    if [[ "$merge_wait_timeout" != "0" ]]; then
      local now_ts
      now_ts="$(date +%s)"
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
  local base="$2"
  local branch_to_delete="$3"

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
}

dirty="$(git -C "$repo_root" status --porcelain)"
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
  git -C "$repo_root" rebase "$remote/$base_branch"
else
  warn "Remote '$remote' not found; skipping fetch/rebase"
fi

ahead_count="0"
if git -C "$repo_root" show-ref --verify --quiet "refs/remotes/${remote}/${base_branch}" 2>/dev/null; then
  ahead_count="$(git -C "$repo_root" rev-list --count "${remote}/${base_branch}..HEAD" 2>/dev/null || echo "0")"
fi

if [[ "$ahead_count" == "0" && -z "$(git -C "$repo_root" status --porcelain)" ]]; then
  warn "No commits ahead of $remote/$base_branch; nothing to PR/merge"
  cleanup_opencode_worktree "$repo_root" "$base_branch" "$current_branch"
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

pr_number="$(gh_in_repo pr view --json number --jq '.number' 2>/dev/null || true)"
if [[ -z "$pr_number" ]]; then
  pr_number="$(gh_in_repo pr list --head "$current_branch" --state open --json number --jq '.[0].number' 2>/dev/null || true)"
fi

if [[ -z "$pr_number" ]]; then
  title="$(git -C "$repo_root" log -1 --pretty=%s)"

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
ok "PR: #$pr_number"

merge_output=""
merge_exit="0"
if ! merge_output="$(gh_in_repo pr merge "$pr_number" --squash --auto 2>&1)"; then
  merge_exit="$?"
fi

if [[ "$merge_exit" != "0" ]]; then
  warn "gh pr merge returned exit $merge_exit; continuing to verify via PR status"
  echo "$merge_output" >&2
fi

wait_for_pr_merge "$pr_number"

head_ref="$(gh_in_repo pr view "$pr_number" --json headRefName --jq '.headRefName' 2>/dev/null || true)"
[[ -n "$head_ref" ]] || head_ref="$current_branch"

if git -C "$repo_root" remote get-url "$remote" >/dev/null 2>&1; then
  ok "Deleting remote branch: $head_ref"
  git -C "$repo_root" push "$remote" --delete "$head_ref" >/dev/null 2>&1 || warn "Remote branch already deleted (or no permission)"
fi

if [[ "$repo_root" == *"/.opencode/worktrees/"* ]]; then
  cleanup_opencode_worktree "$repo_root" "$base_branch" "$head_ref"
fi

ok "Completion workflow finished"
