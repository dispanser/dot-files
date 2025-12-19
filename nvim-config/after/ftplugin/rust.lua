local function nnoremap(key, action, desc)
  vim.keymap.set('n', key, action, { noremap = true, silent = true, desc = desc })
end

nnoremap('<leader>ef', vim.cmd.RustFmt, "[rust] code format")
nnoremap("<leader>rc", function() vim.cmd.RustLsp('openCargo') end, "open Cargo.toml")
nnoremap("<leader>rp", function() vim.cmd.RustLsp('parentModule') end, "open parent module")
nnoremap("<leader>ra", function() vim.cmd.RustLsp('codeAction') end, "rust code actions")
nnoremap("<leader>rr", function() vim.cmd.RustLsp('runnables') end, "show runnables")
nnoremap("<leader>re", function() vim.cmd.RustLsp('explainError') end, "explain error")
nnoremap("<leader>ro", function() vim.cmd.RustLsp('renderDiagnostics') end, "render diagnostics")
nnoremap("<leader>rn", function() vim.cmd.RustLsp('relatedDiagnostics') end, "related diagnostics")
nnoremap("<leader>rd", function() vim.cmd.RustLsp('externalDocs') end, "external docs")
nnoremap("<leader>rD", function() vim.cmd.RustLsp('openDocs') end, "open docs")
nnoremap("<leader>rme", function() vim.cmd.RustLsp('expandMacro') end, "expand macro")
nnoremap("<leader>rmu", function() vim.cmd.RustLsp { 'moveItem', 'up' } end, "move item up")
nnoremap("<leader>rmd", function() vim.cmd.RustLsp { 'moveItem', 'down' } end, "move item down")

vim.keymap.set({ "n", "v" }, "<leader>rj", function() vim.cmd.RustLsp { 'moveItem', 'down' } end,
  { noremap = true, silent = true, desc = "join lines" })
