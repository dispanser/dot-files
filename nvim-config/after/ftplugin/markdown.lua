-- Only for markdown buffers
vim.opt_local.textwidth = 100 -- pick your preferred width (>80)
vim.opt_local.colorcolumn = '100'
vim.opt_local.wrap = true
vim.opt_local.linebreak = true

-- Auto-wrap while typing at textwidth
vim.opt_local.formatoptions:append('t')
