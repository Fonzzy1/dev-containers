" Let the rmd hander function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=rmarkdown
au BufRead,BufNewFile *.rmd  set filetype=rmarkdown
filetype plugin on


autocmd VimEnter,BufEnter,FocusGained,WinEnter * set concealcursor=""
