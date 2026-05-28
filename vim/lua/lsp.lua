require("mason").setup()

vim.lsp.config('bibli_ls', {
    cmd = { "bibli_ls" },
    filetypes = { "markdown", "quarto" },
    root_markers = { ".bibli.toml" },
    -- Optional: visit the URL of the citation with LSP DocumentImplementation
    on_attach = function(client, bufnr)
        vim.keymap.set("n", "<cr>", vim.lsp.buf.implementation, { buffer = bufnr })
    end,
})

vim.lsp.enable('bibli_ls')

vim.lsp.config('marksman', {
    filetypes = { 'markdown', 'markdown.mdx', 'quarto' },
})
vim.lsp.enable('marksman')


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

-- https://github.com/neovim/nvim-lspconfig

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
vim.lsp.enable('r_language_server')



local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

local bibtex_formatter = {
    method = null_ls.methods.FORMATTING,
    filetypes = { "bib" },
    timeout = 10000,
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



-- Show diagnostics in a floating window when hovering (cursor hold)
local diag_hover_group = vim.api.nvim_create_augroup("LspDiagnosticsHover", { clear = true })
vim.api.nvim_create_autocmd("CursorHold", {
    group = diag_hover_group,
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost", "BufNewFile" }, {
    pattern = "*",
    callback = function()
        if vim.bo.buftype == "acwrite" then
            attach_lsp_to_current_popup()
        end
    end,
})


function attach_lsp_to_current_popup()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype

    for _, client in ipairs(vim.lsp.get_clients()) do
        local fts = client.config.filetypes

        if fts and vim.tbl_contains(fts, ft) then
            vim.notify("Attaching " .. client.name .. " (" .. client.id .. ") to " .. ft)
            vim.lsp.buf_attach_client(bufnr, client.id)
        end
    end
end
