local dap = require('dap')

-- see https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb) for setup
-- macos: need to download vscode extensions into absolute path configured below (could try nixos...)
dap.adapters.codelldb = {
  type = 'server',
  host = '127.0.0.1',
  port = 13123, -- 💀 Use the port printed out or specified with `--port`
  executable = {
    command = '/Users/thomas.peiselt/installs/codelldb/extension/adapter/codelldb',
    -- args = {"--port", "${port}"},
    args = {"--port", "13123"},
  }
}

dap.configurations.rust = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
         return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/.tp/targets/all/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
  {
    -- If you get an "Operation not permitted" error using this, try disabling YAMA:
    --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    name = "Attach to process",
    type = 'codelldb',  -- Adjust this to match your adapter name (`dap.adapters.<name>`)
    request = 'attach',
    pid = require('dap.utils').pick_process,
    args = {},
  },
}

local function nnoremap (key, action, desc)
  vim.keymap.set('n', key, action, { noremap = true, desc = desc })
end

local function vnoremap (key, action, desc)
  vim.keymap.set('v', key, action, { noremap = true, desc = desc })
end

vim.fn.sign_define('DapBreakpoint',{ text ='🟥', texthl ='', linehl ='', numhl =''})
vim.fn.sign_define('DapStopped',{ text ='▶️', texthl ='', linehl ='', numhl =''})

nnoremap('<leader>cc', function() require'dap'.toggle_breakpoint() end, "[dap] toggle breakpoint")
nnoremap('<leader>cb', function() 
  require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) 
end, "[dap] set breakpoint condition")
nnoremap('<leader>cr', function() require'dap'.repl.open() end, "[dap] open repl")
nnoremap('<leader>cl', function() require'dap'.repl.run_last() end, "[dap] open repl")
nnoremap('<leader>cr', function() require'dap'.continue() end, "[dap] continue")
nnoremap('<leader>co', function() require'dap'.step_over() end, "[dap] step over")
nnoremap('<S-Space>', function() require'dap'.step_over() end, "[dap] step over")
nnoremap('<M-Space>', function() require'dap'.step_over() end, "[dap] step over")
nnoremap('<leader>ci', function() require'dap'.step_into() end, "[dap] step into")
nnoremap('<S-CR>', function() require'dap'.step_into() end, "[dap] step into")
nnoremap('<M-CR>', function() require'dap'.step_into() end, "[dap] step into")
nnoremap('<leader>cO', function() require'dap'.step_out() end, "[dap] step out")
nnoremap('<M-BS>', function() require'dap'.step_out() end, "[dap] step out")
nnoremap('<leader>cx', function() require'dap'.terminate() end, "[dap] terminate")
nnoremap('<leader>ck', function() require('dapui').eval() end, "[dap] hover")
vnoremap('<leader>ck', function() require('dapui').eval() end, "[dap] hover")
nnoremap('<leader>ce', function() require('dapui').eval(
      vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/.tp/targets/all/debug/', 'file'))
  end, "[dap] eval expression")
nnoremap('<leader>ch', function() require('dap.ui.widgets').hover() end, "[dap] hover")
nnoremap('<leader>cs', function()
  local widgets=require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes) 
end, "[dap] scopes")
nnoremap('<leader>cf', function() require('dapui').float_element() end, "[dap] float")
nnoremap('<leader>cS', function() require('dap.ui.variables').scopes() end, "[dap] variable scopes")

-- nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
