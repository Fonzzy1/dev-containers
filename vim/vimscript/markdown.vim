"" Let the rmd handler function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=quarto
au BufRead,BufNewFile *.rmd  set filetype=quarto
au BufRead,BufNewFile *.qmd  set filetype=quarto
filetype plugin on

highlight link MarkviewPalette7Fg Keyword

highlight link @markup.quote.markdown Comment
highlight link @punctuation.special.markdown Comment
highlight link MarkviewLink MarkviewPalette7Fg


function! QuartoExtras()
    lua require'otter'.activate()
    syntax match Cite /\k\@<!@\k\+\>/
    highlight link Cite MarkviewPalette7Fg
    set wrap
    set linebreak
endfunction

augroup QuartoExtrasGroup
    autocmd!
    autocmd BufReadPost *.qmd,*.quarto if &filetype == 'quarto' | call QuartoExtras() | endif
    autocmd BufWritePost *.qmd call QuartoExtras()
augroup END


""" Bullet Setup
let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text',
    \ 'gitcommit',
    \ 'quarto',
    \ 'rmd'
    \]

let g:bullets_outline_levels = ['ROM', 'ABC', 'num', 'abc', 'rom', 'std-',]
