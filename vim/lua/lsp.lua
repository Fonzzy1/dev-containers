require("mason").setup()
require("mason-lspconfig").setup()


require 'lspconfig'.vimls.setup {}
require 'lspconfig'.dockerls.setup {}
require 'lspconfig'.docker_compose_language_service.setup {}
require 'lspconfig'.jsonls.setup {}
require 'lspconfig'.marksman.setup { filetypes = { 'vimwiki', 'quarto', 'rmarkdown', 'markdown' } }
require 'lspconfig'.nginx_language_server.setup {}
require 'lspconfig'.pyright.setup {}
require 'lspconfig'.air.setup {}
require 'lspconfig'.ts_ls.setup {}
require 'lspconfig'.yamlls.setup {}
require 'lspconfig'.prismals.setup {}
require 'lspconfig'.lua_ls.setup {}
require 'lspconfig'.ltex.setup {
    cmd = { "ltex-ls", "--log-file=/root/ltex_log" },
    settings = {
        ltex = {
            enabled = { "bibtex", "gitcommit", "markdown", "org",
                "tex", "restructuredtext", "rsweave", "latex",
                "quarto", "rmd", "context", "html",
                "xhtml", "mail", "plaintext" },
            markdown = {
                nodes = {
                    CodeBlock = "ignore",
                    FencedCodeBlock = "ignore",
                    AutoLink = "dummy",
                    Code = "dummy"
                },
            },
            completionEnabled = true,
            disabledRules = {
                ["en-AU"] = { "WHITESPACE_RULE" },
            },
            language = "en-AU",
            diagnosticSeverity = {
                MORFOLOGIK_RULE_EN_AU = 'error',
                default = "hints"
            }
        }
    }
}
-- Define the command and arguments for each formatter
local formatters = {
    lua = {
        formatCommand = "stylua --search-parent-directories --stdin-filepath ${INPUT} -",
        formatStdin = true,
    },
    markdown = {
        formatCommand = "pretter --parser markdown ",
        formatStdin = true,
    },
    quarto = {
        formatCommand = "prettier --parser markdown " ,
        formatStdin = true,
    },
    json = {
        formatCommand = "fixjson",
        formatStdin = true,
    },
    python = {
        formatCommand = "black --line-length 80 --quiet -",
        formatStdin = true,
    },
    r = {
        formatCommand = "Rscript -e \"air::style_file(stdin())\"",
        formatStdin = true,
    },
    javascript = {
        formatCommand = "prettier --stdin-filepath ${INPUT}",
        formatStdin = true,
    },
    html = {
        formatCommand = "prettier --stdin-filepath ${INPUT}",
        formatStdin = true,
    },
    yaml = {
        formatCommand = "prettier --stdin-filepath ${INPUT}",
        formatStdin = true,
    },
    prisma = {
        formatCommand = "prisma format -i",
        formatStdin = true,
    },
}

-- Configure efm-langserver
require "lspconfig".efm.setup {
    init_options = { documentFormatting = true },
    settings = {
        rootMarkers = { ".git/" },
        languages = {
            lua = { formatters.lua },
            markdown = { formatters.markdown },
            quarto = { formatters.quarto },
            json = { formatters.json },
            python = { formatters.python },
            r = { formatters.r },
            javascript = { formatters.javascript },
            html = { formatters.html },
            yaml = { formatters.yaml },
            dockerfile = { formatters.dockerfile },
            prisma = { formatters.prisma },
        },
    },
    filetypes = vim.tbl_keys(formatters),
}

vim.diagnostic.config({
    virtual_text = false,
})


vim.api.nvim_create_autocmd({ "CursorHold" },
    {
        pattern = '*',
        callback = function()
            vim.diagnostic.open_float()
        end
    }
)

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
        vim.lsp.buf.format()
    end,
})
