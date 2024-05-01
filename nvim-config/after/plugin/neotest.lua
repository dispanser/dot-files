local t = require("neotest")


local function nnoremap (key, action, desc)
  vim.keymap.set('n', key, action, { noremap = true, silent = true, desc = desc })
end

nnoremap("<leader>nr", function() t.run.run() end, "neotest run")
nnoremap("<leader>nd", function() t.run.run({strategy = "dap"}) end, "neotest debug")
nnoremap("<leader>nf", function() t.run.run(vim.fn.expand("%")) end, "neotest run file")
nnoremap("<leader>na", function() t.run.attach() end, "neotest attach")
nnoremap("<leader>ns", function() t.run.stop() end, "neotest stop")
nnoremap("<leader>no", function() t.output.open({ enter = true }) end, "neotest open")


