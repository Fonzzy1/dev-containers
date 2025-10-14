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
    name = "Docker Build",
    builder = function()
        local current_dir = vim.fn.expand('%:p:h')
        return {
            cmd = { "docker", "build", "-f", vim.fn.expand('%:p'), current_dir },
            components = { "default" },
        }
    end,
    condition = {
        filetype = { "dockerfile" },
    },
})

require("overseer").register_template({
    name = "Docker Run Current",
    builder = function()
        local current_file = vim.fn.expand('%:p')
        return {
            cmd = { "quarto", "render", current_file },
            components = { "default" },
        }
    end,
    condition = {
        filetype = { "dockerfile" },
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

require("overseer").register_template({
    name = "Docker Compose Up",
    builder = function(_)
        return {
            cmd = { "docker", "compose", "up", "--build" },
            components = {
                { "open_output", direction = "float", on_start = "always", focus = true },
                "default"
            }
        }
    end,
    condition = {
        callback = function(search)
            local docker_compose_path = vim.fn.getcwd() .. "/docker-compose.yml"
            local file = io.open(docker_compose_path, "r")
            if file then
                io.close(file)
                return true
            else
                return false
            end
        end,
    },
})

require("overseer").register_template({
    name = "Install Python Requirements",
    builder = function(_)
        return {
            cmd = { "pip", "install", '-r', 'requirements.txt' },
        }
    end,
    condition = {
        callback = function(search)
            local requirements_path = vim.fn.getcwd() .. "/requirements.txt"
            local file = io.open(requirements_path, "r")
            if file then
                io.close(file)
                return true
            else
                return false
            end
        end,
    },
})
