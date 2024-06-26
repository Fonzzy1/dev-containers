" TAGBAR
let g:tagbar_position = 'topleft vertical'
let g:tagbar_width = 32

nnoremap s :call LeftBarToTag()<CR>

function! LeftBarToTag()
    call LeftBarToggle()
    TagbarOpen
    wincmd t
endfunction

let g:tagbar_type_rmarkdown = {
      \ 'ctagstype': 'RMarkdown',
      \ 'kinds': [
      \   'c:Chapters',
      \   's:Sections',
      \   'S:Subsections',
      \   't:Subsubsections',
      \   'l:Chunks'
      \ ],
      \ 'sro': '""', 
      \ 'kind2scope': {
      \   'c': 'chapter',
      \   's': 'section',
      \   'S': 'subsection',
      \   't': 'subsubsection'
      \ },
      \ 'scope2kind': {
      \   'chapter': 'c',
      \   'section': 's',
      \   'subsection': 'S',
      \   'subsubsection': 't'
      \ },
      \ 'sort': 0,
      \ 'ctagsbin': '/usr/local/bin/ctags'
      \ }

let g:tagbar_type_quarto = g:tagbar_type_rmarkdown














