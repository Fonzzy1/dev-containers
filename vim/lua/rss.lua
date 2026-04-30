local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")

local function iso_date_days_ago(days)
    local now = os.time()
    local ts = now - (days * 24 * 60 * 60)
    return os.date("!%Y-%m-%d", ts)
end

local function select_date_range(callback)
    local options = {
        { label = "Today",          since = iso_date_days_ago(0) },
        { label = "Last 3 days",    since = iso_date_days_ago(3) },
        { label = "Last 7 days",    since = iso_date_days_ago(7) },
        { label = "Last 14 days",   since = iso_date_days_ago(14) },
        { label = "Last 30 days",   since = iso_date_days_ago(30) },
        { label = "All",            since = nil },
        { label = "Custom date...", since = "CUSTOM" },
    }

    vim.ui.select(vim.tbl_map(function(o)
        return o.label
    end, options), { prompt = "Select date range:" }, function(choice)
        if not choice then
            return
        end

        local selected = nil
        for _, opt in ipairs(options) do
            if opt.label == choice then
                selected = opt
                break
            end
        end

        if not selected then
            vim.notify("Invalid date range selection", vim.log.levels.ERROR)
            return
        end

        if selected.since == "CUSTOM" then
            vim.ui.input({
                prompt = "Enter start date (YYYY-MM-DD): ",
            }, function(input)
                if not input or input == "" then
                    return
                end

                if not input:match("^%d%d%d%d%-%d%d%-%d%d$") then
                    vim.notify("Invalid date format. Use YYYY-MM-DD", vim.log.levels.ERROR)
                    return
                end

                callback(input)
            end)
        else
            callback(selected.since)
        end
    end)
end

local function run_feed_parser(urls, since_date)
    if not urls or type(urls) ~= "table" or #urls == 0 then
        vim.notify("No feed URLs provided", vim.log.levels.WARN)
        return nil
    end

    local py_script = "/scripts/feed_parser.py"
    local cmd = { "python3", py_script }

    if since_date and since_date ~= "" then
        table.insert(cmd, "--since")
        table.insert(cmd, since_date)
    end

    for _, url in ipairs(urls) do
        table.insert(cmd, url)
    end

    local result
    if vim.system then
        local obj = vim.system(cmd, { text = true }):wait()
        if obj.code ~= 0 then
            vim.notify("feed_parser.py error:\n" .. (obj.stderr or ""), vim.log.levels.ERROR)
            return nil
        end
        result = obj.stdout
    else
        local escaped = {}
        for _, part in ipairs(cmd) do
            table.insert(escaped, vim.fn.shellescape(part))
        end
        result = vim.fn.system(table.concat(escaped, " "))
        if vim.v.shell_error ~= 0 then
            vim.notify("feed_parser.py error:\n" .. result, vim.log.levels.ERROR)
            return nil
        end
    end

    local ok, entries = pcall(vim.fn.json_decode, result)
    if not ok or type(entries) ~= "table" then
        vim.notify("Failed to decode feed JSON", vim.log.levels.ERROR)
        return nil
    end

    local valid_entries = {}
    for _, entry in ipairs(entries) do
        if entry and entry.title and entry.source then
            table.insert(valid_entries, entry)
        end
    end

    if #valid_entries == 0 then
        vim.notify("No feed entries found", vim.log.levels.WARN)
        return nil
    end

    return valid_entries
end

