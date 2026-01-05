# ~/.zshrc (managed by ~/dotfiles)
# Keep startup fast; PATH is handled in ~/.zshenv.

# Profile startup when requested: `ZPROF=1 zsh -i`
if [[ -n "${ZPROF:-}" ]]; then
  zmodload zsh/zprof
fi

# ------------------------------------------------------------------------------
# History

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE="${HISTSIZE:-10000}"
SAVEHIST="${SAVEHIST:-10000}"

setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
unsetopt APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS

[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}" 2>/dev/null

# ------------------------------------------------------------------------------
# Completion (avoid slow `compaudit` on every start)

_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_zsh_cache_dir" 2>/dev/null
_zcompdump="$_zsh_cache_dir/zcompdump-${ZSH_VERSION}"

if (( ! ${+_comps} )); then
  autoload -Uz compinit
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "$_zsh_cache_dir/zcompcache"

  if [[ -f "$_zcompdump" ]]; then
    compinit -C -d "$_zcompdump"
  else
    compinit -d "$_zcompdump"
  fi
fi

# ------------------------------------------------------------------------------
# Cached init snippets (avoid running `... init zsh` on every shell)

_zsh_cache_source() {
  local name="$1"
  local bin="$2"
  shift 2

  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init"
  local cache_file="$cache_dir/${name}.zsh"
  local stamp_file="$cache_dir/${name}.stamp"

  mkdir -p "$cache_dir" 2>/dev/null

  local bin_real="${bin:A}"
  local cached_bin=""
  [[ -r "$stamp_file" ]] && cached_bin="$(<"$stamp_file")"

  if [[ ! -s "$cache_file" || "$cached_bin" != "$bin_real" || "$bin_real" -nt "$cache_file" ]]; then
    local tmp="${cache_file}.$$"
    if "$bin" "$@" >| "$tmp" 2>/dev/null && mv -f "$tmp" "$cache_file"; then
      print -r -- "$bin_real" >| "$stamp_file"
    else
      rm -f "$tmp"
    fi
  fi

  [[ -r "$cache_file" ]] && source "$cache_file"
}

if (( ${+commands[direnv]} )); then
  _zsh_cache_source direnv "${commands[direnv]}" hook zsh
fi

if (( ${+commands[zoxide]} )); then
  _zsh_cache_source zoxide "${commands[zoxide]}" init zsh
fi

if (( ${+commands[atuin]} )); then
  _zsh_cache_source atuin "${commands[atuin]}" init zsh
fi

# fzf integration (completion/key bindings)
if (( ${+commands[fzf]} )); then
  _fzf_prefix="${commands[fzf]:A:h:h}"
  [[ -r "$_fzf_prefix/share/fzf/completion.zsh" ]] && source "$_fzf_prefix/share/fzf/completion.zsh"
  [[ -r "$_fzf_prefix/share/fzf/key-bindings.zsh" ]] && source "$_fzf_prefix/share/fzf/key-bindings.zsh"
  unset _fzf_prefix
fi

if (( ${+commands[starship]} )); then
  _zsh_cache_source starship "${commands[starship]}" init zsh
fi

unset _zsh_cache_dir _zcompdump

# Aliases
alias gi='gitingest . --output -'

if [[ -n "${ZPROF:-}" ]]; then
  zprof
fi

