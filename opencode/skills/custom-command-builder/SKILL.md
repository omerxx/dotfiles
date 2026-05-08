---
name: custom-command-builder
description: Use when a user asks for an OpenCode custom /command (CLI/TUI/Web) to automate a repetitive prompt. Guides format choice (JSON vs .opencode/commands/*.md), frontmatter/template fields, arguments, shell/file injections, and validation steps per current docs.
---

# Custom Command Builder

Follow this playbook whenever a user wants a new OpenCode custom command.

## 1. Clarify Requirements
- Command purpose and success criteria (what should the prompt accomplish?).
- Scope: global (`~/.config/opencode/commands`) vs repo (`.opencode/commands`).
- Preferred format: Markdown file vs `opencode.jsonc` entry. Default to repo Markdown when unsure.
- Agent/model overrides? Subtask isolation needed?
- Does the command expect positional args (`$1`, `$2`) or raw `$ARGUMENTS`?
- Any shell output or file references required? Confirm commands are safe/idempotent.

## 2. Pick Storage Format
- **Markdown (recommended for repos):** Create `.opencode/commands/<name>.md`. File name becomes `/name`.
  ```markdown
  ---
  description: Brief summary
  agent: plan
  model: anthropic/claude-3-5-sonnet-20241022
  subtask: true
  ---
  Your template text here…
  ```
- **JSON config:** Add under `command` in `opencode.jsonc`.
  ```json
  {
    "$schema": "https://opencode.ai/config.json",
    "command": {
      "review": {
        "template": "Summarize recent commits…",
        "description": "Review recent work",
        "agent": "plan",
        "model": "anthropic/claude-3-5-sonnet-20241022",
        "subtask": true
      }
    }
  }
  ```
- Global commands live at `~/.config/opencode/commands/`. Repo commands live at `.opencode/commands/`. Clarify which location the user wants.

## 3. Build the Template Prompt
- Start with a direct imperative. Keep instructions concise and specific to the workflow.
- Use placeholders:
  - `$ARGUMENTS` for the entire argument string.
  - `$1`, `$2`, … for positional arguments when the order matters.
- Embed shell output with ``!`<command>` `` (runs at repo root) when real-time context is required (tests, git logs, etc.). Mention command runtime expectations.
- Reference files with `@path/to/file.ext` to inline their contents.
- Remind the future agent what to output (reports, patches, follow-ups).

## 4. Configure Frontmatter / Options
- `description`: One-line summary shown in TUI autocomplete; mention key inputs/outputs.
- `agent`: Set when a specialized agent (plan/review/build) fits better than default.
- `model`: Override only when a specific model tier is necessary.
- `subtask`: `true` to run as subagent (keeps main context clean) or `false` to force primary.
- Leaving fields blank inherits the user’s defaults.
- Warn if command name overrides a built-in (`/init`, `/share`, etc.). Rename or ensure override is intentional.

## 5. Validate & Handoff
- Ensure directories exist (`mkdir -p .opencode/commands`).
- Confirm YAML frontmatter is on one block with no blank line between `---` markers and fields.
- Double-check placeholders resolve (no `$` typo) and referenced files/commands exist.
- If editing JSON, maintain trailing commas per file style and validate with `node -e "JSON.parse(fs.readFileSync('opencode.jsonc'))"` when feasible.
- Provide the final command path and usage example (`/command ARG1 ARG2`).

## 6. Troubleshooting Patterns
- **Arguments missing:** remind users to pass values after the slash command; include fallback logic in instructions if arguments are optional.
- **Shell output too long:** pipe through short commands (e.g., `git log -5 --oneline`).
- **Need multiple resources:** split instructions into numbered steps so future agent responds predictably.

Keep responses short, cite the doc URL if further reading is useful: https://opencode.ai/docs/commands/
