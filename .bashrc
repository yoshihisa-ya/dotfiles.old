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
