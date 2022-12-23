" recommended by 'gh:dag/fish'
if &shell =~# 'fish$'
  set shell=zsh
endif

" vim:fdm=marker
" plugins {{{
call plug#begin('~/.local/share/nvim/plugged')

" plugins of collections of plugins :D
Plug 'sheerun/vim-polyglot'
Plug 'flazz/vim-colorschemes'

" basic plugins: don't ever go without them
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux'

Plug 'itchyny/lightline.vim'
set noshowmode " because mode's in the statusline anyway
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo', 'percent' ] ]
      \ },
      \ }

Plug 'junegunn/vim-easy-align'
Plug 'machakann/vim-highlightedyank'

Plug 'junegunn/gv.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'
Plug 'airblade/vim-gitgutter'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'

Plug 'machakann/vim-swap'
Plug 'roxma/vim-tmux-clipboard'
" supposedly allows % to work on language-specific blocks
" Plug 'andymass/vim-matchup' " not sure, don't see it.

Plug 'tveskag/nvim-blame-line'
Plug 'LnL7/vim-nix'
Plug 'pearofducks/ansible-vim', { 'do': './UltiSnips/generate.sh' }

" --- eval ---
" testing debugging:
Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh' }
call plug#end()
Plug 'neovim/nvim-lspconfig'
" }}}

let mapleader = " "

" tenzir / C++ setup: lsp, clangd
set expandtab
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=yes
else
  set signcolumn=yes
endif

set shortmess+=c
set cmdheight=2

" Add (Neo)Vim's native statusline support.
set laststatus=3

" lua: conversion {{{
lua require('plugins')
lua require('maps')
lua require('lsp')
" lua require('paq')
" }}}

" nvim-gdb {{{
" We're going to define single-letter keymaps, so don't try to define them
" in the terminal window.  The debugger CLI should continue accepting text commands.
function! NvimGdbNoTKeymaps()
  tnoremap <silent> <buffer> <esc> <c-\><c-n>
endfunction

let g:nvimgdb_config_override = {
  \ 'key_next': 'n',
  \ 'key_step': 's',
  \ 'key_finish': 'f',
  \ 'key_continue': 'c',
  \ 'key_until': 'u',
  \ 'key_breakpoint': 'b',
  \ 'set_tkeymaps': "NvimGdbNoTKeymaps",
  \ }
" }}}
" basic settings {{{
let mapleader = " "
let maplocalleader = ","

set scrolloff=5
filetype plugin on
filetype indent on

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
" Show matching brackets when text indicator is over them
set showmatch

" visual bell
set visualbell

" enable syntax highlighting
syntax on

" indentation settings
set autoindent
set smartindent
set cindent
set tabstop=2
set shiftwidth=2
set smarttab
" set nowrap
set linebreak
set sidescroll=8
" vim-rooter
let g:rooter_patterns = ['stack.yaml', '.git/', 'compile_commands.json']

map <F1> <Esc>
imap <F1> <Esc>

" Move by line
nnoremap j gj
nnoremap k gk

" Use K to show documentation in preview window. TODO: not working
" nnoremap <silent> K :call <SID>show_documentation()<CR>

" }}}
" fuzzy finder / fzf configuration {{{
" mnemonic: p --> project; b --> buffer
nnoremap <leader>pf :Files<CR>
nnoremap <leader>pg :GFiles<CR>
nnoremap <leader>pr :History<CR>
nnoremap <leader>pa :Rg<CR>
nnoremap <silent> <leader>pw :Rg <C-R><C-W><CR>
nnoremap <leader>pl :Lines<CR>
nnoremap <leader>pt :Tags<CR>
nnoremap <leader>pd :Tags <C-R><C-W><CR>
nnoremap <leader>pc :Commits<CR>
" git status
nnoremap <leader>ps :GFiles?<CR>

nnoremap <leader>bb :Buffers<CR>
nnoremap <leader>bt :BTags<CR>
nnoremap <leader>bl :BLines<CR>
nnoremap <silent> <leader>bw :BLines <C-R><C-W><CR>
nnoremap <leader>bc :BCommits<CR>
nnoremap <leader>hc :History:<CR>
nnoremap <leader>h/ :History/<CR>

" let g:fzf_layout = { 'window': 'enew' }
command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>,
  \                 <bang>0 ? fzf#vim#with_preview('up:60%')
  \                         : fzf#vim#with_preview('right:50%', '?'),
  \                 <bang>0)
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
" }}}

" visuals {{{
set background=dark
set termguicolors
set t_Co=256
let g:solarized_termtrans = 1
colorscheme solarized8_dark

set nocompatible
set relativenumber
" number is still required to show absolute for the current line.
set number
set cursorline
" set cursorcolumn
set enc=utf-8

" from: https://begriffs.com/posts/2019-07-19-history-use-vim.html
set swapfile
set directory^=~/.vim/swap//

" use rename-and-write-new method whenever safe
set backupcopy=auto
" patch required to honor double slash at end
if has("patch-8.1.0251")
	" consolidate the writebackups -- not a big
	" deal either way, since they usually get deleted
	set backupdir^=~/.vim/backup//
end

" persist the undo tree for each file
set undofile
set undodir^=~/.vim/undo// path=**

set nobackup
set nowritebackup
set noswapfile
set wildignore+=*.pyc,*.class,.hg/
set hidden

