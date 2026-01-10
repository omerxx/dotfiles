#!/usr/bin/env bash

set -e

fail() {
  echo "opencode worktree-session: $1" >&2
  exit 1
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
  if ! git_output="$(git -C "$repo_root" worktree add -b "$branch" "$worktree_path" HEAD 2>&1)"; then
    fail "$git_output"
  fi
fi

target_dir="$worktree_path"
if [ -n "$prefix" ] && [ -d "$worktree_path/$prefix" ]; then
  target_dir="$worktree_path/$prefix"
fi

printf '%s\t%s\n' "$target_dir" "$branch"
