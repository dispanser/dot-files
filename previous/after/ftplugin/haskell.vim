" vim:fdm=marker
" Tab specific option - from haskell wiki {{{
set tabstop=8                   "A tab is 8 spaces
set expandtab                   "Always uses spaces instead of tabs
set softtabstop=4               "Insert 4 spaces when tab is pressed
set shiftwidth=4                "An indent is 4 spaces
set shiftround                  "Round indent to nearest shiftwidth multiple
" }}}

nnoremap <localleader>hi :Unite haskellimport<CR>p
nnoremap <localleader>hI :Unite haskellimport<CR>i
nnoremap <localleader>hh :Unite hoogle<CR>i
nnoremap <localleader>hw yiw:Unite hoogle<CR>p
nnoremap <localleader>io :InteroOpen<CR>
nnoremap <localleader>if :InteroLoadCurrentFile<CR>
nnoremap <localleader>ir :InteroReload<CR>
" nnoremap <localleader>it :InteroSetTargets<CR>
nnoremap <silent> <localleader>it <Plug>InteroGenericType

nnoremap <localleader>gd :Ghcid<CR>
nnoremap <localleader>gk :GhcidKill<CR>
nnoremap <localleader>dw :Hoogle<CR>
nnoremap <localleader>dh :Hoogle 

nnoremap gd :LspDefinition<CR>
nnoremap <localleader>la :LspCodeAction<CR>
nnoremap <localleader>lh :LspHover<CR>
" nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" nnoremap <F6> :call LanguageClient#textDocument_hover()<CR>
" nnoremap <localleader>lk :call LanguageClient#textDocument_hover()<CR>
" nnoremap <localleader>lg :call LanguageClient#textDocument_definition()<CR>
" nnoremap <localleader>lr :call LanguageClient#textDocument_rename()<CR>
" nnoremap <localleader>lf :call LanguageClient#textDocument_formatting()<CR>
" nnoremap <F7> :call LanguageClient#textDocument_references()<CR>
" nnoremap <localleader>la :call LanguageClient#textDocument_codeAction()<CR>
" nnoremap <localleader>ls :call LanguageClient#textDocument_documentSymbol()<CR>

nnoremap <localleader>ht :! hasktags --ctags .<CR>

" from: https://raw.githubusercontent.com/eborden/dotfiles/master/.vim/ftplugin/haskell.vim
let b:package_root = fnamemodify(findfile('stack.yaml', '.;'), ':p:h')
autocmd BufEnter *.hs exec 'lcd ' . b:package_root

" ALE
let b:ale_linters = ['hlint']
" let b:ale_fixers = ['hlint', 'stylish-haskell']
let b:ale_fixers = ['stylish-haskell']
let b:ale_haskell_hlint_executable='stack'
let b:ale_haskell_stylish_haskell_executable='stack'

" Tags
let b:ctags_command = 'find -name "*.hs" -exec fast-tags -v {} +'
let b:fzf_tags_command = 'fast-tags -v'
