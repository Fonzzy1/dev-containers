---@type opencode.Opts
vim.g.opencode_opts = {}

vim.o.autoread = true -- Required for buffer reload on opencode edits

-- Toggle opencode panel
vim.keymap.set({ "n", "t" }, "sc", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

-- Ask opencode about current context
vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end,
    { desc = "Ask opencode" })

-- Select from prompts/commands
vim.keymap.set({ "n", "x" }, "<leader>os", function() require("opencode").select() end,
    { desc = "Select opencode action" })

-- Operator: send range/motion to opencode
vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
    { desc = "Send range to opencode", expr = true })
vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
    { desc = "Send line to opencode", expr = true })

-- Scroll opencode panel
vim.keymap.set("n", "<leader>ou", function() require("opencode").command("session.half.page.up") end,
    { desc = "Scroll opencode up" })
vim.keymap.set("n", "<leader>od", function() require("opencode").command("session.half.page.down") end,
    { desc = "Scroll opencode down" })
