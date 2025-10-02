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
        ignore_buftypes = {}
    },
    latex = {
        enable = true
    },
    markdown = {
        headings = presets.headings.slanted,
        block_quotes = {
            enable = true,
            default = {
                border = ">",
                hl = "Comment"
            },
        },
        tables = presets.tables.rounded,
        code_blocks = {
            enable = true,
            min_width = 80,
            pad_amount = 0,
        },
        list_items = {
            shift_width = function(buffer, item)
                local parent_indent = math.max(1, item.indent - vim.bo[buffer].shiftwidth);
                return parent_indent + vim.bo[buffer].shiftwidth - 1;
            end,
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
    },
    markdown_inline = {
        hyperlinks = {

            ["[%s;]?@"] = {
                --- github.com/<user>
                hl = "MarkviewPalette7Fg",
                corner_left = "[",
                padding_left = "",
                icon = "",
                padding_right = "",
                corner_right = "]",
                -- padding_left

                -- icon

                -- padding_right

                -- corner_right

                -- corner_left_hl

                -- padding_left_hl

                -- icon_hl

                -- padding_right_hl

                -- corner_right_hl
            }
        },
    },

})


vim.g.virtcolumn_char = '▕' -- char to display the line
vim.g.virtcolumn_priority = 10 -- priority of extmark

require("ibl").setup({
    exclude = {
        filetypes = {
            'dashboard',
            'lazygit',
            'lspinfo',
            'packer',
            'checkhealth',
            'help',
            'man',
            'gitcommit',
            'TelescopePrompt',
            'TelescopeResults',
            '',
            'terminal',
            'rnvimr'
        }
    },
})

require("windows").setup({
    autowidth = {      --		       |windows.autowidth|
        enable = true,
        winwidth = 12, --		        |windows.winwidth|
        filetype = {   --	      |windows.autowidth.filetype|
            help = 2,
        },
    },
    ignore = { --			  |windows.ignore|
        filetype = { "NvimTree", "aerial", "dashboard", 'lazygit' }
    },
    animation = {
        enable = false,
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
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,       -- add a border to hover docs and signature help
    },
})
require('gitsigns').setup {
    signs_staged_enable          = true,
    signcolumn                   = false, -- Toggle with `:Gitsigns toggle_signs`
    numhl                        = true,  -- Toggle with `:Gitsigns toggle_numhl`
    linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir                 = {
        follow_files = true
    },
    auto_attach                  = true,
    attach_to_untracked          = false,
    current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    sign_priority                = 6,
    update_debounce              = 100,
    status_formatter             = nil,   -- Use default
    max_file_length              = 40000, -- Disable if file is longer than this (in lines)
    preview_config               = {
        -- Options passed to nvim_open_win
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
    },
}
