-- Evaluates to a function that offers to install Packer if not already installed.
-- If Packer is installed, the function returns `true`. Otherwise, `false`.

local install_packer = function()
  local decision = vim.fn.inputlist {
    "Packer plugin not found. Install it?",
    "[1] Install packer and all plugins.",
    "[2] Skip installation."
  }
  if decision ~= 1 then return end

  local packer_dir = vim.fn.stdpath("data") .. "/site/pack/packer/start/"
  vim.fn.mkdir(packer_dir, "p")

  print("Downloading packer.nvim ...")

  local git_output =
    vim.fn.system("git clone https://github.com/wbthomason/packer.nvim '" .. packer_dir .. "/packer.nvim'")

  print(git_output)
  print("Packer downloaded.")
  print("Restart and run:")
  print()
  print("    :PackerInstall")
  print("    :PackerSync")
  print()
end

return function()
  if not pcall(require, "packer") then
    install_packer()
    return false
  end
  return true
end
