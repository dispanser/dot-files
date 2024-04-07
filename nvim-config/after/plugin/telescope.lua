local function n(key, action, desc)
  vim.keymap.set('n', key, action, { desc = desc })
end

local builtin = require('telescope.builtin')

-- I'm not sure; find_files uses gitignore, so why would I need it_files? It's supposed to be faster, and the binding is not blocking anthing right now, so ...
n('<leader>pf', builtin.find_files, "find project files")
n('<leader>pF', function() builtin.find_files({ hidden = true, no_ignore_parent = true}) end, "find project files, include hidden / ignored")
n('<leader>pg', builtin.git_files, "git project files")
n('<leader>p/', builtin.live_grep, "search project")
n('<leader>pW', builtin.grep_string, "search word in project")
n('<leader>pw', function() builtin.grep_string({ word_match = '-w' }) end , "search exact word in project")

n('<leader>lm', builtin.marks, "marks")
n('<leader>ls', builtin.search_history, "search history")
n('<leader>:', builtin.commands, "commands")
n('<leader>lc', builtin.command_history, "command history")
n('<leader>lj', builtin.jumplist, "jump list")
n('<leader>ll', builtin.loclist, "location list")
n('<leader><leader>', builtin.resume, "resume previous search")
n('<leader>lp', builtin.pickers, "previous pickers")
n('<leader>lh', builtin.help_tags, "help tags")
n('<leader>lr', builtin.registers, "registers")

n('<leader>qF', builtin.quickfixhistory, "quick fix history")
n('<leader>qf', builtin.quickfix, "quick fix list")

n('<leader>er', builtin.lsp_references, "references for word under cursoer")
n('<leader>ei', builtin.lsp_incoming_calls, "incoming calls")
n('<leader>eo', builtin.lsp_outgoing_calls, "outgoing calls")
n('<leader>bs', builtin.lsp_document_symbols, "buffer symbols")
n('<leader>pS', builtin.lsp_workspace_symbols, "workspace symbols")
n('<leader>ps', builtin.lsp_dynamic_workspace_symbols, "dynamic workspace symbols")
n('<leader>ed', builtin.diagnostics, "full diagnostics")
n('<leader>ep', function() builtin.diagnostics({ severity_limit = 3}) end, "project diagnostics")
n('<leader>bp', function() builtin.diagnostics({ severity_limit = 3, bufnr = 0}) end, "buffer diagnostics")
n('<leader>eP', builtin.diagnostics, "all project diagnostics")
n('<leader>bP', function() builtin.diagnostics({ bufnr = 0 }) end, "all buffer diagnostic")
n('<leader>gs', builtin.git_status, "git status")
n('<leader>gb', builtin.git_bcommits, "git buffer commits")
n('<leader>gx', builtin.git_commits, "git commits")
n('<leader>gt', builtin.git_branches, "git branches")

n('<leader>bb', builtin.buffers, "buffer list")
n('<leader>b/', builtin.current_buffer_fuzzy_find, "search current buffer")
n('<leader>/', builtin.current_buffer_fuzzy_find, "search current buffer")
n('<leader>?', builtin.live_grep, "search entire project")

n('<leader>fr', builtin.oldfiles, "recently loaded files")
n('<leader>ts', builtin.treesitter, "treesitter symbols")

n('gd', builtin.lsp_definitions, "go to definition (telescope)")
n('gt', builtin.lsp_type_definitions, "go to type definition (telescope)")
