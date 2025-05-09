local actions        = require "telescope.actions"
local bibtex_actions = require('telescope-bibtex.actions')
local action_state   = require('telescope.actions.state')

require 'telescope'.setup {
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = actions.select_vertical, -- Use vsplit for 'v'
            },
            n = {
                ["<CR>"] = actions.select_vertical, -- Use vsplit for 'v'
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
