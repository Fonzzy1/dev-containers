"File for setting up the maps in Vim:
""
"This is structured around five key verbs:
""(edit): edit some text in place, always a visual map
"(s)pawn/send: spawn a new window or process, destructive of cursor
""(f)ind: find something, or show something. 
"(g)o: jump to something that we know.
""
"
""Also doing some work on remapping the v commands to make them better.
"Here, the better is just fewer keystrokes for my main workflows.
"" base insert
"edit this is leader
""
vnoremap <silent> ec :Commentary<cr>
vnoremap <silent> es :AIE fix spelling and grammar using Australian English, assume markdown formatting is being used.<cr>
vnoremap <silent> ew :AIE Split this over multiple lines, so that no line exceeds 80 chars.<cr>  
vnoremap <silent> ee :AIE

"spawn
nnoremap <silent> svb :vnew<CR>:wincmd L<CR>
nnoremap <silent> sb :new<CR>
nnoremap <silent> sc :AIC<CR>
vnoremap <silent> sc :AIC 
nnoremap <silent> sN :call LeftBarToNerdFind() <CR>
nnoremap <silent> ss :lua LeftBarToOutline()<CR>
nnoremap <silent> sn :call LeftBarToNerd()<CR>
" sa, si st and sT are all defined vim iron for sending code
nnoremap sr :OverseerRunCmd 
nnoremap sR :lua LeftBarToOver()<CR>


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
nnoremap + :WindowsMaximize<CR>

nnoremap <silent> dw :wq<CR>
nnoremap <silent> da :wa<CR>:qa<CR>
nnoremap <silent> dn :q!<CR>


