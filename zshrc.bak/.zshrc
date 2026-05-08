# Path to your oh-my-zsh installation.
# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit
if (( $+commands[kubectl] )); then
  source <(kubectl completion zsh)
fi
if [ -x /usr/local/bin/aws_completer ]; then
  complete -C '/usr/local/bin/aws_completer' aws
fi

typeset -g _zsh_autosuggestions_script=""
if (( $+commands[brew] )); then
  _zsh_autosuggestions_script="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [ -z "$_zsh_autosuggestions_script" ] || [ ! -f "$_zsh_autosuggestions_script" ]; then
  _zsh_autosuggestions_script="$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [ -f "$_zsh_autosuggestions_script" ]; then
  source "$_zsh_autosuggestions_script"
  bindkey '^w' autosuggest-execute
  bindkey '^e' autosuggest-accept
  bindkey '^u' autosuggest-toggle
fi
unset _zsh_autosuggestions_script
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# You may need to manually set your language environment
export LANG=en_US.UTF-8

if [ -x "$HOME/.nix-profile/bin/nvim" ]; then
  export EDITOR="$HOME/.nix-profile/bin/nvim"
elif [ -x /opt/homebrew/bin/nvim ]; then
  export EDITOR=/opt/homebrew/bin/nvim
else
  export EDITOR=nvim
fi

alias la=tree
alias cat=bat

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# GO
export GOPATH="${GOPATH:-$HOME/go}"

# VIM
if [ -x "$HOME/.nix-profile/bin/nvim" ]; then
  alias v="$HOME/.nix-profile/bin/nvim"
else
  alias v="nvim"
fi

# Nmap
alias nm="nmap -sC -sV -oN nmap"

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.vimpkg/bin:${GOPATH}/bin:$HOME/.cargo/bin

alias cl='clear'

# K8S
export KUBECONFIG=~/.kube/config
alias k="kubectl"
alias ka="kubectl apply -f"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kl="kubectl logs"
alias kgpo="kubectl get pod"
alias kgd="kubectl get deployments"
alias kc="kubectx"
alias kns="kubens"
alias kl="kubectl logs -f"
alias ke="kubectl exec -it"
alias kcns='kubectl config set-context --current --namespace'
alias podname=''

# HTTP requests with xh!
alias http="xh"

# VI Mode!!!
bindkey jj vi-cmd-mode

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# SEC STUFF
alias gobust='gobuster dir --wordlist ~/security/wordlists/diccnoext.txt --wildcard --url'
alias dirsearch='python dirsearch.py -w db/dicc.txt -b -u'
alias massdns='~/hacking/tools/massdns/bin/massdns -r ~/hacking/tools/massdns/lists/resolvers.txt -t A -o S bf-targets.txt -w livehosts.txt -s 4000'
alias server='python -m http.server 4445'
alias tunnel='ngrok http 4445'
alias fuzz='ffuf -w ~/hacking/SecLists/content_discovery_all.txt -mc all -u'
alias gr='~/go/src/github.com/tomnomnom/gf/gf'

### FZF ###
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ -d /opt/homebrew/bin ]; then
  export PATH=/opt/homebrew/bin:$PATH
fi
if [ -d /home/linuxbrew/.linuxbrew/bin ]; then
  export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
fi

alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'

# Nix!
export NIX_CONF_DIR=$HOME/.config/nix
export PATH=/run/current-system/sw/bin:$PATH

function ranger {
	local IFS=$'\t\n'
	local tempfile="$(mktemp -t tmp.XXXXXX)"
	local ranger_cmd=(
		command
		ranger
		--cmd="map Q chain shell echo %d > "$tempfile"; quitall"
	)

	${ranger_cmd[@]} "$@"
	if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
		cd -- "$(cat "$tempfile")" || return
	fi
	command rm -f -- "$tempfile" 2>/dev/null
}
alias rr='ranger'

# navigation
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

 # Nix
 if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	 . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
 fi
 # End Nix

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh)"
fi
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
