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
nnoremap + :only<CR>

function! MoveRight()
    let l:left_bar_ft = ['nerdtree','aerial']
    " If it is a left bar element move the element to the left
    if index(l:left_bar_ft, &filetype) >= 0
        wincmd H
        wincmd t
        vertical resize 32
        setlocal winfixwidth
    endif
    vertical wincmd = 
endfunction

autocmd FileType * call MoveRight()

" Easier Nav of buffers
nnoremap bv :vnew<CR>:wincmd L<CR>

nnoremap bh :new<CR>

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
require'telescope'.setup {
  extensions = {
    bibtex = {
      -- Depth for the *.bib file
      depth = 2,
      search_keys = { 'author', 'year', 'title' },
      wrap = false,
    }
  }
}
EOF

nnoremap fb <cmd>Telescope bibtex<cr>
