-- This should be executed before you configure any language server

local lspconfig = require('lspconfig')
local lspconfig_defaults = lspconfig.util.default_config

lspconfig_defaults.capabilities = vim.tbl_deep_extend(
-- Add cmp_nvim_lsp capabilities settings to lspconfig
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = true,
  },
})

sign({name = 'DiagnosticSignError', text = '✘'})
sign({name = 'DiagnosticSignWarn', text = '▲'})
sign({name = 'DiagnosticSignHint', text = '⚑'})
sign({name = 'DiagnosticSignInfo', text = ''})

local function o(buf, desc)
  return { noremap=true, silent=true, buffer=buf, desc = desc }
end

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local s = vim.keymap.set
    local builtin = require('telescope.builtin')

    s('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', o(event.buf, 'hover'))
    s('n', '<leader>ek', '<cmd>lua vim.lsp.buf.hover()<cr>', o(event.buf, 'hover'))
    s('n', 'gd', builtin.lsp_definitions, o(event.buf, '[lsp] go to definition'))
    s('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', o(event.buf, '[lsp]: go to declaration'))
    s('n', 'gt', builtin.lsp_type_definitions, o(event.buf, '[lsp]: go to type definition'))

    s('n', '<leader>em', builtin.lsp_implementations, o(event.buf, '[lsp]: go to implementation'))
    s('n', '<leader>es', '<cmd>lua vim.lsp.buf.signature_help()<cr>', o(event.buf, '[lsp]: show signature'))
    s('n', '<leader>en', '<cmd>lua vim.lsp.buf.rename()<cr>', o(event.buf, '[lsp]: rename'))
    s({'n', 'x'}, '<leader>ef', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', o(event.buf, '[lsp]: format'))
    s('n', '<leader>ea', '<cmd>lua vim.lsp.buf.code_action()<cr>', o(event.buf, '[lsp]: code action'))

    s('n', '[e', vim.diagnostic.goto_prev, o(event.buf, "next code problem"))
    s('n', ']e', vim.diagnostic.goto_next, o(event.buf, "prev code problem"))

    s('n', '<leader>er', builtin.lsp_references, o(event.buf, "references for word under cursoer"))
    s('n', '<leader>ei', builtin.lsp_incoming_calls, o(event.buf, "incoming calls"))
    s('n', '<leader>eo', builtin.lsp_outgoing_calls, o(event.buf, "outgoing calls"))
    s('n', '<leader>bs', builtin.lsp_document_symbols, o(event.buf, "buffer symbols"))
    s('n', '<leader>ep', function() builtin.diagnostics({ severity_limit = 3}) end, o(event.buf, "project diagnostics"))
    s('n', '<leader>bp', function() builtin.diagnostics({ severity_limit = 3, bufnr = 0}) end, o(event.buf, "buffer diagnostics"))
    s('n', '<leader>eP', builtin.diagnostics, o(event.buf, "all project diagnostics"))
    s('n', '<leader>bP', function() builtin.diagnostics({ bufnr = 0 }) end, o(event.buf, "all buffer diagnostic"))
    s('n', '<leader>pS', builtin.lsp_workspace_symbols, o(event.buf, "workspace symbols"))
    s('n', '<leader>ps',
      function()
        builtin.lsp_dynamic_workspace_symbols({
            symbol_type_width = 10,
            fname_width = 50,
          })
      end,
      o(event.buf, "dynamic workspace symbols"))
  end,
})

lspconfig.protols.setup({})
lspconfig.metals.setup({})
lspconfig.jsonls.setup({})
lspconfig.pyright.setup({})
lspconfig.marksman.setup({})
lspconfig.nil_ls.setup({})
lspconfig.clangd.setup({})
lspconfig.lua_ls.setup({
    settings = {
      Lua = {
        diagnostics = {
          globals = {'vim'}
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true)
        }
      }
    },
  })

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
require("lspconfig").markdown_oxide.setup({
    -- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
    -- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
    capabilities = vim.tbl_deep_extend(
        'force',
        capabilities,
        {
            workspace = {
                didChangeWatchedFiles = {
                    dynamicRegistration = true,
                },
            },
        }
    ),
    on_attach = on_attach -- configure your on attach config
})
local cmp = require('cmp')

cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'vsnip' },
    { name = 'buffer' },
  },
  window = {
    completion = cmp.config.window.bordered(),
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
      ['<C-u>'] = cmp.mapping.scroll_docs(-8),
      ['<C-d>'] = cmp.mapping.scroll_docs(8),
      ['<C-g>'] = cmp.mapping.abort(),
      ['<C-Space>'] = cmp.mapping.complete(),
      -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
})

vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
