-- this is "general settings"

vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.linebreak = true
vim.o.visualbell = true
vim.o.updatetime = 250
vim.o.exrc = true
vim.o.secure = true
vim.o.wrap = false
vim.o.breakindent = true
vim.o.breakindentopt = 'shift:4,min:20,sbr,list:-1'
vim.o.showbreak = '↪ '
vim.o.shiftround = true -- Round indent to multiple of shiftwidth
vim.o.listchars = "tab:| ,multispace:   ,eol:󰌑" -- Characters to show for tabs, spaces, and end of line
vim.o.list = true -- Show whitespace characters
vim.o.number = true -- Show line numbers

-- wo: window-scoped
-- g: "global", plugins only + leader keys (see remap)
-- bo: buffer-scoped options
-- opt: "global, window and buffer" ?? not sure 
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.signcolumn = 'yes:1'
vim.opt.laststatus = 3
vim.opt.syntax = 'on'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.completeopt = { "menuone", "popup", "noinsert", "fuzzy" } -- Options for completion menu
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.foldenable = false;
vim.opt.winborder = "rounded"

-- Highlight on yank (built-in, replaces vim-highlightedyank)
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 400 })
  end,
})

-- testing: nvim-ufo
--
-- use Neovim nightly branch
vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:'
vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end,
    close_fold_kinds_for_ft = {
        default = {'imports', 'comment'},
        json = {'array'},
        c = {'comment', 'region'}
    },
    preview = {
        win_config = {
            border = {'', '─', '', '', '', '─', '', ''},
            winhighlight = 'Normal:Folded',
            winblend = 0
        },
        mappings = {
            scrollU = '<C-u>',
            scrollD = '<C-d>',
            jumpTop = '[',
            jumpBot = ']'
        }
    },
})

vim.keymap.set('n', 'K', function()
    local winid = require('ufo').peekFoldedLinesUnderCursor()
    if not winid then
        vim.lsp.buf.hover()
    end
end)

vim.keymap.set('n', 'X', require('ufo').peekFoldedLinesUnderCursor)
