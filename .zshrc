# vim: set foldmethod=marker :

export TERM=screen-256color
export PATH="$PATH:$HOME/.gem/ruby/2.2.0/bin"

# Lang {{{1
# ---------
export LANG=ja_JP.UTF-8
export EDITOR=vim
# }}}1

# Complement {{{1
# ---------------
# compsys有効化。
autoload -U compinit
compinit
# ここまで。
setopt always_last_prompt       # 候補をプロンプト下に出したあと、現在のプロンプトを再利用する。
setopt complete_in_word         # カーソル位置に*を置いたかのような保管をする。
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
zstyle ':completion:*' menu true select
# マッチング時に大文字と小文字を区別しない。"._-"の前は*を入れる。(ht.c → httpd.conf)
# 但し、通常のマッチングで候補が無い場合のみ。
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z} r:|[._-]=*'
# 指定コマンドで候補表示を無効にする。マッチングは有効。
zstyle ':completion:*:(rm|rmdir):*' menu false
zstyle ':completion:*:ping:*' hosts \
    www.google.{com,co.jp} www.yahoo.{com,co.jp}
zstyle ':completion:*:ssh:*' users \
    root\
    yoshihisa
# zstyle ':completion:*:ssh:*' users-hosts \
    # user@{host1,host2}
zstyle ':completion:*:(ping|ssh):*' sort false
# 既に指定されている引数を候補としない。
zstyle ':completion:*:(less|rm|rmdir|cp|mv|vi|vim):*' ignore-line true
# }}}1

# Alias {{{1
# ----------
alias vi='vim'
alias grep="grep --color=auto"
# alias less="/usr/share/vim/vim74/macros/less.sh"
alias rm=" rm -iv"
alias mv=" mv -iv"
alias cp="cp -i"
alias nssh='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'

alias -s py=python
alias -s {png,jpg,bmp,PNG,JPG,BMP}=eog
# alias -s {html,htm}=google-chrome
alias -s {html,htm,pdf}=google-chrome-stable
# alias -s {html,htm}=chromium
alias -s {mp3,wma,wav}=rhythmbox

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

# }}}1

# Prompt {{{1
# -----------
autoload colors
colors

PROMPT="%{${fg[cyan]}%}%n%# %{${reset_color}%}"
[ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
    PROMPT="%{${fg[blue]}%}[%n@%{${fg[red]}%}%M%{${fg[blue]}%}]%# %{${reset_color}%}"
RPROMPT="%{${fg[blue]}%}[%~]%{${reset_color}%}"


# case "${TERM}" in
# kterm*|xterm)
#     precmd() {
#         echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
#     }
#     ;;
# esac

# setopt prompt_subst             # PROMPT変数に対して、変数展開・コマンド置換・算術展開を施す。
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
# setopt hist_ignore_dups         # ヒストリリストに登録する際、直前のものと同じであれば登録しない。
setopt hist_ignore_space        # 先頭にスペースを入れた際に、ヒストリリストに登録しない。
setopt hist_no_functions        # 関数定義をヒストリリストから消去。
setopt hist_no_store            # history,fcコマンドは、ヒストリリストから消去する。
setopt hist_reduce_blanks       # 余分なスペースを、ヒストリリストに登録する際に削除する。
setopt hist_save_no_dups        # ヒストリファイルに保存する際、重複したコマンドラインは、古い方を削除する。
setopt hist_verify              # ヒストリ展開の際にいきなり実行せず、マッチしたものを一旦提示する。
setopt inc_append_history       # ヒストリリストに登録すると直ちに、ヒストリファイルにも追加で書き込む。
setopt share_history            # 稼働中のすべてのzshプロセスで、ヒストリリストを共有する。(悩み中)
# }}}1

# vi key bind {{{1
# ----------------
bindkey -v      # viinsキーマップを利用。
bindkey -a 'q' push-line
# ViInsertモードでも、Ctrl+P,Nを有効化。
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
# ここまで。
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
# zstyle ':completion:*' list-colors ''   # Complement Color
# }}}1

# Setting Include {{{1
# --------------------
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f ~/dotfiles/.git-flow-completion.zsh ]; then
    source ~/dotfiles/.git-flow-completion.zsh
fi

if [ `hostname` = "www1112.sakura.ne.jp" ]; then
    alias tmux='export LD_LIBRARY_PATH=~/opt/libevent/lib && ~/opt/tmux/bin/tmux'
    export MAILCHECK=0
fi

[ -f ~/.zshrc.group ] && source ~/.zshrc.group
[ -f ~/.zshrc.user ] && source ~/.zshrc.user
# }}}1
#
