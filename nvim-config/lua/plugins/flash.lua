return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      char = {
        jump_labels = true
      },
      treesitter = {
        jump = { pos = "start" },
      },
    },
    label = {
      -- show labels at beginning, not end, of match. More natural for me, because
      -- that's also the position we're going to jump to (beginning of match)
      after = false,
      before = true,
    },
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    { "gw", mode = { "n", "x", "o"}, function()
      require("flash").jump({ pattern = vim.fn.expand("<cword>")})
    end, desc = "jump word under cursor" },
    { "<leader>sw", mode = { "n", "x", "o"}, function()
      require("flash").jump({
          search = {
            mode = function(str)
              return "\\<" .. str
            end,
          }
        })
      end, desc = "search words",
    },
    { "<leader>sl", mode = { "n", "x", "o"}, function()
      require("flash").jump({
          search = {
            search = { mode = "search" },
            highlight = { label = { after = { 0, 0 } } },
            pattern = "^",
          }
        })
      end, desc = "search words",
    },
  },
}
