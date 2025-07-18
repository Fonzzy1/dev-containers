-- autocmd({ "VimEnter", "BufEnter", "FocusGained", "WinEnter" }, {startin
--     callback = function()
--         local line = vim.fn.getline(1)
--         vim.g.shebang = line:match("^#!%s*(.*)") or "/usr/bin/bash"
--     end
-- })

local iron = require("iron.core")
local view = require("iron.view")
local common = require("iron.fts.common")

iron.setup {
    config = {
        -- Whether a repl should be discarded or not
        scratch_repl = true,
        -- Your repl definitions come here
        repl_definition = {
            quarto = { command = '/bin/bash' },
            text = { command = '/bin/bash' },
            aichat = { command = '/bin/bash' },
            python = {
                command = { "ipython", "--no-autoindent"}, -- or { "ipython", "--no-autoindent" }
                format = common.bracketed_paste_python,
                block_dividers = { "# %%", "#%%" },
            }
        },
        -- set the file type of the newly created repl to ft
        -- bufnr is the buffer id of the REPL and ft is the filetype of the
        -- language being used for the REPL.
        repl_filetype = function(bufnr, ft)
            return ft
            -- or return a string name such as the following
            -- return "iron"
        end,
        -- How the repl window will be displayed
        -- See below for more information
        repl_open_cmd = view.split("40%")

        -- repl_open_cmd can also be an array-style table so that multiple
        -- repl_open_commands can be given.
        -- When repl_open_cmd is given as a table, the first command given will
        -- be the command that `IronRepl` initially toggles.
        -- Moreover, when repl_open_cmd is a table, each key will automatically
        -- be available as a keymap (see `keymaps` below) with the names
        -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
        -- For example,
        --
        -- repl_open_cmd = {
        --   view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
        --   view.split.rightbelow("%25")  -- cmd_2: open a repl below
        -- }

    },
    -- Iron doesn't set keymaps by default anymore.
    -- You can set them here or manually add keymaps to the functions in iron.core
    keymaps = {
        toggle_repl = "st",  -- toggles the repl open and closed.
        restart_repl = "sT", -- calls `IronRestart` to restart the repl
        send_motion = "t",
        visual_send = "tt",
    },
    -- If the highlight is on, you can change how it looks
    -- For the available options, check nvim_set_hl
    highlight = {
        italic = true
    },
    ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
}

function load_project_overseer_templates()
    local file = vim.fn.getcwd() .. "/.overseer.lua"
    local ok, templates = pcall(dofile, file)
    if ok and type(templates) == "table" then
        for _, tpl in ipairs(templates) do
            require("overseer").register_template(tpl)
        end
        print("[Overseer] Loaded project templates from .overseer.lua")
    end
end

-- iron also has a list of commands, see :h iron-commands for all available commands
require('overseer').setup({
    task_list = {
        direction = 'left'
        ,
        bindings = {
            ["?"] = "ShowHelp",
            ["g?"] = "ShowHelp",
            ["<CR>"] = "OpenFloat",
            ["S"] = "<CMD>OverseerQuickAction Save as template<CR>",
            ["l"] = "IncreaseDetail",
            ["h"] = "DecreaseDetail",
            ["L"] = "IncreaseAllDetail",
            ["H"] = "DecreaseAllDetail",
            ["k"] = "PrevTask",
            ["j"] = "NextTask",
            ["q"] = "Close",
            ["dd"] = "Dispose",
        },
    },
    actions = {
        ["Save as template"] = {
            desc = "Save minimal task template with name, cwd, and cmd to .overseer.lua",
            condition = function(task)
                return task.serialize ~= nil
            end,
            run = function(task)
                local def = task:serialize()

                -- Minimal fields: name, cwd, cmd only
                local minimal = {
                    name = def.name,
                    cwd = def.cwd,
                    cmd = def.cmd,
                }

                local function serialize(tbl, indent)
                    indent = indent or 0
                    local pad = string.rep("  ", indent)
                    local chunks = { "{\n" }
                    for k, v in pairs(tbl) do
                        if v ~= nil then
                            local key = type(k) == "string" and string.format("%s", k) or tostring(k)
                            local value
                            if type(v) == "string" then
                                value = string.format("%q", v)
                            elseif type(v) == "table" then
                                if vim.tbl_islist(v) then
                                    local parts = {}
                                    for _, item in ipairs(v) do
                                        table.insert(parts, string.format("%q", item))
                                    end
                                    value = "{ " .. table.concat(parts, ", ") .. " }"
                                else
                                    value = serialize(v, indent + 1)
                                end
                            else
                                value = tostring(v)
                            end
                            table.insert(chunks, string.format("%s  %s = %s,\n", pad, key, value))
                        end
                    end
                    table.insert(chunks, pad .. "}")
                    return table.concat(chunks)
                end

                local block = string.format([[
{
  name = %q,
  builder = function()
    return %s
  end,
},
]], minimal.name or "Task", serialize(minimal))

                local path = vim.fn.getcwd() .. "/.overseer.lua"

                -- Read existing file or create new
                local lines = {}
                local file = io.open(path, "r")
                if file then
                    for line in file:lines() do
                        table.insert(lines, line)
                    end
                    file:close()
                else
                    lines = { "return {", block, "}" }
                end

                -- Find closing brace to insert before
                local insert_index = nil
                for i = #lines, 1, -1 do
                    if vim.trim(lines[i]) == "}" then
                        insert_index = i
                        break
                    end
                end
                if not insert_index then
                    vim.notify("No closing } found in .overseer.lua", vim.log.levels.ERROR)
                    return
                end

                table.insert(lines, insert_index, block)

                file = io.open(path, "w")
                if not file then
                    vim.notify("Failed to write to .overseer.lua", vim.log.levels.ERROR)
                    return
                end
                file:write(table.concat(lines, "\n") .. "\n")
                file:close()

                vim.notify("✅ Task saved (name, cwd, cmd only) to .overseer.lua", vim.log.levels.INFO)
                load_project_overseer_templates()
            end,
        },

        -- Disable unwanted default actions
        watch = false,
    },

})


vim.api.nvim_create_autocmd("VimEnter", {
    callback = load_project_overseer_templates,
})

-- Define the function in Lua
function LeftBarToOver()
    vim.cmd("call LeftBarToggle()") -- or use the appropriate Lua function if available
    vim.cmd("OverseerOpen")         -- or the equivalent Lua function
    vim.cmd('call LeftBarPost()')
end
