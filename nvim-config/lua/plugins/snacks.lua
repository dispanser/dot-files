return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dim = { enabled = true },
    explorer = { enabled = true },
    gitbrowse = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
      margin = { top = 5, right = 1, bottom = 5 },
      level = vim.log.levels.INFO,
    },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    { "<leader>tr", function() Snacks.explorer.reveal() end,                    desc = "reveal current file" },

    ---------------------------------------------------------------------------
    -- Picker: files
    ---------------------------------------------------------------------------
    { "<leader>pf", function() Snacks.picker.files() end,                       desc = "find project files" },
    { "<leader>pg", function() Snacks.picker.git_files() end,                   desc = "git files" },
    { "<leader>p/", function() Snacks.picker.grep() end,                        desc = "search project" },
    { "<leader>pt", function() Snacks.picker.grep({ search = "tyx/" }) end,     desc = "search my tag in project" },
    { "<leader>pT", function() Snacks.picker.grep({ search = "tyx/TODO" }) end, desc = "search my TODO in project" },
    { "<leader>pW", function() Snacks.picker.grep_word() end,                   desc = "search word in project",       mode = { "n", "x" } },
    { "<leader>pw", function() Snacks.picker.grep_word() end,                   desc = "search exact word in project", mode = { "n", "x" } },
    { "<leader>pw", function() Snacks.picker.projects() end,                    desc = "recent projects",              mode = { "n", "x" } },
    { "<leader>fr", function() Snacks.picker.recent() end,                      desc = "recently loaded files" },

    ---------------------------------------------------------------------------
    -- Picker: buffers
    ---------------------------------------------------------------------------
    { "<leader>bb", function() Snacks.picker.buffers() end,                     desc = "buffer list" },
    { "<leader>bg", function() Snacks.picker.grep_buffers() end,                desc = "buffer list" },
    { "<leader>b/", function() Snacks.picker.lines() end,                       desc = "search current buffer" },
    { "<leader>bl", function() Snacks.picker.lines() end,                       desc = "search current buffer" },
    {
      "<leader>bw",
      function()
        Snacks.picker.lines({ pattern = vim.fn.expand("<cword>") })
      end,
      desc = "search word in buffer"
    },
    {
      "<leader>bt",
      function()
        Snacks.picker.lines({ pattern = "tyx/" })
      end,
      desc = "search my tag in buffer"
    },
    { "<leader>/",        function() Snacks.picker.grep() end,                                   desc = "search entire project" },

    ---------------------------------------------------------------------------
    -- Picker: various lists
    ---------------------------------------------------------------------------
    { "<leader>lt",       function() Snacks.picker.colorschemes() end,                           desc = "pick theme" },
    { "<leader>lm",       function() Snacks.picker.marks() end,                                  desc = "marks" },
    { "<leader>ls",       function() Snacks.picker.search_history() end,                         desc = "search history" },
    { "<leader>:",        function() Snacks.picker.commands() end,                               desc = "commands" },
    { "<leader>lc",       function() Snacks.picker.command_history() end,                        desc = "command history" },
    { "<leader>li",       function() Snacks.picker.icons() end,                                  desc = "icons" },
    { "<leader>lj",       function() Snacks.picker.jumps() end,                                  desc = "jump list" },
    { "<leader>ll",       function() Snacks.picker.loclist() end,                                desc = "location list" },
    { "<leader><leader>", function() Snacks.picker.resume() end,                                 desc = "resume previous search" },
    -- { "<leader>lp",       function() Snacks.picker.preview() end,                                desc = "previous pickers" },
    { "<leader>lh",       function() Snacks.picker.help() end,                                   desc = "help tags" },
    { "<leader>lr",       function() Snacks.picker.registers() end,                              desc = "registers" },
    { "<leader>lz",       function() Snacks.picker.zoxide() end,                                 desc = "zoxide" },
    -- { "<leader>ly",       function() Snacks.picker.cliphist() end,                              desc = "clipboard / registers" },

    ---------------------------------------------------------------------------
    -- Picker: quickfix
    ---------------------------------------------------------------------------
    { "<leader>qf",       function() Snacks.picker.qflist() end,                                 desc = "quick fix list" },
    { "<leader>qF",       function() Snacks.picker.qflist() end,                                 desc = "quick fix history" },

    ---------------------------------------------------------------------------
    -- Picker: git
    ---------------------------------------------------------------------------
    { "<leader>gs",       function() Snacks.picker.git_status() end,                             desc = "git status" },
    { "<leader>gb",       function() Snacks.picker.git_log_file() end,                           desc = "git buffer commits" },
    { "<leader>gx",       function() Snacks.picker.git_log() end,                                desc = "git commits" },
    { "<leader>gt",       function() Snacks.picker.git_branches() end,                           desc = "git branches" },
    { "<leader>gd",       function() Snacks.picker.git_diff() end,                               desc = "git diff (hunks)" },
    { "<leader>gg",       function() Snacks.picker.git_grep() end,                               desc = "git grep" },
    { "<leader>gl",       function() Snacks.picker.git_log_line() end,                           desc = "git line commits" },
    { "<leader>lg",       function() Snacks.lazygit.open() end,                                  desc = "lazygit" },

    ---------------------------------------------------------------------------
    -- Picker: treesitter / LSP symbols
    ---------------------------------------------------------------------------
    { "<leader>ts",       function() Snacks.picker.treesitter() end,                             desc = "treesitter symbosl" },
    { "<leader>tt",       function() Snacks.terminal.toggle("fish") end,                         desc = "terminal" },

    ---------------------------------------------------------------------------
    -- Picker: undo
    ---------------------------------------------------------------------------
    { "<leader>tu",       function() Snacks.picker.undo() end,                                   desc = "undo history" },

    ---------------------------------------------------------------------------
    -- Git browse (replaces git-link.nvim)
    ---------------------------------------------------------------------------
    { "<leader>gu",       function() Snacks.gitbrowse({ notify = false, clipboard = true }) end, desc = "Copy code link to clipboard", mode = { "n", "x" } },
    { "<leader>go",       function() Snacks.gitbrowse() end,                                     desc = "Open code link in browser",   mode = { "n", "x" } },

    ---------------------------------------------------------------------------
    -- Lazygit
    ---------------------------------------------------------------------------
    { "<leader>gg",       function() Snacks.lazygit() end,                                       desc = "lazygit" },

    ---------------------------------------------------------------------------
    -- Buffer delete (replaces vim-bbye)
    ---------------------------------------------------------------------------
    { "<leader>bc",       function() Snacks.bufdelete() end,                                     desc = "close file shown in buffer" },
    { "<leader>bx",       function() Snacks.bufdelete.delete() end,                              desc = "wipe file shown in buffer" },

    ---------------------------------------------------------------------------
    -- Dim (replaces vim-diminactive)
    ---------------------------------------------------------------------------
    {
      "<leader>ti",
      function()
        local dim = require('snacks.dim')
        if dim.enabled then
          dim.disable()
        else
          dim.enable()
        end
      end,
      desc = "toggle inactive dim"
    },

    ---------------------------------------------------------------------------
    -- Words (replaces vim-illuminate)
    ---------------------------------------------------------------------------
    { "]]",         function() Snacks.words.jump(vim.v.count1) end,  desc = "Next Reference",           mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference",           mode = { "n", "t" } },

    ---------------------------------------------------------------------------
    -- Notifier
    ---------------------------------------------------------------------------
    { "<leader>nu", function() Snacks.notifier.hide() end,           desc = "Dismiss All Notifications" },
    { "<leader>nh", function() Snacks.notifier.show_history() end,   desc = "Dismiss All Notifications" },
    { "<leader>nn", function() Snacks.picker.notifications() end,    desc = "Dismiss All Notifications" },
  },
}
