# Core zsh configuration
setopt prompt_subst
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# XDG Base Directory specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Completion system
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit

