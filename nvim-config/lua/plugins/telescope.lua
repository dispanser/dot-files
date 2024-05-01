return {
  'nvim-telescope/telescope.nvim', branch = '0.1.x',
  dependencies = { 
    'nvim-lua/plenary.nvim',
    'AckslD/nvim-neoclip.lua',
    "debugloop/telescope-undo.nvim",
    "nvim-telescope/telescope-dap.nvim",
  },
  config = function()
    require("telescope").setup({
      -- the rest of your telescope config goes here
      defaults = {
        cache_picker = {
          num_pickers = 20,
        },
        layout_strategy = 'flex',
        layout_config = {
          vertical = { width = 0.9 },
          flex = {
            flip_columns = 150,
            vertical = { width = 0.9 },
          },
          -- other layout configuration here
        },
        pickers = {
          find_files = {
            find_command="rg,--ignore,--files prompt_prefix=🔍"
          }
        },
      },
      extensions = {
        undo = {
          -- telescope-undo.nvim config, see below
        },
        -- other extensions:
        -- file_browser = { ... }
      },
    })
    require('telescope').load_extension('dap')
    require("telescope").load_extension("undo")
    vim.keymap.set("n", "<leader>tu", "<cmd>Telescope undo<cr>")
  end,
  lazy = false,
}

