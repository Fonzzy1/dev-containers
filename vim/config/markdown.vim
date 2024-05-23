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
  let current_file = expand('%:p')

  " Prepare the R command to knit the file
  let r_cmd = "'require(rmarkdown); rmarkdown::render(\"' . current_file . '\")'"

  " Run the R command
  execute '!R -e ' . r_cmd
endfunction


function KnitToClip()


endfunction


function KnitToOpen()
    call Knit()



endfunction


function KnitToGist()




endfunction






