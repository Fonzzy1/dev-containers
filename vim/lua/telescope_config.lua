local actions        = require "telescope.actions"
local bibtex_actions = require('telescope-bibtex.actions')
local action_state   = require('telescope.actions.state')

vim.api.nvim_create_autocmd("User", {
    pattern = "TelescopePreviewerLoaded",
    callback = function()
        vim.opt_local.wrap = true
    end,
})

local function xdg_open_selected_file(prompt_bufnr)
    local entry = action_state.get_selected_entry()
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
                    ["<c-a>"] = bibtex_actions.citation_append('[@{{label}}] -- {{abstract}}'),
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



function TelescopeRssPicker(urls)
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values

    -- Check input
    if not urls or type(urls) ~= "table" or #urls == 0 then
        vim.notify("No feed URLs provided", vim.log.levels.WARN)
        return
    end

    -- Build command: list of URLs as arguments
    local py_script = "/scripts/feed_parser.py"
    local args = { "python3", py_script }
    for _, url in ipairs(urls) do table.insert(args, url) end

    -- Start job and collect output (synchronously for simplicity)
    local result = vim.fn.system(args)
    if vim.v.shell_error ~= 0 then
        vim.notify("feed_parser.py error: " .. result, vim.log.levels.ERROR)
        return
    end

    local ok, entries = pcall(vim.fn.json_decode, result)
    local valid_entries = {}

    if ok and entries and type(entries) == "table" then
        for _, entry in ipairs(entries) do
            if entry and entry.title and entry.source then
                table.insert(valid_entries, entry)
            end
        end
    end

    if #valid_entries == 0 then
        vim.notify("No feed entries found or JSON decode error",
            vim.log.levels.WARN)
        return
    end

    pickers.new({}, {
        prompt_title = "RSS",
        finder = finders.new_table {
            results = valid_entries,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format("[%s] %s", entry.date,
                        entry.title),
                    ordinal = entry.title .. " " .. entry.date .. " " .. entry.source,
                }
            end
        },
        sorter = conf.generic_sorter({}),
        previewer = require('telescope.previewers').new_buffer_previewer {
            define_preview = function(self, entry, status)
                local e      = entry.value or entry
                local title  = e.title or ""
                local desc   = e.description or ""
                local source = e.source or ""
                local date   = e.date or ""

                local lines  = {
                    "Title: " .. title,
                    "Source: " .. source,
                    "Date:   " .. date,
                    "",
                    desc
                }
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            end
        },
        attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            local open_link = function()
                local entry = action_state.get_selected_entry()
                if entry and entry.value and entry.value.link and entry.value.link
                    ~= "" then
                    vim.fn.jobstart({ "xdg-open", entry.value.link }, {
                        detach =
                            true
                    })
                else
                    vim.notify("No link to open", vim.log.levels.WARN)
                end
            end
            map('i', '<CR>', open_link)
            map('n', '<CR>', open_link)
            return true
        end,
    }):find()
end

vim.keymap.set('n', 'sp', function()
    TelescopeRssPicker({
        -- The Conversation
        "https://theconversation.com/au/articles.atom",
        -- The Conversation - Enviroment
        "https://theconversation.com/au/environment/articles.atom",
        -- The Conversation - Politics
        "https://theconversation.com/au/politics/articles.atom",
        -- The Guardian AU
        "https://www.theguardian.com/au/rss",
        -- The Guardian AU - Enviroment
        "https://www.theguardian.com/au/environment/rss",
        -- The Guardian AU - Politics
        "https://www.theguardian.com/au/politics/rss",
        -- The Guardian AU - Opinion
        "https://www.theguardian.com/au/opinion/rss",
        -- ABC News
        "https://www.abc.net.au/news/feed/10719986/rss.xml",
        -- ABC News - Long Reads
        "https://www.abc.net.au/news/feed/104496728/rss.xml",
        -- Crikey
        'https://www.crikey.com.au/feed/',
        -- NYT Climate
        'https://rss.nytimes.com/services/xml/rss/nyt/Climate.xml'
    })
end)

vim.keymap.set('n', 'sj', function()
    TelescopeRssPicker({
        -- Enviromental Communication
        'https://www.tandfonline.com/feed/rss/renc20',
        -- Global Climate Change
        'https://rss.sciencedirect.com/publication/science/09593780',
        -- Nature Climate Change
        'https://www.nature.com/nclimate.rss',
        -- Political Communication
        'https://www.tandfonline.com/feed/rss/upcp20',
        -- Annals of the International Communication Association
        'https://academic.oup.com/rss/site_6685/4208.xml',
        -- Information, Communication and Society
        'https://www.tandfonline.com/feed/rss/rics20',
        -- Journalism & Mass Communication Quarterly
        'https://journals.sagepub.com/action/showFeed?ui=0&mi=ehikzz&ai=2b4&jc=jmq&type=etoc&feed=rss',
        -- Digital Journalism
        'https://www.tandfonline.com/feed/rss/rdij20',
        -- Journal of Computer-Mediated Communication
        'https://academic.oup.com/rss/site_6096/3967.xml',
        -- Journal of Political Marketing
        'https://www.tandfonline.com/feed/rss/wplm20',
        -- Enviromental Science and Policy
        'https://rss.sciencedirect.com/publication/science/14629011',
        -- Computational Communication Research
        'https://journal.computationalcommunication.org/gateway/plugin/WebFeedGatewayPlugin/rss2',
        -- Journal of Computational Social Science
        'https://link.springer.com/search.rss?new-search=true&query=*&content-type=Article&sortBy=relevance&search-within=Journal&facet-journal-id=42001',
        -- Big Data and Society
        'https://journals.sagepub.com/action/showFeed?ui=0&mi=ehikzz&ai=2b4&jc=bds&type=etoc&feed=rss',
        -- Journal of Information Technology & Politics
        'https://www.tandfonline.com/feed/rss/witp20',
        -- Australian Journal of Political Science
        'https://www.tandfonline.com/feed/rss/cajp20',
        -- Arxiv
        'http://export.arxiv.org/api/query?search_query=cat:cs.CL+AND+all:"climate+change"+AND+all:(framing+OR+denial+OR+misinformation)&start=0&max_results=50&sortBy=lastUpdatedDate&sortOrder=descending',
        -- Arxiv Automated framing
        'http://export.arxiv.org/api/query?search_query=cat:cs.cl+and+all:media+and+all:framing&start=0&max_results=50&sortby=lastUpdateddate&sortorder=descending',
        -- Automated Misinformation Analysis
        'http://export.arxiv.org/api/query?search_query=cat:cs.CL+AND+all:misinformation&start=0&max_results=50&sortBy=lastUpdatedDate&sortOrder=descending',
        -- Automated Denial Analysis
        'http://export.arxiv.org/api/query?search_query=cat:cs.CL+AND+all:denial&start=0&max_results=50&sortBy=lastUpdatedDate&sortOrder=descending',
        -- Automated Australian Political Analysis
        'http://export.arxiv.org/api/query?search_query=cat:cs.CL+AND+(all:Australia+AND+all:politics)&start=0&max_results=50&sortBy=updatedDate&sortOrder=descending',
    })
end)
