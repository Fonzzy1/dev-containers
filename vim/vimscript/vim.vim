set ruler
set fillchars+=vert:\|
set visualbell
set autoindent
set splitright
set expandtab
set shiftwidth=4
set tabstop=4
set linebreak
set nospell
set belloff=all
syntax on
set background=dark
set signcolumn=yes
set number
set bufhidden=delete
highlight clear SignColumn
set incsearch
set nohidden
set autowrite
set switchbuf=vsplit
set backspace=indent,eol,start
set clipboard=unnamedplus
set encoding=utf-8
set shell=/bin/bash
let $PATH = $PATH . ':/usr/bin'
let g:python3_host_prog = '/usr/bin/python3'


"" Quick nav maps
nnoremap gb <c-o>
nnoremap ; :


vnoremap > >gv
vnoremap < <gv
