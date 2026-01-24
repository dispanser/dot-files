-- no lazy-loading b/c of shell bindings directly calling plugin from CLI
return { 'sindrets/diffview.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  keys = {
      { '<leader>gv', vim.cmd.DiffviewOpen, desc = "open diff view" },
      { '<leader>gV', vim.cmd.DiffviewClose, desc = "close diff view" },
      { '<leader>ghf', function() vim.cmd.DiffviewFileHistory('%') end, desc = "open file history diff view" },
      { '<leader>ghp', vim.cmd.DiffviewFileHistory, desc = "open project history diff view" },
  },
  lazy = false,
}

