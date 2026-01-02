# Keep PATH consistent for *all* zsh invocations (including non-interactive `zsh -c`).
# Codex and git hooks rely on this to find Homebrew/Nix-installed tools.

if [[ -n "${ZPROF:-}" ]]; then
  zmodload zsh/zprof
fi

# Keep zsh fully user-configured and avoid slow/variable `/etc/*` startup files.
unsetopt GLOBAL_RCS

typeset -U path

path_additions=()

# Nix (nix-darwin)
[[ -d /run/current-system/sw/bin ]] && path_additions+=(/run/current-system/sw/bin)

# Homebrew (Apple Silicon)
[[ -d /opt/homebrew/bin ]] && path_additions+=(/opt/homebrew/bin)
[[ -d /opt/homebrew/sbin ]] && path_additions+=(/opt/homebrew/sbin)

# User-level tool bins (created by setup.sh and various tool installers)
[[ -d "$HOME/.local/bin" ]] && path_additions+=("$HOME/.local/bin")
[[ -d "$HOME/.opencode/bin" ]] && path_additions+=("$HOME/.opencode/bin")
[[ -d "$HOME/.npm-global/bin" ]] && path_additions+=("$HOME/.npm-global/bin")
[[ -d "$HOME/.bun/bin" ]] && path_additions+=("$HOME/.bun/bin")
[[ -d "$HOME/go/bin" ]] && path_additions+=("$HOME/go/bin")
[[ -d "$HOME/.cargo/bin" ]] && path_additions+=("$HOME/.cargo/bin")

# libpq (PostgreSQL)
[[ -d "/opt/homebrew/opt/libpq/bin" ]] && path_additions+=("/opt/homebrew/opt/libpq/bin")

# App bundle CLIs (optional, but convenient)
[[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]] && \
  path_additions+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")
[[ -d "/Applications/Cursor.app/Contents/Resources/app/bin" ]] && \
  path_additions+=("/Applications/Cursor.app/Contents/Resources/app/bin")
[[ -d "/Applications/Windsurf.app/Contents/Resources/app/bin" ]] && \
  path_additions+=("/Applications/Windsurf.app/Contents/Resources/app/bin")

path=($path_additions $path)
export PATH

unset path_additions
