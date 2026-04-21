"" Let the rmd handler function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=quarto
au BufRead,BufNewFile *.rmd  set filetype=quarto
au BufRead,BufNewFile *.qmd  set filetype=quarto
filetype plugin on

highlight link MarkviewPalette7Fg Keyword

highlight link @markup.quote.markdown Comment
highlight link @punctuation.special.markdown Comment
highlight link MarkviewLink MarkviewPalette7Fg


"" Default Note
function! NoteDefault()
execute 'silent 0r !/scripts/note_default.py ' . shellescape(expand('%:p'))
    normal! gg
endfunction
autocmd BufNewFile *.qmd :call NoteDefault()
autocmd BufRead *.qmd if getfsize(expand('%'))==0|call NoteDefault()|endif

function! QuartoExtras()
    lua require'otter'.activate()
    syntax match Cite /\k\@<!@\k\+\>/
    highlight link Cite MarkviewPalette7Fg
    setlocal wrap
    setlocal linebreak
endfunction

augroup QuartoExtrasGroup
    autocmd!
    autocmd BufReadPost *.qmd,*.quarto,*.md,*.rmd call QuartoExtras()
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
