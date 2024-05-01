local function nnoremap (key, action, desc)
  vim.keymap.set('n', key, action, { noremap = true, silent = true, desc = desc })
end


local bufnr = vim.api.nvim_get_current_buf()

nnoremap('<leader>ef', vim.cmd.RustFmt, "[rust] code format")
nnoremap("<leader>rc", function() vim.cmd.RustLsp('openCargo') end, "open Cargo.toml")
nnoremap("<leader>rp", function() vim.cmd.RustLsp('parentModule') end,"open parent module")
nnoremap("<leader>ra", function() vim.cmd.RustLsp('codeAction') end, "rust code actions")
nnoremap("<leader>rr", function() vim.cmd.RustLsp('runnables') end, "show runnables")
nnoremap("<leader>rme", function() vim.cmd.RustLsp('expandMacro') end, "expand macro")
nnoremap("<leader>re", function() vim.cmd.RustLsp('explainError') end, "explain error")
nnoremap("<leader>rd", function() vim.cmd.RustLsp('externalDocs') end, "external docs")
nnoremap("<leader>rD", function() vim.cmd.RustLsp('openDocs') end, "open docs")
nnoremap("<leader>rmu", function() vim.cmd.RustLsp{'move_item', 'up'} end, "move item up")
nnoremap("<leader>rmd", function() vim.cmd.RustLsp{'move_item', 'down'} end, "move item down")

nnoremap(")", vim.cmd.AerialNext, "aerial next token")
nnoremap("(", vim.cmd.AerialPrev, "aerial previous token")


