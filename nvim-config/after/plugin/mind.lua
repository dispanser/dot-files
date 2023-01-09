mind = require('mind')
vim.keymap.set('n', '<leader>pn', mind.open_project, { desc = "open project notes" } )
vim.keymap.set('n', '<leader>pc', mind.close, { desc = "close project notes" } )
