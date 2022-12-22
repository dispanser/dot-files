local function nnoremap (key, action, desc)
	vim.keymap.set('n', key, action, { noremap = true, desc = desc })
end

local function inoremap (key, action, desc)
	vim.keymap.set('i', key, action, { noremap = true, desc = desc })
end

-- map the leader key
vim.keymap.set('n', '<Space>', '', {})
vim.g.mapleader = ' '  -- 'vim.g' sets global variables

-- file mappings
nnoremap('<leader>fs', ':w<cr>', "file save")
nnoremap('<leader>fq', ':wq<cr>', "file save + quit")
nnoremap('<leader>fa', ':wall<cr>', "file save all")
nnoremap('<leader>qq', ':wqa<cr>', "file save + quit all")
nnoremap('<leader><Tab>', '<C-^>', "switch to alternate buffer")

-- buffer mappings
nnoremap('<leader>bc', ':close<cr>', "close buffer")
nnoremap(']b', ':next<CR>', "next buffer")
nnoremap('[b', ':prev<CR>', "previous buffer")
nnoremap('<leader>bn', ':next<CR>', "next buffer")
nnoremap('<leader>bp', ':prev<CR>', "previous buffer")

inoremap('jk', '<Esc>', "enter normal mode")
inoremap('jw', '<Esc>:w<CR>', "leave insert mode and save")
inoremap('jq', '<Esc>:wq<CR>', "leave insert mode and save + quit")

nnoremap('<leader>w/', ':vs<CR>', "vertical split current buffer")
nnoremap('<leader>w-', ':sp<CR>', "horizontal split current buffer")
nnoremap('<leader>w=', '<C-w>=', "balance panes")
nnoremap('<leader>wH', '<C-w>H', "move current pane to the left")
nnoremap('<leader>wJ', '<C-w>J', "move current pane down")
nnoremap('<leader>wK', '<C-w>K', "move current pane up")
nnoremap('<leader>wL', '<C-w>L', "move current pane to the right")
nnoremap('<leader>wh', '<C-w>h', "go to  pane to the left")
nnoremap('<leader>wj', '<C-w>j', "go to  pane down")
nnoremap('<leader>wk', '<C-w>k', "go to  pane up")
nnoremap('<leader>wl', '<C-w>l', "go to  pane to the right")

nnoremap('<leader>sc', ':nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>', "clear search")
nnoremap('<Leader>t-', ':let &scrolloff=999-&scrolloff<CR>', "toggle centered mode")
nnoremap('<leader>tl', ':ToggleBlameLine<CR>', "toggle blame line")
nnoremap('<leader>tp', ':set pastetoggle<CR>', "toggle paste")
nnoremap('<leader>tr', ':set relativenumber!<CR>', "toggle relative line numbers")
nnoremap('<leader>tc', ':set cursorcolumn!<CR>', "toggle cursorcolumn")
nnoremap('<leader>tw', ':set wrap!<CR>', "toggle line wrap")

