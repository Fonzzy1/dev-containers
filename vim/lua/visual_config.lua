require('csvview').setup()
-- Set autocommad to set  :CsvViewEnable when opening CSV
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.csv"},
  command = ":CsvViewEnable<CR>"
})

local markview = require("markview")
local presets = require("markview.presets").headings
--
markview.setup({
  markdown = {
    enable = true,
    block_quotes = {
      ["^NOTE$"] = {},
    },
    code_blocks = {
      enable = true,
      style = "block",
      label_direction = "right",
      border_hl = "MarkviewCode",
      info_hl = "MarkviewCodeInfo",
      min_width = 80,
      pad_amount = 2,
      pad_char = " ",
      sign = true,
      default = {
        block_hl = "MarkviewCodeInfo",
        pad_hl = "MarkviewCodeInfo",
      },
    list_items = { indent_size = 2, shift_width=0 },
  },
})

