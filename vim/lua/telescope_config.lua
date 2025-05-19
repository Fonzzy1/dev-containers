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
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = actions.select_vertical, -- Use vsplit for 'v'
                ["<C-o>"] = xdg_open_selected_file  -- Open file with default system
            },
            n = {
                ["<CR>"] = actions.select_vertical, -- Use vsplit for 'v'
                ["<C-o>"] = xdg_open_selected_file
            },
        },
    },
    extensions = {
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
