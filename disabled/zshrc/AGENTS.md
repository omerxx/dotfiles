# zshrc Agent Guide

This directory owns the user's Zsh startup configuration. The files here are expected to be symlinked into the home directory of whatever machine is being configured:

- `.zshrc` -> `~/.zshrc`
- `.zshrc_ide` -> `~/.zshrc_ide`
- `.zshrc_warp` -> `~/.zshrc_warp`

Treat these files as cross-platform dotfiles. They should work on macOS, Linux, and WSL on Windows. Do not add macOS-only, Linux-only, or user-specific absolute paths without guards and a fallback strategy.

## File Roles

### `.zshrc`

This is the main shell entrypoint. It sets baseline PATH entries, aliases, tool initialization, editor defaults, and terminal-specific branching.

At the bottom of the file, it checks `TERM_PROGRAM`. If the shell is running in Warp, it sources `~/.zshrc_warp`; otherwise it sources `~/.zshrc_ide`.

The intended policy is:

- Warp gets a lighter config because Warp already provides many interactive shell features.
- IDE terminals such as Zed, PyCharm, VS Code, and similar embedded terminals get additional shell features because they do not provide the same terminal-layer experience as Warp.

Keep this split intact unless the user explicitly asks to redesign terminal detection.

### `.zshrc_warp`

This file is intentionally small. It avoids Oh My Zsh and keeps only high-use explicit aliases, currently focused on common git commands.

Do not add heavyweight prompt frameworks, autosuggestion plugins, completion frameworks, or Oh My Zsh setup here unless the user explicitly asks. Warp should stay fast and uncluttered.

### `.zshrc_ide`

This file configures richer shell ergonomics for non-Warp terminals. It currently handles:

- OpenSpec completions
- Explicit high-use git aliases
- Starship prompt initialization
- zsh-autosuggestions

This file may assume interactive terminal use, but it still needs guards around optional dependencies so a missing package does not break shell startup.

## Compatibility Expectations

Future edits should preserve macOS, Linux, and WSL compatibility. Current files contain some macOS-specific paths, including `/opt/homebrew` and `/Users/L.Fitzpatrick`. Those are existing implementation details, not the desired long-term pattern.

When touching these areas:

- Prefer `$HOME` over hardcoded `/Users/...` paths.
- Guard optional sources with `[[ -f ... ]]` or `command -v ...`.
- Guard optional PATH additions with `[[ -d ... ]]`.
- Detect Homebrew paths rather than assuming `/opt/homebrew`.
- Consider common Linux locations such as `/home/linuxbrew/.linuxbrew` when relevant.
- Keep WSL in mind; it may have Linux paths while still needing access to Windows-oriented workflows.

Do not let a missing optional tool make every new shell print errors or fail to initialize.

## Tool Assumptions

"Core assumptions" means tools this config expects to exist for the user's normal workflow, where removing or radically changing them would alter daily shell behavior. Optional tools can be enabled when present, but shell startup should survive without them.

Current normal-workflow tools include:

- `eza` for `ls`, `ll`, `la`, and `lt`
- `zoxide` for directory jumping, including aliasing `cd` to `z`
- `wt` / worktrunk for git worktree workflows
- `pyenv` for Python version management
- Volta for Node tooling
- Bun
- Google Cloud SDK
- `luaver`
- `zed` as `EDITOR` and `VISUAL`
- `bat` for highlighted `man` and help output
- OpenSpec completions
- Starship and zsh-autosuggestions in IDE terminals
- Vite+ environment setup

These tools should be treated as important to preserve, but not all of them should be unconditional requirements. Prefer graceful degradation: if a tool is missing, skip its integration rather than breaking the shell.

## Aliases And Command Overrides

Some aliases intentionally replace standard command names:

- `cd` -> `z`
- `ls` -> `eza --icons=always`
- `grep` -> `rg`
- `pip` -> `pip3`

"Avoid changing these" means future agents should not remove, rename, or substantially alter these overrides as incidental cleanup. They are part of the user's muscle memory. Only change them when the task specifically concerns that alias, when it is broken on a target platform, or when the user asks for a broader shell behavior change.

If improving portability, prefer guarded aliases. For example, only alias `ls` to `eza` when `eza` exists, and only alias `cd` to `z` when `zoxide` initialized successfully.

## Known Cleanup

The `test:central` function is no longer required and may be removed. It currently forces `TZ='America/Chicago'` and runs `npm exec vitest -- --reporter=verbose`.

Do not preserve this helper unless the user reverses that decision.

## Editing Guidelines

- Keep startup fast. Avoid expensive commands during shell initialization.
- Keep terminal-specific behavior in the terminal-specific files where possible.
- Use comments to explain non-obvious compatibility checks, not every PATH addition.
- Do not assume Oh My Zsh is available in active shell startup files.
- Do not add tool initialization that requires interactive prompts during startup.
- Preserve `GPG_TTY=$(tty)` unless there is a concrete reason to change it.
- Prefer idempotent PATH handling when adding new directories, especially if a shell may source files more than once.
- When adding completions, make sure they do not conflict with existing `compinit` handling.

## Bootstrap Notes

On a new machine, the intended setup is to symlink the three files from this directory into the user's home directory. Example:

```zsh
ln -sf /path/to/dotfiles/zshrc/.zshrc ~/.zshrc
ln -sf /path/to/dotfiles/zshrc/.zshrc_ide ~/.zshrc_ide
ln -sf /path/to/dotfiles/zshrc/.zshrc_warp ~/.zshrc_warp
```

After symlinking, open a new shell. If startup prints missing-file errors, fix the relevant source/PATH line with a guard instead of installing the missing tool blindly. These dotfiles should be able to run on a partially provisioned system.

Suggested package families for a fully featured setup:

- Zsh
- Homebrew or the platform's package manager
- `eza`
- `zoxide`
- `ripgrep`
- `bat`
- `pyenv`
- Volta
- Bun
- Google Cloud SDK
- Starship
- zsh-autosuggestions

Keep exact install commands out of this file unless the repo gains a platform-aware bootstrap script.
