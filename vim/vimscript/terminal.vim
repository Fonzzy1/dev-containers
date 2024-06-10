" Slime
let g:slime_target = 'neovim'
let g:slime_input_pid=1

" Auto close the terminal
autocmd TermClose * execute 'close!'
" Shebang stuff
autocmd VimEnter,BufEnter,FocusGained,WinEnter * let g:slime_vimterminal_cmd = getline(1) =~ '\v^#!\s*\zs.*' ? matchstr(getline(1), '\v^#!\s*\zs.*') : '/usr/bin/bash'

" Terminal Things
" function! for opening terminal
fun! StartTerm()
  execute 'terminal '. g:slime_vimterminal_cmd
  setlocal nonumber
  setlocal nornu
  setlocal scl=no
  let term_id = str2nr(b:terminal_job_id)
  wincmd p
  let b:slime_config = {"jobid": term_id }
endfun

nnoremap t :split \| call StartTerm()<CR>
nnoremap bt :vsplit \| call StartTerm()<CR>
tnoremap <Esc><Esc> <C-\><C-n>



