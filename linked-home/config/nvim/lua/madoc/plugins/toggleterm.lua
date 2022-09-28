-- Terminal that can be toggled on and off.

return {
  setup = function()
    require("toggleterm").setup {
      open_mapping = [[<F12>]]
    }
  end
}
