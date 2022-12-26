# Telescope

- enable sending selection / all from a telescope into quick fix list, see
https://github.com/kitagry/dotfiles/blob/4fe3af3288d40f296a782971080b7b8cb43a36d5/.config/nvim/lua/kitagry/telescope.lua
  - look into other `telescope.actions` - there may be additional gems hiding
- lr -> list registers doesn't work, there's an error message

# General

- "center toggle" (t-) does not work (generally, `scrolloff)
- colors are ugly as hell

# Plugins

## New functionality

- note-taking, beautiful: [mind.nvim](https://github.com/phaazon/mind.nvim)
  - youtube series, [part 2](https://www.reddit.com/r/neovim/comments/zuwpi0/mind_nvim_part_25_content_fuzzy_searching_and_more/)
- git commit browser [gv](https://github.com/junegunn/gv.vim)
  - technically that was installed previously, but I can't remember using it
- [vim-swap](machakann/vim-swap): text objects and swap function arguments
  - this was already enabled, but never actively used
- [vim-cutlass](https://github.com/svermeulen/vim-cutlass)
  - do not put the deleted / changed stuff (cc, dw, ...) into a register
  - while this sounds useful, it changes my current mental model

## Replacements

- potential replacement for gitgutter: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

## Improve already in use

- [diffview](https://github.com/sindrets/diffview.nvim): also supports file history: 
  - the diff looks beautiful, I want that as well :-) (green / red)

