local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "<leader>rc", rt.open_cargo_toml.open_cargo_toml, {buffer = bufnr, desc = "open Cargo.toml"})
      vim.keymap.set("n", "<leader>rp", rt.parent_module.parent_module, {buffer = bufnr, desc = "open parent module"})
      vim.keymap.set("n", "<leader>rk", rt.hover_actions.hover_actions, { buffer = bufnr , desc = "rust hover actions"})
      vim.keymap.set("n", "<leader>ra", rt.code_action_group.code_action_group, { buffer = bufnr , desc = "rust code actions"})
      vim.keymap.set("n", "<leader>rr", rt.runnables.runnables, {buffer = bufnr, desc = "show runnables"})
      vim.keymap.set("n", "<leader>rme", rt.expand_macro.expand_macro, {buffer = bufnr, desc = "expand macro"})
      vim.keymap.set("n", "<leader>rmu", function() rt.move_item.move_item(up) end, {buffer = bufnr, desc = "move item up"})
      vim.keymap.set("n", "<leader>rmd", function() rt.move_item.move_item(down) end, {buffer = bufnr, desc = "move item down"})
    end,
  },
})
