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
-- used to be ',', but that clashes with flash.nvim <previous> somehow,
-- and we also currently don't define any mapping utilizing `<LocalLeader>`
vim.g.maplocalleader = ' '  -- 'vim.g' sets global variables

require('lazy').setup('plugins')

vim.cmd [[
  colorscheme gruvbox
]]

