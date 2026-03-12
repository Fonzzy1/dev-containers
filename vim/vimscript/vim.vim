" --- UI ---
set ruler
set visualbell
set belloff=all
set number
set signcolumn=yes
set background=dark
set linebreak
set nowrap
set fillchars+=vert:\▕
set conceallevel=3
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
set bufhidden=delete
set nohidden
set autowrite
set autoread
set switchbuf=vsplit

" --- Search ---
set incsearch
set cc=0
set ss=79

" --- Environment ---
set encoding=utf-8
set shell=/bin/bash
let $PATH = $PATH . ':/usr/bin'
let g:python3_host_prog = '/usr/bin/python3'

" --- Colorcolumn ---
augroup ColorLine
  autocmd!
  autocmd FileType *              setlocal textwidth=80
  autocmd FileType *              setlocal cc=81
  autocmd FileType dashboard      setlocal cc=0
  autocmd FileType lazygit        setlocal cc=0
  autocmd FileType Telescope      setlocal cc=0
  autocmd FileType TelescopePrompt setlocal cc=0
  autocmd FileType rnvimr         setlocal cc=0
augroup END

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

" --- Quickfix navigation maps ---
nnoremap ; :
vnoremap > >gv
vnoremap < <gv

" --- Plugin highlight links ---
hi link LazyGitFloat TelescopeNormal
hi link LazyGitBorder TelescopeBorder

lua vim.g.opencode_opts = { server = { port = 3000 } }
