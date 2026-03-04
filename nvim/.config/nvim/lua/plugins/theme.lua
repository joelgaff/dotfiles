-- Load theme from omarchy's current theme
local theme_path = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
if vim.fn.filereadable(theme_path) == 1 then
  return dofile(theme_path)
end
return {}
