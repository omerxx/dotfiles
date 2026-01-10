# OpenCode Completion Workflow

This document explains how `opencode/completion-workflow.sh` works and how it’s used by the `o` launcher to make OpenCode worktree sessions fully disposable.

## What It Does

`opencode/completion-workflow.sh` automates:

1. Stage all changes (`git add -A`)
2. Commit with an auto-generated Conventional Commit message
3. Rebase onto the base branch (`origin/<base>`)
4. Push the branch
5. Create (or reuse) a GitHub PR
6. Merge the PR (enables auto-merge if checks/merge queue are required)
7. Wait until the PR is actually merged
8. Delete the remote branch
9. If this is an OpenCode worktree, remove the worktree and delete the local branch

## How It’s Invoked (Normal Usage)

You normally don’t run `completion-workflow.sh` directly.

- `o` creates or reuses a git worktree via `opencode/worktree-session.sh`.
- When you exit OpenCode (including Ctrl+C), `o` starts the completion workflow **in the background** via `opencode/completion-workflow-start.sh`.
- The background launcher writes a log file and returns control to your shell immediately.

Relevant entrypoints:
- Zsh: `zsh/.zshenv` function `o()`
- Nushell: `nushell/config.nu` function `o`
- Background launcher: `opencode/completion-workflow-start.sh`

## Script Inputs

`opencode/completion-workflow.sh` supports:

- `--repo <path>`: Any path inside the target repo/worktree (defaults to `pwd`)
- `--remote <name>`: Git remote name (default `origin`)
- `--base <branch>`: Base branch name (default: remote HEAD branch; falls back to `main`)

## Early Exit Rules

The workflow intentionally does nothing when it can’t safely proceed:

- Not in a git repo → prints a warning and exits `0`
- Detached HEAD → hard-fails (can’t create a PR safely)
- Current branch equals base branch → prints a warning and exits `0`

## Commit Message Generation

When the repo has uncommitted changes, the script stages everything (`git add -A`) and commits with a best-effort Conventional Commit message:

### Type detection

1. If *all* staged files are `*.md`/`*.txt` → `docs`
2. If any staged file looks like a test (`*/tests/*`, `*.test.*`, etc.) → `test`
3. If this is an OpenCode session branch (`oc/*`):
   - If it includes “code-like” files (`*.ts`, `*.py`, `Dockerfile`, etc.) → `feat`
   - Otherwise → `chore`
4. Otherwise, infer from branch prefix (`feat/`, `fix/`, `refactor/`, etc.), defaulting to `chore`

### Description generation

- For OpenCode session branches (`oc/*`), the description is derived from the staged diff:
  - Single file change → `add|remove|update <file>`
  - Multiple files → `add|remove|update <primary dir>` (computed from `git diff --dirstat` / biggest file by `--numstat`)
- For non-OpenCode branches, the description is derived from the branch name.

The final subject is trimmed and capped at 72 chars.

## Rebase + Push

If the configured remote exists:

- `git fetch <remote> <base>`
- `git rebase <remote>/<base>`
- `git push -u <remote> HEAD` (retrying with `--force-with-lease` if needed)

If the remote is missing, it skips fetch/rebase/push.

If the rebase fails (typically due to conflicts), the workflow:

- Aborts the rebase (`git rebase --abort`) so the worktree isn’t left in a broken rebase state
- Continues without rebasing (it will still push the branch and open a PR)

## PR Creation

Requires GitHub CLI: `gh`.

The script:

1. Reuses an existing PR for the current branch if present.
2. Otherwise creates a PR:
   - Title = last commit subject
   - Body = bullet list of commit subjects between `<remote>/<base>..HEAD`

It prints (and logs) the PR number and URL.

## Merge Behavior (Worktree-Safe)

The script intentionally avoids `gh pr merge --delete-branch` because `gh` often tries to switch branches locally, which fails in worktrees with:

`fatal: 'main' is already used by worktree at ...`

Instead it:

1. Calls `gh pr merge <PR> --auto` with a selected merge strategy.
2. Always verifies merge success by polling PR state until it’s actually merged.
3. Deletes the remote branch via `git push <remote> --delete <branch>`.

### Merge strategy selection

Default preference is **rebase**.

You can override with:

`OPENCODE_MERGE_METHOD=rebase|squash|merge|default`

If the requested method isn’t allowed by repo settings, the script fails. If no override is set, it picks the best allowed method in this order:

1. `rebase` (preferred)
2. Viewer default (if allowed)
3. `squash`
4. `merge`

## Waiting Until It’s Merged

To support required checks and merge queues, the script polls `gh pr view` until:

- `state=MERGED` and `mergedAt` is set

Failure conditions:

- PR is a draft → fail
- PR has merge conflicts (`mergeStateStatus=DIRTY`) → fail fast (automation can’t resolve conflicts)
- PR closes without merge → fail
- Timeout exceeded → fail

Controls:

- `OPENCODE_MERGE_WAIT_TIMEOUT` (seconds, default `7200`, `0` = no timeout)
- `OPENCODE_MERGE_POLL_INTERVAL` (seconds, default `10`)
- `OPENCODE_MERGE_HEARTBEAT_INTERVAL` (seconds, default `60`)

## Worktree Cleanup

If the repo path contains `/.opencode/worktrees/`, the script assumes it’s an OpenCode-generated worktree and performs local cleanup after merge:

- Finds a “main” worktree (prefers the base branch worktree, otherwise any non-`.opencode/worktrees/` worktree)
- Removes the OpenCode worktree (`git worktree remove --force`)
- Deletes the local branch (`git branch -D <branch>`)

## Logs + Debugging

### Background mode (recommended)

`opencode/completion-workflow-start.sh` runs the workflow with `nohup` and writes a log:

- Default log dir: `~/.cache/opencode/workflows/`
- It also writes `<log>.pid`

To watch progress:

`tail -f ~/.cache/opencode/workflows/<latest>.log`

### Direct mode (manual)

If you run `completion-workflow.sh` directly, it can also write its own timestamped log entries:

- Enable/disable: `OPENCODE_WORKFLOW_LOG` (default `1`)
- Log directory: `OPENCODE_WORKFLOW_LOG_DIR`
- Log file override: `OPENCODE_WORKFLOW_LOG_FILE`

## Preconditions

- `git` must be available
- `gh` must be installed and authenticated for PR/merge
- Your git remote must be writable (push + delete branch)

If credentials are missing in background mode, the log will show the failure (the launcher sets `GIT_TERMINAL_PROMPT=0` so it won’t hang waiting for input).
