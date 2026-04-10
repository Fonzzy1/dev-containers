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
