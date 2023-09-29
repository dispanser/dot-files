-- no lazy-loading b/c of shell bindings directly calling plugin from CLI
return { 'sindrets/diffview.nvim', 
  dependencies = 'nvim-lua/plenary.nvim',
  keys = { 
      { '<leader>dv', vim.cmd.DiffviewOpen, { desc = "open diff view"} },
      { '<leader>dc', vim.cmd.DiffviewClose, { desc = "close diff view"} },
      { '<leader>df', function() vim.cmd.DiffviewFileHistory('%') end, { desc = "open file history diff view"} },
      { '<leader>dh', vim.cmd.DiffviewFileHistor, { desc = "open project history diff view"} },
  }
}
