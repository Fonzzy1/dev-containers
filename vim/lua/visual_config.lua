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
  preview = {
    enable = true,
    enable_hybrid_mode = false,
    filetypes = { "md", "rmd", "quarto", "aichat" },
    ignore_buftypes = {},
    modes = { "n", "no", "c" },
    },
  markdown = {
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


vim.g.virtcolumn_char = '▕' -- char to display the line
vim.g.virtcolumn_priority = 10 -- priority of extmark


