local actions = require("diffview.actions")
require("diffview").setup({
  keymaps = {
    view = {
      -- Disable the default normal mode mapping for `<leader>e which is in conflict with our LSP-related bindings`:
      { 'n', '<leader>e',  false },
      { 'n', '<leader>dt', actions.toggle_files, desc = 'toggle diff view file pane' },
    },
    file_panel = {
      { 'n', '<leader>b',  false },
      { 'n', '<leader>df', actions.focus_files, desc = 'focus fils pane'},
      { 'n', 'R',          false },
      { 'n', '<leader>dr', actions.refresh_files, desc = 'refresh diff view' },
      { 'n', '<leader>e',  false },
      { 'n', '<leader>dt', actions.toggle_files, desc = 'toggle diff view file pane' },
    },
    file_history_panel = {
      { 'n', '<leader>b',  false },
      { 'n', '<leader>df', actions.focus_files, desc = 'focus fils pane'},
    },
  },
})
