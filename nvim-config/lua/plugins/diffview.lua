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
      { '<leader>dv', function() activate(vim.cmd.DiffviewOpen) end, desc = "open diff view" },
      { '<leader>dc', function()
          vim.cmd.colorscheme(previous) 
          vim.cmd.DiffviewClose()
        end, desc = "close diff view"
      },
      { '<leader>dh', function()
          vim.cmd.colorscheme(diff_scheme)
          vim.cmd.DiffviewFileHistory('%')
        end, desc = "open file history diff view"
      },
      { '<leader>dH', function() activate(vim.cmd.DiffviewFileHistory) end, desc = "open project history diff view" },
      { '<leader>dt', vim.cmd.DiffviewToggleFiles, desc = "toggle diff view file pane" },
      { '<leader>df', vim.cmd.DiffviewFocusFiles, desc = "focus fils pane" },
      { '<leader>df', vim.cmd.DiffviewRefresh, desc = "refresh diff view" },
  },
  lazy = false,
}

