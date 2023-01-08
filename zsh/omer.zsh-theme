# CRUNCH - created from Steve Eley's cat waxing.
# Initially hacked from the Dallas theme. Thanks, Dallas Reedy.
#
# This theme assumes you do most of your oh-my-zsh'ed "colorful" work at a single machine,
# and eschews the standard space-consuming user and hostname info.  Instead, only the
# things that vary in my own workflow are shown:
#
# * The time (not the date)
# * The RVM version and gemset (omitting the 'ruby' name if it's MRI)
# * The current directory
# * The Git branch and its 'dirty' state
#
# Colors are at the top so you can mess with those separately if you like.
# For the most part I stuck with Dallas's.

CRUNCH_BRACKET_COLOR="%{$fg[white]%}"
CRUNCH_TIME_COLOR="%{$fg[yellow]%}"
CRUNCH_RVM_COLOR="%{$fg[magenta]%}"
CRUNCH_DIR_COLOR="%{$fg[cyan]%}"
CRUNCH_GIT_BRANCH_COLOR="%{$fg[green]%}"
CRUNCH_GIT_CLEAN_COLOR="%{$fg[green]%}"
CRUNCH_GIT_DIRTY_COLOR="%{$fg[red]%}"

# These Git variables are used by the oh-my-zsh git_prompt_info helper:
ZSH_THEME_GIT_PROMPT_PREFIX="$CRUNCH_BRACKET_COLOR:${CRUNCH_GIT_BRANCH_COLOR}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_CLEAN=" $CRUNCH_GIT_CLEAN_COLOR✓"
ZSH_THEME_GIT_PROMPT_DIRTY=" $CRUNCH_GIT_DIRTY_COLOR✗"

# Our elements:
CRUNCH_TIME_="$CRUNCH_BRACKET_COLOR$CRUNCH_TIME_COLOR%T$CRUNCH_BRACKET_COLOR:%{$reset_color%}"
# CRUNCH_TIME_="$CRUNCH_BRACKET_COLOR{$CRUNCH_TIME_COLOR%T$CRUNCH_BRACKET_COLOR}%{$reset_color%}"
CRUNCH_DIR_="$CRUNCH_DIR_COLOR%~\$(git_prompt_info) "
CRUNCH_PROMPT="$CRUNCH_BRACKET_COLOR"

# K8S Context
K8S_CONTEXT='[$(kubectl config current-context)] '
CRUNCH_K8S="%{$fg[green]%}% $K8S_CONTEXT%{$reset_color%}"

# Put it all together!
USER_="%{$fg[green]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%}"

# Promt with K8S context
# PROMPT="$CRUNCH_TIME_$CRUNCH_DIR_$CRUNCH_PROMPT$CRUNCH_K8S%{$reset_color%}"

# Prompt without user prefix
PROMPT="$CRUNCH_TIME_$CRUNCH_DIR_$CRUNCH_PROMPT%{$reset_color%}"

# Prompt with user prefix (old)
# PROMPT="$USER_$CRUNCH_TIME_$CRUNCH_DIR_$CRUNCH_PROMPT%{$reset_color%}"
