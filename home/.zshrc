export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.luaver/luarocks/5.1/bin:$HOME/.luaver/lua/5.1/bin:$PATH"
if [[ -d "/opt/nvim-linux-x86_64/bin" ]]; then
  export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
fi

# Add Poetry to PATH
export PATH="$HOME/.poetry/bin:$PATH"

# Aliases for eza
alias ls='eza --icons=always'
alias ll='eza -lh --icons=always'
alias la='eza -lha --icons=always'
alias lt='eza --tree --icons=always'

# ---- Zoxide (better cd)
eval "$(zoxide init zsh)"

# Aliases for Zoxide
alias cd="z"
alias zi="zoxide add"         # Add a directory to zoxide
alias zq="zoxide query"       # Query zoxide's database
alias zr="zoxide remove"      # Remove a directory from zoxide

# Aliases for worktrunk
alias wtl='wt list'                          # List all worktrees
alias wtlf='wt list --full'                  # List with CI status + LLM summaries
alias wts='wt switch'                        # Switch worktrees (opens interactive picker if no arg)
alias wtc='wt switch --create'               # Create new branch+worktree from main
alias wtr='wt remove'                        # Remove current worktree+branch
alias wtm='wt merge'                         # Local merge back to main + cleanup
alias wtd='wt step diff'                     # Show all changes since branching
alias wtcom='wt step commit'                 # Stage + LLM commit message
alias wtpush='wt step push'                  # Fast-forward push
alias wtco='wt switch --create -x opencode'  # Create worktree + launch opencode

export GPG_TTY=$(tty)

alias wez="code ~/.wezterm.lua"
alias zshrc="code ~/.zshrc"
alias pip=pip3
alias grep="rg"
if [[ -x "/mnt/c/Users/pdlou/AppData/Local/Programs/Zed/zed.exe" ]]; then
  alias zed='/mnt/c/Users/pdlou/AppData/Local/Programs/Zed/zed.exe'
elif command -v zed.exe >/dev/null 2>&1; then
  alias zed='zed.exe'
fi

if [[ -f "$HOME/.luaver" ]]; then
  source "$HOME/.luaver"
fi

PATH=~/.console-ninja/.bin:$PATH

# Volta Configuration
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# opencode
export PATH=/Users/L.Fitzpatrick/.opencode/bin:$PATH

# Prefer Homebrew bin first (added by Agent Mode)
export PATH="/opt/homebrew/bin:$PATH"

export PATH="$HOME/bin:$PATH"

# --- Custom test helpers ---
function test:central() {
  if [ $# -lt 1 ]; then
    echo "Usage: test:central <path-to-test-or-dir> [additional vitest args]" >&2
    return 1
  fi
  TZ='America/Chicago' npm exec vitest -- --reporter=verbose "$@"
}

# Google Cloud SDK
if [[ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ]]; then
  source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
fi
if [[ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
fi

# bun completions
[ -s "/Users/L.Fitzpatrick/.bun/_bun" ] && source "/Users/L.Fitzpatrick/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# you-should-use (direct install, no oh-my-zsh wrapper)
if [[ -f "$HOME/.zsh/zsh-you-should-use/you-should-use.plugin.zsh" ]]; then
  source "$HOME/.zsh/zsh-you-should-use/you-should-use.plugin.zsh"
fi

# bat-based man/help highlighting
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -plman"
  alias bathelp='bat --plain --language=help'
  help() {
    "$@" --help 2>&1 | bathelp
  }
fi

export EDITOR='zed --wait'
export VISUAL='zed --wait'

# Terminal-specific configuration
if [[ "$TERM_PROGRAM" == "WarpTerminal" ]]; then
  if [[ -f "$HOME/.zshrc_warp" ]]; then
    source "$HOME/.zshrc_warp"
  fi
else
  if [[ -f "$HOME/.zshrc_ide" ]]; then
    source "$HOME/.zshrc_ide"
  fi
fi
