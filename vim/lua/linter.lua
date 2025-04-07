require('lint').linters_by_ft = {
  vim = {'vint'},
  dockerfile = {'hadolint'},
  json = {'prettier'},
  markdown = {'markdownlint', 'vale'},
  nginx = {'nginx-lint'},
  python = {'flake8'},
  r = {'lintr'},
  sql = {'sqlfluff'},
  typescript = {'eslint'},
  yaml = {'yamllint'},
  javascript = {'eslint'},
  quarto = {'vale'},
  lua = {'luacheck'},
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
})
