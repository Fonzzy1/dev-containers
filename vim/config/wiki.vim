let wiki_1 = {}
let wiki_1.path = '/wiki/'
let wiki_1.syntax = 'markdown'
let wiki_1.ext = '.rmd'
let wiki_1.diary_rel_path = '.'

let g:vimwiki_list = [wiki_1]
let g:vimwiki_ext2syntax = {'md':'markdown','rmd':'markdown'}


function! NoteDefault()
    :silent 0r !/scripts/note_default.py '%'
    normal! gg
endfunction

autocmd BufNewFile /wiki/*.rmd :call NoteDefault()
au FileType vimwiki :set syntax=rmarkdown | call RmdLinkSyntax() | setlocal foldexpr=MarkdownLevel() | setlocal foldmethod=expr



let g:vimwiki_global_ext = 0

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

let g:vimwiki_link_mappings = 1

function LeftBarToCalendar()
    call LeftBarToggle()
    :Calendar
endfunction

let g:calendar_diary='/wiki'
nnoremap c :call LeftBarToCalendar() <CR>
nnoremap F :call LeftBarToNerdFind() <CR>


function MarkdownLevel()
    let h = matchstr(getline(v:lnum), '^#\+')     
    if empty(h)       
        return "="     
        else       
            return ">" . len(h)     
        endif
endfunction

