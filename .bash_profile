#
# ~/.bash_profile
#

export GOPATH=$HOME/dev
export PATH=$PATH:~/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:~/opt/terraform/

[[ -f ~/.bashrc ]] && . ~/.bashrc
