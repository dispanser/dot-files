return {
  "AckslD/nvim-neoclip.lua",
  dependencies = { "kkharji/sqlite.lua" },
  keys = {
    { "<leader>ly", "<cmd>Telescope neoclip<cr>", desc = "Neoclip" },
  },
  config = function()
    require('neoclip').setup({
      keys = {
        -- mostly defaults, changed "paste" to get expected C-n / C-p behavior 
        telescope = {
          i = {
            select = '<cr>',
            paste = '<c-v>',
            paste_behind = '<c-k>',
            replay = '<c-q>',  -- replay a macro
            delete = '<c-d>',  -- delete an entry
            edit = '<c-e>',  -- edit an entry
            custom = {},
          },
          n = {
            select = '<cr>',
            paste = 'p',
            --- It is possible to map to more than one key.
            -- paste = { 'p', '<c-p>' },
            paste_behind = 'P',
            replay = 'q',
            delete = 'd',
            edit = 'e',
            custom = {},
          },
        },
      },
    })
  end,
}
