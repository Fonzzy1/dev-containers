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

-- SmartVsplit: jump to existing buffer or open in vertical split
-- Pass the full entry to SmartVsplit so it can extract line/col info if available
-- Falls back to default selection for non-file pickers (e.g., highlights, autocommands)
local function smart_vsplit_selected_file(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    if not entry then
        print("No valid entry to open.")
        return
    end

    local has_path = entry.path or entry.filename or entry.uri
        or (entry.value and type(entry.value) == "table" and (entry.value.path or entry.value.filename))

    if not has_path then
        actions.select_default(prompt_bufnr)
        return
    end

    -- IMPORTANT: close telescope FIRST
    actions.close(prompt_bufnr)

    -- defer actual opening until UI fully exits telescope context
    vim.schedule(function()
        -- now safe to open split
        _G.SmartVsplit(entry)

        -- force normal mode (fix insert-mode carryover)
        vim.cmd("stopinsert")
    end)
end


require 'telescope'.setup {
    defaults = {
        -- No global <CR> mapping - each picker defines its own behavior
    },
    pickers = {
        -- find_files: SmartVsplit on <CR>, xdg-open on <C-o>
        find_files = {
            mappings = {
                i = {
                    ["<CR>"] = smart_vsplit_selected_file,
                    ["<C-o>"] = xdg_open_selected_file,
                },
                n = {
                    ["<CR>"] = smart_vsplit_selected_file,
                    ["<C-o>"] = xdg_open_selected_file,
                },
            },
        },
        -- live_grep: SmartVsplit on <CR>, xdg-open on <C-o>
        live_grep = {
            mappings = {
                i = {
                    ["<CR>"] = smart_vsplit_selected_file,
                    ["<C-o>"] = xdg_open_selected_file,
                },
                n = {
                    ["<CR>"] = smart_vsplit_selected_file,
                    ["<C-o>"] = xdg_open_selected_file,
                },
            },
        },
        -- lsp_document_symbols: SmartVsplit on <CR>
        lsp_document_symbols = {
            mappings = {
                i = {
                    ["<CR>"] = smart_vsplit_selected_file,
                },
                n = {
                    ["<CR>"] = smart_vsplit_selected_file,
                },
            },
        },
        -- lsp_references: SmartVsplit on <CR>
        lsp_references = {
            mappings = {
                i = {
                    ["<CR>"] = smart_vsplit_selected_file,
                },
                n = {
                    ["<CR>"] = smart_vsplit_selected_file,
                },
            },
        },
        -- lsp_definitions: SmartVsplit on <CR>
        lsp_definitions = {
            mappings = {
                i = {
                    ["<CR>"] = smart_vsplit_selected_file,
                },
                n = {
                    ["<CR>"] = smart_vsplit_selected_file,
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
    -- Research / Academic work
    ["Research"] = {
        ["name"] = "Research & Academic Search",
        ["Monash Library"] =
        "https://monash.primo.exlibrisgroup.com/discovery/search?vid=61MONASH_AU:MONUI&tab=MonashLibrary&search_scope=MonashAll&lang=en&query=any,contains,%s",
        ["Google Scholar"] = "https://scholar.google.com/scholar?q=%s",
        ["Semantic Scholar"] = "https://www.semanticscholar.org/search?q=%s",
        ["Connected Papers"] = "https://www.connectedpapers.com/search?q=%s",
        ["OpenAlex"] = "https://openalex.org/works?search=%s",
        ["Wikipedia"] = "https://en.wikipedia.org/wiki/Special:Search?search=%s",
        ["Marginalia"] = "https://search.marginalia.nu/search?query=%s",
        ["Reddit"] = "https://www.reddit.com/search/?q=%s",
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

    -- Development / Coding (all search-first)
    ["Dev"] = {
        ["name"] = "Development Search",
        ["GitHub"] = "https://github.com/search?q=%s",
        ["Stack Overflow"] = "https://stackoverflow.com/search?q=%s",
        ["Posit Community"] = "https://community.rstudio.com/search?q=%s",
        ["Prisma Docs"] = "https://www.prisma.io/docs/search?q=%s",
        ["Docker Docs"] = "https://docs.docker.com/search/?q=%s",
        ["Python Docs"] = "https://docs.python.org/3/search.html?q=%s",
        ["PyPI"] = "https://pypi.org/search/?q=%s",
        ["Quarto Docs"] = "https://quarto.org/docs/search.html?q=%s",
        ["Tidyverse Docs"] = "https://www.tidyverse.org/search?q=%s",
        ["Neovim Docs"] = "https://neovim.io/doc/user/",
    },

    -- Communication tools
    ["Comms"] = {
        ["name"] = "All my messaging platforms",
        ["Personal Emails"] = "https://outlook.live.com/mail/0/",
        ["Staff Email"] = "https://mail.google.com/mail/?authuser=alfie.chadwick@monash.edu",
        ["MCCCRH Slack"] = "https://mcccrh.slack.com",
        ["Soda Labs Slack"] = "https://soda-labs.slack.com",
        ["ADMS Slack"] = "https://adms-centre.slack.com/",
        ["Messenger"] = "https://www.messenger.com/",
        ["WhatsApp"] = "https://web.whatsapp.com/",
        ["Google Calendar"] = "https://calendar.google.com/calendar/u/1/r",
    },

    -- News (direct homepages)
    ["News"] = {
        ["name"] = "Australian & General News",
        ["The Conversation"] = "https://theconversation.com/au/",
        ["The Guardian Australia"] = "https://www.theguardian.com/au/",
        ["ABC News Australia"] = "https://www.abc.net.au/news/",
        ["Crikey"] = "https://www.crikey.com.au/",
        ["Inside Story"] = "https://insidestory.org.au/",
        ["The Saturday Paper"] = "https://www.thesaturdaypaper.com.au/",
    },

    -- News search (search within specific outlets)
    ["News Search"] = {
        ["name"] = "Search within news outlets",
        ["The Conversation"] = "https://theconversation.com/au/search?q=%s",
        ["The Guardian AU"] = "https://www.theguardian.com/au/search?q=%s",
        ["ABC News"] = "https://www.abc.net.au/news/search?query=%s",
        ["Crikey"] = "https://www.crikey.com.au/?s=%s",
        ["The Saturday Paper"] = "https://www.thesaturdaypaper.com.au/?s=%s",
        ["Inside Story"] = "https://insidestory.org.au/?s=%s",
    },

    -- Culture / Melbourne
    ["Culture"] = {
        ["name"] = "Culture & Melbourne",
        ["Broadsheet Melbourne"] = "https://www.broadsheet.com.au/melbourne",
        ["Album of the Year"] = "https://www.albumoftheyear.org/",
        ["shfl"] = "https://theshfl.com/",
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

    -- Hockey
    ["Hockey"] = {
        ["name"] = "Hockey Vic Fixtures",
        ["PEN A"] = "https://www.hockeyvictoria.org.au/games/team/21935/337151",
        ["Monday"] = "https://www.hockeyvictoria.org.au/games/team/22076/338838",
    },
}
require('browse').setup({
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
                    -- Check if any URLs in the group have a %s search placeholder
                    local has_search = false
                    for _, v in pairs(group) do
                        if type(v) == "string" and v:find("%%s") then
                            has_search = true
                            break
                        end
                    end

                    if has_search then
                        local query = vim.fn.input("Search: ")
                        if query == "" then return end
                        local encoded = vim.uri_encode(query)
                        for _, v in pairs(group) do
                            if type(v) == "string" and v:find("%%s") then
                                vim.fn.jobstart({ "xdg-open", v:gsub("%%s", encoded) }, { detach = true })
                            end
                        end
                    else
                        open_urls(group)
                    end
                elseif type(group) == "string" then
                    if group:find("%%s") then
                        local query = vim.fn.input("Search: ")
                        if query == "" then return end
                        local encoded = vim.uri_encode(query)
                        vim.fn.jobstart({ "xdg-open", group:gsub("%%s", encoded) }, { detach = true })
                    else
                        vim.fn.jobstart({ "xdg-open", group }, { detach = true })
                    end
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

-- Pick feeds from /root/feeds directory
function rss_picker()
    local feeds_dir = "/root/feeds"

    -- Get all .opml files from the feeds directory
    local opml_files = vim.fn.globpath(feeds_dir, "*.opml", false, true)

    if #opml_files == 0 then
        vim.notify("No OPML files found in " .. feeds_dir, vim.log.levels.WARN)
        return
    end

    -- Build feed set choices from filenames
    local feed_sets = {}
    for _, filepath in ipairs(opml_files) do
        local filename = vim.fn.fnamemodify(filepath, ":t:r")
        local display_name = filename:gsub("[^a-zA-Z0-9]", " "):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
        table.insert(feed_sets, {
            name = display_name,
            file = filepath
        })
    end

    local choices = vim.tbl_map(function(set)
        return set.name
    end, feed_sets)

    vim.ui.select(choices, { prompt = "Select feed set:" }, function(choice)
        if not choice then return end

        local selected_set = nil
        for _, set in ipairs(feed_sets) do
            if set.name == choice then
                selected_set = set
                break
            end
        end

        if selected_set then
            -- Read the OPML file
            local ok, lines = pcall(vim.fn.readfile, selected_set.file)
            if not ok or not lines then
                vim.notify("Could not read OPML file: " .. selected_set.file, vim.log.levels.ERROR)
                return
            end

            -- Join lines into a single string for parsing
            local xml = table.concat(lines, "\n")

            -- Parse feeds from OPML
            local feeds = {}
            for url in xml:gmatch('xmlUrl="([^"]+)"') do
                table.insert(feeds, url)
            end

            if #feeds == 0 then
                vim.notify("No feeds found in OPML file", vim.log.levels.WARN)
                return
            end

            -- Open the RSS picker with the feeds
            TelescopeRssPicker(feeds)
        end
    end)
end
