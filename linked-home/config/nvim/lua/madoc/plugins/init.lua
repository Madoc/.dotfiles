return require('packer').startup(function(use)
  use "wbthomason/packer.nvim"

  use {"akinsho/toggleterm.nvim", tag = 'v2.*', config = require("madoc.plugins.toggleterm").setup()}
  use {"feline-nvim/feline.nvim", config = require("madoc.plugins.feline").setup()}
  use {"hrsh7th/nvim-cmp", requires = {{ "hrsh7th/cmp-nvim-lsp" }, { "hrsh7th/cmp-vsnip" }, { "hrsh7th/vim-vsnip" }}}
  use {"lewis6991/gitsigns.nvim", config = require("madoc.plugins.gitsigns").setup()}
  use {"nvim-neo-tree/neo-tree.nvim", branch = "v2.x", requires = {"nvim-lua/plenary.nvim", "kyazdani42/nvim-web-devicons", "MunifTanjim/nui.nvim"}}
  use {"scalameta/nvim-metals", requires = {"nvim-lua/plenary.nvim", "mfussenegger/nvim-dap"}}
  use {"terryma/vim-expand-region"}

  if packer_bootstrap then require('packer').sync() end
end)
