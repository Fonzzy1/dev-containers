local actions        = require "telescope.actions"
local bibtex_actions = require('telescope-bibtex.actions')
local action_state   = require('telescope.actions.state')
local pickers        = require('telescope.pickers')
local finders        = require('telescope.finders')
local conf           = require('telescope.config').values
local themes         = require("telescope.themes")

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
        git_status = {
            mappings = {
                i = {
                    ["<CR>"] = actions.select_vertical,
                },
                n = {
                    ["<CR>"] = actions.select_vertical,
                },
            },
        },
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

                    -- Shift+Enter: insert @key; and keep picker open
                    ["<S-CR>"] = function(prompt_bufnr)
                        local entry = action_state.get_selected_entry()
                        if not entry then return end

                        -- extract key
                        local content = table.concat(entry.id.content, "\n")
                        local key = content:match("@%w+{(.-),")

                        -- capture original buffer (the one Telescope was opened from)
                        local original_buf = vim.fn.bufnr("#")

                        vim.schedule(function()
                            -- insert into the *original* buffer, not Telescope prompt
                            vim.api.nvim_set_current_buf(original_buf)
                            vim.api.nvim_put({ "@" .. key .. ";" }, "c", true, true)
                            vim.api.nvim_set_current_win(0) -- ensure cursor stays correct
                        end)

                        -- keep Telescope open and move to next selection
                        actions.move_selection_next(prompt_bufnr)
                    end,

                    ["<C-o>"] = function(prompt_bufnr)
                        local entry = action_state.get_selected_entry().id.content
                        entry = table.concat(entry, "\n")
                        local key = entry:match("@%w+{(.-),")
                        vim.fn.jobstart({ "xdg-open", "/wiki/References/" .. key .. ".pdf" }, { detach = true })
                    end,

                    ["<C-i>"] = bibtex_actions.citation_append('({{url}}?cite_key={{label}})'),
                },
            }
        },
    },
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')
require("telescope").load_extension("lazygit")
-- default values for the setup
local bookmarks = {
    -- Communication tools
    ["Comms"] = {
        ["name"] = "All my messaging platforms",
        ["Personal Emails"] = "https://outlook.live.com/mail/0/",
        ["Staff Email"] = "https://mail.google.com/mail/?authuser=alfie.chadwick@monash.edu",
        ["Student Email"] = "https://mail.google.com/mail/?authuser=alfie.chadwick1@monash.edu",
        ["MCCCRH Slack"] = "https://mcccrh.slack.com",
        ["Soda Labs Slack"] = "https://soda-labs.slack.com",
        ["ADMS Slack"] = "https://adms-centre..slack.com/",
        ["Messenger"] = "https://www.messenger.com/",
        ["WhatsApp"] = "https://web.whatsapp.com/",
        ["Google Calendar"] = "https://calendar.google.com/calendar/u/1/r",
    },

    -- Development / Coding (all search-first)
    ["Dev"] = {
        ["name"] = "Development Search",
        ["GitHub"] = "https://github.com/search?q=%s",
        ["Stack Overflow"] = "https://stackoverflow.com/search?q=%s",
        ["Prisma Docs"] = "https://www.prisma.io/docs/search?q=%s",
        ["Docker Docs"] = "https://docs.docker.com/search/?q=%s",
        ["Python Docs"] = "https://docs.python.org/3/search.html?q=%s",
        ["PyPI"] = "https://pypi.org/search/?q=%s",
        ["Quarto Docs"] = "https://quarto.org/docs/search.html?q=%s",
        ["Tidyverse Docs"] = "https://www.tidyverse.org/search?q=%s",
    },

    -- Research / Academic work
    ["Research"] = {
        ["name"] = "Research & Academic Search",
        ["Monash Library"] =
        "https://monash.primo.exlibrisgroup.com/discovery/search?vid=61MONASH_AU:MONUI&tab=MonashLibrary&search_scope=MonashAll&lang=en&query=any,contains,%s",
        ["Google Scholar"] = "https://scholar.google.com/scholar?q=%s",
        ["Semantic Scholar"] = "https://www.semanticscholar.org/search?q=%s",
        ["Wikipedia"] = "https://en.wikipedia.org/wiki/Special:Search?search=%s",
        ["Marginalia"] = "https://search.marginalia.nu/search?query=%s",
        ["Reddit"] = "https://www.reddit.com/search/?q=%s",
        ["Kagi"] = "https://kagi.com/search?q=%s"

    },

    -- News
    ["News"] = {
        ["name"] = "Australian & General News",
        ["The Conversation"] = "https://theconversation.com/au/",
        ["The Guardian Australia"] = "https://www.theguardian.com/au/",
        ["ABC News Australia"] = "https://www.abc.net.au/news/",
        ["Crikey"] = "https://www.crikey.com.au/",
    },

    -- Personal / Life admin
    ["Life"] = {
        ["name"] = "Life & Everyday Tools",
        ["Money - Raiz"] = "https://app.raizinvest.com.au/?activeTab=today",
        ["Money - Splitwise"] = "https://secure.splitwise.com/#/dashboard",
        ["Money - Afterpay"] = "https://portal.afterpay.com/en-AU/home",
        ["Google Maps"] = "https://www.google.com/maps/search/%s",
        ["Uber"] = "https://m.uber.com/",
        ["PTV (Myki)"] = "https://www.ptv.vic.gov.au/tickets/myki",
        ["Weather (BOM)"] = "http://www.bom.gov.au/vic/forecasts/melbourne.shtml",
    },

    -- Monash work-specific tools
    ["Monash"] = {
        ["name"] = "Monash Tools",
        ["My Monash"] = "https://my.monash.edu.au/",
        ["Timesheet"] = "https://eservices.monash.edu.au/irj/portal#TimeSheetEntry-manage",
        ["WES"] = "https://my.monash.edu.au/wes/",
        ["O-Park"] = "https://portal.opark.com.au/motorist/dashboard",
        ["Moodle"] = "https://lms.monash.edu/",
    },

    -- Hockey
    ["Hockey"] = {
        ["name"] = "Hockey Vic Fixtures",
        ["PEN A"] = "https://www.hockeyvictoria.org.au/games/team/21935/337151",
        ["Monday"] = "https://www.hockeyvictoria.org.au/games/team/22076/338838",
    },
}
require('browse').setup({
    -- search provider you want to use
    provider = "google", -- duckduckgo, bing

    bookmarks = bookmarks,
    -- either pass it here or just pass the table to the functions
    -- see below for more
    icons = {
        bookmark_alias = "", -- if you have nerd fonts, you can set this to ""
        bookmarks_prompt = "📑   ", -- if you have nerd fonts, you can set this to "󰂺 "
        grouped_bookmarks = "", -- if you have nerd fonts, you can set this to 
    },
    -- if you want to persist the query for grouped bookmarks
    -- See https://github.com/lalitmee/browse.nvim/pull/23
    persist_grouped_bookmarks_query = false
})


