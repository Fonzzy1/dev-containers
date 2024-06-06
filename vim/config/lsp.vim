let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_signs_enabled = 1
let g:lsp_diagnostics_highlights_enabled = 1
let g:lsp_preview_float = 1
let g:lsp_completion_documentation_delay = 0
let g:lsp_diagnostics_highlight_delay = 0
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_hover_ui = 'float'
let g:lsp_fold_enabled = 0


let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')

" for asyncomplete.vim log
let g:asyncomplete_log_file = expand('~/asyncomplete.log')




let g:lsp_diagnostics_signs_hint = {'text': '➤'}
let g:lsp_diagnostics_signs_information = {'text': 'ℹ'}
let g:lsp_diagnostics_signs_warning = {'text': '⚠'}
let g:lsp_diagnostics_signs_error = {'text': '✗'}


function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete

    set foldmethod=expr
      \ foldexpr=lsp#ui#vim#folding#foldexpr()
      \ foldtext=lsp#ui#vim#folding#foldtext()

    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> <c-p> <plug>(lsp-previous-diagnostic)
    nmap <buffer> <c-n> <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre * call execute('LspDocumentFormatSync') 

    hi clear LspErrorHighlight
    hi clear LspWarningHighlight
    hi clear LspInformationHighlight
    hi clear LspHintHighlight

    highlight LspErrorHighlight  gui=underline cterm=underline guisp=red
    highlight LspWarningHighlight gui=underline cterm=underline guisp=yellow
    highlight LspInformationHighlight gui=underline cterm=underline guisp=blue
    highlight LspHintHighlightNE gui=underline cterm=underline guisp=green

endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END


au User lsp_setup call lsp#register_server({
\ 'name': 'r-languageserver',
\ 'cmd': {server_info->['/scripts/r-languageserver']},
\ 'allowlist': ['r']
\ })

au User lsp_setup call lsp#register_server({
            \ 'name': 'Ltex-ls',
            \ 'cmd': ['/usr/bin/ltex-ls/bin/ltex-ls', '--log-file=/root/ltex_log', '--endless'],
            \ 'allowlist': ['rmarkdown','vimwiki','text'],
            \ 'workspace_config': {
                \ 'ltex': {
                    \ 'completionEnabled' : v:true,
                    \ 'disabledRules': {"en-AU": ["WHITESPACE_RULE"]},
                    \ 'language': 'en-AU',
                    \ "diagnosticSeverity":{
                       \ "MORFOLOGIK_RULE_EN_AU" : 'error',
                       \ "default": "hints"
                       \ }
                    \ }
                \ }
            \ })




