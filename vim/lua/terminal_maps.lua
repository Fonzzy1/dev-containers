-- terminal_maps.lua
-- Programmatically mirrors all normal and visual mode maps into terminal mode
-- using <C-BS> as a leader prefix. Edit maps.vim as normal -- this stays in sync.

local function setup_terminal_maps()
  local leader = "<C-BS>"

  -- Collect lhs keys from normal and visual mode maps
  local seen = {}
  for _, mode in ipairs({ "n", "v" }) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      local lhs = map.lhs
      -- Skip single-key or <Plug> / <SNR> internal maps
      if not seen[lhs] and not lhs:match("^<Plug>") and not lhs:match("^<SNR>") then
        seen[lhs] = true
        -- <C-\><C-n> exits terminal insert mode silently, then replays the lhs
        vim.keymap.set("t", leader .. lhs, function()
          local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>" .. lhs, true, false, true)
          vim.api.nvim_feedkeys(keys, "m", false)
        end, { noremap = true, silent = true, desc = "terminal: " .. lhs })
      end
    end
  end
end

-- Run after VimEnter so all maps.vim keymaps are already registered
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = setup_terminal_maps,
})
