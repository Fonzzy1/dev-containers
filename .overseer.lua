return {
    {
        name = "Run build script",
        desc = "Executes the ./build script with sh",
        builder = function(_)
            return {
                cmd = { "sh", "./build" },
                components = { "default" },
            }
        end,
    },
    {
        name = "Login to Docker",
        desc = "Log in to Docker Hub",
        builder = function(_)
            return {
                cmd = { "docker login -u fonzzy1" },
                components = {
                    { "open_output", direction = "float", on_start = "always", focus = true },
                    "default"
                }
            }
        end,
    }
}
