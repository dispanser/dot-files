" map <leader>s :execute "Ack -w --type=scala " . expand("<cword>") <CR> 

" scala generally uses 2 spaces for indentation.
set expandtab
set shiftwidth=2
set tabstop=2

if !exists('g:loaded_ensime')
    finish
endif

nnoremap <buffer> <silent> <C-]> :EnDeclaration<cr>
nnoremap <buffer> <silent> <localleader>gg :EnDeclaration<cr>
nnoremap <buffer> <silent> <localleader>gs :EnDeclarationSplit<cr>
nnoremap <buffer> <silent> <localleader>gv :EnDeclarationSplit v<cr>
nnoremap <buffer> <silent> <localleader>hh :EnDocBrowse<cr>
nnoremap <buffer> <silent> <localleader>ti :EnType<cr>
nnoremap <buffer> <silent> <localleader>tt :EnInspectType<cr>
nnoremap <buffer> <silent> <localleader>tc :EnTypeCheck<cr>
nnoremap <buffer> <silent> <localleader>sp :EnShowPackage<cr>
nnoremap <buffer> <silent> <localleader>rr :EnRename<cr>
nnoremap <buffer> <silent> <localleader>ri :EnSuggestImport<cr>

"debugging
nnoremap <buffer> <silent> <localleader>db :EnDebugSetBreak<cr>
nnoremap <buffer> <silent> <localleader>dd :EnDebugStart localhost 5005<cr>
nnoremap <buffer> <localleader>dD :EnDebugStart localhost 
nnoremap <buffer> <silent> <localleader>dr :EnDebugContinue<cr>
nnoremap <buffer> <silent> <localleader>di :EnDebugStep<cr>
nnoremap <buffer> <silent> <localleader>ds :EnDebugNext<cr>
nnoremap <buffer> <silent> <localleader>do :EnDebugStepOut<cr>
nnoremap <buffer> <silent><F5> :EnDebugStep<CR>
nnoremap <buffer> <silent><F6> :EnDebugNext<CR>
nnoremap <buffer> <silent><F7> :EnDebugStepOut<CR>
nnoremap <buffer> <silent><F8> :EnDebugContinue<CR>
nnoremap <buffer> <silent> <localleader>dt :EnDebugBacktrace<cr>

autocmd BufWritePost *.scala silent :EnTypeCheck

" nnoremap <buffer> <silent> <localleader>ss :EnSearch expand('<cword>')<CR> 
" nnoremap <buffer> <silent> <localleader>ee :echo expand('<cword>')<CR> 

func! GetTestFile() 
  let dir = substitute(expand('%:h'), "main", "test", "")
  let base = expand('%:t:r')
  let ext = expand('%:e')
  return l:dir . '/'  . l:base . 'Test' . '.' . l:ext
endfunc

