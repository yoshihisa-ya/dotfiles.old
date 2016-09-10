" vim: set ts=2 sw=2 sts=2 et :

" NeoBundle {{{1
" ------------------------------
if has('vim_starting')
  if &compatible
    set nocompatible
  endif

  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

" Unite
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'Shougo/vimproc.vim', {
  \ 'build' : {
  \     'windows' : 'tools\\update-dll-mingw',
  \     'cygwin' : 'make -f make_cygwin.mak',
  \     'mac' : 'make -f make_mac.mak',
  \     'unix' : 'make -f make_unix.mak',
  \    },
  \ }

" Search
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'haya14busa/incsearch.vim'
NeoBundle 'haya14busa/incsearch-fuzzy.vim'

" TweetVim
NeoBundle 'basyura/TweetVim'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'basyura/twibill.vim'

" Indent
" NeoBundle 'nathanaelkane/vim-indent-guides'

" Format
NeoBundle 'Align'

" Buffer | Filer
NeoBundle 'buftabs'
NeoBundle 'bufexplorer.zip'
NeoBundle 'Shougo/vimfiler.vim'

" Other
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'surround.vim'
NeoBundle 'DrawIt'
NeoBundle 'EasyMotion'
NeoBundle 'Emmet.vim'
NeoBundle 'localrc.vim'
NeoBundle 'speeddating.vim'
NeoBundle 'tComment'
NeoBundle 'Toggle'

" NeoBundle 'camelcasemotion'
" NeoBundle 'textobj-user'
" NeoBundle 'textobj-fold'
" NeoBundle 'textobj-indent'
" NeoBundle 'textobj-lastpat'
" NeoBundle 'ref.vim'
" NeoBundle 'repeat.vim'
" NeoBundle 'smartchr'

call neobundle#end()

filetype plugin indent on

NeoBundleCheck
" }}}1


" Plugin Setting {{{1
" ------------------------------
"  Unite
let g:unite_enable_start_insert = 1
let g:unite_source_file_mru_limit = 50
nnoremap [unite] <Nop>
nmap <Space>f [unite]
nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>

" align
let g:Align_xstrlen = 3
let g:DrChipTpLevlMenu = 1

" buftabs
let g:buftabs_only_basename = 1
let g:buftabs_in_statusline = 1 ":s/w:/g:/g
let g:buftabs_active_highlight_group="Visual"

" bufexplorer
let bufExplorerDetailedHelp = 1

" VimFiler
let g:vimfiler_as_default_explorer = 1

" EasyMotion
let g:EasyMotion_leader_key = ','

" neocomplete
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#auto_completion_start_length = 1
let g:neocomplete#enable_auto_select = 1

" vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
" }}}1


set nocompatible
syntax on

set title

if isdirectory(expand('~/.vim/doc'))
  helptags ~/.vim/doc
  set helplang=ja
endif

set modeline

nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

nmap <C-o><C-o> <ESC>i<C-R>=strftime("%Y-%m-%d")<CR>



nmap <c-l> :BufExplorer<CR>
nnoremap <C-j> <C-^>
nmap n nzz
nmap N Nzz
nmap ZZ <Nop>
let mapleader=","
map z/ <Plug>(incsearch-fuzzy-/)
map z? <Plug>(incsearch-fuzzy-?)
map zg/ <Plug>(incsearch-fuzzy-stay)

inoremap jj <ESC>

" 行数とルーラーを表示
set number
set ruler

" 不可視文字を表示
set list listchars=tab:^_,trail:_

" 全角スペースをハイライト
" scriptencoding utf-8
" augroup highlightIdegraphicSpace
"   autocmd!
"   autocmd ColorScheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
"   autocmd VimEnter,WinEnter * match IdeographicSpace /　/
" augroup END

" PHPファイルで保存時に書式チェック
augroup phpsyntaxcheck
  autocmd!
  autocmd BufWrite *.php w !php -l
augroup END

" ファイルに応じて自動インデント
augroup foldmethod
  autocmd!
  autocmd BufRead,BufNewFile *.c,*.cpp,*.php,*.java setlocal foldmethod=syntax
  autocmd BufRead,BufNewFile *.py,*.rst setlocal foldmethod=indent
augroup END

" プロジェクトに合わせてカレントディレクトリを変更
augroup sotsukenProjroot
  autocmd!
  autocmd BufEnter ~/Dropbox/2015_卒業研究/**/* lcd ~/Dropbox/2015_卒業研究
augroup END

" 新規作成時にテンプレートを利用
" augroup templateload
"   autocmd!
"   autocmd BufNewFile *.c 0r ~/.vim/template.c
"   autocmd BufNewFile *.cpp 0r ~/.vim/template.cpp
"   autocmd BufNewFile *.php 0r ~/.vim/template.php
"   autocmd BufNewFile *.java 0r ~/.vim/template.java
"   autocmd BufNewFile *.py 0r ~/.vim/template.py
"   autocmd BufNewFile *.rst 0r ~/.vim/template.rst
"   autocmd BufNewFile *.html 0r ~/.vim/template.html
"   autocmd BufNewFile *.css 0r ~/.vim/template.css
" augroup END

" 最後の編集位置にカーソルを復元
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

set cursorline
set nocursorcolumn
set cmdheight=2
set laststatus=2
let ff_type = {'dos' : 'CR+LF', 'unix' : 'LF', 'mac' : 'CR' }
set statusline=%m%r%h%w[%Y,%{ff_type[&ff]}(%{&ff})]\ [%{(&fenc!=''?&fenc:&enc)}]\ [%03l/%03L,%03c]\ [%02p%%]

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=0
set noautoindent
set nosmartindent
set nocindent
set showmatch

set ignorecase
set smartcase
set incsearch
set hlsearch

set wrapscan
nnoremap <ESC><ESC> :nohlsearch<CR>

set nobackup
set noswapfile
set hidden
set autoread


if has('unix')
  if filereadable(expand('~/.vim/unix.vimrc'))
    source ~/.vim/unix.vimrc
  endif
elseif has('mac')
  if filereadable(expand('~/.vim/mac.vimrc'))
    source ~/.vim/mac.vimrc
  endif
endif

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
