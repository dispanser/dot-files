" recommended by 'gh:dag/fish'
if &shell =~# 'fish$'
  set shell=zsh
endif

" vim:fdm=marker
" plugins {{{
call plug#begin('~/.local/share/nvim/plugged')

" basic plugins: don't ever go without them
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
Plug 'airblade/vim-rooter'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'

Plug 'machakann/vim-swap'
Plug 'roxma/vim-tmux-clipboard'

Plug 'LnL7/vim-nix'
Plug 'pearofducks/ansible-vim', { 'do': './UltiSnips/generate.sh' }

" --- eval ---
" testing debugging:
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
lua require('lsp')
" }}}

" basic settings {{{

filetype plugin on
filetype indent on

" TODO: figure out what that actually does
set whichwrap+=<,>,h,l


" visual bell
set visualbell

" set nowrap
set linebreak
set sidescroll=8
" vim-rooter
let g:rooter_patterns = ['stack.yaml', '.git/', 'compile_commands.json']

" Move by line
nnoremap j gj
nnoremap k gk

" Use K to show documentation in preview window. TODO: not working
" nnoremap <silent> K :call <SID>show_documentation()<CR>

" }}}

" visuals {{{
set background=dark
set termguicolors
set t_Co=256
let g:solarized_termtrans = 1
colorscheme solarized8_dark

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

set nobackup
set nowritebackup
set noswapfile
set wildignore+=*.pyc,*.class,.hg/

" let g:airline_theme='solarized'
" }}}

set diffopt+=iwhite


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
" }}}
