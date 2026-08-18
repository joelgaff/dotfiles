-- Load theme from omarchy's current theme
local theme_path = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")
if vim.fn.filereadable(theme_path) == 1 then
  return dofile(theme_path)
end
return {}
