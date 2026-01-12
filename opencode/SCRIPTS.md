# OpenCode shell scripts

This directory (`opencode/`) is stowed to `~/.config/opencode/`. The `.sh` scripts here power the OpenCode
worktree workflow and the “commit → PR → auto-merge” automation used by the `o` shell wrapper (zsh + Nushell).

## Index

| Script | Purpose |
|--------|---------|
| `worktree-session.sh` | Create/reuse a branch worktree under `.opencode/worktrees/` and print the directory to run in |
| `completion-workflow-start.sh` | Launch `completion-workflow.sh` in the background and write a log file |
| `completion-workflow.sh` | Stage/commit → rebase → push → PR → merge/auto-merge → cleanup |

---

## `worktree-session.sh`

### Purpose

Creates (or reuses) a git worktree for a branch and prints a tab-separated `<target_dir>\t<branch_used>` line.
This is consumed by shell wrappers to `cd` into the correct worktree before launching OpenCode.

### Usage

```bash
bash worktree-session.sh [base_dir] [branch]
```

- `base_dir` (optional): directory inside a git repository (defaults to `pwd`)
- `branch` (optional): branch name to use (defaults to an auto-generated `oc/<timestamp>-<rand>` name)

### Output

One line:

```
<target_dir>\t<branch_used>
```

If `base_dir` is not inside a git repository, it prints `<base_dir>\t` and exits successfully.

### Environment

- `OPENCODE_WORKTREE_REMOTE` (default: `origin`): remote used to determine/fetch the default base branch

### What it does

- Resolves `repo_root` and the subdirectory `prefix` (relative path from repo root to `base_dir`).
- Validates the branch name (no leading `-`, no whitespace).
- Determines a base branch from `<remote>/HEAD` (fallback: `main`/`master`) and attempts a `git fetch`.
- Chooses an `anchor_root` worktree (prefers a non-`.opencode/worktrees` worktree on the base branch).
- Ensures `.opencode/worktrees/` is excluded via `.git/info/exclude` in the common git dir.
- Runs `git worktree add`:
  - existing branch → `git worktree add <path> <branch>`
  - new branch → `git worktree add -b <branch> <path> <start_point>`
- If `base_dir` was inside a subdirectory, it returns `<worktree_path>/<prefix>` when that path exists.

---

## `completion-workflow-start.sh`

### Purpose

Starts `completion-workflow.sh` detached (via `nohup`), writes output to a log file, and prints the log path.
This lets the shell wrapper return immediately while the “PR → merge → cleanup” workflow continues.

### Usage

```bash
bash completion-workflow-start.sh --repo <path> [--remote origin] [--base <branch>]
```

### Environment

- `OPENCODE_WORKFLOW_LOG_DIR`: override log directory (default: `~/.cache/opencode/workflows`)
- `OPENCODE_WORKFLOW_LOG_FILE`: override full log file path

### What it does

- Verifies `bash`, `git`, and `nohup` are available.
- Refuses to run on a detached HEAD.
- Chooses a log file name based on repo + current branch + timestamp.
- Writes a pointer file `last.logpath` next to the log (used by `t` helpers to tail the latest run).
- Runs the workflow in the background:
  - sets `OPENCODE_WORKFLOW_LOG=0` (the workflow itself won’t also write a separate log)
  - redirects stdout/stderr to the chosen log file
  - writes a `*.pid` file next to the log

---

## `completion-workflow.sh`

### Purpose

Runs a worktree-safe “finish the branch” workflow:

`stage → commit → fetch/rebase → push → PR → merge/auto-merge → wait → delete remote branch → cleanup`.

### Usage

```bash
bash completion-workflow.sh --repo <path> [--remote origin] [--base <branch>]
```

### Dependencies

- `git`
- `gh` (GitHub CLI) for PR create/merge/status polling
- `python3` (optional): reads OpenCode session metadata for a better PR title

### Environment

- `OPENCODE_PR_TITLE`: explicit PR title override
- `OPENCODE_SESSION_TITLE`: optional title hint (used when not the default “New session - …”)
- `OPENCODE_WORKFLOW_LOG`: enable internal log file output (`1` default; usually `0` when run via `completion-workflow-start.sh`)
- `OPENCODE_WORKFLOW_LOG_DIR`: internal log dir override (default: `~/.cache/opencode/workflows`)
- `OPENCODE_WORKFLOW_LOG_FILE`: internal log file path override
- `OPENCODE_MERGE_METHOD`: `rebase|squash|merge|default` (default selects the best allowed for the repo)
- `OPENCODE_MERGE_WAIT_TIMEOUT`: seconds to wait for merge (default: `7200`; `0` disables timeout)
- `OPENCODE_MERGE_POLL_INTERVAL`: seconds between PR status polls (default: `10`)
- `OPENCODE_MERGE_HEARTBEAT_INTERVAL`: seconds between “still waiting” messages (default: `60`)

### PR title selection

The PR title is chosen in this order:

1. `OPENCODE_PR_TITLE` (if set)
2. `OPENCODE_SESSION_TITLE` (if set and not a default placeholder)
3. Latest matching session title from `~/.local/share/opencode/storage/session/**` (requires `python3`)
4. Last git commit subject

### Worktree cleanup

If the repo path matches `*/.opencode/worktrees/*`, the workflow will:

- remove the worktree from a main worktree (`git worktree remove --force`)
- delete the local branch in the main worktree
- attempt a fast-forward update of the main worktree’s base branch (only if clean)

