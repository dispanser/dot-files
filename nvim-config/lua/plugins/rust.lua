return {
  "mrcjkb/rustaceanvim",
  ft = { "rust" },
  config = function(_, opts)
    local codelldb_root = vim.env.CODELLDB_ROOT or "/home/pi/installs/codelldb/extension"
    opts = {
      server = {
        capabilities = {
          general = { positionEncodings = { 'utf-16' } },
        },
        default_settings = {
          ['rust-analyzer'] = {
            cargo = {
              -- allFeatures = true,
              targetDir = ".tp/targets/rust-analyzer",
            },
            check = {
              command = 'clippy',
              extraArgs = {},
            },
            files = {
              excludeDirs = {
                '.git', 'bin', '.venv', 'venv', 'target'
              }
            },
            procMacro = {
              enable = true,
              ignored = {
                ['async-trait'] = { 'async_trait' },
                ['async-recursion'] = { 'async_recursion' },
              }
            }
          }
        }
      },
      dap = {
        adapter = require('rustaceanvim.config').get_codelldb_adapter(
          codelldb_root .. "/adapter/codelldb",
          codelldb_root .. "lldb/lib/liblldb.so"),
      },
    }
    vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
  end
}
