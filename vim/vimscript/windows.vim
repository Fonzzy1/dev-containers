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


function! LeftBarToggle()
    wincmd t
    if ((&ft=='NvimTree') || (&ft=='aerial') || (&ft=='OverseerList'))
        close
    endif
    wincmd p
endfunction


function LeftBarPost()
    vertical resize 32
    setlocal winhighlight=Normal:NvimTreeNormal
endfunction

