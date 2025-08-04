require("mason").setup()
-- require("mason-lspconfig").setup {
--     ensure_installed = {},
--     automatic_installation = true,
-- }

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



local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

local prisma_formatter = {
    method = null_ls.methods.FORMATTING,
    filetypes = { "prisma" },
    generator = helpers.formatter_factory({
        command = "prisma",
        args = { "format", "--stdin" }, -- prisma doesn't support stdin as of July 2025
        to_stdin = false,               -- should be false if no stdin support
        from_stderr = false,
    }),
}

null_ls.setup({
    sources = {

        -- Markdown, Quarto, YAML, EJS, HTML, JavaScript
        null_ls.builtins.formatting.prettier.with({
            filetypes = { "markdown", "quarto", "yaml", "html", "javascript", "ejs", "json" },
        }),
        --spell
        null_ls.builtins.formatting.codespell,
        -- Python
        null_ls.builtins.formatting.black.with({
            filetypes = { "py", 'python' },
            args = { "--line-length", "80", "--stdin-filename", "$FILENAME", "-" }
        }),

        null_ls.builtins.formatting.format_r,

        -- Shell/Bash
        null_ls.builtins.formatting.shellharden.with({
            filetypes = { "sh", "bash" },
            to_stdin = false,
        }),
        null_ls.builtins.formatting.shfmt
    },
    -- Optional: format on save
    on_attach = function(client, bufnr)
        -- Always create the group first
        local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

        -- Then clear any existing autocommands for that group & buffer
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })

        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
        })
    end
})

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
