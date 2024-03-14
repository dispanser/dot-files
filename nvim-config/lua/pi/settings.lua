-- this is "general settings"

vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.linebreak = true
vim.o.visualbell = on
vim.o.updatetime = 250
vim.o.exrc = true
vim.o.secure = true

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
vim.opt.syntax = enable
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.splitright = true
vim.opt.splitbelow = true
