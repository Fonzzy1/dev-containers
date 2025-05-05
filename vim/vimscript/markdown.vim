"" Let the rmd hander function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=quarto
au BufRead,BufNewFile *.rmd  set filetype=quarto
au BufRead,BufNewFile *.qmd  set filetype=quarto
filetype plugin on
inoremap [[[ <cmd>Telescope bibtex<cr>

autocmd FileType quarto setlocal textwidth=80
highlight link @markup.quote.markdown Comment
highlight link @punctuation.special.markdown Comment



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
    " Save the current file
    write

    " Get the full path of the current file
    let l:current_file = expand('%:p')

    " Construct the command to be executed
    let l:cmd = 'quarto preview ' . shellescape(l:current_file)

    " Execute the command using OverseerRunCmd
    execute 'OverseerRunCmd ' . l:cmd
endfunction

function! QuartoRender()
    " Save the current file
    write

    " Get the full path of the current file
    let l:current_file = expand('%:p')

    " Construct the command to be executed
    let l:cmd = 'quarto render ' . shellescape(l:current_file)

    " Execute the command using OverseerRunCmd
    execute 'OverseerRunCmd ' . l:cmd
endfunction

function! QuartoPublish()
    " Save the current file
    write

    " Get the full path of the current file
    let l:current_file = expand('%:p')

    " Get the output file name with .pdf extension
    let l:output_file = expand('%:t:r') . ".pdf"

    " Construct the command to be executed
    let l:cmd = 'cd /wiki/Public && ' .
                \ 'quarto render ' . shellescape(l:current_file) . ' --to pdf -o ' . shellescape(l:output_file) . ' && ' .
                \ 'git add . && ' .
                \ 'git commit -m ' . shellescape('Add ' . expand('%:t')) . ' && ' .
                \ 'git push'

    " Execute the command using OverseerRunCmd
    execute 'OverseerRunCmd ' . string(l:cmd)
endfunction

command! Preview :call QuartoPreview()
command! Publish :call QuartoPublish()
command! Render :call QuartoRender()

