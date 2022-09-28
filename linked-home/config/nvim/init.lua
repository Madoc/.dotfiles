-- Skip initialization if Packer is not present. In that case, install it instead.
if not require("madoc.ensure_packer")() then return end

-- Global variables needed by other scripts.
require "madoc.globals"

-- Honor the `.vimrc` too.
require "madoc.load_vimrc"

-- Time to load the plugins.
require "madoc.plugins"

-- Specific settings for Neovide.
require "madoc.neovide"

-- LSP and Scala-Metals.

vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }
vim.opt_global.shortmess:remove("F"):append("c")
