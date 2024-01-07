" Let the rmd hander function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=rmarkdown | set concealcursor=""
au BufRead,BufNewFile *.rmd  set filetype=rmarkdown | set concealcursor=""
filetype plugin on

