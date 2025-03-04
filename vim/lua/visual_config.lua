require('csvview').setup()
-- Set autocommad to set  :CsvViewEnable when opening CSV
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.csv"},
  command = ":CsvViewEnable<CR>"
})

local markview = require("markview")
local presets = require("markview.presets")
--
markview.setup({
  markdown = {
    enable = true,
    headings = presets.headings.slanted,
    tables = presets.tables.rounded,
    code_blocks = {
      enable = true,
      min_width = 80,
      pad_amount = 0,
    },
    list_items = { indent_size = 0, shift_width = 1 },
  },
})
