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
vnoremap ee :AIE 

"spawn (permanent windows)
nnoremap <silent> svb :vnew<CR>:wincmd L<CR>
nnoremap <silent> sb :new<CR>
nnoremap <silent> sc :AIC<CR>
vnoremap sc :AIC 
nnoremap <silent> sN :call LeftBarToNerdFind() <CR>
nnoremap <silent> ss :lua LeftBarToOutline()<CR>
nnoremap <silent> sn :call LeftBarToNerd()<CR>
" sa, si st and sT are all defined vim iron for sending code
nnoremap sr :OverseerRunCmd 
nnoremap <silent> sR :lua LeftBarToOver()<CR>


""find (temp windows)
nnoremap fb <cmd>Telescope bibtex<cr>
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap <silent> fd :lua vim.lsp.buf.hover()<cr>
nnoremap <silent> fw :lua require("telescope").extensions.arecibo.websearch()<cr>

"go
" Big Jumps
nnoremap gb <c-o>
nnoremap gr <cmd>Telescope lsp_references<cr>
nnoremap <silent> gd :lua vim.lsp.buf.definition()<cr>
nnoremap <silent> gn :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> gp :lua vim.diagnostic.goto_prev()<CR>

" miscmap
vnoremap > >gv
vnoremap < <gv
nnoremap + :WindowsMaximize<CR>
"" map esc to enter terminal normal mode
tnoremap <Esc><Esc> <C-\><C-n>



nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
tnoremap <c-h> <Cmd>wincmd h<CR>
tnoremap <c-j> <Cmd>wincmd j<CR>
tnoremap <c-k> <Cmd>wincmd k<CR>
tnoremap <c-l> <Cmd>wincmd l<CR>
inoremap <C-h> <Esc><C-w>h
inoremap <C-j> <Esc><C-w>j
inoremap <C-k> <Esc><C-w>k
inoremap <C-l> <Esc><C-w>l
