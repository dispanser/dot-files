local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '  -- 'vim.g' sets global variables
vim.g.maplocalleader = ','  -- 'vim.g' sets global variables

require('lazy').setup('plugins')

vim.cmd [[
  colorscheme gruvbox
]]


-- to be configured separately (have their own config):
  -- use 'svermeulen/vim-yoink'
  --

-- skipped (not deemeed useful enough):
-- use 'tmux-plugins/vim-tmux'
-- use 'mfussenegger/nvim-dap'
-- use 'mfussenegger/nvim-jdtls'
