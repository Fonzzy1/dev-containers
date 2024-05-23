" Let the rmd hander function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=rmarkdown 
au BufRead,BufNewFile *.rmd  set filetype=rmarkdown
filetype plugin on

function RmdLinkSyntax()
    syntax match FooBar /\v\[[^]]+\]\([^\)]+\)/ containedin=ALL contains=Foo,Bar,ConcealBrackets
    syntax match Foo /\v([^]]+)/ contained containedin=FooBar
    syntax match Bar /\v\(([^()[\]]+)\)/ contained containedin=FooBar conceal
    syntax match ConcealBrackets /[\[\]]/ contained containedin=FooBar conceal
    set conceallevel=2
    hi Foo cterm=underline gui=underline
endfunction

au FileType rmarkdown :call RmdLinkSyntax()


function! Knit()
  silent !/scripts/knit.R --args '%' | redraw! | echo
endfunction


function KnitToClip()
    call Knit()
    let knit_path = expand("%:p:h") . "/knits/" . expand("%:t:r") . ".pdf"
    execute "silent !xclip -sel clip -t application/pdf -i " . knit_path
endfunction


function KnitToOpen()
    call Knit()
    let knit_path = expand("%:p:h") . "/knits/" . expand("%:t:r") . ".pdf"
    execute "silent !xdg-open " . knit_path
endfunction


