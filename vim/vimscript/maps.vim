"File for setting up the maps in Vim:
""
"This is structured around five key verbs:
""(edit): edit some text in place, always a visual map
"(s)pawn: spawn a new window or process, destructive of cursor
""(f)ind: find something, or show something. 
"(g)o: jump to something that we know.
""
"
""Also doing some work on remapping the v commands to make them better.
"Here, the better is just fewer keystrokes for my main workflows.
"" base insert
"edit this is leader
""
vnoremap ec :Commentary<cr>
vnoremap es :AIE fix spelling and grammar using Australian English, assume markdown formatting is being used.<cr>
vnoremap ew :AIE Split this over multiple lines, so that no line exceeds 80 chars.<cr>  
vnoremap ee :AIE
vnoremap el :AIE

"spawn
nnoremap svb :vnew<CR>:wincmd L<CR>
nnoremap sb :new<CR>
nnoremap sc :AIC<CR>
vnoremap sc :AIC 
nnoremap st :split \| call StartTerm(g:slime_vimterminal_cmd)<CR>
nnoremap svt :vsplit \| call StartTerm(g:slime_vimterminal_cmd)<CR>
nnoremap sr :split \| call StartTerm(g:slime_vimterminal_cmd." %")<CR>
nnoremap sN :call LeftBarToNerdFind() <CR>
nnoremap ss :lua LeftBarToOutline()<CR>
nnoremap sn :call LeftBarToNerd()<CR>

""find
nnoremap fb <cmd>Telescope bibtex<cr>
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap <silent> fd :lua vim.lsp.buf.hover()<cr>

"go
" Big Jumps
nnoremap gb <c-o>
nnoremap gr <cmd>Telescope lsp_references<cr>
nnoremap <silent> gd :lua vim.lsp.buf.definition()<cr>
nnoremap <silent> gn :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> gp :lua vim.diagnostic.goto_prev()<CR>

" misc
vnoremap > >gv
vnoremap < <gv
nnoremap + :let pos=getpos(".")<CR>:tabedit %<CR>:call setpos(".", pos)<CR>



