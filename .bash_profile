#
# ~/.bash_profile
#

export PATH=$PATH:/sbin
export GOPATH=$HOME/dev
export PATH=$GOPATH/bin:$PATH
export PATH=~/bin:$PATH

export MOZ_DISABLE_RDD_SANDBOX=1

[[ -f ~/.bashrc ]] && . ~/.bashrc
