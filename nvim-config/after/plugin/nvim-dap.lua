local dap = require('dap')
local dapui = require('dapui')
-- see https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb) for setup
-- macos: need to download vscode extensions into absolute path configured below (could try nixos...)
local codelldb_root = vim.env.CODELLDB_ROOT or vim.env.HOME .. "/installs/codelldb/extension"
dap.adapters.codelldb = {
  type = "executable",
  -- https://medium.com/@hpheshan/setting-up-neovim-dap-for-codelldb-in-nix-dev-shell-b4ad29e34bf4
  command = codelldb_root .. "/adapter/codelldb",
}

dap.configurations.rust = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    args = function()
      local input = vim.fn.input('arguments: ', '--retries 0 ', 'file')
      local args = {}
      for arg in input:gmatch("%S+") do
        table.insert(args, arg)
      end
      return args
    end,
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/.tp/targets/test/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
  {
    -- If you get an "Operation not permitted" error using this, try disabling YAMA:
    --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    name = "Attach to process",
    type = 'codelldb', -- Adjust this to match your adapter name (`dap.adapters.<name>`)
    request = 'attach',
    pid = require('dap.utils').pick_process,
    args = {},
  },
}

vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })

vim.keymap.set('n', '<leader>DD', function()
  local bufnr = vim.api.nvim_get_current_buf()
  set_dap_buf_keymaps(bufnr)
end, { noremap = true, silent = true, desc = "[dap] enable keybindings" })

local dap_keymaps = {
  { '<leader>dc', function() dap.toggle_breakpoint() end, "[dap] toggle breakpoint" },
  { '<leader>db', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end, "[dap] set breakpoint condition" },
  { '<leader>dl', function() dap.repl.run_last() end,     "[dap] open repl" },
  { '<leader>dr', function() dap.continue() end,          "[dap] continue" },
  { '<leader>dR', function() dap.reverse_continue() end,  "[dap] reverse continue" },
  { '<leader>do', function() dap.step_over() end,         "[dap] step over" },
  { '<M-Space>',  function() dap.step_over() end,         "[dap] step over" },
  { '<leader>di', function() dap.step_into() end,         "[dap] step into" },
  { '<M-CR>',     function() dap.step_into() end,         "[dap] step into" },
  { '<leader>dO', function() dap.step_out() end,          "[dap] step out" },
  { '<M-BS>',     function() dap.step_out() end,          "[dap] step out" },
  { '<leader>dd', function() dap.disconnect() end,        "[dap] disconnect" },
  { '<leader>dx', function() dap.terminate() end,         "[dap] terminate" },
  { '<leader>dk', function() dapui.eval() end,            "[dap] hover" },
  { '<leader>de', function()
    dapui.eval(vim.fn.input('evaluate: '))
  end, "[dap] eval expression" },
  { '<leader>dh', function() require('dap.ui.widgets').hover() end,    "[dap] hover" },
  { '<leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
  end, "[dap] scopes" },
  { '<leader>df', function() dapui.float_element() end,                "[dap] float" },
  { '<leader>dS', function() require('dap.ui.variables').scopes() end, "[dap] variable scopes" },
}

-- -- Set buffer-local keymaps for dap actions
-- function set_dap_buf_keymaps(bufnr)
--   for _, map in ipairs(dap_keymaps) do
--     vim.api.nvim_buf_set_keymap(bufnr, 'n', map[1], '', {
--       noremap = true,
--       callback = map[2],
--       desc = map[3],
--       silent = true,
--     })
--   end
-- end

-- -- Remove buffer-local keymaps for dap actions
-- local function remove_dap_buf_keymaps(bufnr)
--   for _, map in ipairs(dap_keymaps) do
--     vim.api.nvim_buf_del_keymap(bufnr, 'n', map[1])
--   end
-- end

-- -- Attach keymaps when dap session starts
-- dap.listeners.after.event_initialized['dap_keymaps'] = function()
--   local bufnr = vim.api.nvim_get_current_buf()
--   set_dap_buf_keymaps(bufnr)
-- end

-- -- Remove keymaps when dap session ends
-- dap.listeners.after.event_terminated['dap_keymaps'] = function()
--   local bufnr = vim.api.nvim_get_current_buf()
--   remove_dap_buf_keymaps(bufnr)
-- end
-- dap.listeners.after.event_exited['dap_keymaps'] = function()
--   local bufnr = vim.api.nvim_get_current_buf()
--   remove_dap_buf_keymaps(bufnr)
-- end
