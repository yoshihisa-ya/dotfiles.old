# vim: set foldmethod=marker :

export PAGER=less
export EDITOR=nvim
export LESS='-g -i -M -R -W -x2 -S'
export TERM=xterm-256color
export MAKEOBJDIRPREFIX=$HOME/.obj
export ANSIBLE_NOCOWS=1
export BR2_DL_DIR=~/buildroot/download

# Add color to the display of man
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[00;47;30m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# gpg-agent
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi


# Complement {{{1
# ---------------
autoload -Uz compinit #promptinit
compinit
# promptinit
# prompt walters
setopt always_last_prompt       # 候補をプロンプト下に出したあと、現在のプロンプトを再利用する。
setopt complete_in_word         # TODO: カーソル位置に*を置いたかのような保管をする。
setopt auto_list                # 候補がある場合、^Dを利用せずともTABだけで候補を表示する。
unsetopt bash_auto_list         # 2度補完キーを押さなくても、1度目から補完する。
setopt auto_menu                # メニュー補完を有効にする。
unsetopt menu_complete          # いきなりメニュー補完へ移行しない。
# setopt auto_param_keys          # 変数補完時に補完された記号を、次に入力されたものによって、必要ならば削除を行う。
# setopt auto_param_slash         # 変数補完時にディレクトリ名である場合、末尾にスラッシュを付加。
setopt auto_remove_slash        # ディレクトリ名補完時に、後にデリミタを入力すると、保管されたスラッシュを削除。
unsetopt complete_aliases       # コマンドのオプション等の補完時に、そのコマンドエイリアスを内部的に置き換えない。
# unsetopt glob_complete
# setopt hash_list_all
# setopt list_ambiguous
unsetopt list_beep              # 補完結果が1つにならない時にビープを鳴らさない。
setopt list_packed              # 一覧行数を少なくする。
unsetopt list_rows_first        # 候補一覧を横進みにしない。
setopt list_types               # 候補一覧に種類を表す記号を付ける。
# unsetopt rec_exact
# 方向キーで選択可能とする。
zstyle ':completion:*' menu true select
# マッチング時に大文字と小文字を区別しない。"._-"の前は*を入れる。(ht.c → httpd.conf)
# 但し、通常のマッチングで候補が無い場合のみ。
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z} r:|[._-]=*'
# 指定コマンドで候補表示を無効にする。マッチングは有効。
zstyle ':completion:*:(rm|rmdir):*' menu false
# zstyle ':completion:*:ping:*' hosts \
#     www.google.{com,co.jp} www.yahoo.{com,co.jp}
zstyle ':completion:*:ssh:*' users \
    yoshihisa\
    y-yamano\
    ubuntu\
    root
# zstyle ':completion:*:ssh:*' users-hosts \
#     user@{host1,host2}
zstyle ':completion:*:(ping|ssh):*' sort false
# 既に指定されている引数を候補としない。
zstyle ':completion:*:(less|rm|rmdir|cp|mv|vi|vim):*' ignore-line true
setopt completealiases
# }}}1

# Alias {{{1
# ----------
alias ls='ls --color=auto'
alias vi='nvim'
alias vim='nvim'
alias grep="grep --color=auto"
alias rm=" rm -iv"
alias mv=" mv -iv"
alias cp='cp -i --reflink=auto'

alias -s {png,jpg,bmp,PNG,JPG,BMP}=sxiv
alias -s {html,htm,pdf}=firefox
# alias -s {mp3,wma,wav}=rhythmbox

function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.zip) unzip $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.gz) gunzip $1;;
    *.bz2) bzip2 -dc $1;;
    *.tar) tar xvf $1;;
  esac
}
alias -s {gz,tgz,zip,bz2,tbz,tar}=extract

alias n='mpc next'
alias p='mpc pause'
alias xclip='xclip -selection clipboard'
windowid() {
    xwininfo | awk '/Window id/{print$4}'
}
alias import-window="import -window \$(windowid)"
# }}}1

# Prompt {{{1
# -----------
autoload colors
colors

