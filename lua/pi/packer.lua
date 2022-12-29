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
  use 'airblade/vim-gitgutter'
  use 'sheerun/vim-polyglot'
  use 'flazz/vim-colorschemes'
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  use {
    'andymass/vim-matchup',
    setup = function()
      -- may set any options here
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end
  }
  use 'tveskag/nvim-blame-line'
  use 'machakann/vim-highlightedyank'
  use 'roxma/vim-tmux-clipboard'
  use 'christoomey/vim-tmux-navigator'
  use 'tmux-plugins/vim-tmux'
  use 'tpope/vim-commentary'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'tpope/vim-unimpaired'
  use 'svermeulen/vim-yoink'
  use 'machakann/vim-swap'
  use {
    "chrisgrieser/nvim-various-textobjs",
    config = function () 
      require("various-textobjs").setup({ useDefaultKeymaps = true })
    end,
  }
end)

