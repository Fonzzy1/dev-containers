let g:NERDTreeGitStatusUseNerdFonts = 0 " you should install nerdfonts by yourself. default: 0
let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0

let g:NERDTreeCustomOpenArgs = {'file':{'where': 'v', 'reuse':'all', 'keepopen':1}}

" Remap nerdtree opens to v and h
let NERDTreeMapOpenVSplit='v'
let NERDTreeMapOpenSplit='h'
let NERDTreeMapQuit = 'Q'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:NERDTreeWinSize = 32   " Set the width to 30 columns (adjust to your preference)


nnoremap gT :call LeftBarToNerdFind() <CR>
nnoremap gt :call LeftBarToNerd()<CR>

function! LeftBarToNerd()
    call LeftBarToggle()
    NERDTreeFocus
endfunction

function! LeftBarToNerdFind()
    call LeftBarToggle()
    NERDTreeFind
endfunction


autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
