regular_scheme = 'gruvbox' -- vim.cmd.colorscheme()
diff_scheme = 'solarized8_dark_high'
activate = function (f) 
  vim.cmd.colorscheme(diff_scheme) 
  f()
end

-- no lazy-loading b/c of shell bindings directly calling plugin from CLI
return { 'sindrets/diffview.nvim', 
  dependencies = 'nvim-lua/plenary.nvim',
  keys = { 
      { '<leader>dv', vim.cmd.DiffviewOpen, desc = "open diff view" },
      { '<leader>dc', vim.cmd.DiffviewClose, desc = "close diff view" },
      { '<leader>dh', function() vim.cmd.DiffviewFileHistory('%') end, desc = "open file history diff view" },
      { '<leader>dH', vim.cmd.DiffviewFileHistory, desc = "open project history diff view" },
  },
  lazy = false,
}

