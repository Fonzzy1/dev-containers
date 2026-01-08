require("mason").setup()

vim.lsp.config('bibli_ls', {
    cmd = { "bibli_ls" },
    filetypes = { "markdown", "quarto" },
    root_markers = { ".bibli.toml" },
    -- Optional: visit the URL of the citation with LSP DocumentImplementation
    on_attach = function(client, bufnr)
        vim.keymap.set({ "n" }, "<cr>", function()
            vim.lsp.buf.implementation()
        end)
    end,
})

vim.lsp.enable('bibli_ls')


vim.lsp.config('ltex', {
    cmd = { "ltex-ls", "--log-file=/root/ltex_log" },
    settings = {
        ltex = {
            enabled = { "gitcommit", "markdown", "org",
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
})


vim.lsp.enable('ltex')
vim.lsp.enable('vimls')
vim.lsp.enable('dockerls')
vim.lsp.enable('docker_compose_language_service')
vim.lsp.enable('jsonls')
vim.lsp.enable('nginx_language_server')
vim.lsp.enable('pyright')
vim.lsp.enable('air')
vim.lsp.enable('ts_ls')
vim.lsp.enable('yamlls')
vim.lsp.enable('prismals')
vim.lsp.enable('lua_ls')



local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

local bibtex_formatter = {
    method = null_ls.methods.FORMATTING,
    filetypes = { "bib" },
    generator = helpers.formatter_factory({
        command =
        "bibtex-tidy",
        args = {
            '--v2', "--curly", "--numeric", "--align=13", "--duplicates=key", "no-escape",
            "--sort-fields", "--remove-empty-fields", "--no-remove-dupe-fields",
            "sort=-year,key", "--wrap=80"
        },
        to_stdin = true, -- should be false if no stdin support
        from_stderr = true,
    }),
}
local prisma_formatter = {
    method = null_ls.methods.FORMATTING,
    filetypes = { "prisma" },
    generator = require("null-ls.helpers").formatter_factory({
        command = "npx",
        args = { "prisma", "format", "--stdin" },
        to_stdin = true,
    }),
}

null_ls.setup({
    sources = {
        bibtex_formatter,
        prisma_formatter,

        -- Markdown, Quarto, YAML, EJS, HTML, JavaScript
        null_ls.builtins.formatting.prettier.with({
            filetypes = { "markdown", "quarto", "yaml", "html", "javascript", "ejs", "json" },
        }),
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
        null_ls.builtins.formatting.shfmt,
    }
}
)

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


-- Always create the group first
local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

-- Then clear any existing autocommands for that group & buffer
vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    buffer = bufnr,
    callback = function()
        vim.lsp.buf.format({ async = true })
    end,
})