function open_urls(tbl)
    for _, v in pairs(tbl) do
        if type(v) == "string" and not v:find("%%s") then
            vim.fn.jobstart({ "xdg-open", v }, { detach = true })
        end
    end
end

function browse_bookmarks()
    local keys = vim.tbl_keys(bookmarks)
    table.sort(keys)

    local theme = themes.get_dropdown({
        prompt_title = "📚 Bookmark Groups",
        results_height = 15,
        width = 0.5,
    })

    pickers.new(theme, {
        finder = finders.new_table({
            results = keys,
        }),

        sorter = conf.generic_sorter(theme),

        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local key = selection[1]
                local group = bookmarks[key]

                if type(group) == "table" then
                    open_urls(group)
                elseif type(group) == "string" and not group:find("%%s") then
                    vim.fn.jobstart({ "xdg-open", group }, { detach = true })
                end
            end)
            return true
        end,
    }):find()
end

function TelescopeRssPicker(urls)
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

vim.keymap.set('n', 'sj', function()
    TelescopeRssPicker({
        -- Environmental Communication
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
        -- Environmental Science and Policy
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
        'http://export.arxiv.org/api/query?search_query=cat:cs.CL+AND+(all:Australia+AND+all:politics)&start=0&max_results=50&sortBy=lastUpdatedDate&sortOrder=descending',
        -- energy policy
        'https://rss.sciencedirect.com/publication/science/03014215',
        -- Energy and social science
        'https://rss.sciencedirect.com/publication/science/22146296'
    })
end)
