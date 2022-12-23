-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
    'nvim-telescope/telescope.nvim', 
    branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use (
    'nvim-treesitter/nvim-treesitter',
    { run = ':TSUpdate' }
  )
  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
      }
    end
  }
  use 'mbbill/undotree'
  use 'tpope/vim-fugitive'
  use 'sheerun/vim-polyglot'
  use 'flazz/vim-colorschemes'
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
end)

