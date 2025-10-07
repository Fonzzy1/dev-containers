return {
    {
        name = "Run build script",
        builder = function(_)
            return {
                cmd = { "sh", "./build" },
                components = { "default" },
            }
        end,
    },
    {
        name = "Login to Docker",
        builder = function(_)
            return {
                cmd = { "docker", "login", "-u", "fonzzy1" },
                components = {
                    { "open_output", direction = "float", on_start = "always", focus = true },
                    "default"
                }
            }
        end,
    }
}
