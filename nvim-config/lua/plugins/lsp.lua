return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },
  },
  {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    opts = {}, -- required, even if empty
    },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      { 'L3MON4D3/LuaSnip' },
      { 'honza/vim-snippets' },
      { 'zjp-CN/nvim-cmp-lsp-rs' },
    },
  },
  { 'zjp-CN/nvim-cmp-lsp-rs' },
  { 'andersevenrud/cmp-tmux' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-nvim-lua' },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require('rustaceanvim.neotest')
        },
      }
    end
  },
}
