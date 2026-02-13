local function n(key, action, desc)
  vim.keymap.set('n', key, action, { desc = desc })
end

n('<leader>gc', ':Git commit<CR>', "Git commit")
n('<leader>gl', ':Git log<CR>', "Git log")
n('<leader>gP', ':Git push<cr>', "Git push")
n('<leader>gr', ':Git rm %%', "Git remove")
