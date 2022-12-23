local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local p = require('packer')
return p.startup(function(use)
  p.use {
    'wbthomason/packer.nvim', -- Package manager
    'nvim-lua/plenary.nvim',
    'neovim/nvim-lspconfig', -- Configurations for Nvim LSP
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'gfanto/fzf-lsp.nvim',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'p00f/clangd_extensions.nvim',
    'lukas-reineke/lsp-format.nvim',
    'ray-x/lsp_signature.nvim',
  }
  if packer_bootstrap then
    require('packer').sync()
  end
end)
