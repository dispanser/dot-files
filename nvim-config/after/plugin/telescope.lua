require('telescope').setup {
  defaults = {
    cache_picker = {
      num_pickers = 10,
    },
    layout_config = {
      vertical = { width = 0.7 }
      -- other layout configuration here
    },
    pickers = {
      find_files = {
        find_command="rg,--ignore,--hidden,--files prompt_prefix=🔍"
      }
    },
  },
}

local function n(key, action, desc)
  vim.keymap.set('n', key, action, { desc = desc })
end

local builtin = require('telescope.builtin')

-- I'm not sure; find_files uses gitignore, so why would I need it_files? It's supposed to be faster, and the binding is not blocking anthing right now, so ...
n('<leader>pf', builtin.find_files, "find project files")
n('<leader>pg', builtin.git_files, "git project files")
n('<leader>p/', builtin.live_grep, "search project")
n('<leader>pw', builtin.grep_string, "search word in project")

n('<leader>lm', builtin.marks, "marks")
n('<leader>ls', builtin.search_history, "search history")
n('<leader>lc', builtin.commands, "commands")
n('<leader>lC', builtin.command_history, "command history")
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
n('<leader>ps', builtin.lsp_workspace_symbols, "workspace symbols")
n('<leader>pS', builtin.lsp_dynamic_workspace_symbols, "dynamic workspace symbols")
n('<leader>ed', builtin.diagnostics, "diagnostics")

n('<leader>gs', builtin.git_status, "git status")
n('<leader>gb', builtin.git_bcommits, "git buffer commits")
n('<leader>gx', builtin.git_commits, "git commits")
n('<leader>gt', builtin.git_branches, "git branchescommits")

n('<leader>bb', builtin.buffers, "buffer list")
n('<leader>b/', builtin.current_buffer_fuzzy_find, "search current buffer")
n('<leader>/', builtin.current_buffer_fuzzy_find, "search current buffer")
n('<leader>?', builtin.live_grep, "search entire project")

n('<leader>fr', builtin.oldfiles, "recently loaded files")
n('<leader>ts', builtin.treesitter, "treesitter symbols")

