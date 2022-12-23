require('telescope').setup {
  defaults = {
    cache_picker = {
      num_pickers = 10,
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
n('<leader>ps', builtin.live_grep, "search project")
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
-- TODO: doesn't work, error message
n('<leader>lr', builtin.registers, "registers")


n('<leader>qF', builtin.quickfixhistory, "quick fix history")
n('<leader>qf', builtin.quickfix, "quick fix list")

n('<leader>bb', builtin.buffers, "buffer list")
n('<leader>bs', builtin.current_buffer_fuzzy_find, "search current buffer")

n('<leader>fr', builtin.oldfiles, "recently loaded files")
n('<leader>ts', builtin.treesitter, "treesitter symbols")

