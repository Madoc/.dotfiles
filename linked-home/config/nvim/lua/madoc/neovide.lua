local is_macos = vim.loop.os_uname().sysname == "Darwin"

if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_remember_window_size = true

  if is_macos then
    vim.g.neovide_macos_alt_is_meta = true
  end
end
