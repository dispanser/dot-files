require("lsp-format").setup {}

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']g', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>qf', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  require "lsp-format".on_attach(client)
  -- TODO/eval: lsp signature is not yet secured
  require "lsp_signature".on_attach({
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      handler_opts = {
        border = "rounded"
      }
    }, bufnr)

  -- Enable completion triggered by <c-x><c-o>
  -- TODO: revisit
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<leader>ch',  ":ClangdSwitchSourceHeader<cr>", bufopts)
  vim.keymap.set('n', 'gD', ":Declarations<CR>", bufopts) -- typically not used / implemented
  vim.keymap.set('n', 'gd', ":Definitions<CR>", bufopts)
  vim.keymap.set('n', 'ge', ":Diagnostics<CR>", bufopts)
  vim.keymap.set('n', 'gr', ":References<CR>", bufopts)
  vim.keymap.set('n', 'ga', ":DiagnosticsAll<CR>", bufopts)
  vim.keymap.set('n', 'gs', ":DocumentSymbols<CR>", bufopts)
  vim.keymap.set('n', 'gw', ":WorkspaceSymbols", bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gI',  ":Implementations<CR>", bufopts)
  vim.keymap.set('n', 'gi',  ":IncomingCalls<CR>", bufopts)
  vim.keymap.set('n', 'go',  ":OutgoingCalls<CR>", bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D',  ":TypeDefinitions<CR>", bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader><leader>', ":CodeActions<CR>", bufopts)
  vim.keymap.set('n', '<leader>ff', vim.lsp.buf.formatting, bufopts)

  -- TODO: condition is met but highlighting isn't happening, also not on `:`
	if client.supports_method('textDocument/documentHighlight') then
		vim.api.nvim_exec([[
			augroup lsp_document_highlight
				autocmd! * <buffer>
				autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
				autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
			augroup END
		]], false)
	end
end

local clangd_attach = function(client, bufnr)
  on_attach(client, bufnr)
  -- override some bindings
  vim.keymap.set('n', 'gt',  ":ClangdTypeHierarchy<CR>", bufopts)
end

local nvim_cmp_setup = function()
  local cmp = require'cmp'

  cmp.setup({
      snippet = {
        expand = function(args)
          require'luasnip'.lsp_expand(args.body)
        end
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
      sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        }),
      view = {                                                        
        -- TODO/eval: the order of the entries is done to have the most relevant
        -- near the cursor, instead of always top-down
        entries = {name = 'custom', selection_order = 'near_cursor' } 
      },                                                               
    })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    },
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('clangd_extensions').setup {
    server = {
      on_attach = clangd_attach,
      flags = lsp_flags,
      capabilities = capabilities,
    },
    inlay_hints = {
      max_len_align = true,
      -- padding from the left if max_len_align is true
      max_len_align_padding = 1,
    },
  }
end

nvim_cmp_setup()

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

require('lspconfig')['rust_analyzer'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    -- Server-specific settings...
    settings = {
      ["rust-analyzer"] = {}
    }
}

require'lspconfig'.jedi_language_server.setup{}
