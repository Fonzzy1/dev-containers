" Long fix for having two different states for inside and outside working tree
silent! !git rev-parse --is-inside-work-tree
if v:shell_error == 0
    let g:gitgutter_async=0
    let g:gitgutter_max_signs = -1
endif


let g:airline_theme = 'catppuccin'

"lightline
if !has('gui_running')
    set t_Co=256
endif
set laststatus=2

"Relative Numbers
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave * if &nu | set nornu | endif
augroup END

" Color stuff
let g:indentLine_setColors = 1
let g:indentLine_char = '▏'
let g:indentLine_setConceal = 0
set t_Co=256
set termguicolors
silent! colorscheme catppuccin-macchiato
let g:rainbow_active = 1
" Color for the terminal
let g:terminal_ansi_colors = [
    \ "#45475A",
    \ "#F38BA8",
    \ "#A6E3A1",
    \ "#F9E2AF",
    \ "#89B4FA",
    \ "#F5C2E7",
    \ "#94E2D5",
    \ "#BAC2DE",
    \ "#585B70",
    \ "#F38BA8",
    \ "#A6E3A1",
    \ "#F9E2AF",
    \ "#89B4FA",
    \ "#F5C2E7",
    \ "#94E2D5",
    \ "#A6ADC8"
\ ]
" Color for git GitGutter
highlight GitGutterAdd    guifg=#89B4FA guibg=NONE
highlight GitGutterChange guifg=#F9E2AF guibg=NONE
highlight GitGutterDelete guifg=#F38BA8 guibg=NONE

augroup CursorLine
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
