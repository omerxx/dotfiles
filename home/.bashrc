# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc
# Ported from .zshrc (Bash-compatible)

# Environment
export LANG=en_US.UTF-8
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export GOPATH="${GOPATH:-$HOME/go}"
export KUBECONFIG="$HOME/.kube/config"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'

if [ -x /opt/homebrew/bin/nvim ]; then
  export EDITOR=/opt/homebrew/bin/nvim
else
  export EDITOR=nvim
fi

# PATH updates (idempotent)
path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

path_append() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$PATH:$1" ;;
  esac
}

path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.local/bin"
path_append "$HOME/.vimpkg/bin"
path_append "${GOPATH}/bin"
path_append "$HOME/.cargo/bin"

if [ -d /opt/homebrew/bin ]; then
  path_prepend /opt/homebrew/bin
fi
if [ -d /home/linuxbrew/.linuxbrew/bin ]; then
  path_prepend /home/linuxbrew/.linuxbrew/bin
fi

unset -f path_prepend path_append

# Tool/env init
[ -f "$HOME/.vite-plus/env" ] && . "$HOME/.vite-plus/env"
if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init bash)"
fi
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
fi
if [ -x /usr/local/bin/aws_completer ]; then
  complete -C '/usr/local/bin/aws_completer' aws
fi
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Worktrunk aliases
alias wtc='wt --switch create'
alias wts='wt --switch'
alias wtl='wt list'
alias wtr='wt remove'
alias wtcom='wt step commit'

# Core aliases
if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

# Git
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gp='git push origin HEAD'
alias gpu='git pull origin'
alias gst='git status'
alias gl='git pull'
alias gm='git merge'
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'
alias gfr='~/go/src/github.com/tomnomnom/gf/gf'

# Podman (ported from docker aliases)
alias d='podman'
alias dco='podman compose'
alias dps='podman ps'
alias dpa='podman ps -a'
alias dl='podman ps -l -q'
alias dx='podman exec -it'

# Directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Eza aliases (requested)
alias ls='eza --icons=always'
alias ll='eza -lh --icons=always'
alias la='eza -lha --icons=always'
alias lt='eza --tree --icons=always'
alias ltree='eza --tree --level=2 --icons=always'

# Zoxide aliases (requested)
if command -v zoxide >/dev/null 2>&1; then
  alias cd='z'
  alias zi='zoxide add'
  alias zq='zoxide query'
  alias zr='zoxide remove'
fi

# VIM
if [ -x /opt/homebrew/bin/nvim ]; then
  alias v='/opt/homebrew/bin/nvim'
else
  alias v='nvim'
fi

# General tools
alias cl='clear'
alias nm='nmap -sC -sV -oN nmap'
alias http='xh'

# Kubernetes
alias k='kubectl'
alias ka='kubectl apply -f'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kl='kubectl logs -f'
alias kgpo='kubectl get pod'
alias kgd='kubectl get deployments'
alias kc='kubectx'
alias kns='kubens'
alias ke='kubectl exec -it'
alias kcns='kubectl config set-context --current --namespace'

# Security helpers
alias gobust='gobuster dir --wordlist ~/security/wordlists/diccnoext.txt --wildcard --url'
alias dirsearch='python dirsearch.py -w db/dicc.txt -b -u'
alias massdns='~/hacking/tools/massdns/bin/massdns -r ~/hacking/tools/massdns/lists/resolvers.txt -t A -o S bf-targets.txt -w livehosts.txt -s 4000'
alias server='python -m http.server 4445'
alias tunnel='ngrok http 4445'
alias fuzz='ffuf -w ~/hacking/SecLists/content_discovery_all.txt -mc all -u'

if command -v osascript >/dev/null 2>&1; then
  alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'
fi
unalias cx fcd f fv ranger 2>/dev/null

# Ranger function that changes cwd on quit
ranger() {
  local tempfile newdir
  tempfile="$(mktemp -t tmp.XXXXXX)"

  command ranger --cmd="map Q chain shell echo %d > \"$tempfile\"; quitall" "$@"
  if [[ -f "$tempfile" ]]; then
    newdir="$(cat -- "$tempfile")"
    if [[ -n "$newdir" && "$newdir" != "$PWD" ]]; then
      builtin cd -- "$newdir" || return
    fi
  fi
  command rm -f -- "$tempfile" 2>/dev/null
}
alias rr='ranger'

# Navigation helpers
cx() {
  builtin cd "$@" && ls
}

fcd() {
  local dir
  dir="$(find . -type d -not -path '*/.*' | fzf)" || return
  [[ -n "$dir" ]] || return
  builtin cd "$dir" && ls
}

f() {
  local file
  file="$(find . -type f -not -path '*/.*' | fzf)" || return
  [[ -n "$file" ]] || return

  if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$file" | wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    printf '%s' "$file" | xclip -selection clipboard
  elif command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "$file" | pbcopy
  else
    printf '%s\n' "$file"
  fi
}

fv() {
  local file
  file="$(find . -type f -not -path '*/.*' | fzf)" || return
  [[ -n "$file" ]] || return
  nvim "$file"
}
