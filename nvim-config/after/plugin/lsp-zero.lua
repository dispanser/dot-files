local lsp = require('lsp-zero')

lsp.preset('recommended')

lsp.setup()

-- require('lspconfig').rust_analyzer.setup({})
require('lspconfig').metals.setup({})
require('lspconfig').jsonls.setup({})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  -- tp::TODO: check if that's better
  severity_sort = true,
  float = true,
})

local cmp = require('cmp')
local cmp_config = lsp.defaults.cmp_config({
  window = {
    completion = cmp.config.window.bordered()
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-g>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
    }, {
      { name = 'buffer' },
    })
})


local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({name = 'DiagnosticSignError', text = '✘'})
sign({name = 'DiagnosticSignWarn', text = '▲'})
sign({name = 'DiagnosticSignHint', text = '⚑'})
sign({name = 'DiagnosticSignInfo', text = ''})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

local function n(key, action, desc)
  local bufopts = { noremap=true, silent=true, buffer=bufnr, desc = desc }
  vim.keymap.set('n', key, action, bufopts)
end

n('<leader>ek', vim.lsp.buf.hover, "hover")
n('<leader>es', vim.lsp.buf.signature_help, "show signature help")
n('<leader>ew', vim.diagnostic.open_float, "open diagnostic float")
n('<leader>ea', vim.lsp.buf.code_action, "code actions" )
n('<leader>ef', function() vim.lsp.buf.format { async = true } end, "code format")
n('<leader>en', vim.lsp.buf.rename, "refactor: rename")
n('[e', vim.diagnostic.goto_prev)
n(']e', vim.diagnostic.goto_next)

vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

cmp.setup(cmp_config)

require('luasnip.loaders.from_snipmate').lazy_load()
