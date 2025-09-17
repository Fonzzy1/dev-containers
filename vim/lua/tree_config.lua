vim.treesitter.language.register("markdown", { "quarto", "rmd", "aichat" })
vim.treesitter.language.register("html", { "ejs" })
require 'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = {
        'latex',
        'r',
        'python',
        'markdown',
        'markdown_inline',
        'bash',
        'yaml',
        'lua',
        'vim',
        'query',
        'vimdoc',
        'html',
        'css',
        'dot',
        'javascript',
        'mermaid',
        'norg',
        'typescript',
        'prisma',
    },
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = false,
    incremental_selection = { enable = true },
    textobjects = {
        enable = true,
        select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
                ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
                ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
                ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

                ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
                ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

                ["ae"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
                ["ie"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

                ["ai"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
                ["ii"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

                ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
                ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

                ["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
                ["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

                ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
                ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            include_surrounding_whitespace = false,
        },
    },
    highlight = {
        enable = true,
        disable = { 'aichat' },
        additional_vim_regex_highlighting = false,
    },
    playground = { enable = false }, -- Fixed the syntax here

}
-- additional hunk object

vim.api.nvim_create_autocmd("FileType", {
    pattern = "aichat",
    callback = function()
        local query = require("vim.treesitter.query")
        local parser_config = vim.treesitter.language.get_lang("markdown")

        -- Get the existing highlight query for markdown
        local existing = query.get_query("markdown", "highlights")
        local existing_str = tostring(existing)

        -- Add your custom rule to highlight lines starting with ">>>"
        local custom = [[
      ((paragraph) @comment (#match? @comment "^>>>"))
    ]]

        -- Merge and set the new combined query
        query.set("markdown", "highlights", existing_str .. "\n" .. custom)
    end,
})


require('mini.ai').setup()
