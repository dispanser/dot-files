return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    -- todo: might need master here - https://github.com/olimorris/codecompanion.nvim/issues/377
    -- { "nvim-lua/plenary.nvim", branch = "master" },
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>cn", '<cmd>CodeCompanionChat<cr>', desc = "new CC", mode = { "n", "v" } },
    { "<leader>cc", '<cmd>CodeCompanionChat Toggle<cr>', desc = "toggle CC", mode = { "n", "v" } },
    { "<leader>cs", '<cmd>CodeCompanionChat Add<cr>', desc = "add to CC", mode = { "n", "v" } },
  },
  opts = {
    strategies = {
      chat = {
        adapter = "llamacpp",
      },
      inline = {
        adapter = "llamacpp",
      },
    },
    adapters = {
      http = {
        llamacpp = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
              name = "llamacpp",
              opts = {
                  vision = true,
                  stream = true,
              },
             env = {
                url = "http://10.1.3.4:3333",
                api_key = "n/a",
                -- chat_url = "/v1/chat/completions",
              },
          })
        end,
      },
    },
    extensions = {
      -- mcphub = {
        --   callback = "mcphub.extensions.codecompanion",
        --   opts = {
          --     make_vars = true,
          --     make_slash_commands = true,
          --     show_result_in_chat = true
        --   }
      -- },
      -- codecompanion_history = {
      --     enabled = true,
      --     opts = {
      --         history_file = "/Users/thomas.peiselt/codecompanion_chats.json",
      --         max_history = 30,
      --     }
      -- }
    }
  }
}
