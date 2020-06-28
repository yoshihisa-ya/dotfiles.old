" vim-plug
" ------------------------------
call plug#begin('~/.vim/plugged')

" Markdown
Plug 'kannokanno/previm'
Plug 'tyru/open-browser.vim'

" Golang
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'mattn/vim-goimports'

" LSP
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'
" Plug 'natebosch/vim-lsc'

" Bash
Plug 'vim-scripts/sh.vim'
Plug 'z0mbix/vim-shfmt'

" Git
Plug 'tpope/vim-fugitive'

" Search
Plug 'thinca/vim-visualstar'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'

" Other
Plug 'tomtom/tcomment_vim'
Plug 'vim-jp/vimdoc-ja'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'Rykka/riv.vim'
Plug 'skanehira/translate.vim'
Plug 'fuenor/JpFormat.vim'

call plug#end()

let mapleader=","

" Plugin Setting
" ------------------------------

" vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1

" vim-lsp
nmap <silent> <Leader>d :LspDefinition<CR>
nmap <silent> <Leader>p :LspHover<CR>
nmap <silent> <Leader>r :LspReferences<CR>
nmap <silent> <Leader>i :LspImplementation<CR>
nmap <silent> <Leader>s :split \| :LspDefinition <CR>
nmap <silent> <Leader>v :vsplit \| :LspDefinition <CR>

" vim-go
" let g:go_fmt_command = "goimports"
" let g:go_fmt_autosave = 1
" let g:go_def_mapping_enabled = 0
" let g:go_doc_keywordprg_enabled = 0
" let g:lsp_async_completion = 1
set autowrite
map <C-n> :cnext<CR>
map <C-p> :cprevious<CR>
nnoremap <leader>a :cclose<CR>
if executable('gopls')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
  autocmd BufWritePre *.go "LspDocumentFormatSync<CR>"
endif

" Gtags
let Gtags_Auto_Map = 1

" vim-shfmt
let g:shfmt_extra_args = '-i 4'
let g:shfmt_fmt_on_save = 1

" incsearch-fuzzy.vim
map z/ <Plug>(incsearch-fuzzy-/)
map z? <Plug>(incsearch-fuzzy-?)
map zg/ <Plug>(incsearch-fuzzy-stay)

let g:lsp_diagnostics_echo_cursor = 1


" Basic
" ------------------------------

syntax enable

set title
" set modeline

set cursorline
set nocursorcolumn

set nobackup
set noswapfile

set hidden
set autoread


" Map
" ------------------------------

" ペースト範囲をビジュアル選択する
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" 日付を入力する
nmap <C-o><C-o> <ESC>i<C-R>=strftime("%Y-%m-%d")<CR>

" C-jでC-^とする
nnoremap <C-j> <C-^>

" 探索結果を中心とする
nmap n nzz
nmap N Nzz

" ZZ無効化
nmap ZZ <Nop>


" Display
" ------------------------------

" 行数とルーラーを表示
set number
set ruler

" 不可視文字を表示
set list listchars=tab:^_,trail:_

" 全角スペースをハイライト
scriptencoding utf-8
augroup highlightIdegraphicSpace
  autocmd!
  autocmd ColorScheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END

" colorscheme
colorscheme elflord

" Git commit で差分を表示
autocmd FileType gitcommit DiffGitCached | wincmd x | resize 10

" 最後の編集位置にカーソルを復元
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" cmdline & statusline
set cmdheight=2
set laststatus=2
let ff_type = {'dos' : 'CR+LF', 'unix' : 'LF', 'mac' : 'CR' }
set statusline=%=%m%r%h%w%{FugitiveStatusline()}[%Y,%{ff_type[&ff]}(%{&ff})][%{(&fenc!=''?&fenc:&enc)}][%03l/%03L,%03c][%02p%%]


" Code format
" ------------------------------

" Indent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=0
set autoindent
" set smartindent
set cindent
set showmatch

augroup foldmethod
  autocmd!
  autocmd FileType sh setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=0
  autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0
augroup END


" Search
" ------------------------------

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch
set wrapscan
nnoremap <ESC><ESC> :nohlsearch<CR>
