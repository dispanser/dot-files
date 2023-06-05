local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.nvim_workspace()
lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  float = true,
})

local cmp = require('cmp')
local cmp_config = lsp.defaults.cmp_config({
  window = {
    completion = cmp.config.window.bordered()
  }
})

local function n(key, action, desc)
  local bufopts = { noremap=true, silent=true, buffer=bufnr, desc = desc }
  vim.keymap.set('n', key, action, bufopts)
end


n('<space>ea', vim.lsp.buf.code_action, "code actions" )
n('<space>ef', function() vim.lsp.buf.format { async = true } end, "code format")
n('<leader>en', vim.lsp.buf.rename, "refactor: rename")
n('[e', vim.diagnostic.goto_prev)
n(']e', vim.diagnostic.goto_next)
n('gd', vim.lsp.buf.definition)
--n('gl', vim.diagnostic.open_float)

vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

cmp.setup(cmp_config)

require('luasnip.loaders.from_snipmate').lazy_load()
