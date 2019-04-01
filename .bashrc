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
export TERM=xterm-256color
export MAKEOBJDIRPREFIX=$HOME/obj

export ANSIBLE_NOCOWS=1

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
alias ssh-root='ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -q -l root'
alias n='mpc next'
alias xclip='xclip -selection clipboard'
windowid() {
    xwininfo | awk '/Window id/{print$4}'
}
alias import-window="import -window \$(windowid)"

# functions
shopt -s extglob
extract() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
        *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
            c=(bsdtar xvf)
            ;;
        *.7z) c=(7z x) ;;
        *.Z) c=(uncompress) ;;
        *.bz2) c=(bunzip2) ;;
        *.exe) c=(cabextract) ;;
        *.gz) c=(gunzip) ;;
        *.rar) c=(unrar x) ;;
        *.xz) c=(unxz) ;;
        *.zip) c=(unzip) ;;
        *)
            echo "$0: unrecognized file extension: \`$i'" >&2
            continue
            ;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}

function repos() {
    local repo=$(ghq list --full-path | peco --query "$LBUFFER")
    if [ -n ${repo} ]; then
        echo ${repo}
        cd ${repo}
    fi
}

if [ -f ~/.bashrc_private ]; then
    . ~/.bashrc_private
fi

if [ -f ~/.bashrc_work ]; then
    . ~/.bashrc_work
fi
