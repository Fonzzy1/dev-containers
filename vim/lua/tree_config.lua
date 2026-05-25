-- Register custom filetypes to existing parsers
vim.treesitter.language.register("markdown", { "quarto", "rmd", "aichat" })

vim.g.ts_enable = {
    auto_init = true,
    auto_install = true,
    highlights = true,
    regex_syntax = true,
    parser_info = vim.fn.stdpath('config') .. '/treesitter-parsers.json',
}

-- nvim-treesitter-textobjects
local select    = require('nvim-treesitter-textobjects.select')
local move      = require('nvim-treesitter-textobjects.move')

require('nvim-treesitter-textobjects').setup({
  select = {
    enable = true,
    lookahead = true,
  },
  move = {
    enable = true,
    set_jumps = true,
  },
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
    ab = '@fenced_code_block',
    ib = '@code_fence_content',
}
for key, query in pairs(textobjects) do
    vim.keymap.set({ 'x', 'o' }, key, sel(query))
end

local moves = {
    gpm  = { 'previous_start', '@function.outer' },
    gnm  = { 'next_start', '@function.outer' },
    gpem = { 'previous_end', '@function.outer' },
    gnem = { 'next_end', '@function.outer' },

    gpc  = { 'previous_start', '@class.outer' },
    gnc  = { 'next_start', '@class.outer' },
    gpec = { 'previous_end', '@class.outer' },
    gnec = { 'next_end', '@class.outer' },

    gpb  = { 'previous_start', '@fenced_code_block' },
    gnb  = { 'next_start', '@fenced_code_block' },
    gpeb = { 'previous_end', '@fenced_code_block' },
    gneb = { 'next_end', '@fenced_code_block' },

}
for key, v in pairs(moves) do
    local dir, query = v[1], v[2]
    vim.keymap.set({ 'n', 'x', 'o' }, key, function()
        move['goto_' .. dir](query, 'textobjects')
    end)
end
