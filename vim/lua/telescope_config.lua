local actions = require "telescope.actions"
local bibtex_actions = require('telescope-bibtex.actions')

require 'telescope'.setup {
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = actions.select_vertical, -- Use vsplit for Enter in insert mode
            },
            n = {
                ["<CR>"] = actions.select_vertical, -- Use vsplit for Enter in normal mode
            },
        },
    },
    extensions = {
        bibtex = {
            -- Depth for the *.bib file
            depth = 2,
            search_keys = { 'author', 'year', 'title', 'keywords' },
            wrap = true,
            citation_max_auth = 1,
            custom_formats = {
                { id = 'quarto', cite_marker = '[[%s]]' },
            },
            format = 'quarto',
            mappings = {
                i = {
                    ["<CR>"] = bibtex_actions.key_append('[[%s]]'),
                    ["o"] = function(prompt_bufnr)
                        local entry =
                            require("telescope.actions.state").get_selected_entry(prompt_bufnr)
                        local citation = entry.value
                        actions.close(prompt_bufnr)
                        os.execute("xdg-open references/" .. citation .. ".pdf")
                    end,
                },
                n = {
                    ["<CR>"] = bibtex_actions.key_append('[[%s]]'),
                    ["o"] = function(prompt_bufnr)
                        local entry =
                            require("telescope.actions.state").get_selected_entry(prompt_bufnr)
                        local citation = entry.value
                        actions.close(prompt_bufnr)
                        os.execute("xdg-open references/" .. citation .. ".pdf")
                    end,
                },
            },
        },
    },
}
