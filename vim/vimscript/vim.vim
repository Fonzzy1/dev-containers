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
set clipboard=unnamedplus

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

" -- diff
set diffopt=internal,filler,closeoff,indent-heuristic,inline:char,linematch:40,vertical,algorithm:histogram

" Diff-mode keymaps
augroup DiffKeymaps
  autocmd!
  " Apply these mappings only when a window is in diff mode
  autocmd VimEnter,WinEnter * if &diff
        \ | setlocal nofoldenable foldcolumn=0
        \ | nnoremap <silent> <buffer> gn ]c
        \ | nnoremap <silent> <buffer> gp [c
        \ | nnoremap <silent> <buffer> aa do          " accept hunk (diffget)
        \ | nnoremap <silent> <buffer> ar dp          " reject hunk (diffput)
        \ | nnoremap <silent> <buffer> da :%diffget<CR> " accept whole diff
        \ | nnoremap <silent> <buffer> dr :%diffput<CR> " reject whole diff
        \ | endif
augroup END

" --- Quickfix navigation maps ---
nnoremap ; :
vnoremap > >gv
vnoremap < <gv

" --- Plugin highlight links ---
hi link LazyGitFloat TelescopeNormal
hi link LazyGitBorder TelescopeBorder



