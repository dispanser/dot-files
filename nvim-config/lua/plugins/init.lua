-- TODO: lazy = false indicates that I _want_ true, but setup needs to change
return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    requires = {
      "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    },
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      logger = {
        file_log_level = vim.log.levels.INFO,
        print_log_level = vim.log.levels.DEBUG,
      },
    },
  },
  {
    "juacker/git-link.nvim",
    keys = {
      {
        "<leader>gu",
        function() require("git-link.main").copy_line_url() end,
        desc = "Copy code link to clipboard",
        mode = { "n", "x" }
      },
      {
        "<leader>go",
        function() require("git-link.main").open_line_url() end,
        desc = "Open code link in browser",
        mode = { "n", "x" }
      },
    },
  },
  {
    'kevinhwang91/nvim-ufo', dependencies = 'kevinhwang91/promise-async'
  },
  { 'wellle/targets.vim' },
  { 'HiPhish/rainbow-delimiters.nvim' },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ---@module 'render-markdown'
    ft = { "markdown", "codecompanion" },
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    opts = {
      on_attach = function(bufnr)
        local map = vim.keymap.set
        local opts = { buffer = bufnr }
        map({ 'n', 'i' }, '<M-l><M-o>', '<Cmd>MDListItemBelow<CR>', opts)
        map({ 'n', 'i' }, '<M-L><M-O>', '<Cmd>MDListItemAbove<CR>', opts)
        map({ 'n', 'i' }, '<M-Return>', '<Cmd>MDTaskToggle<CR>', opts)
        map('x', '<M-Return>', ':MDTaskToggle<CR>', opts)
      end,
    },
  },
  {
    'kwkarlwang/bufresize.nvim',
    config = function()
      require("bufresize").setup()
    end,
  },
  {
    'moll/vim-bbye',
    keys = {
      { '<leader>bc', ':Bdelete<cr>',  desc = "close file shown in buffer" },
      { '<leader>bx', ':Bwipeout<cr>', desc = "wipe file shown in buffer" },
    },
  },
  { "catppuccin/nvim",         name = "catppuccin", priority = 1000 },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'rebelot/kanagawa.nvim',
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
        { "<leader>a", group = "aider" },
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code companion" },
        { "<leader>D", group = "debug" },
        { "<leader>d", group = "diff view" },
        { "<leader>e", group = "code" },
        { "<leader>f", group = "files" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "various telescopes" },
        { "<leader>o", group = "navigate notes" },
        { "<leader>p", group = "project" },
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
      })
    end
  },
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
  {
    'blueyed/vim-diminactive',
    keys = {
      { '<leader>ti', vim.cmd.DimInactiveToggle, desc = "toggle inactive dim" },
    },
    lazy = false,
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
      { '<leader>]',  vim.cmd.AerialNext,       desc = "aerial next token" },
      { '<leader>[',  vim.cmd.AerialPrev,       desc = "aerial previous token" },
      { ')',          vim.cmd.AerialNext,       desc = "aerial next token" },
      { '(',          vim.cmd.AerialPrev,       desc = "aerial previous token" },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
    init = function()
      require('lualine').setup()
    end,
  },
  { 'stevearc/dressing.nvim',  lazy = false },
  { 'tveskag/nvim-blame-line', lazy = false },
  { 'sheerun/vim-polyglot',    lazy = false },
  { 'tpope/vim-fugitive',      lazy = false },
  {
    'mbbill/undotree',
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
    config = function()
      require("various-textobjs").setup({ useDefaultKeymaps = true })
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({})
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } }
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup(
        -- {
        --   icons = {
        --     expanded = "⯆",
        --     collapsed = "⯈",
        --     circular = "↺"
        --   },
        --   mappings = {
        --     expand = "<CR>",
        --     open = "o",
        --     remove = "d"
        --   },
        --   sidebar = {
        --     elements = {
        --       elements.SCOPES,
        --       elements.STACKS,
        --       elements.WATCHES
        --     },
        --     width = 40,
        --     position = "left"
        --   },
        --   tray = {
        --     elements = {
        --       elements.REPL
        --     },
        --     height = 10,
        --     position = "bottom"
        --   }
        -- }
        -- {
        -- layouts = {
        --   {
        --     elements = {
        --       { id = "stacks", size = 0.5 },
        --       { id = "scopes", size = 0.5 },
        --     },
        --     position = "bottom",
        --     size = 15,
        --   },
        -- },
      -- }
      )
    end,
    keys = {
      { '<leader>Du', function() require('dapui').toggle() end, desc = "[dap] toggle ui" },
      { '<leader>dc', function() require('dap').toggle_breakpoint() end, "[dap] toggle breakpoint" },
      { '<leader>db', function()
        require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, "[dap] set breakpoint condition" },
      { '<leader>dl', function() require('dap').repl.run_last() end,     "[dap] open repl" },
      { '<leader>dr', function() require('dap').continue() end,          "[dap] continue" },
      { '<leader>dR', function() require('dap').reverse_continue() end,  "[dap] reverse continue" },
      { '<leader>do', function() require('dap').step_over() end,         "[dap] step over" },
      { '<M-Space>',  function() require('dap').step_over() end,         "[dap] step over" },
      { '<leader>di', function() require('dap').step_into() end,         "[dap] step into" },
      { '<M-CR>',     function() require('dap').step_into() end,         "[dap] step into" },
      { '<leader>dO', function() require('dap').step_out() end,          "[dap] step out" },
      { '<M-BS>',     function() require('dap').step_out() end,          "[dap] step out" },
      { '<leader>dd', function() require('dap').disconnect() end,        "[dap] disconnect" },
      { '<leader>dx', function() require('dap').terminate() end,         "[dap] terminate" },
      { '<leader>dk', function() require('dapui').eval() end,            "[dap] hover" },
      { '<leader>de', function()
        require('dapui').eval(vim.fn.input('evaluate: '))
      end, "[dap] eval expression" },
      { '<leader>dh', function() require('dap.ui.widgets').hover() end,    "[dap] hover" },
      { '<leader>ds', function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
      end, "[dap] scopes" },
      { '<leader>df', function() require('dapui').float_element() end,                "[dap] float" },
      { '<leader>dS', function() require('dap.ui.variables').scopes() end, "[dap] variable scopes" },
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("nvim-dap-virtual-text").setup({})
    end,
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
  },
  {
    'dhruvasagar/vim-table-mode',
    keys = {
      { '<leader>t=', ':TableModeRealign<cr>', desc = "re-align table" },
    },
  },
}
