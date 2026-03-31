-- Register custom filetypes to existing parsers
vim.treesitter.language.register("markdown", { "quarto", "rmd", "aichat" })
vim.treesitter.language.register("html", { "ejs" })

-- Install parsers (async, no-op if already installed)
require('nvim-treesitter').install({
    'latex',
    'r',
    'python',
    'markdown',
    'markdown_inline',
    'bash',
    'yaml',
    'lua',
    'vim',
    'query',
    'vimdoc',
    'html',
    'css',
    'dot',
    'javascript',
    'mermaid',
    'norg',
    'typescript',
    'prisma',
})


-- nvim-treesitter-textobjects
local select = require('nvim-treesitter-textobjects.select')
local move   = require('nvim-treesitter-textobjects.move')

require('nvim-treesitter-textobjects').setup({
    select = { lookahead = true },
    move   = { set_jumps = true },
})

local function sel(query, mode)
    return function() select.select_textobject(query, 'textobjects', mode) end
end

-- Text objects (visual + operator-pending)
local textobjects = {
    am = '@function.outer',  im = '@function.inner',
    ac = '@class.outer',     ic = '@class.inner',
    al = '@loop.outer',      il = '@loop.inner',
    ae = '@conditional.outer', ie = '@conditional.inner',
    af = '@call.outer',      ['if'] = '@call.inner',
    ag = '@parameter.outer', ig = '@parameter.inner',
    ['a='] = '@assignment.outer', ['i='] = '@assignment.inner',
}
for key, query in pairs(textobjects) do
    vim.keymap.set({ 'x', 'o' }, key, sel(query))
end

-- Move between functions/classes
-- gfn/gfp: go func start next/prev
-- gfen/gfep: go func end next/prev
-- gcn/gcp: go class start next/prev
-- gcen/gcep: go class end next/prev
local moves = {
    gfn  = { 'next_start',     '@function.outer' },
    gfp  = { 'previous_start', '@function.outer' },
    gfen = { 'next_end',       '@function.outer' },
    gfep = { 'previous_end',   '@function.outer' },
    gcn  = { 'next_start',     '@class.outer'    },
    gcp  = { 'previous_start', '@class.outer'    },
    gcen = { 'next_end',       '@class.outer'    },
    gcep = { 'previous_end',   '@class.outer'    },
}
for key, v in pairs(moves) do
    local dir, query = v[1], v[2]
    vim.keymap.set({ 'n', 'x', 'o' }, key, function()
        move['goto_' .. dir](query, 'textobjects')
    end)
end
