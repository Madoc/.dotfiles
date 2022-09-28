-- Displays a fancy status bar.

return {
  setup = function()
    vim.opt_global.termguicolors = true -- No idea why the setting from `.vimrc` does not take effect.
    require("feline").setup()
  end
}
