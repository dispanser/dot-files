-- TODO: lazy = false indicates that I _want_ true, but setup needs to change
return {
  -- https://github.com/wellle/targets.vim
  {
    'kevinhwang91/nvim-ufo', dependencies = 'kevinhwang91/promise-async'
  },
  {'wellle/targets.vim'},
  {'HiPhish/rainbow-delimiters.nvim'},
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    opts = {
      on_attach = function(bufnr)
        local map = vim.keymap.set
        local opts = { buffer = bufnr }
        map({'n', 'i'}, '<M-l><M-o>', '<Cmd>MDListItemBelow<CR>', opts)
        map({'n', 'i'}, '<M-L><M-O>', '<Cmd>MDListItemAbove<CR>', opts)
        map({'n', 'i'}, '<M-Return>', '<Cmd>MDTaskToggle<CR>', opts)
        map('x', '<M-Return>', ':MDTaskToggle<CR>', opts)
      end,
    },
  },
  {'kwkarlwang/bufresize.nvim',
    config = function()
        require("bufresize").setup()
    end,
  },
  { 'moll/vim-bbye',
    keys = {
        { '<leader>bc', ':Bdelete<cr>', desc = "close file shown in buffer" },
        { '<leader>bx', ':Bwipeout<cr>', desc = "wipe file shown in buffer" },
      },
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  { 'rebelot/kanagawa.nvim',
    -- color scheme determines highlight groups that should be loaded first
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('kanagawa')
    end,
  },
  {
    "folke/which-key.nvim",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = function()
      require("which-key").add({
          { "<leader>b", group = "buffers" },
          { "<leader>d", group = "diff view" },
          { "<leader>e", group = "code" },
          { "<leader>f", group = "files" },
          { "<leader>g", group = "git" },
          { "<leader>l", group = "various telescopes" },
          { "<leader>q", group = "quickfix" },
          { "<leader>t", group = "toggles" },
          { "<leader>w", group = "windows" },
        })
    end,
    priority = 900,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  },
  'machakann/vim-highlightedyank',
  'roxma/vim-tmux-clipboard',
  'christoomey/vim-tmux-navigator',
  'nvim-tree/nvim-web-devicons',
  'tpope/vim-commentary',
  'tpope/vim-rsi',
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
  },
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
  { 'blueyed/vim-diminactive',
    keys = {
      { '<leader>ti', vim.cmd.DimInactiveToggle, desc = "toggle inactive dim" },
    },
    lazy = false,
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^4', -- Recommended
    lazy = false, -- This plugin is already lazy
  },
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
        -- ...,
        adapters = {
          -- ...,
          require('rustaceanvim.neotest')
        },
      }
    end
  },
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
      { ')', vim.cmd.AerialNext, desc = "aerial next token" },
      { '(', vim.cmd.AerialPrev, desc = "aerial previous token" },
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
      { '<leader>tU', vim.cmd.UndotreeToggle, desc = "toggle undo tree" },
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

  { "rcarriga/nvim-dap-ui", 
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = function()
      require("dapui").setup({
          layouts = { 
            {
              elements = {
                { id = "stacks", size = 0.5 },
                { id = "scopes", size = 0.5 },
              },
              position = "bottom",
              size = 15,
            },
          },
        })
    end,
    keys = {
      { '<leader>cu', function() require('dapui').toggle() end, desc = "[dap] toggle ui" },
    },
  },
  { "theHamsta/nvim-dap-virtual-text",
    dependencies = { "nvim-lua/plenary.nvim"  },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { "nvim-lua/plenary.nvim"  },
    },
  },
  {
    'dhruvasagar/vim-table-mode',
    keys = {
        { '<leader>t=', ':TableModeRealign<cr>', desc = "re-align table" },
      },
  },
  -- {
  --   "j-hui/fidget.nvim",
  --   opts = {
  --     -- options
  --   },
  -- },
}
