" Slime
let g:slime_target = 'vimterminal'
" Shebang stuff
autocmd VimEnter,BufEnter,FocusGained,WinEnter * let g:slime_vimterminal_cmd = getline(1) =~ '\v^#!\s*\zs.*' ? matchstr(getline(1), '\v^#!\s*\zs.*') : '/usr/bin/bash'

" Terminal Things
" function! for opening terminal
function! OpenTerm()
    "  Get command
    let l:term_command = g:slime_vimterminal_cmd
    
    "Open Term in a new split 
    call term_start(l:term_command,{'term_finish':'close', 'term_kill':'term'})

    " Set the format
    set ft=terminal
    setlocal winfixheight
    let l:term_buf_no = winbufnr(0)  
    resize 24

    " Jump back to the og window
    wincmd p
    let b:slime_config = {"bufnr": l:term_buf_no}
endfunction

nnoremap t :call OpenTerm()<CR>
tnoremap <Esc><Esc> <C-w>N
