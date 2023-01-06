vim.cmd [[
  autocmd BufEnter * EnableBlameLine
]]
vim.keymap.set('n', '<leader>tl', vim.cmd.ToggleBlameLine, { desc = "toggle blame line" } )
