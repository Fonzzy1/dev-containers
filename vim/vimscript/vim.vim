set ruler
set visualbell
set autoindent
set splitright
set splitbelow
set expandtab
set shiftwidth=4
set tabstop=4
set linebreak
set nospell
set belloff=all
set nowrap
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
set textwidth=80
set smartindent
set nosmarttab
set fillchars+=vert:\▕

augroup ColorLine
  autocmd!
  autocmd FileType * setlocal cc=81
  autocmd FileType fugitive setlocal cc=0
  autocmd FileType dashboard setlocal cc=0
  autocmd FileType Telescope setlocal cc=0
  autocmd FileType TelescopePrompt setlocal cc=0
augroup END
"" Quick nav maps
nnoremap ; :
vnoremap > >gv
vnoremap < <gv

