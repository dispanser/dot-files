require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "help", "lua", "rust", "vim", "fish" },
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript", "help" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>", -- set to `false` to disable one of the mappings
      node_incremental = "<CR>",
      scope_incremental = "<C-s>",
      node_decremental = "<BS>",
    },
  },
  -- textsubjects = {
  --     enable = true,
  --     prev_selection = ',', -- (Optional) keymap to select the previous selection
  --     keymaps = {
  --         ['.'] = 'textsubjects-smart',
  --         [';'] = 'textsubjects-container-outer',
  --         ['i;'] = 'textsubjects-container-inner',
  --         ['i;'] = { 'textsubjects-container-inner', desc = "Select inside containers (classes, functions, etc.)" },
  --     },
  -- },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["aa"] = "@assignment.outer",
        ["ai"] = "@assignment.inner",
        ["al"] = "@assignment.lhs",
        ["ar"] = "@assignment.rhs",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
        ["ac"] = "@call.outer",
        ["ic"] = "@call.inner",
        ["co"] = "@conditional.outer",
        ["ci"] = "@conditional.inner",
        ["os"] = "@statement.outer",
        ["pi"] = "@parameter.inner",
        ["pa"] = "@parameter.outer",
        -- candidates: @parameter.inner, @parameter.outer, number.inner
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        -- ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@function.outer'] = 'V', -- linewise
        ['@block.outer'] = 'V', -- linewise
        ['@conditional.outer'] = 'V',
        -- ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true or false
      include_surrounding_whitespace = true,
    },
    move = {
      enable = true,
      set_jumps = false,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]c"] = "@call.outer",
        ["]a"] = "@parameter.inner",
        ["]s"] = "@statement.outer",
        ["]M"] = "@function.inner",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[c"] = "@call.outer",
        ["[a"] = "@parameter.inner",
        ["[s"] = "@statement.outer",
        ["[M"] = "@function.inner",
        ["[["] = { query = "@class.outer", desc = "Next class start" },
      },
    },
    lsp_interop = {
      enable = true,
      border = 'none',
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>df"] = "@function.outer",
        ["<leader>dF"] = "@class.outer",
      },
    },
  },
}

-- from https://github.com/nvim-treesitter/nvim-treesitter-textobjects
local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false;
