"" Default Note
function! NoteDefault()
    :silent 0r !/scripts/note_default.py '%'
    normal! gg
endfunction
autocmd BufNewFile *.qmd :call NoteDefault()


"" Calender
nnoremap c :call LeftBarToCalendar() <CR>
function LeftBarToCalendar()
    call LeftBarToggle()
    :Calendar
endfunction

function! MyCalAction(day, month, year, week, dir)
    let filename = printf("Diary/%04d-%02d-%02d.qmd", a:year, a:month, a:day)
    let filename = fnameescape(filename)
    execute 'edit ' . filename
    if !filereadable(filename)
        write
    endif
endfunction
  
let calendar_action = 'MyCalAction'

