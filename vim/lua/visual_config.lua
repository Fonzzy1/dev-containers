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



require("windows").setup({
    autowidth = {     --		       |windows.autowidth|
        enable = true,
        winwidth = 7, --		        |windows.winwidth|
        filetype = {  --	      |windows.autowidth.filetype|
            help = 2,
        },
    },
    ignore = { --			  |windows.ignore|
        filetype = { "dashboard", 'lazygit', 'no-neck-pain' }
    },
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

-- Smart Vsplit: If file is already open in any window, jump to that buffer; otherwise open in vertical split
-- Accepts either a filename string or a Telescope-style entry table (with path/filename/uri/value and optional lnum/col)
-- Usage: :SmartVsplit 
--        :SmartVsplit { entry with path, lnum, col fields }
_G.SmartVsplit = function(filename_or_entry)
  local filename, target_lnum, target_col

  -- Determine if input is a string or table, extract file path and optional line/col
  if type(filename_or_entry) == "string" then
    -- Plain filename string - preserve existing behavior
    filename = filename_or_entry
  elseif type(filename_or_entry) == "table" then
    -- Telescope-style entry table - derive path from common fields
    local entry = filename_or_entry

    -- Extract file path from common Telescope fields (priority: path > filename > uri > value)
    filename = entry.path or entry.filename
    if not filename and entry.uri then
      -- Strip file:// prefix if present
      filename = entry.uri:gsub("^file://", "")
    end
    if not filename and entry.value then
      -- value might be a string path or a table with path field
      if type(entry.value) == "string" then
        filename = entry.value
      elseif type(entry.value) == "table" then
        filename = entry.value.path or entry.value.filename
      end
    end

    -- Extract line number (common fields: lnum, line, start_line)
    target_lnum = entry.lnum or entry.line or entry.start_line
    -- Extract column number (common fields: col, column, start_col)
    target_col = entry.col or entry.column or entry.start_col
  else
    print("SmartVsplit: invalid input - expected string or table")
    return
  end

  if not filename or filename == "" then
    print("SmartVsplit: no valid file path found")
    return
  end

  local target_file = vim.fn.fnamemodify(filename, ":p")
  local target_basename = vim.fn.fnamemodify(filename, ":t")

  -- Search for the buffer in all windows
  local found_bufnr = nil
  local found_winid = nil

  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local full_path = vim.fn.fnamemodify(bufname, ":p")
    local basename = vim.fn.fnamemodify(bufname, ":t")

    if full_path == target_file or basename == target_basename then
      found_bufnr = bufnr
      found_winid = winid
      break
    end
  end

  if found_bufnr then
    -- Jump to existing buffer
    vim.api.nvim_set_current_win(found_winid)
    print("Jumped to existing buffer: " .. target_basename)
  else
    -- Open in vertical split
    vim.cmd("vsplit " .. vim.fn.fnameescape(filename))
    print("Opened in vertical split: " .. target_basename)
  end

  -- Jump to specific line/column if provided
  if target_lnum and target_lnum > 0 then
    vim.api.nvim_win_set_cursor(0, { target_lnum, (target_col or 1) - 1 })
  end
end

-- Vim command wrapper for the smart vsplit
vim.api.nvim_create_user_command("SmartVsplit", function(opts)
  _G.SmartVsplit(opts.args)
end, {
  nargs = 1,
  complete = "file",
  desc = "Smart vsplit: jump to existing buffer or open in vertical split"
})
