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

