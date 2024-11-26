" Slime
let g:slime_target = 'neovim'
let g:slime_input_pid=1

" Auto close the terminal
autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif
autocmd BufWinEnter,WinEnter term://* startinsert
" Shebang stuff
autocmd VimEnter,BufEnter,FocusGained,WinEnter * let g:slime_vimterminal_cmd = getline(1) =~ '\v^#!\s*\zs.*' ? matchstr(getline(1), '\v^#!\s*\zs.*') : '/usr/bin/bash'

" Terminal Things
function! StartTerm(cmd)
  " Escape the command for proper execution
  execute 'terminal '. a:cmd
  setlocal nonumber
  setlocal nornu
  setlocal scl=no
  let term_id = str2nr(b:terminal_job_id)
  wincmd p
  let b:slime_config = {'jobid': term_id}
  wincmd p
endfunction

function! RunTerm(cmd)
  " Escape the command for proper execution
  execute 'terminal '. a:cmd . ' && tail -f /dev/null'
  setlocal nonumber
  setlocal nornu
  setlocal scl=no
endfunction

nnoremap t :split \| call StartTerm(g:slime_vimterminal_cmd)<CR>
nnoremap rt :split \| call StartTerm(g:slime_vimterminal_cmd." %")<CR>
nnoremap bt :vsplit \| wincmd L \| call StartTerm(g:slime_vimterminal_cmd)<CR>
tnoremap <Esc><Esc> <C-\><C-n>

