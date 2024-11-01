require'lspconfig'.vimls.setup{}
require'lspconfig'.dockerls.setup{}
require'lspconfig'.jsonls.setup{}
require'lspconfig'.marksman.setup{filetypes= {'vimwiki','quarto','rmarkdown','markdown'}}
require'lspconfig'.nginx_language_server.setup{}
require'lspconfig'.pyright.setup{}
require'lspconfig'.r_language_server.setup{}
require'lspconfig'.sqlls.setup{}
require'lspconfig'.ts_ls.setup{}
require'lspconfig'.yamlls.setup{}
require'lspconfig'.quick_lint_js.setup{}
vim.treesitter.language.register("markdown", { "quarto", "rmd" })
require'lspconfig'.ltex.setup{
  cmd = {"/usr/bin/ltex-ls/bin/ltex-ls", "--log-file=/root/ltex_log"},
  settings = {
    ltex = {
      enabled = { "bibtex", "gitcommit", "markdown", "org", "tex", "restructuredtext", "rsweave", "latex", "quarto", "rmd", "context", "html", "xhtml", "mail", "plaintext" },
      markdown = {
        nodes = {CodeBlock = "ignore", FencedCodeBlock = "ignore", AutoLink =  "dummy", Code = "dummy"},
      },
      completionEnabled = true,
      disabledRules = {
        ["en-AU"] = {"WHITESPACE_RULE"},
      },
      language = "en-AU",
      diagnosticSeverity = {
        MORFOLOGIK_RULE_EN_AU = 'error',
        default = "hints" 
      }
    }
  } 
}

vim.api.nvim_set_keymap("n", "gd", "<cmd>lua require'otter'.ask_definition()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua require'otter'.ask_references()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "K", "<cmd>lua require'otter'.ask_hover()<CR>", {noremap = true, silent = true})

