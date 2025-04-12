"" Let the rmd hander function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=quarto
au BufRead,BufNewFile *.rmd  set filetype=quarto
au BufRead,BufNewFile *.qmd  set filetype=quarto
filetype plugin on
inoremap [[[ <cmd>Telescope bibtex<cr>



function! QuartoExtras()
    lua require'otter'.activate()
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


"" Quato Preview Funtions
function! QuartoPreview() 
    :w
    let l:current_file = expand('%:p')
    :split
    call StartTerm('quarto preview "'.l:current_file .'"')
endfunction

function! QuartoRender() 
    :w
    let l:current_file = expand('%:p')
    :split
    call StartTerm('quarto render "'.l:current_file .'"')
endfunction

function! QuartoPublish()
    :w
    let l:current_file = expand('%:p')
    let l:output_file = expand('%:t:r') . ".pdf"
    :split
    call StartTerm('cd /wiki/Public; quarto render "' . l:current_file . '" --to pdf -o "' . l:output_file . '";  git add .; git commit -m "Add ' . expand('%:t') . '"; git push')
endfunction

command! Preview :call QuartoPreview()
command! Publish :call QuartoPublish()
command! Render :call QuartoRender()

