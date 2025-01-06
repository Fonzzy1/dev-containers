require("aerial").setup({
  -- Priority list of preferred backends for aerial.
  -- This can be a filetype map (see :help aerial-filetype-map)
  backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },

  layout = {
    -- These control the width of the aerial window.
    -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a list of mixed types.
    -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
    max_width = { 40, 0.2 },
    width = nil,
    min_width = 32,

    -- key-value pairs of window-local options for aerial window (e.g. winhl)
    win_opts = {},

    default_direction = "left",

    placement = "edge",


  },

  -- Determines how the aerial window decides which buffer to display symbols for
  --   window - aerial window will display symbols for the buffer in the window from which it was opened
  --   global - aerial window will display symbols for the current window
  attach_mode = "global",

  -- Defaults to true, unless `on_attach` is provided, then it defaults to false
  lazy_load = true,

  -- Disable aerial on files with this many lines
  disable_max_lines = 10000,

  -- Disable aerial on files this size or larger (in bytes)
  disable_max_size = 2000000, -- Default 2MB

  -- A list of all symbols to display. Set to false to display all symbols.
  -- This can be a filetype map (see :help aerial-filetype-map)
  -- To see all available values, see :help SymbolKind
  filter_kind = false

  -- Jump to symbol in source window when the cursor moves
  autojump = true,

  -- This can be a function (see :help aerial-open-automatic)
  open_automatic = false,

  -- Run this command after jumping to a symbol (false will disable)
  post_jump_cmd = "normal! zz",

})

-- Define the function in Lua
function LeftBarToOutline()
  vim.cmd("call LeftBarToggle()") -- or use the appropriate Lua function if available
  vim.cmd("AerialOpen") -- or the equivalent Lua function
end

-- Map the function to a key (e.g., <Leader>s)
vim.api.nvim_set_keymap('n', 's', ':lua LeftBarToOutline()<CR>', { noremap = true, silent = true })
