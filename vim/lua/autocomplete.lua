local cmp = require'cmp'

cmp.setup{
  mapping = {
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, {'i', 's'}),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, {'i', 's'}),

    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
      else
        fallback()
      end
    end, {'i', 's'}),
    -- Your rest mappings...
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'otter'},
    -- { name = 'path'},
    -- { name = 'buffer', keyword_length = 2 },
  },
  experimental = {
    ghost_text = true,
  },
}


local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- An example for configuring `clangd` LSP to use nvim-cmp as a completion engine
require('lspconfig').clangd.setup {
  capabilities = capabilities,
  ...  -- other lspconfig configs
}
