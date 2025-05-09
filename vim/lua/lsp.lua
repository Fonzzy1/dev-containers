require("mason").setup()
require("mason-lspconfig").setup()

local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")


lspconfig.vimls.setup {}
lspconfig.prismals.setup {}
lspconfig.dockerls.setup {}
lspconfig.docker_compose_language_service.setup {}
lspconfig.jsonls.setup {}
lspconfig.nginx_language_server.setup {}
lspconfig.pyright.setup {}
lspconfig.air.setup {}
lspconfig.ts_ls.setup {}
lspconfig.yamlls.setup {}
lspconfig.prismals.setup {}
lspconfig.lua_ls.setup {}
lspconfig.ltex.setup {
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
        formatCommand = "prettier --parser markdown ",
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
    bash = {
        formatCommand = "shellharden --transform",
        formatStdin = true,
    },
    sh = {
        formatCommand = "shellharden --transform",
        formatStdin = true,
    },
}

-- Configure efm-langserver
lspconfig.efm.setup {
    init_options = { documentFormatting = true, },
    settings = {
        rootMarkers = { ".git/" },
        languages = formatters,
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


if not configs.bibli_ls then
    configs.bibli_ls = {
        default_config = {
            cmd = { "bibli_ls" },
            filetypes = { "quarto" },
            root_dir = lspconfig.util.root_pattern(".bibli.toml"),
        },
    }
end

lspconfig.bibli_ls.setup({})
