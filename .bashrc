#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export VISUAL="vim"

# Command Alias
if [ $OSTYPE == 'linux-gnu' ]; then
  alias ls='ls --color=auto'
elif [ $OSTYPE == 'darwin16' ]; then
  alias vi='/usr/local/bin/vim'
  # Delete extra key bindings
  stty discard undef
fi

PS1='[\u@\h \W]\$ '

export PAGER=less
export LESS='-g -i -M -R -W -x2'

# Add color to the display of man
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[00;47;30m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# ssh-agent
## AutoStart
if [[ -e $XDG_RUNTIME_DIR/ssh-agent.socket ]]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

## Automatically add key of ssh command
ssh-add -l >/dev/null || alias ssh='ssh-add -l >/dev/null || ssh-add && unalias ssh; ssh'

# Alias
alias notevim='mkdir -p ~/Documents/note/`date +%Y%m%d`; cd  ~/Documents/note/`date +%Y%m%d`; vim'

if [ -f ~/.bashrc_private ]; then
  . ~/.bashrc_private
fi

if [ -f ~/.bashrc_work ]; then
  . ~/.bashrc_work
fi
