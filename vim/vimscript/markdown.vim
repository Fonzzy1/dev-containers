" Let the rmd hander function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=quarto
au BufRead,BufNewFile *.rmd  set filetype=quarto
au BufRead,BufNewFile *.qmd  set filetype=quarto
filetype plugin on

function LinkSyntax()
    syntax match FooBar /\v\[[^]]+\]\([^\)]+\)/ containedin=ALL contains=Foo,Bar,ConcealBrackets
    syntax match Foo /\v([^]]+)/ contained containedin=FooBar
    syntax match Bar /\v\(([^()[\]]+)\)/ contained containedin=FooBar conceal
    syntax match ConcealBrackets /[\[\]]/ contained containedin=FooBar conceal
    set conceallevel=2
    hi Foo cterm=underline gui=underline
endfunction

au FileType quarto :call LinkSyntax()

let g:markdown_fenced_languages = ['bash=sh']
let g:pandoc#syntax#codeblocks#embeds#langs = ["bash=sh"]

function! QuartoPreview() 
    let l:current_file = expand('%:p')
    execute '!quarto preview '.l:current_file.' &'
endfunction

command! Preview call QuartoPreview()

function! QuartoRender() 
    let l:current_file = expand('%:p')
    execute '!quarto render '.l:current_file
endfunction

command! Knit call QuartoRender()
