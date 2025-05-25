local actions        = require "telescope.actions"
local bibtex_actions = require('telescope-bibtex.actions')
local action_state   = require('telescope.actions.state')

local function xdg_open_selected_file(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    if entry and entry.path then
        vim.fn.jobstart({ "xdg-open", entry.path }, { detach = true })
    else
        print("No valid path to open.")
    end
end


require 'telescope'.setup {
    pickers = {
        find_files = {
            mappings = {
                i = {
                    ["<CR>"] = actions.select_vertical,
                    ["<C-o>"] = xdg_open_selected_file,
                },
                n = {
                    ["<CR>"] = actions.select_vertical,
                    ["<C-o>"] = xdg_open_selected_file,
                },
            },
        },
        live_grep = {
            mappings = {
                i = {
                    ["<CR>"] = actions.select_vertical,
                    ["<C-o>"] = xdg_open_selected_file,
                },
                n = {
                    ["<CR>"] = actions.select_vertical,
                    ["<C-o>"] = xdg_open_selected_file,
                },
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        },
        bibtex = {
            -- Depth for the *.bib file
            depth = 2,
            search_keys = { 'author', 'title', 'abstract' },
            wrap = true,
            citation_max_auth = 1,
            custom_formats = {
                { id = 'quarto', cite_marker = '@%s' },
            },
            format = 'quarto',
            mappings = {
                i = {
                    ["<CR>"] = bibtex_actions.key_append('@%s'),
                    ["<c-o>"] = function(prompt_bufnr)
                        local entry = action_state.get_selected_entry().id.content
                        entry = table.concat(entry, "\n")
                        local key = entry:match("@%w+{(.-),")
                        os.execute('xdg-open /wiki/References/' .. key .. '.pdf')
                    end,
                    ["<c-i>"] = bibtex_actions.citation_append('({{url}}?cite_key={{label}}'),
                },
            },
        },
    },
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')
-- default values for the setup
require('browse').setup({
    -- search provider you want to use
    provider = "duckduckgo", -- duckduckgo, bing

    -- either pass it here or just pass the table to the functions
    -- see below for more
    bookmarks = {},
    icons = {
        bookmark_alias = "->",    -- if you have nerd fonts, you can set this to ""
        bookmarks_prompt = "",    -- if you have nerd fonts, you can set this to "󰂺 "
        grouped_bookmarks = "->", -- if you have nerd fonts, you can set this to 
    },
    -- if you want to persist the query for grouped bookmarks
    -- See https://github.com/lalitmee/browse.nvim/pull/23
    persist_grouped_bookmarks_query = false,
})
