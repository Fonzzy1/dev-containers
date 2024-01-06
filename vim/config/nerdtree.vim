" Don't start focused on nerdtree
let g:NERDTreeGitStatusUseNerdFonts = 0 " you should install nerdfonts by yourself. default: 0
let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0

let NERDTreeCustomOpenArgs = {'file':{'where': 'v', 'reuse':'all', 'keepopen':0}}
" Remap nerdtree opens to v and h
let NERDTreeMapOpenVSplit='v'
let NERDTreeMapOpenSplit='h'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
" Special fuzzy find in nerdtree
autocmd FileType nerdtree  noremap <buffer> / :call OpenFzf()<CR>

function! OpenFzf()
    NERDTree
    let job = term_start('/bin/sh -c "fzf"', {'curwin':1, 'out_io': 'file', 'out_name': '/tmp/fzf.file', 'close_cb':'SendFZFtoOpen', 'term_finish':'close'})
endfunction
function! SendFZFtoOpen(channel)
    let l:file_name = readfile('/tmp/fzf.file')[0]    
    execute 'vs ' . l:file_name
endfunction

nnoremap F :call LeftBarToNerdFind() <CR>
nnoremap f :call LeftBarToNerd()<CR>

function! LeftBarToNerd()
    call LeftBarToggle()
    NERDTreeFocus
endfunction

function! LeftBarToNerdFind()
    call LeftBarToggle()
    NERDTreeFind
endfunction
