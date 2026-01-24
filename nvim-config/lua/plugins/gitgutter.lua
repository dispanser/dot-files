return {
  'airblade/vim-gitgutter',
  keys = {
    {  mode = {'v', 'n'}, '<leader>ga', ':GitGutterStageHunk<CR>', desc = "git stage hunk" },
    {  '<leader>gn', ':GitGutterNextHunk<CR>', desc = "git goto next hunk" },
    {  '<leader>gp', ':GitGutterPrevHunk<CR>', desc = "git goto previous hunk" },
  },
  init = function()
    vim.g.gitgutter_map_keys = 0
    vim.g.gitgutter_preview_win_floating = 1
  end,
  lazy = false,
}
