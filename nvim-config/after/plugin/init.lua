require("pi-nvim").setup()

vim.keymap.set("n", "<leader>ap", ":PiSend<CR>")
vim.keymap.set("n", "<leader>af", ":PiSendFile<CR>")
vim.keymap.set("v", "<leader>as", ":PiSendSelection<CR>")
vim.keymap.set("n", "<leader>ab", ":PiSendBuffer<CR>")
vim.keymap.set("n", "<leader>ai", ":PiPing<CR>")

