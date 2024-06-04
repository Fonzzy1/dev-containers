inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
let g:asyncomplete_remove_duplicates = 1
let g:asyncomplete_smart_completion = 1
let g:asyncomplete_matchfuzzy    = 1


function! s:link_completor(opt, ctx) abort
    let l:col = a:ctx['col']
    let l:typed = a:ctx['typed']
    let l:kw = matchstr(l:typed, '\v\]\(')
    let l:kwlen = len(l:kw) - 1 
    let l:startcol = l:col - l:kwlen 

    if l:kwlen > 0

        let l:matches = split(globpath('.', '*'), '\n')
        let l:matches =  map(l:matches, 'substitute(v:val, "^\\./", "", "")')
        let l:matches = map(l:matches, 'substitute(v:val, "\\.[^.]*$", "", "")')

        call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
    endif
endfunction

au User asyncomplete_setup call asyncomplete#register_source({
    \ 'name': 'vimwiki',
    \ 'allowlist': ['vimwiki'],
    \ 'completor': function('s:link_completor'),
    \ })