" smartcase + ignorecase: use ignorecase only when search term is all-lower.
set ignorecase
set smartcase

" let g:airline_theme='solarized'
" }}}
" fugitive / diff keybindings {{{
set diffopt+=iwhite

map <Leader>1 :diffget LOCAL<CR>
map <Leader>2 :diffget BASE<CR>
map <Leader>3 :diffget REMOTE<CR>
" }}}
" keybindings save / quit / reload / window management {{{

" nnoremap <leader>fs :w<cr>
" nnoremap <leader>fw :w<cr>
" nnoremap <leader>fc :close<cr>
" nnoremap <localleader>d :close<cr>
" nnoremap <leader>fq :wq<cr>
" nnoremap <leader>qq :wqa<cr>
nnoremap <leader>RR :source $MYVIMRC<cr>
" nnoremap <leader>]b :next<CR>
" nnoremap <leader>[b :prev<CR>

" inoremap jk <Esc>
" inoremap jw <Esc>:w<CR>
" inoremap jq <Esc>:wq<CR>

" nnoremap <leader>w/ :vs<CR>
" nnoremap <leader>w- :sp<CR>
" nnoremap <leader>w= <C-w>=
" nnoremap <leader>wH <C-w>H
" nnoremap <leader>wJ <C-w>J
" nnoremap <leader>wK <C-w>K
" nnoremap <leader>wL <C-w>L

nnoremap <silent> <leader>sc :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>
nnoremap <silent> <Leader>t- :let &scrolloff=999-&scrolloff<CR>
nnoremap <silent> <leader>tl :ToggleBlameLine<CR>
nnoremap <silent> <leader>tp :set pastetoggle<CR>
nnoremap <silent> <leader>tr :set relativenumber!<CR>
nnoremap <silent> <leader>tc :set cursorcolumn!<CR>
nnoremap <silent> <leader>tw :set wrap!<CR>
nnoremap <silent> <leader>td :colorscheme solarized8_dark<CR>
nnoremap <silent> <leader>tD :colorscheme solarized8_light<CR>

" }}}
" keybindings: navigate buffers and location lists {{{
map <leader><Tab> <C-^>
map <M-space> <C-^>

" nnoremap <Tab> za
" }}}
" terraform {{{
let g:terraform_align=1
let g:terraform_fold_sections=0
let g:terraform_fmt_on_save=1
autocmd BufRead,BufNewFile *.hcl set filetype=terraform
" }}}
" nerdtree {{{
nnoremap <leader>nf :NERDTreeFind<CR>
nnoremap <leader>nt :NERDTree<CR>
" }}}
" tagbar {{{
" tagbar: open tagbar, jump to it, and close after jumping back to editor
nnoremap <leader>tb :TagbarOpen fjc<CR>
" tagbar: open. if already open, jump to it instead.
nnoremap <leader>tt :TagbarOpen j<CR>
let g:tagbar_left = 1
" }}}
" forwards and backwards {{{
nnoremap [E :cfirst<CR>
nnoremap ]e :cnext<CR>
nnoremap [e :cprevious<CR>
nnoremap ]E :clast<CR>
nnoremap [L :lfirst<CR>
nnoremap ]l :lnext<CR>
nnoremap [l :lprevious<CR>
nnoremap ]L :llast<CR>
" }}}
" easy-align {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}}
" keybindings for layout (window navigation, tabs, ...) {{{
" mnemonics: higher, lower, wider, slimmer
nnoremap <leader>rh 5<C-W>+
nnoremap <leader>rH 50<C-W>+
nnoremap <leader>rl 5<C-W>-
nnoremap <leader>rL 50<C-W>-
nnoremap <leader>rw 5<C-W>>
nnoremap <leader>rW 50<C-W>>
nnoremap <leader>rs 5<C-W><
nnoremap <leader>rS 50<C-W><
nnoremap <leader>vv :vertical resize
nnoremap <leader>rr :resize
nnoremap <leader>vs :vertical resize 50<CR>
nnoremap <leader>vm :vertical resize 90<CR>
nnoremap <leader>vl :vertical resize 120<CR>
nnoremap <leader>vx :vertical resize 200<CR>
nnoremap <leader>hs :resize 8<CR>
nnoremap <leader>hm :resize 16<CR>
nnoremap <leader>hl :resize 32<CR>
nnoremap <leader>hx :resize 64<CR>
" }}}
" file path based expansions {{{
" practical vim: %% in command mode to expand path of current file
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
cnoremap <expr> %f getcmdtype() == ':' ? expand('%:t:r') : '%f'
cnoremap <expr> %p getcmdtype() == ':' ? expand('%:p:.') : '%p'
"
" insert current file name (no ending)
inoremap <C-i>fn <C-R>=expand("%:t:r")<CR>
inoremap <C-i>pk <C-R>=expand("%:h")<CR>

" }}}
" clipboard settings: yank, paste w/ clipboard {{{
" set clipboard^=autoselect " not working in neovim (see https://github.com/neovim/neovim/issues/2325)
vmap <leader>Y "*y
map <leader>Y "*y
map <leader>P "*p
vmap <leader>y "+y
map <leader>y "+y
map <leader>p "+p
map <leader>aP :%y*<CR>
map <leader>ap :%y+<CR>
" }}}
" pandoc configuration {{{
let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
" }}}
