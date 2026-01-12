# Takopi (Telegram agent bridge)

Takopi lets you run agent CLIs (Codex / Claude Code / OpenCode / Pi) from Telegram and stream progress back into chat.
It complements (does not replace) OpenPortal:

- **OpenPortal (`oo`)**: Tailscale + web UI for OpenCode sessions (ports, browser access).
- **Takopi (`takopi`)**: Telegram control plane for running/continuing agent work across repos/branches (no port 3000).

This repo also installs a custom Takopi command plugin:

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
- choose a default engine

Config is stored at `~/.takopi/takopi.toml` (not in this repo, because it contains secrets).

### 2) Register projects (so `/project` works)

For each repo you want to control from Telegram:

```bash
cd ~/dev/my-repo
takopi init my-repo
```

Recommended for compatibility with your existing `o`/worktree + cleanup automation:

- set `worktrees_dir = ".opencode/worktrees"` for that project in `~/.takopi/takopi.toml`

### 3) Run Takopi in the background (recommended)

This repo installs a LaunchAgent:

- `~/Library/LaunchAgents/com.klaudioz.takopi.plist`

It runs `~/dotfiles/takopi-launchd.sh` and logs to:

- `/tmp/com.klaudioz.takopi.out`
- `/tmp/com.klaudioz.takopi.err`

After `./setup.sh --update`, it should be loaded automatically (if `~/.takopi/takopi.toml` exists).

---

## Telegram usage

### Start a run

- Send a message to your bot:
  - `/my-repo do the thing`
  - `/my-repo @feat/branch do the thing in a worktree`
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

### Start a fresh thread

- Don’t reply (send a new message), or use topics + `/new` if you enabled them in Takopi.

---

## Local workflow integration

When you start an OpenCode session locally with `o`, the wrapper prints a hint like:

```
takopi: /repo-name @oc/20260112-...
```

That’s a ready-to-paste starting point for Telegram (after you’ve registered the project with `takopi init repo-name`).

