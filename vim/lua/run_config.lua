-- autocmd({ "VimEnter", "BufEnter", "FocusGained", "WinEnter" }, {starting
--     callback = function()
--         local line = vim.fn.getline(1)
--         vim.g.shebang = line:match("^#!%s*(.*)") or "/usr/bin/bash"
--     end
-- })
--
--


local iron = require("iron.core")
local view = require("iron.view")
local common = require("iron.fts.common")

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if vim.bo.buftype == "terminal" then
            vim.opt_local.colorcolumn = "0"
        end
    end,
})

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
                command = { "ipython", "--no-autoindent" }, -- or { "ipython", "--no-autoindent" }
                format = common.bracketed_paste_python,
                block_dividers = { "# %%", "#%%" },
            }
        },
        -- set the file type of the newly created repl to ft
        -- bufnr is the buffer id of the REPL and ft is the filetype of the
        -- language being used for the REPL.
        repl_filetype = function(bufnr, ft)
            return "iron"
            -- or return a string name such as the following
            -- return "iron"
        end,
        -- How the repl window will be displayed
        -- See below for more information
        repl_open_cmd = "botright 10 split | wincmd J | set nowrap | set nonumber | set norelativenumber"

        -- repl_open_cmd = view.split.vertical.rightbelow(80, {
        --     winfixwidth = true,
        --     number = false,
        --     relativenumber = false
        -- })

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
        direction = 'left',
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


})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = load_project_overseer_templates,
})
