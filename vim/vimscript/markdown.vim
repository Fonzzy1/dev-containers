" Let the rmd hander function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=quarto
au BufRead,BufNewFile *.rmd  set filetype=quarto
au BufRead,BufNewFile *.qmd  set filetype=quarto
filetype plugin on

function! QuartoExtras()
    "" Conceal For links
    syntax match FooBar /\v\[[^]]+\]\([^\)]+\)/ containedin=ALL contains=Foo,Bar,ConcealBrackets
    syntax match Foo /\v([^]]+)/ contained containedin=FooBar
    syntax match Bar /\v\(([^()[\]]+)\)/ contained containedin=FooBar conceal
    syntax match ConcealBrackets /[\[\]]/ contained containedin=FooBar conceal
    set conceallevel=2
    hi Foo cterm=underline gui=underline

    "" ctrl t gives you todays link
    inoremap <C-t> <C-R>=printf('[[%s]]', strftime('%Y-%m-%d'))<CR>

    "" todo stuff
    nnoremap gt :ToggleCheckbox<cr>

    autocmd InsertLeave <buffer> TableModeRealign
    "" Make links
    vnoremap <CR> :call CreateMdLink()<cr>

    "" Make a new file
    nnoremap gn :call CreateMdFile()<cr>


endfunction

function! CreateMdFile()
    write
    let path=substitute(expand('<cfile>'), '%20', ' ', 'g')
    execute 'edit ' . substitute(path,'/','','')
endfunction


function! CreateMdLink() range
    let text = getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]]
    let mdlink = '[' . text . '](\/' . substitute(text, ' ', '%20', 'g') . '.qmd)'
    execute a:firstline . "," . a:lastline . "s/". text . "/" . mdlink . "/g"
endfunction

au FileType quarto :call QuartoExtras()

"" Fenced Language
let g:markdown_fenced_languages = ['bash=sh']
let g:pandoc#syntax#codeblocks#embeds#langs = ["bash=sh"]

"" Bullet Setup
let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text',
    \ 'gitcommit',
    \ 'quarto',
    \ 'rmd'
    \]

"" TableMode
let g:table_mode_always_active =1
let g:table_mode_syntax = 1

"" Quato Preview Funtions
function! QuartoPreview() 
    let l:current_file = expand('%:p')
    :split
    call StartTerm('quarto preview "'.l:current_file .'"')
endfunction

function! QuartoRender() 
    let l:current_file = expand('%:p')
    :split
    call StartTerm('quarto render "'.l:current_file .'" --to pdf')
endfunction

command! Preview :call QuartoPreview()
command! Render :call QuartoRender()

