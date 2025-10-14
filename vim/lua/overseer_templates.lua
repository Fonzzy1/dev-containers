require("overseer").register_template({
    name = "Quarto Preview",
    builder = function()
        local current_file = vim.fn.expand('%:p')
        return {
            cmd = { "quarto", "preview", current_file },
            components = { "default" },
        }
    end,
    condition = {
        filetype = { "quarto" },
    },
})

require("overseer").register_template({
    name = "Quarto Render",
    builder = function()
        local current_file = vim.fn.expand('%:p')
        return {
            cmd = { "quarto", "render", current_file },
            components = { "default" },
        }
    end,
    condition = {
        filetype = { "quarto" },
    },
})

require("overseer").register_template({
    name = "Open Shell",
    builder = function(_)
        return {
            cmd = { "bash" },
            components = {
                { "open_output", direction = "float", on_start = "always", focus = true },
                "default"
            }
        }
    end,
})
