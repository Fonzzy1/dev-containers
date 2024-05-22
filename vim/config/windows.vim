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
nnoremap + :only<CR>


function! MoveRight()
    let l:exempt_ft = ['terminal','nerdtree','tagbar','fugitive','gitcommit','qf','calendar']
    let l:left_bar_ft = ['nerdtree','tagbar','calendar']
    if index(l:exempt_ft, &filetype) == -1
        execute " wincmd L"
        execute " vertical wincmd = "
    endif
    " If it is a left bar element move the element to the left
    if index(l:left_bar_ft, &filetype) >= 0
        execute " wincmd H"
        execute " wincmd t"
        execute " vertical resize 32"
        setlocal winfixwidth
    endif
    if (&filetype=='qf')
        execute " wincmd H"
        execute " vertical resize 32"
        setlocal winfixwidth
    endif

    execute " vertical wincmd = "
endfunction

autocmd FileType  * call MoveRight()

" Easier Nav of buffers
nnoremap bv :vnew<CR>:wincmd L<CR>

nnoremap bh :new<CR>

function! LeftBarToggle()
    wincmd t
    if ((&ft=='nerdtree') || (&ft=='tagbar') || (&ft=='qf') || (&ft=='calendar'))
        close
    endif
    wincmd p
endfunction

