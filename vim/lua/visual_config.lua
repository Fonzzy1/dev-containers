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
    modes = { "n", "no", "c", "o" },
    callbacks = {
        on_enable = function (_, win)
              vim.wo[win].conceallevel = 2;
          -- This will prevent Tree-sitter concealment being disabled on the cmdline mode
              vim.wo[win].concealcursor = "n";
           end
     },
    },
  markdown = {
     headings = presets.headings.slanted,
     tables = presets.tables.rounded,
     code_blocks = {
      enable = true,
      min_width = 80,
      pad_amount = 0,
    },
  list_items = {
          shift_width = function (buffer, item)
                  local parent_indnet = math.max(1, item.indent - vim.bo[buffer].shiftwidth);
                  return parent_indent+vim.bo[buffer].shiftwidth-1;
          end,
          marker_minus = {
                  add_padding = false
          }
    }
}})


vim.g.virtcolumn_char = '▕' -- char to display the line
vim.g.virtcolumn_priority = 10 -- priority of extmark

require("ibl").setup({
  exclude = {
    filetypes = {
      'dashboard',
      'lspinfo',
      'packer',
      'checkhealth',
      'help',
      'man',
      'gitcommit',
      'TelescopePrompt',
      'TelescopeResults',
      ''
    }
  }
})
