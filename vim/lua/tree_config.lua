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
    am = '@function.outer',
    im = '@function.inner',
    ac = '@class.outer',
    ic = '@class.inner',
    al = '@loop.outer',
    il = '@loop.inner',
    ae = '@conditional.outer',
    ie = '@conditional.inner',
    af = '@call.outer',
    ['if'] = '@call.inner',
    ag = '@parameter.outer',
    ig = '@parameter.inner',
    ['a='] = '@assignment.outer',
    ['i='] = '@assignment.inner',
    ab = '@block.outer',
    ib = '@block.inner',
    az = '@section.outer',
    iz = '@section.outer',
}
for key, query in pairs(textobjects) do
    vim.keymap.set({ 'x', 'o' }, key, sel(query))
end

local moves = {
    gnf  = { 'previous_start', '@function.outer' },
    gpf  = { 'next_start', '@function.outer' },
    gnef = { 'previous_end', '@function.outer' },
    gpef = { 'next_end', '@function.outer' },

    gnc  = { 'previous_start', '@class.outer' },
    gpc  = { 'next_start', '@class.outer' },
    gnec = { 'previous_end', '@class.outer' },
    gpec = { 'next_end', '@class.outer' },

    gnb  = { 'previous_start', '@block.outer' },
    gpb  = { 'next_start', '@block.outer' },
    gneb = { 'previous_end', '@block.outer' },
    gpeb = { 'next_end', '@block.outer' },

    gnz  = { 'next_start', '@section.outer' },
    gpz  = { 'previous_start', '@section.outer' },
    gnez = { 'next_end', '@section.outer' },
    gpez = { 'previous_end', '@section.outer' },
}
for key, v in pairs(moves) do
    local dir, query = v[1], v[2]
    vim.keymap.set({ 'n', 'x', 'o' }, key, function()
        move['goto_' .. dir](query, 'textobjects')
    end)
end
