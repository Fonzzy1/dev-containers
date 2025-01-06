require("aerial").setup()

-- Define the function in Lua
function LeftBarToOutline()
  vim.cmd("call LeftBarToggle()") -- or use the appropriate Lua function if available
  vim.cmd("SymbolsOutlineOpen") -- or the equivalent Lua function
end

-- Map the function to a key (e.g., <Leader>s)
vim.api.nvim_set_keymap('n', 's', ':lua LeftBarToOutline()<CR>', { noremap = true, silent = true })
