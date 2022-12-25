vim.keymap.set('n', '<leader>ga', ':GitGutterStageHunk<CR>', { desc = "git stage hunk" } )
vim.keymap.set('n', '<leader>gn', ':GitGutterNextHunk<CR>', { desc = "git goto next hunk" } )
vim.keymap.set('n', '<leader>gp', ':GitGutterPrevHunk<CR>', { desc = "git goto previous hunk" } )

vim.g.gitgutter_map_keys = 0
vim.g.gitgutter_preview_win_floating = 1