PROMPT="%{${fg[cyan]}%}%n%# %{${reset_color}%}"
RPROMPT="%{${fg[yellow]}%}[%~]%{${reset_color}%}"
[ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
    PROMPT="%{${fg[cyan]}%}[%n@%{${fg[red]}%}%M%{${fg[cyan]}%}]%# %{${reset_color}%}"  &&
    RPROMPT="%{${fg[red]}%}[%~]%{${reset_color}%}"


# setopt prompt_subst             # プロンプトで、変数展開・コマンド置換・算術展開を施す。
setopt prompt_bang              # プロンプト文字列内の!を次に保存されるヒストリ番号に置換する。
setopt prompt_percent           # %記号の展開を行う。
setopt prompt_cr                # プロンプト文字列発生時に、復帰文字(CR)を出力する。
setopt prompt_sp                # PROMPT_CRオプションを改善する。
unsetopt transient_rprompt      # コマンド実行時に、右プロンプトを消去しない。
# }}}1

# History {{{1
# ------------
histchars=!^#                   # Default. イベント呼び出し 簡略ヒストリ置換 コメント開始文字。
HISTFILE=~/.zsh_history         # HistoryFile.
HISTSIZE=10000                  # HistorySize (Memory).
SAVEHIST=10000                  # HistorySize (File).
setopt append_history           # シェル終了時に、ヒストリファイルにヒストリを上書きするのではなく追加する。
setopt extended_history         # ヒストリファイルに、拡張フォーマットで保存する。
unsetopt hist_allow_clobber     # ファイルへのリダイレクトを行った際、ヒストリには「>|」に置き換えない。
setopt hist_beep                # ヒストリに無いものを取り出そうとしたときにベルを鳴らす。
setopt hist_expire_dups_first   # HISTSIZEに達したとき、重複があるものを消去する。
# setopt hist_find_no_dups        # ラインエディタでヒストリ検索を行う際、一度見つかったものは更に先に重複したものがあってもないものとみなす。
setopt hist_ignore_all_dups     # ヒストリリストに登録する際、既に同じものがあればそれを削除する。
setopt hist_ignore_dups         # ヒストリリストに登録する際、直前のものと同じであれば登録しない。
setopt hist_ignore_space        # 先頭にスペースを入れた際に、ヒストリリストに登録しない。
setopt hist_no_functions        # 関数定義をヒストリリストから消去。
setopt hist_no_store            # history,fcコマンドは、ヒストリリストから消去する。
setopt hist_reduce_blanks       # 余分なスペースを、ヒストリリストに登録する際に削除する。
setopt hist_save_no_dups        # ヒストリファイルに保存する際、重複したコマンドラインは、古い方を削除する。
#setopt hist_verify              # ヒストリ展開の際にいきなり実行せず、マッチしたものを一旦提示する。
setopt inc_append_history       # ヒストリリストに登録すると直ちに、ヒストリファイルにも追加で書き込む。
setopt share_history            # 稼働中のすべてのzshプロセスで、ヒストリリストを共有する。(悩み中)
# }}}1

# Key bind {{{1
# -------------
bindkey -e  # Emacs key-bindings

## Bash like Ctrl-W, Ctrl-Alt-H
zle -N backward-kill-space-word
backward-kill-space-word() {
  zle -f kill
  WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' zle .backward-kill-word
}

zle -N backward-kill-bash-word
backward-kill-bash-word() {
  zle -f kill
  WORDCHARS='' zle .backward-kill-word
}

bindkey   '^W' backward-kill-space-word
bindkey '^[^H' backward-kill-bash-word
# }}}1

# Change Directory {{{1
# ---------------------
DIRSTACKSIZE=50                         # ディレクトリスタック数。
setopt auto_cd                          # ディレクトリ名だけで移動。
setopt auto_pushd                       # cdコマンドで自動スタック。
setopt cdable_vars                      # /で始まらない && 存在しない場合、前に~を補って名前付きディレクトリへ。
setopt pushd_ignore_dups                # ディレクトリスタックに同じものは追加しない。
unsetopt pushd_minus                    # ディレクトリスタック書く要素アクセス時に+,-を反転しない。
unsetopt pushd_silent                   # pushd,popdでサイレントにディレクトリスタックしない。
unsetopt pushd_to_home                  # pushdを引数なしで実行した場合、ホームディレクトリへ移動しない。
unsetopt chase_dots                     # cd時に、".."を論理パスを物理パスに変換しない。
unsetopt chase_links                    # "chase_dots"と同様の効果を".."以外にも適用する。
# }}}1

# Other Settings {{{1
# -------------------
# setopt correct                          # Command revise
# setopt list_packed                      # Complement closely
# setopt nolistbeep                       # No Beep
# setopt multios                          # multios (redirect)
zstyle ':completion:*' list-colors ''   # Complement Color

## run-help
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn
# }}}1

# Git prompt {{{1
# ---------------
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{cyan}+"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}-"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'
# }}}1
function repos() {
    local repo=$(ghq list --full-path | peco --query "$LBUFFER")
    if [ -n ${repo} ]; then
        echo ${repo}
        cd ${repo}
    fi
}

# Setting Include {{{1
# --------------------
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/doc/pkgfile/command-not-found.zsh
# }}}1
