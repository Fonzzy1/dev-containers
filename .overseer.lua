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
}
