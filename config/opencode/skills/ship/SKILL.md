---
name: ship
description: Use when the user wants to commit, push, and open a pull request for the current changes. Stages relevant files, writes a descriptive commit message, pushes the branch, opens a PR against main, and posts an /oc review comment so opencode automatically reviews and approves if ready.
---

# Ship

Commits staged changes, pushes the branch, opens a PR, and triggers an automated opencode review.

## When to Use This Skill

Invoke this skill when the user says things like:
- "ship it"
- "commit push pr"
- "ship this"
- "create a pr"
- "push and open a pr"
- "commit and ship"

## Workflow

Follow these steps **in order**, stopping and reporting any errors immediately.

### Step 1 — Sanity checks

Run these in parallel:
```bash
git status
git diff
git log --oneline -5
git remote -v
```

Use the output to understand: what branch we're on, what's changed, what the recent commit style looks like, and what the remote is.

### Step 2 — Fetch and rebase

```bash
git fetch origin
git rebase origin/main
```

If there are conflicts, resolve them (keeping both sides where appropriate), then continue the rebase. Do NOT skip this step.

### Step 3 — Stage files

Stage all changed/new files that are relevant to the work. Explicitly exclude:
- `.DS_Store`
- `*.db`, `*.db-shm`, `*.db-wal`
- Any file that looks like it contains secrets (`.env`, `credentials.*`, etc.)
- Prototype/demo directories unless they are part of the deliverable

```bash
git add <relevant files>
git status   # verify staging looks right
```

### Step 4 — Commit

Write a commit message that:
- Uses the imperative mood (`feat:`, `fix:`, `ci:`, `docs:`, `refactor:`)
- First line ≤ 72 characters summarising the **why**, not the what
- Body bullet points for non-obvious details (optional but preferred for large changes)
- Matches the style of recent commits in `git log`

```bash
git commit -m "<message>"
```

### Step 5 — Push

If the branch has no upstream yet:
```bash
git push -u origin <branch>
```

Otherwise:
```bash
git push
```

### Step 6 — Open PR

Use the `gh` CLI to create a PR targeting `main`:

```bash
gh pr create \
  --title "<concise title matching commit subject>" \
  --body "$(cat <<'EOF'
## Summary

<2-4 bullet points describing what changed and why>

## Notes

<any reviewer context, migration steps, known limitations — omit section if none>
EOF
)" \
  --base main
```

Capture the PR URL from the output.

### Step 7 — Trigger opencode review

Post the review comment on the PR so the opencode GitHub Action picks it up:

```bash
gh pr comment <PR number> --body "/oc please review this PR and approve if you find it ready to merge"
```

### Step 8 — Report back

Tell the user:
- The commit hash and message
- The PR URL
- That the opencode review has been triggered

## Rules

- **Never force-push** to `main` or `master`
- **Never commit** `.env`, secrets, or credential files — warn the user if they're staged
- **Always rebase** onto `origin/main` before pushing to minimise conflicts
- If `gh` is not authenticated, tell the user to run `gh auth login` first
- If the build/tests are known to exist (e.g. `go build ./...`, `npm test`), run them before committing and abort if they fail
