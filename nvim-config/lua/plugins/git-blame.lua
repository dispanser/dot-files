return {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
        enabled = true,
        -- message_template = " <summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
        date_format = "%m-%d-%Y %H:%M",
        virtual_text_column = 1,  -- virtual text start column, check Start virtual text at column section for more options
    },
    keys = {
      { '<leader>gu', vim.cmd.GitBlameCopyFileURL, desc = "copy git url" },
      { '<leader>tl', vim.cmd.GitBlameToggle, desc = "toggle blame line" }
    },
}
