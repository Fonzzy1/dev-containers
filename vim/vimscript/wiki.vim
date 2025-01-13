"" Default Note
function! NoteDefault()
    :silent 0r !/scripts/note_default.py '%'
    normal! gg
endfunction
autocmd BufNewFile *.qmd :call NoteDefault()
autocmd BufRead *.qmd if getfsize(expand('%'))==0|call NoteDefault()|endif

