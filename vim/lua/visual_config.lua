require('csvview').setup()
-- Set autocommad to set  :CsvViewEnable when opening CSV
--
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.csv" },
    command = ":CsvViewEnable<CR>"
})

local markview = require("markview")
local presets = require("markview.presets")

--
markview.setup({
    preview = {
        enable = true,
        filetypes = { "md", "rmd", "quarto", "aichat" },
        ignore_buftypes = {},
    },
    latex = {
        enable = true
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
            shift_width = function(buffer, item)
                local parent_indnet = math.max(1, item.indent - vim.bo[buffer].shiftwidth);
                return parent_indent + vim.bo[buffer].shiftwidth - 1;
            end,
            marker_minus = {
                add_padding = false
            },
            marker_minus = {
                add_padding = false
            },

            marker_plus = {
                add_padding = false
            },

            marker_star = {
                add_padding = false
            },

            marker_dot = {
                add_padding = false
            },

            marker_parenthesis = {
                add_padding = false
            }
        }
    }
})


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

require("windows").setup({
    autowidth = {     --		       |windows.autowidth|
        enable = true,
        winwidth = 5, --		        |windows.winwidth|
        filetype = {  --	      |windows.autowidth.filetype|
            help = 2,
        },
    },
    ignore = { --			  |windows.ignore|
        buftype = { "quickfix" },
        filetype = { "NERDTree", "aerial" }
    },
    animation = {
        enable = true,
        duration = 300,
        fps = 30,
        easing = "in_out_sine"
    }
})
