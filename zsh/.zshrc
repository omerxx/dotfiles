# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/omer/.oh-my-zsh

# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="omer"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

if command -v tmux>/dev/null; then
  [[ ! $TERM =~ screen ]] && [ -z $TMUX ] && killall tmux && exec tmux
fi

alias la=tree

# Git
alias gc="git commit -a -m"
alias gp="git push origin"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'

# AWS
alias ecrspt='aws ecr get-login --no-include-email --region us-east-1'

# Docker
alias dco="docker-compose"
alias de="docker exec"
alias dr="docker run"
alias dshalpine="docker exec -it $(docker ps -q) /bin/sh"
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias dl="docker ps -l -q"


# GO
export GOPATH='/Users/omer/go'

# Drone
export DRONE_SERVER=https://droneio.company.im
export DRONE_TOKEN=123

# VIM
#alias vim="mvim -v"
alias v="vim"

# SSH
ssh-add ~/.ssh/companyimadmin 2> /dev/null
ssh-add ~/.ssh/id_rsa 2> /dev/null

# VPN
alias vpncompanyim="sudo openvpn ~/Downloads/client.ovpn"
alias vpncorporate="sudo openvpn ~/corporate/corporate-profile.ovpn"

# Nmap
alias nm="nmap -sC -sV -oN -T4 nmap"

# Tree
alias tree="tree -L"

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/omer/.vimpkg/bin

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/omer/exec -l /bin/zsh/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/omer/exec -l /bin/zsh/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/omer/exec -l /bin/zsh/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/omer/exec -l /bin/zsh/google-cloud-sdk/completion.zsh.inc'; fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# K8S
alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kl="kubectl logs"
alias kgpo="kubectl get pod"
alias zshk8s="vim -s ~/projects/dotfiles/vim/zsh-k8s-toggle.vim ~/.oh-my-zsh/themes/omer.zsh-theme && source ~/.oh-my-zsh/themes/omer.zsh-theme"
