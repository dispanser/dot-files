return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = 'TSUpdate',
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'BufRead',
    branch = "main",
  },
  -- dead for now :-( https://github.com/RRethy/nvim-treesitter-textsubjects/issues/52
  -- { 'RRethy/nvim-treesitter-textsubjects', dependencies = { 'nvim-treesitter/nvim-treesitter' }, },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  'nvim-treesitter/nvim-treesitter-context'
}
