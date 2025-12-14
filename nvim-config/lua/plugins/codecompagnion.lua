return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    -- todo: might need master here - https://github.com/olimorris/codecompanion.nvim/issues/377
    -- { "nvim-lua/plenary.nvim", branch = "master" },
    "ravitemer/codecompanion-history.nvim",
    "nvim-lua/plenary.nvim",
    {
      "ravitemer/mcphub.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
      config = function()
        require("mcphub").setup({
          use_bundled_binary = true, -- Use local `mcp-hub` binary
        })
      end,
    }
  },
  keys = {
    { "<leader>cn", '<cmd>CodeCompanionChat<cr>',        desc = "new CC",    mode = { "n", "v" } },
    { "<leader>cc", '<cmd>CodeCompanionChat Toggle<cr>', desc = "toggle CC", mode = { "n", "v" } },
    { "<leader>cs", '<cmd>CodeCompanionChat Add<cr>',    desc = "add to CC", mode = { "n", "v" } },
  },
  opts = {
    strategies = {
      chat = {
        adapter = "openrouter",
      },
      inline = {
        adapter = "openrouter",
      },
    },
    adapters = {
      acp = {
        opts = {
          show_defaults = false,
        },
      },
      http = {
        opts = {
          show_defaults = false,
        },
        copilot = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = {
                default = 'claude-4.5-sonnet',
              },
            },
          })
        end,
        -- https://codecompanion.olimorris.dev/configuration/adapters
        openrouter = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api",
              api_key = "OPENROUTER_KEY",
              chat_url = "/v1/chat/completions",
            },
            -- https://github.com/olimorris/codecompanion.nvim/discussions/1013#discussioncomment-15113143
            schema = {
              model = {
                default = "mistralai/devstral-2512",
                choices = {
                  ["z-ai/glm-4.6"] = {},
                  ["mistralai/devstral-2512"] = {},
                  ["minimax/minimax-m2"] = {},
                  ["deepseek/deepseek-v3.2"] = {},
                  ["moonshotai/kimi-k2"] = {},
                  ["qwen/qwen3-235b-a22b"] = {},
                },
              },
            },
            handlers = {
              parse_message_meta = function(self, data)
                local extra = data.extra
                if extra and extra.reasoning then
                  data.output.reasoning = { content = extra.reasoning }
                  if data.output.content == "" then
                    data.output.content = nil
                  end
                end
                return data
              end,
            },
          })
        end,
        llamacpp = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "llamacpp",
            opts = {
              vision = true,
              stream = true,
            },
            env = {
              -- url = "http://10.1.3.4:3333",
              url = "http://192.168.1.159:3333",
              api_key = "n/a",
              -- chat_url = "/v1/chat/completions",
            },
          })
        end,
      },
    },
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_vars = true,
          make_slash_commands = true,
          show_result_in_chat = true
        }
      },
      history = {
        enabled = true,
        opts = {
          history_file = vim.fn.expand('~/codecompanion_chats.json'),
          max_history = 30,
        }
      }
    }
  }
}
