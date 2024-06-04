inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

au User asyncomplete_setup call asyncomplete#register_source({
    \ 'name': 'vimwiki',
    \ 'allowlist': ['vimwiki'],
    \ 'completor': function('Complete_wikifiles'),
    \ }


