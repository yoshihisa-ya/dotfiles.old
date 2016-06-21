export ANSIBLE_NOCOWS=1
export LC_ALL='ja_JP.UTF-8'
if [ `hostname` = "www1112.sakura.ne.jp" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  export TMPDIR="$HOME/tmp"
  eval "$(pyenv init -)"
  # eval "$(pyenv virtualenv-init -)"
fi
