local map = vim.api.nvim_set_keymap

local noremap = { noremap = true }

local function nnoremap (key, action)
	map('n', key, action, noremap)
end

local function inoremap (key, action)
	map('i', key, action, noremap)
end

-- map the leader key
map('n', '<Space>', '', {})
vim.g.mapleader = ' '  -- 'vim.g' sets global variables

-- map('n', '<leader>qq', ':wqa<cr>', {})
nnoremap('<leader>fs', ':w<cr>')
nnoremap('<leader>fw', ':w<cr>')
nnoremap('<leader>fc', ':close<cr>')
nnoremap('<localleader>d', ':close<cr>')
nnoremap('<leader>fq', ':wq<cr>')
nnoremap('<leader>fa', ':wall<cr>')
nnoremap('<leader>qq', ':wqa<cr>')
nnoremap('<leader>RR', ':source', '$MYVIMRC<cr>')
nnoremap(']b', ':next<CR>')
nnoremap('[b', ':prev<CR>')


inoremap('jk', '<Esc>')
inoremap('jw', '<Esc>:w<CR>')
inoremap('jq', '<Esc>:wq<CR>')

nnoremap('<leader>w/', ':vs<CR>')
nnoremap('<leader>w-', ':sp<CR>')
nnoremap('<leader>w=', '<C-w>=')
nnoremap('<leader>wH', '<C-w>H')
nnoremap('<leader>wJ', '<C-w>J')
nnoremap('<leader>wK', '<C-w>K')
nnoremap('<leader>wL', '<C-w>L')

-- fugitives
nnoremap('<leader>gg', ':Git<CR>')
nnoremap('<leader>gc', ':Git commit<CR>')
nnoremap('<leader>gd', ':Git diff<CR>')
nnoremap('<leader>gl', ':Git log<CR>')
nnoremap('<leader>gp', ':Git push<cr>')
nnoremap('<leader>gr', ':Git remove<CR>')
nnoremap('<leader>gt', ':Git status<CR>')
nnoremap('<leader>ga', ':GitGutterStageHunk<CR>')
nnoremap(']h', ':GitGutterNextHunk<CR>')
nnoremap('[h', ':GitGutterPrevHunk<CR>')
