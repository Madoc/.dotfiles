HOME = os.getenv("HOME")

vim.cmd("source " .. HOME .. "/.vimrc")

if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_remember_window_size = true
end