local function TelescopeRssPicker(urls, since_date)
    local valid_entries = run_feed_parser(urls, since_date)
    if not valid_entries then
        return
    end

    local origin_win = vim.api.nvim_get_current_win()
    local origin_buf = vim.api.nvim_get_current_buf()

    pickers.new({}, {
        prompt_title = "RSS",
        finder = finders.new_table({
            results = valid_entries,
            entry_maker = function(entry)
                local title = entry.title or "<No Title>"
                local source = entry.source or "<Unknown Source>"
                local date = entry.date or ""

                return {
                    value = entry,
                    display = string.format("%s [%s] %s", title, source, date),
                    ordinal = table.concat({
                        title,
                        source,
                        date,
                        entry.description or "",
                        entry.link or "",
                    }, " "),
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
            define_preview = function(self, entry, _)
                local e = entry.value or entry
                local lines = {
                    "Title:  " .. (e.title or ""),
                    "Source: " .. (e.source or ""),
                    "Date:   " .. (e.date or ""),
                    "Link:   " .. (e.link or ""),
                    "",
                    e.description or "",
                }
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            end,
        }),
        attach_mappings = function(_, map)
            local get_entry = function()
                local entry = action_state.get_selected_entry()
                return entry and entry.value or nil
            end

            local append_line_to_origin = function(text)
                if not vim.api.nvim_buf_is_valid(origin_buf) then
                    vim.notify("Original buffer is no longer valid", vim.log.levels.ERROR)
                    return
                end

                if not vim.api.nvim_win_is_valid(origin_win) then
                    vim.notify("Original window is no longer valid", vim.log.levels.ERROR)
                    return
                end

                local cursor = vim.api.nvim_win_get_cursor(origin_win)
                local row = cursor[1]

                vim.api.nvim_buf_set_lines(origin_buf, row, row, false, { text })
                vim.api.nvim_win_set_cursor(origin_win, { row + 1, 0 })
            end

            local insert_plain_link = function()
                local e = get_entry()
                local link = e and e.link or nil

                if not link or link == "" then
                    vim.notify("No link to insert", vim.log.levels.WARN)
                    return
                end

                append_line_to_origin(link)
            end

            local insert_markdown_link = function()
                local e = get_entry()
                local link = e and e.link or nil
                local title = e and e.title or "link"

                if not link or link == "" then
                    vim.notify("No link to insert", vim.log.levels.WARN)
                    return
                end

                append_line_to_origin(string.format("[%s](%s)", title, link))
            end

            local open_link = function()
                local e = get_entry()
                local link = e and e.link or nil

                if link and link ~= "" then
                    vim.fn.jobstart({ "xdg-open", link }, { detach = true })
                else
                    vim.notify("No link to open", vim.log.levels.WARN)
                end
            end

            map("i", "<CR>", insert_plain_link)
            map("n", "<CR>", insert_plain_link)
            map("i", "<C-l>", insert_markdown_link)
            map("n", "<C-l>", insert_markdown_link)
            map("i", "<C-o>", open_link)
            map("n", "<C-o>", open_link)

            return true
        end,
    }):find()
end

local function get_opml_files()
    local feeds_dir = "/root/feeds"
    local opml_files = vim.fn.globpath(feeds_dir, "*.opml", false, true)

    if #opml_files == 0 then
        vim.notify("No OPML files found in " .. feeds_dir, vim.log.levels.WARN)
        return nil
    end

    local feed_sets = {}
    for _, filepath in ipairs(opml_files) do
        local filename = vim.fn.fnamemodify(filepath, ":t:r")
        local display_name = filename
            :gsub("[^a-zA-Z0-9]", " ")
            :gsub("%s+", " ")
            :gsub("^%s*(.-)%s*$", "%1")

        table.insert(feed_sets, {
            name = display_name,
            file = filepath,
        })
    end

    return feed_sets
end

local function pick_feed_set(callback)
    local feed_sets = get_opml_files()
    if not feed_sets then
        return
    end

    vim.ui.select(vim.tbl_map(function(set)
        return set.name
    end, feed_sets), { prompt = "Select feed set:" }, function(choice)
        if not choice then
            return
        end

        for _, set in ipairs(feed_sets) do
            if set.name == choice then
                callback(set)
                return
            end
        end

        vim.notify("Selected feed set not found", vim.log.levels.ERROR)
    end)
end

local function read_file(filepath)
    local ok, lines = pcall(vim.fn.readfile, filepath)
    if not ok or not lines then
        vim.notify("Could not read file: " .. filepath, vim.log.levels.ERROR)
        return nil
    end
    return table.concat(lines, "\n")
end

local function read_opml_urls(filepath)
    local xml = read_file(filepath)
    if not xml then
        return nil
    end

    local feeds = {}
    for url in xml:gmatch('xmlUrl="([^"]+)"') do
        table.insert(feeds, url)
    end

    if #feeds == 0 then
        vim.notify("No feeds found in OPML file", vim.log.levels.WARN)
        return nil
    end

    return feeds
end

local function read_opml_feed_objects(filepath)
    local xml = read_file(filepath)
    if not xml then
        return nil
    end

    local feeds = {}

    for attrs in xml:gmatch("<outline%s+([^>]-)/?>") do
        local xml_url = attrs:match('xmlUrl="([^"]+)"')
        if xml_url then
            local title = attrs:match('title="([^"]+)"')
                or attrs:match('text="([^"]+)"')
                or xml_url

            local html_url = attrs:match('htmlUrl="([^"]+)"')

            table.insert(feeds, {
                title = title,
                xmlUrl = xml_url,
                htmlUrl = html_url,
            })
        end
    end

    if #feeds == 0 then
        vim.notify("No sub-feeds found in OPML file", vim.log.levels.WARN)
        return nil
    end

    return feeds
end

local function pick_single_subfeed(opml_file, callback)
    local feeds = read_opml_feed_objects(opml_file)
    if not feeds then
        return
    end

    vim.ui.select(vim.tbl_map(function(feed)
        return feed.title
    end, feeds), { prompt = "Select sub-feed:" }, function(choice)
        if not choice then
            return
        end

        for _, feed in ipairs(feeds) do
            if feed.title == choice then
                callback(feed)
                return
            end
        end

        vim.notify("Selected sub-feed not found", vim.log.levels.ERROR)
    end)
end

function rss_picker()
    pick_feed_set(function(selected_set)
        select_date_range(function(since_date)
            local feeds = read_opml_urls(selected_set.file)
            if not feeds then
                return
            end

            TelescopeRssPicker(feeds, since_date)
        end)
    end)
end

function rss_single_feed_picker()
    pick_feed_set(function(selected_set)
        pick_single_subfeed(selected_set.file, function(feed)
            select_date_range(function(since_date)
                TelescopeRssPicker({ feed.xmlUrl }, since_date)
            end)
        end)
    end)
end
