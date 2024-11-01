require("outline").setup({
  outline_window = {
    -- Where to open the split window: right/left
    position = 'left',
  }
})

-- Define the function in Lua
function LeftBarToOutline()
  vim.cmd("call LeftBarToggle()") -- or use the appropriate Lua function if available
  vim.cmd("Outline") -- or the equivalent Lua function
end

-- Map the function to a key (e.g., <Leader>s)
vim.api.nvim_set_keymap('n', 's', ':lua LeftBarToOutline()<CR>', { noremap = true, silent = true })
