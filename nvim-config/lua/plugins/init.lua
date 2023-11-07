-- TODO: lazy = false indicates that I _want_ true, but setup needs to change
return {
  -- https://github.com/wellle/targets.vim
  {'wellle/targets.vim'},
  {'kwkarlwang/bufresize.nvim',
    config = function()
        require("bufresize").setup()
    end,
  },
  -- keys defined in remaps because of lack of description
  { 'moll/vim-bbye',
    keys = {
        { '<leader>bc', ':Bdelete<cr>', desc = "close file shown in buffer" },
        { '<leader>bw', ':Bwipeout<cr>', desc = "wipe file shown in buffer" },
      },
  },
  { 'flazz/vim-colorschemes',
    -- color scheme determines highlight groups that should be loaded first
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('gruvbox')
      -- vim.cmd [[ colorscheme gruvbox ]]
    end,
  },
  {
    "folke/which-key.nvim",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = function()
      require("which-key").register({
          ["<leader>b"] = { name = "+buffers" },
          ["<leader>d"] = { name = "+diff view" },
          ["<leader>e"] = { name = "+code" },
          ["<leader>f"] = { name = "+files" },
          ["<leader>g"] = { name = "+git" },
          ["<leader>l"] = { name = "+various telescopes" },
          ["<leader>q"] = { name = "+quickfix" },
          ["<leader>t"] = { name = "+toggles" },
          ["<leader>w"] = { name = "+windows" },
        })
    end,
    priority = 900,
  },
  'machakann/vim-highlightedyank',
  'roxma/vim-tmux-clipboard',
  'christoomey/vim-tmux-navigator',
  'nvim-tree/nvim-web-devicons',
  'tpope/vim-commentary',
  'tpope/vim-surround',
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
  { 'blueyed/vim-diminactive',
    keys = {
      { '<leader>ti', vim.cmd.DimInactiveToggle, desc = "toggle inactive dim" },
    },
    lazy = false,
  },
	{ 'machakann/vim-swap', lazy = false },
	{ 'simrat39/rust-tools.nvim', lazy = true },
	{ 'ray-x/lsp_signature.nvim', lazy = false,
    init = function()
      require "lsp_signature".setup({
          bind = true, -- This is mandatory, otherwise border config won't get registered.
          handler_opts = {
            border = "rounded"
          }
        })
    end,
  },
  {
    'stevearc/aerial.nvim',
    opts = {},
    dependencies = {
       -- "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { '<leader>ta', "<cmd>AerialToggle!<CR>", desc = "toggle aerial code outline" },
      { '<leader>]', vim.cmd.AerialNext, desc = "aerial next token" },
      { '<leader>[', vim.cmd.AerialPrev, desc = "aerial previous token" },
    },
  },
	{
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
    init = function()
      require('lualine').setup()
    end,
  },
	{ 'stevearc/dressing.nvim', lazy = false },
	{ 'tveskag/nvim-blame-line', lazy = false},
	{ 'sheerun/vim-polyglot', lazy = false },
	{ 'tpope/vim-fugitive', lazy = false },
  { 'mbbill/undotree',
    keys = {
      { '<leader>tu', vim.cmd.UndotreeToggle, desc = "toggle undo tree" },
    },
    lazy = true,
  },
  { 'RRethy/vim-illuminate' },
  -- {
  --   'nvim-treesitter/nvim-treesitter',
  --   build = function()
  --     local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
  --     ts_update()
  --   end,
  -- },
  {
    'andymass/vim-matchup',
    init = function()
      -- may set any options here
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
    lazy = true,
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    config = function () 
      require("various-textobjs").setup({ useDefaultKeymaps = true })
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({})
    end,
    dependencies = { {"nvim-tree/nvim-web-devicons"} }
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = { { "nvim-lua/plenary.nvim"  } },
  },
}

