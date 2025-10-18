# External tool integrations

# Starship prompt
# Select Starship config based on terminal capabilities. Put this in an
# interactive startup file (zshrc) rather than ~/.zshenv so non-interactive
# shells and scripts won't inherit interactive-only environment variables.
if [[ -n "$TERM_PROGRAM" && "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    export STARSHIP_CONFIG="$HOME/.config/starship/starship-terminal.toml"
else
    export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
fi

eval "$(starship init zsh)"

# Completions
source <(kubectl completion zsh) 2>/dev/null
complete -C '/usr/local/bin/aws_completer' aws 2>/dev/null

# Auto-suggestions (if available)
if [[ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    bindkey '^w' autosuggest-execute
    bindkey '^e' autosuggest-accept
    bindkey '^u' autosuggest-toggle
fi

# Key bindings
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey jj vi-cmd-mode

# FZF integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Directory-based environment loading (replaces oh-my-zsh autoenv)
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# Modern navigation tools
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi