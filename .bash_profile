#
# ~/.bash_profile
#

export PATH=$PATH:/sbin
export GOPATH=$HOME/dev
export PATH=$GOPATH/bin:$PATH
export PATH=~/bin:$PATH

[[ -f ~/.bashrc ]] && . ~/.bashrc
