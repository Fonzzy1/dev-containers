"" Let the rmd handler function! on files ending with .md
augroup quarto_ft
  autocmd!
  autocmd BufRead,BufNewFile *.md,*.rmd,*.qmd,*.brainstorm setfiletype quarto
augroup END
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
    echo "Quarto Extras Set up"
    syntax match Cite /\%(\k\)\@<!@[A-Za-z0-9:_-]\+\%(\>\|[^A-Za-z0-9:_-]\)/
    highlight link Cite MarkviewPalette7Fg
    setlocal wrap
    setlocal linebreak
    setlocal foldmethod=expr
    setlocal foldexpr=QuartoChunkFoldExpr()
    setlocal foldenable
    setlocal foldlevel=0
    inoremap <buffer> ``` ```{}<CR><CR>```<Esc>kA
    nnoremap <silent> <buffer> se zaj:EditCodeBlock<CR>
endfunction

augroup QuartoExtrasGroup
    autocmd!
    autocmd BufReadPost *.qmd,*.quarto,*.md,*.rmd,*.brainstorm call QuartoExtras()
    autocmd BufWritePost *.qmd call QuartoExtras()
augroup END


function! QuartoChunkFoldExpr()
   let l:line = getline(v:lnum)

  if l:line =~ '^```{\_.\+}\s*$'
    return '>1'
  elseif l:line =~ '^```\w\+\s*$'
    return '>1'
  elseif l:line =~ '^```\s*$'
    return '<1'
  else
    return '='
  endif
endfunction

lua require('ecb').setup { wincmd = 'tabnew' }


""" Bullet Setup
let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text',
    \ 'gitcommit',
    \ 'quarto',
    \ 'rmd'
    \]

let g:bullets_outline_levels = ['ROM', 'ABC', 'num', 'abc' , 'std-',]
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'sh', 'zsh', 'fish', 'javascript', 'js=javascript', 'typescript', 'ts=typescript', 'json', 'yaml', 'yml=yaml', 'toml', 'ini', 'conf', 'css', 'scss', 'less', 'sql', 'lua', 'vim', 'ruby', 'rb=ruby', 'perl', 'php', 'go', 'rust', 'c', 'cpp', 'java', 'kotlin', 'swift', 'dart', 'r', 'matlab', 'octave', 'make', 'dockerfile', 'markdown', 'md=markdown', 'xml', 'svg', 'latex', 'tex=latex']
