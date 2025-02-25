" Navigation around windows is now ctrl with arrow 
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
tnoremap <c-h> <Cmd>wincmd h<CR>
tnoremap <c-j> <Cmd>wincmd j<CR>
tnoremap <c-k> <Cmd>wincmd k<CR>
tnoremap <c-l> <Cmd>wincmd l<CR>

nnoremap = :horizontal wincmd =<CR>
autocmd VimResized * wincmd =
set equalalways
nnoremap + :let pos=getpos(".")<CR>:tabedit %<CR>:call setpos(".", pos)<CR>

" Easier Nav of buffers
nnoremap gvb :vnew<CR>:wincmd L<CR>

nnoremap gb :new<CR>

function! LeftBarToggle()
    wincmd t
    if ((&ft=='nerdtree') || (&ft=='aerial'))
        close
    endif
    wincmd p
endfunction


nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap gr <cmd>Telescope lsp_references<cr>

lua << EOF
local actions = require "telescope.actions"
local bibtex_actions = require('telescope-bibtex.actions')
require 'telescope'.setup {
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = actions.select_vertical, -- Use vsplit for the Enter key in insert mode
            },
            n = {
                ["<CR>"] = actions.select_vertical, -- Use vsplit for the Enter key in normal mode
            },
        }
    },
    extensions = {
        bibtex = {
            -- Depth for the *.bib file
            depth = 2,
            search_keys = { 'author', 'year', 'title', 'keywords' },
            wrap = true,
            citation_max_auth = 1,
            custom_formats = {
                { id = 'quarto', cite_marker = '[[%s]]' }
            },
            format = 'quarto',
            mappings = {
                i = {
                    ["<CR>"] = bibtex_actions.key_append('[[%s]]'),
                },
                n = {
                    ["<CR>"] = bibtex_actions.key_append('[[%s]]'),
                }
            }
        }
    }
}
EOF

nnoremap fb <cmd>Telescope bibtex<cr>
