"
"File for settin up the maps in the vim:
"
"This is stuctrued around five key verbs:
"(a)ct: edit some text in place
"(s)pawn: spawn a new window or process, Destrvive of curson
"(f)ind: find something, or show something. Wont move cursor
"(g)o: jump to something.
"(d)elete: close and hide thingd.

"act
vnoremap ac :'<,'>Commentary<cr>
nnoremap ac :Commentary<cr>
nnoremap <silent> aa :lua vim.lsp.buf.code_action()<CR>
vnoremap as :'<,'>AIE fix spelling and grammar using Australian English, assume markdown formatting is being used. Only return the text without wrapping it in code blocks:<cr>
nnoremap as :.AIE fix spelling and grammar using Australian English, assume markdown formatting is being used. Only return the text without wrapping it in code blocks:<cr>
nnoremap aw :.AIE Split this over multiple lines, so that no line exceeds 80 chars. Only return the text without wrapping it in code blocks:<cr>  
vnoremap aw :'<,'>AIE Split this over multiple lines, so that no line exceeds 80 chars. Only return the text without wrapping it in code blocks:<cr>  
nnoremap af :.AIE fix this. Only return the text without wrapping it in code blocks:<cr>
vnoremap af :'<,'>AIE fix this. Only return the text without wrapping it in code blocks:<cr>



"spawn
nnoremap svb :vnew<CR>:wincmd L<CR>
nnoremap sb :new<CR>
nnoremap sc :AIC<CR>
vnoremap sc :'<,'>AIC read this and wait for further instructions. Only respond with 'Understood.'<CR>
nnoremap st :split \| call StartTerm(g:slime_vimterminal_cmd)<CR>
nnoremap svt :vsplit \| call StartTerm(g:slime_vimterminal_cmd)<CR>
nnoremap sr :split \| call StartTerm(g:slime_vimterminal_cmd." %")<CR>

"find
nnoremap fT :call LeftBarToNerdFind() <CR>
nnoremap fs :lua LeftBarToOutline()<CR>'
nnoremap ft :call LeftBarToNerd()<CR>
nnoremap fb <cmd>Telescope bibtex<cr>
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap <silent> fd :lua require'otter'.ask_hover()<CR>

"delete
nnoremap do :let pos=getpos(".")<CR>:tabedit %<CR>:call setpos(".", pos)<CR>
nnoremap dw :wq<CR>
nnoremap ds :q<CR>

"go
nnoremap gb <c-o>
nnoremap gr <cmd>Telescope lsp_references<cr>
nnoremap <silent> gd :lua require'otter'.ask_definition()<CR>
nnoremap <silent> gn :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> gp :lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> gl :wincmd L
nnoremap <silent> gh :wincmd H


