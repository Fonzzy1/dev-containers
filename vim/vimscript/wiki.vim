let wiki_1 = {}
let wiki_1.path = '/wiki/'
let wiki_1.syntax = 'markdown'
let wiki_1.auto_tags = 0
let wiki_1.ext = '.qmd'
let wiki_1.diary_rel_path = '.'

let g:vimwiki_list = [wiki_1]
let g:vimwiki_ext2syntax = {'md':'markdown','rmd':'markdown','qmd':'markdown'}

  let g:vimwiki_key_mappings =
    \ {
    \   'all_maps': 1,
    \   'global': 1,
    \   'headers': 0,
    \   'text_objs': 1,
    \   'table_format': 1,
    \   'table_mappings': 0,
    \   'lists': 1,
    \   'links': 1,
    \   'html': 1,
    \   'mouse': 0,
    \ }



function! NoteDefault()
    :silent 0r !/scripts/note_default.py '%'
    normal! gg
endfunction

autocmd BufNewFile /wiki/*.qmd :call NoteDefault()

au FileType vimwiki :setlocal syntax=quarto | call LinkSyntax() 
au FileType vimwiki inoremap <C-t> <C-R>=printf('[%s](%s)', strftime('%Y-%m-%d'), strftime('%Y-%m-%d'))<CR>


function! MyCustomVimwikiLinkHandler(link) 
    if a:link =~ '^file:'
        let l:filename = a:link[5:]
        silent !xdg-open l:filename
    elseif a:link =~ '^url:'
        let l:filename = a:link[4:]
        silent !xdg-open l:filename
    elseif a:link =~ '^img:'
        let l:filename = a:link[4:]
        silent !xdg-open l:filename
    else
        return 0 " Fall back to default link handling
    endif
    return 1 " Indicate that we have handled the link
endfunction

let g:vimwiki_custom_wikilink_follow = 'MyCustomVimwikiLinkHandler'


function LeftBarToCalendar()
    call LeftBarToggle()
    :Calendar
endfunction

let g:calendar_diary='/wiki'

nnoremap c :call LeftBarToCalendar() <CR>

