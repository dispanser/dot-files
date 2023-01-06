" comment line via %
nmap <leader>cc I%<Esc>
nmap <leader>cu 0x

" (un)comment visual selection via %
vmap <leader>cc :s@^@%@<CR>:noh<CR>
vmap <leader>cu :s@^%@@<CR>:noh<CR>


