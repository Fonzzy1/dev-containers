vim.treesitter.language.register("markdown", { "quarto", "rmd" })
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
         ensure_installed = {
          'r',
          'python',
          'latex',
          'markdown',
          'markdown_inline',
          'julia',
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
        },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = false,
  incremental_selection = { enable = true },
  textobjects = {
    enable=true,
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

            ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

            ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
            ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

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
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
    additional_vim_regex_highlighting = false,
  },
  playground = { enable = true },  -- Fixed the syntax here

}
