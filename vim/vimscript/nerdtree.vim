let g:NERDTreeGitStatusUseNerdFonts = 0 " you should install nerdfonts by yourself. default: 0
let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0

let g:NERDTreeCustomOpenArgs = {'file':{'where': 'p', 'reuse':'all', 'keepopen':1}}

" Remap nerdtree opens to v and h
let NERDTreeMapOpenVSplit='v'
let NERDTreeMapOpenSplit='h'
let NERDTreeMapQuit = 'Q'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
" Special fuzzy find in nerdtree
autocmd FileType nerdtree  noremap <buffer> / :Files<cr>

let g:fzf_layout = { 'window': 'enew' }
let g:fzf_vim = {'preview_window':[]}

nnoremap fT :call LeftBarToNerdFind() <CR>
nnoremap ft :call LeftBarToNerd()<CR>

function! LeftBarToNerd()
    call LeftBarToggle()
    NERDTreeFocus
endfunction

function! LeftBarToNerdFind()
    call LeftBarToggle()
    NERDTreeFind
endfunction


