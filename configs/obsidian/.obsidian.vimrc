unmap <Space>

imap jk <Esc>
imap jw <Esc>:w<CR>
imap jq <Esc>:wq<CR>

" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk
" I like using H and L for beginning/end of line
nmap H ^
nmap L $
" Quickly remove search highlights
nmap <Space>sc :nohl
nmap <Space>pf <C-O> 
 
nmap <Space>fs :w<cr>
nmap <Space>fw :w<cr>

" Yank to system clipboard
set clipboard=unnamed
