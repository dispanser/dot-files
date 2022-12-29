local function n(key, action, desc)
  vim.keymap.set('n', key, action, { desc = desc })
end

n('<leader>gg', vim.cmd.Git, "run fugitive")
n('<leader>gc', ':Git commit<CR>', "Git commit")
n('<leader>gd', ':Git diff<CR>', "Git diff")
n('<leader>gl', ':Git log<CR>', "Git log")
-- `gp` conflicts with next hunk, which wins because n/p are for many things
n('<leader>gu', ':Git push<cr>', "Git push")
n('<leader>gr', ':Git remove<CR>', "Git remove")
