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
        filetype = { "nerdtree", "aerial", "dashboard" }
    },
    animation = {
        enable = true,
        duration = 300,
        fps = 30,
        easing = "in_out_sine"
    }
})

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})
