return {
  {
    'VonHeikemen/lsp-zero.nvim',
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 
      'hrsh7th/cmp-nvim-lsp'
    },
  },
  { 
    'hrsh7th/nvim-cmp',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
      {'honza/vim-snippets'},
    },
  },
  {'hrsh7th/cmp-buffer'},
  {'hrsh7th/cmp-path'},
  {'saadparwaiz1/cmp_luasnip'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/cmp-nvim-lua'},
}
