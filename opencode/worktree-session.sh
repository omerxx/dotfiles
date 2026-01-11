#!/usr/bin/env bash

set -e

fail() {
  echo "opencode worktree-session: $1" >&2
  exit 1
}

warn() {
  echo "opencode worktree-session: $1" >&2
}

find_base_worktree() {
  local repo_root="$1"
  local base_branch="$2"

  local wt_path=""
  local wt_branch=""
  local fallback=""

  while IFS= read -r line; do
    case "$line" in
      worktree\ *)
        wt_path="${line#worktree }"
        wt_branch=""
        if [ -z "$fallback" ] && [ -n "$wt_path" ]; then
          case "$wt_path" in
            *"/.opencode/worktrees/"*) ;;
            *) fallback="$wt_path" ;;
          esac
        fi
        ;;
      branch\ refs/heads/*)
        wt_branch="${line#branch refs/heads/}"
        if [ "$wt_branch" = "$base_branch" ] && [ -n "$wt_path" ]; then
          case "$wt_path" in
            *"/.opencode/worktrees/"*) ;;
            *)
              echo "$wt_path"
              return 0
              ;;
          esac
        fi
        ;;
    esac
  done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null || true)

  if [ -n "$fallback" ]; then
    echo "$fallback"
    return 0
  fi

  return 1
}

update_base_worktree() {
  local repo_root="$1"
  local remote="$2"
  local base_branch="$3"

  local base_worktree=""
  base_worktree="$(find_base_worktree "$repo_root" "$base_branch" 2>/dev/null || true)"
  [ -n "${base_worktree:-}" ] || return 0

  local current_branch=""
  current_branch="$(git -C "$base_worktree" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  [ "$current_branch" = "$base_branch" ] || return 0

  if [ -n "$(git -C "$base_worktree" status --porcelain 2>/dev/null)" ]; then
    return 0
  fi

  if ! git -C "$base_worktree" remote get-url "$remote" >/dev/null 2>&1; then
    return 0
  fi

  if ! git -C "$base_worktree" show-ref --verify --quiet "refs/remotes/${remote}/${base_branch}" 2>/dev/null; then
    return 0
  fi

  local local_head=""
  local remote_head=""
  local_head="$(git -C "$base_worktree" rev-parse "$base_branch" 2>/dev/null || true)"
  remote_head="$(git -C "$base_worktree" rev-parse "${remote}/${base_branch}" 2>/dev/null || true)"

  if [ -z "${local_head:-}" ] || [ -z "${remote_head:-}" ]; then
    return 0
  fi

  if [ "$local_head" = "$remote_head" ]; then
    return 0
  fi

  if ! git -C "$base_worktree" merge --ff-only "${remote}/${base_branch}" >/dev/null 2>&1; then
    warn "warning: unable to fast-forward update $base_branch to $remote/$base_branch in $base_worktree"
  fi
}

base_dir="${1:-}"
branch="${2:-}"

if [ -z "$base_dir" ]; then
  base_dir="$(pwd)"
fi

if ! repo_root="$(git -C "$base_dir" rev-parse --show-toplevel 2>/dev/null)"; then
  printf '%s\t%s\n' "$base_dir" ""
  exit 0
fi

prefix="$(git -C "$base_dir" rev-parse --show-prefix 2>/dev/null || true)"
prefix="${prefix%/}"

if [ -z "$branch" ]; then
  ts="$(date +%Y%m%d-%H%M%S)"
  rand="$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 6 || true)"
  [ -n "$rand" ] || rand="000000"
  branch="oc/${ts}-${rand}"
fi

case "$branch" in
  -*)
    fail "branch cannot start with '-'"
    ;;
  *[[:space:]]*)
    fail "branch cannot contain whitespace"
    ;;
esac

worktree_path="${repo_root}/.opencode/worktrees/${branch}"
mkdir -p "$(dirname "$worktree_path")"

# Always fetch the latest remote default branch so new worktrees start from up-to-date code.
remote="${OPENCODE_WORKTREE_REMOTE:-origin}"
start_point="HEAD"
if git -C "$repo_root" remote get-url "$remote" >/dev/null 2>&1; then
  remote_head_ref="$(git -C "$repo_root" symbolic-ref --quiet "refs/remotes/${remote}/HEAD" 2>/dev/null || true)"
  base_branch="${remote_head_ref##*/}"

  if [ -z "${base_branch:-}" ]; then
    base_branch="$(git -C "$repo_root" remote show -n "$remote" 2>/dev/null | sed -n 's/^[[:space:]]*HEAD branch: //p' | head -n 1 || true)"
    base_branch="${base_branch//[[:space:]]/}"
  fi

  if [ -z "${base_branch:-}" ]; then
    if git -C "$repo_root" show-ref --verify --quiet "refs/remotes/${remote}/main" 2>/dev/null; then
      base_branch="main"
    elif git -C "$repo_root" show-ref --verify --quiet "refs/remotes/${remote}/master" 2>/dev/null; then
      base_branch="master"
    else
      base_branch="main"
    fi
  fi

  if git -C "$repo_root" fetch "$remote" "$base_branch" --prune --quiet 2>/dev/null; then
    if git -C "$repo_root" show-ref --verify --quiet "refs/remotes/${remote}/${base_branch}" 2>/dev/null; then
      start_point="${remote}/${base_branch}"
    fi
  else
    warn "warning: failed to fetch $remote/$base_branch; worktree may be based on stale code"
  fi
fi

if [ -n "${base_branch:-}" ]; then
  update_base_worktree "$repo_root" "$remote" "$base_branch" || true
fi

# Hide worktrees from `git status` without touching tracked files.
git_common_dir="$(git -C "$repo_root" rev-parse --git-common-dir 2>/dev/null || true)"
if [ -n "$git_common_dir" ]; then
  if [ "${git_common_dir#/}" != "$git_common_dir" ]; then
    exclude_file="${git_common_dir}/info/exclude"
  else
    exclude_file="${repo_root}/${git_common_dir}/info/exclude"
  fi

  mkdir -p "$(dirname "$exclude_file")"
  touch "$exclude_file"
  if ! grep -Fqx ".opencode/worktrees/" "$exclude_file"; then
    printf '\n%s\n' ".opencode/worktrees/" >>"$exclude_file"
  fi
fi

if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
  if ! git_output="$(git -C "$repo_root" worktree add "$worktree_path" "$branch" 2>&1)"; then
    fail "$git_output"
  fi
else
  if ! git_output="$(git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "$start_point" 2>&1)"; then
    fail "$git_output"
  fi
fi

target_dir="$worktree_path"
if [ -n "$prefix" ] && [ -d "$worktree_path/$prefix" ]; then
  target_dir="$worktree_path/$prefix"
fi

printf '%s\t%s\n' "$target_dir" "$branch"
