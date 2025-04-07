require("mason").setup()
require("mason-lspconfig").setup()


require 'lspconfig'.vimls.setup {}
require 'lspconfig'.dockerls.setup {}
require 'lspconfig'.docker_compose_language_service.setup {}
require 'lspconfig'.jsonls.setup {}
require 'lspconfig'.marksman.setup { filetypes = { 'vimwiki', 'quarto', 'rmarkdown', 'markdown' } }
require 'lspconfig'.nginx_language_server.setup {}
require 'lspconfig'.pyright.setup {}
require 'lspconfig'.r_language_server.setup {}
require 'lspconfig'.ts_ls.setup {}
require 'lspconfig'.yamlls.setup {}
require 'lspconfig'.prismals.setup {}
require 'lspconfig'.lua_ls.setup {}
require 'lspconfig'.quick_lint_js.setup {}
require 'lspconfig'.ltex.setup {
    cmd = { "/usr/bin/ltex-ls/bin/ltex-ls", "--log-file=/root/ltex_log" },
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
require "lspconfig".efm.setup {
    init_options = { documentFormatting = true },
    settings = {
        languages = {
            lua = {
                { formatCommand = "stylua ", formatStdin = false }
            }
        }
    }
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
    end, -- Added missing 'end' for the function
})
