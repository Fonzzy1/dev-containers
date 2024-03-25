" Make Vim open by default with NERDTree in full screen
let g:NERDTreeGitStatusUseNerdFonts = 0 " you should install nerdfonts by yourself. default: 0
let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0

function! Set_nerdtree_open_args()
  let empty_buffer =  line('$') == 1 && getline(1) == '' && !&modified
  if empty_buffer
    let g:NERDTreeCustomOpenArgs = {'file':{'where': 'p', 'reuse':'all', 'keepopen':0}}
  else
    let g:NERDTreeCustomOpenArgs = {'file':{'where': 'v', 'reuse':'all', 'keepopen':0}}
  endif
endfunction

" Remap nerdtree opens to v and h
let NERDTreeMapOpenVSplit='v'
let NERDTreeMapOpenSplit='h'
let NERDTreeMapQuit = 'Q'
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
    call Set_nerdtree_open_args()
    NERDTreeFocus
endfunction

function! LeftBarToNerdFind()
    call LeftBarToggle()
    call Set_nerdtree_open_args()
    NERDTreeFind
endfunction


