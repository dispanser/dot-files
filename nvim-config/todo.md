# Plugins

## New functionality

- git commit browser [gv](https://github.com/junegunn/gv.vim)
  - technically that was installed previously, but I can't remember using it
- [vim-swap](machakann/vim-swap): text objects and swap function arguments
  - this was already enabled, but never actively used
- [vim-cutlass](https://github.com/svermeulen/vim-cutlass)
  - do not put the deleted / changed stuff (cc, dw, ...) into a register
  - while this sounds useful, it changes my current mental model
- treesitter extensions:
  - [nvim-dap](https://github.com/mfussenegger/nvim-dap): debug (extension of LSP?)
     - [available adapters](https://microsoft.github.io/debug-adapter-protocol/implementors/adapters/)
     - all the stuff you'd hope for, except for a scala-specific one (doh!)
  - [nvim-treehopper](https://github.com/mfussenegger/nvim-treehopper): navigate via treesitter AST
  - [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
  - [nvim-textsubjects](https://github.com/RRethy/nvim-treesitter-textsubjects)
- [mini.ai](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md) textobjects with continuous expansion
  - e.g., hitting a) multiple times expands the selection to more outer parens
  - top-level project hosts 20 "swiss-army knife" plugins, check those out as well

## Replacements

- potential replacement for gitgutter: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

## Improve already in use

- [diffview](https://github.com/sindrets/diffview.nvim): also supports file history: 
  - the diff looks beautiful, I want that as well :-) (green / red)
- [telescope-lsp-handlers](https://github.com/gbrlsnchs/telescope-lsp-handlers.nvim): use telescope for "normal" lsp-related actions, no need for telescope-specific mappings

## For Inspiration

- [kickstart](https://github.com/nvim-lua/kickstart.nvim): good set of defaults
