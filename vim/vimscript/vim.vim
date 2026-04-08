" --- UI ---
set ruler
set visualbell
set belloff=all
set number
set signcolumn=yes
set background=dark
set nowrap
set fillchars+=vert:\▕
set conceallevel=3
set hidden
highlight clear SignColumn
syntax on

" --- Editing ---
set autoindent
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set backspace=indent,eol,start
set nospell

" --- Splits ---
set splitright
set splitbelow

" --- Buffers ---
set autowrite
set autoread
set switchbuf=vsplit

" --- Environment ---
set encoding=utf-8
set shell=/bin/bash
let $PATH = $PATH . ':/usr/bin'
let g:python3_host_prog = '/usr/bin/python3'

" --- Autoread ---
augroup AutoRead
  autocmd!
  autocmd FocusGained,BufEnter * checktime
  autocmd FileType DressingInput startinsert
  autocmd BufEnter,WinEnter * if &buftype == 'terminal' | startinsert | endif
augroup END

if has('nvim')
  call timer_start(500, {-> execute('checktime')}, {'repeat': -1})
endif

"-- diff
set diffopt=internal,filler,closeoff,indent-heuristic,inline:char,linematch:40,vertical,algorithm:histogram
"
"
" --- Quickfix navigation maps ---
nnoremap ; :
vnoremap > >gv
vnoremap < <gv

" --- Plugin highlight links ---
hi link LazyGitFloat TelescopeNormal
hi link LazyGitBorder TelescopeBorder

lua <<EOF
vim.g.opencode_opts = {
  server = {
    port = 3000,
    start = function() end,
    stop = function() end,
    toggle = function() end,
  },
}
EOF



