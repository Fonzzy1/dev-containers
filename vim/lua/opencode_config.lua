require("snacks").setup({
    input = { enabled = true },
    picker = {
        enabled = true,
        actions = {
            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
        },
        win = {
            input = {
                keys = {
                    ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
            },
        },
    },
})


vim.g.opencode_opts = {
    server = {
        port = 3000,
        start = function() end,
        stop = function() end,
        toggle = function() end,
    },
    events = {
        enabled = true,
        reload = true,
        permissions = {
            enabled = true,
            idle_delay_ms = 1000,
            edits = {
                enabled = true,
            }
        }
    }
}
vim.api.nvim_create_autocmd("User", {
    pattern = "OpencodeEvent:*", -- Optionally filter event types
    callback = function(args)
        ---@type opencode.server.Event
        local event = args.data.event
        ---@type number
        local port = args.data.port

        -- See the available event types and their properties
        -- vim.notify(vim.inspect(event)) -- uncomment for debugging

        if event.type == "session.idle" then
            vim.notify("`opencode` finished responding")
        elseif event.type == "question.asked" then
            local props = event.properties or {}
            local questions = props.questions or {}
            local first = questions[1] or {}

            local text = first.question or "<no question text>"
            local label = first.header or first.label or "<no label>"

            vim.notify(
                string.format("Question: %s\nLabel: %s", text, label),
                vim.log.levels.INFO,
                { title = "OpenCode Question" }
            )
        end
    end,
})
