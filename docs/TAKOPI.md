# Takopi (Telegram agent bridge)

Takopi lets you run agent CLIs (Codex / Claude Code / OpenCode / Pi) from Telegram and stream progress back into chat.
It complements (does not replace) OpenPortal:

- **OpenPortal (`oo`)**: Tailscale + web UI for OpenCode sessions (ports, browser access).
- **Takopi (`takopi`)**: Telegram control plane for running/continuing agent work across repos/branches (no port 3000).

This repo also installs custom Takopi command plugins:

- **`/o`**: OpenCode-style worktree session (auto branch). Keeps the worktree so you can continue; reply with `/finish` when ready to PR/merge/cleanup.
- **`/finish`**: cancel the in-flight run (Ctrl‑C equivalent) and start the OpenCode completion workflow (PR → merge → cleanup).

---

## Setup (one-time)

### 1) Onboard Takopi (create bot + config)

Run on the machine that will execute the agents:

```bash
takopi --onboard
```

This will:

- ask you to create a bot token via `@BotFather`
- capture your `chat_id` (you send the bot a message once)
- choose a default engine (use OpenCode)

Config is stored at `~/.takopi/takopi.toml` (not in this repo, because it contains secrets).

### 2) Register projects (so `/project` works)

For each repo you want to control from Telegram:

```bash
cd ~/dev/my-repo
takopi init my-repo
```

Recommended for compatibility with your existing `o`/worktree + cleanup automation:

- set `worktrees_dir = ".opencode/worktrees"` for that project in `~/.takopi/takopi.toml`

Optional quality-of-life settings (for iPhone-first usage):

- set `default_project = "my-repo"` so you can omit `/my-repo` in messages
- set `[transports.telegram] session_mode = "chat"` so follow-ups can auto-resume without replying (reset with `/new`)

### 3) Run Takopi in the background (recommended)

This repo installs a LaunchAgent:

- `~/Library/LaunchAgents/com.klaudioz.takopi.plist`

It runs `~/dotfiles/takopi-launchd.sh` and logs to:

- `/tmp/com.klaudioz.takopi.out`
- `/tmp/com.klaudioz.takopi.err`

After `./setup.sh --update`, it should be loaded automatically (if `~/.takopi/takopi.toml` exists).
The LaunchAgent always starts `takopi opencode` and sources `~/.config/opencode/secrets.zsh` so OpenCode has the same env as your terminal.
`./setup.sh --update` also upgrades Takopi via `uv tool install -U takopi` so you stay current with upstream releases.

---

## Telegram usage

### Start a run

- Recommended (matches local `o`): use `/o` so every run gets its own worktree branch.
  - `/o do the thing` (uses `default_project`, otherwise falls back to `dot`)
  - `/o /my-repo do the thing`
  - `/o /my-repo @feat/branch do the thing in a named worktree branch`
- When you’re ready to land it, reply to the progress message with `/finish` to run PR automation (PR → merge → cleanup).
- If you run a project command directly (e.g. `/my-repo ...`) **without** `@branch`, Takopi runs in the main checkout (can lead to direct pushes to `master`/`main`).
- Reply to the bot’s messages to continue the same thread (Takopi preserves context via a `ctx:` footer).

### Cancel a run

- Reply to the *progress message* with:
  - `/cancel`

### Finish + auto-merge (Ctrl‑C equivalent)

- Reply to the *progress message* with:
  - `/finish`

This triggers the dotfiles Takopi plugin (`takopi-dotfiles`) which:

1. requests cancellation of the in-flight run (best-effort)
2. starts `~/.config/opencode/completion-workflow-start.sh --repo <worktree>`

It will reply with the log file path. If you enable Takopi file transfer, you can fetch it:

- `/file get <log-path>`

### Optional: auto-finish `/o`

If you want `/o` to automatically start the completion workflow when the run completes (one-shot mode), add this to `~/.takopi/takopi.toml`:

```toml
[plugins.o]
auto_finish = true
```

---

## Why did Telegram push to `master` instead of opening a PR?

That happens when the Takopi run context shows `ctx: dot` (no `@branch`):

- Takopi ran inside the **main checkout** on the base branch.
- The agent followed this repo’s “commit + push after changes” rule, so it pushed directly to the base branch.

Use `/o` (or `/my-repo @oc/...`) so the run happens in an isolated worktree branch; then the completion workflow can open a PR.

### Start a fresh thread

- Don’t reply (send a new message), or use topics + `/new` if you enabled them in Takopi.

---

## Local workflow integration

### Resume on Mac (from Telegram → `o`)

Takopi’s OpenCode runner prints a resume line like:

```
opencode --session ses_XXX
```

On your Mac, paste it as:

```bash
o --session ses_XXX
```

`o` will auto-cd into the session’s original repo/worktree before launching OpenCode.
If you run `opencode --session ...` directly from a random folder, OpenCode may show “Session not found” (it’s cwd-sensitive).

### Start on Mac (from `o` → Telegram)

When you start an OpenCode session locally with `o`, the wrapper prints a hint like:

```
takopi: /repo-name @oc/20260112-...
```

That’s a ready-to-paste starting point for Telegram (after you’ve registered the project with `takopi init repo-name`).
