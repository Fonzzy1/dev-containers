let wiki_1 = {}
let wiki_1.path = '/wiki/'
let wiki_1.syntax = 'markdown'
let wiki_1.ext = '.rmd'

let g:vimwiki_list = [wiki_1]
let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown', '.rmd':'markdown'}


au BufNewFile /wiki/*.md :silent 0r !/scripts/note_default.py '%'
au FileType vimwiki setlocal syntax=rmarkdown

function! MyRmdHighlight()
    syntax region myRegion matchgroup=myDelimiter start="\[\[" end="\]\]" concealends
    highlight myRegion guifg=LightMagenta
endfunction

autocmd FileType vimwiki call MyRmdHighlight()

function! MyCustomVimwikiLinkHandler(link) 
  if a:link =~ '^file:'
    let l:filename = a:link[5:]
    silent !xdg-open l:filename
  else
    return 0 " Fall back to default link handling
  endif
  return 1 " Indicate that we have handled the link
endfunction

let g:vimwiki_custom_wikilink_follow = 'MyCustomVimwikiLinkHandler'

let g:vimwiki_link_mappings = 1

function LeftBarToCalendar()
    call LeftBarToggle()
    :Calendar
endfunction

let g:calendar_diary='/wiki/diary'
nnoremap c :call LeftBarToCalendar() <CR>
nnoremap F :call LeftBarToNerdFind() <CR>
