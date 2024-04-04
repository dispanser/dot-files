local function n (key, action, desc)
  vim.keymap.set('n', key, action, { desc = desc })
end

local function v (key, action, desc)
  vim.keymap.set('v', key, action, { desc = desc })
end

local function i (key, action, desc)
  vim.keymap.set('i', key, action, { desc = desc })
end

local function nnoremap (key, action, desc)
  vim.keymap.set('n', key, action, { noremap = true, desc = desc })
end

local function tnoremap (key, action)
  vim.keymap.set('t', key, action, { noremap = true })
end

local function inoremap (key, action, desc)
  vim.keymap.set('i', key, action, { noremap = true, desc = desc })
end

-- map the leader key
vim.keymap.set('n', '<Space>', '', {})

-- file mappings
nnoremap('<leader>fs', ':w<cr>', "file save")
nnoremap('<leader>fq', ':wq<cr>', "file save + quit")
nnoremap('<leader>fa', ':wall<cr>', "file save all")
nnoremap('<leader>qq', ':wqa<cr>', "file save + quit all")
nnoremap('<leader><Tab>', '<C-^>', "switch to alternate buffer")

-- buffer mappings
nnoremap('<leader>bd', ':close<cr>', "close buffer")
nnoremap(']b', ':next<CR>', "next buffer")
nnoremap('[b', ':prev<CR>', "previous buffer")

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
nnoremap('<leader>ww', ':vertical resize ', "vertical resize window")
nnoremap('<leader>wr', ':resize ', "horizontal resize window")

tnoremap('<C-h>', '<C-\\><C-N><C-w>h')
tnoremap('<C-j>', '<C-\\><C-N><C-w>j')
tnoremap('<C-k>', '<C-\\><C-N><C-w>k')
tnoremap('<C-l>', '<C-\\><C-N><C-w>l')
inoremap('<C-h>', '<C-\\><C-N><C-w>h')
inoremap('<C-j>', '<C-\\><C-N><C-w>j')
inoremap('<C-k>', '<C-\\><C-N><C-w>k')
inoremap('<C-l>', '<C-\\><C-N><C-w>l')

vim.keymap.set('', '<M-j>', 'gT')
vim.keymap.set('', '<M-k>', 'gt')

nnoremap('<leader>sc', ':nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>', "clear search")
nnoremap('<Leader>t-', ':let &scrolloff=999-&scrolloff<CR>', "toggle centered mode")
nnoremap('<leader>tp', ':set pastetoggle<CR>', "toggle paste")
nnoremap('<leader>tr', ':set relativenumber!<CR>', "toggle relative line numbers")
nnoremap('<leader>tc', ':set cursorcolumn!<CR>', "toggle cursorcolumn")
nnoremap('<leader>tw', ':set wrap!<CR>', "toggle line wrap")

v('<leader>Y', '"*y', "yank to primary clipboard")
v('<leader>y', '"+y', "yank to system clipboard")
n('<leader>Y', '"*y', "yank to primary clipboard")
n('<leader>y', '"+y', "yank to system clipboard")
n('<leader>P', '"*p', "put from primary clipboard")
n('<leader>p', '"+p', "put from system clipboard")

-- cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
-- cnoremap <expr> %f getcmdtype() == ':' ? expand('%:t:r') : '%f'
-- cnoremap <expr> %p getcmdtype() == ':' ? expand('%:p:.') : '%p'
vim.keymap.set('c', '%%', vim.fn.expand("%:h"), {noremap = true})

-- does not seem to work
-- vim.keymap.set('c', '%_', function()
--   print (vim.fn.getcmdtype())
--   if vim.fn.getcmdtype() == ':' then
--     return vim.fn.expand("%:h") .. '/'
--   else
--     return '%%'
--   end
-- end, {noremap = true})
