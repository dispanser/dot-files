vim.keymap.set('n', '<leader>dv', vim.cmd.DiffviewOpen, { desc = "open diff view"} )
vim.keymap.set('n', '<leader>dc', vim.cmd.DiffviewClose, { desc = "close diff view"} )
vim.keymap.set('n', '<leader>df', function() vim.cmd.DiffviewFileHistory('%') end, { desc = "open file history diff view"} )
vim.keymap.set('n', '<leader>dh', vim.cmd.DiffviewFileHistor, { desc = "open project history diff view"} )
