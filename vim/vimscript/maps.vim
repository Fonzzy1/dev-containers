"
"File for settin up the maps in the vim:
"
"This is stuctrued around four key verbs:
"(a)ct: edit some text in place
"(s)pawn: spawn a new window or process, non-destructive of cursor
"(f)ind: find something, or show something. Wont move cursor
"(g)o: jump to something.


"act
vnoremap ad gc
nnoremap <silent> aa :lua vim.lsp.buf.code_action()<CR>
nnoremap at :split \| call StartTerm(g:slime_vimterminal_cmd." %")<CR>
vnoremap as :'<,'>AIE fix spelling and gramar using australian english, assume marrdown formatting is being used. Only return the text without wraping it in code blocks:<cr>
nnoremap as :.AIE fix spelling and gramar using australian english, assume marrdown formatting is being used. Only return the text without wraping it in code blocks:<cr>
nnoremap ac :.AI Complete this with boilerplate code:<CR>
vnoremap ac :'<,'>AI Complete this with boilerplate code:<CR>

"spawn
nnoremap svb :vnew<CR>:wincmd L<CR>
nnoremap sb :new<CR>
nnoremap sc :AIC<CR>
vnoremap sc :'<,'>AIC read this and wait for further instructions. Only respond with 'Understood.'<CR>
nnoremap st :split \| call StartTerm(g:slime_vimterminal_cmd)<CR>
nnoremap svt :vsplit \| call StartTerm(g:slime_vimterminal_cmd)<CR>

"find
nnoremap fT :call LeftBarToNerdFind() <CR>
nnoremap fs :lua LeftBarToOutline()<CR>'
nnoremap ft :call LeftBarToNerd()<CR>
nnoremap fb <cmd>Telescope bibtex<cr>
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap <silent> fd :lua require'otter'.ask_hover()<CR>

"go
nnoremap gb <c-o>
nnoremap gr <cmd>Telescope lsp_references<cr>
nnoremap <silent> gd :lua require'otter'.ask_definition()<CR>
nnoremap <silent> gn :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> gp :lua vim.diagnostic.goto_prev()<CR>


