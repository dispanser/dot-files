require('render-markdown').setup({
  completions = { lsp = { enabled = true } },
  code = {
    conceal_delimiters = false,
    width = 'block',
    right_pad = 8,
    border = 'thin',
  },
  indent = {
    enabled = true,
  },
})

