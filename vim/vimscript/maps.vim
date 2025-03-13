"
"File for settin up the maps in the vim:
"
"This is stuctrued around five key verbs:
"(a)ct: edit some text in place, always a visual map
"(s)pawn: spawn a new window or process, Destrvive of curson
"(f)ind: find something, or show something. Wont move cursor
"(g)o: jump to something.
"(d)elete: close and hide thingd.
"
"
"Also doing some work on remapping the v commands to make them better
"Here, the better is just lest key strokes for my main workflows
" base insert
"act
"
vnoremap ac :'<,'>Commentary<cr>
vnoremap <silent> aa :lua vim.lsp.buf.code_action()<CR>
vnoremap as :'<,'>AIE fix spelling and grammar using Australian English, assume markdown formatting is being used.<cr>
vnoremap aw :'<,'>AIE Split this over multiple lines, so that no line exceeds 80 chars.<cr>  
vnoremap af :'<,'>AIE fix this<cr>
vnoremap ae :'<,'>AIE

"spawn
nnoremap svb :vnew<CR>:wincmd L<CR>
nnoremap sb :new<CR>
nnoremap sc :AIC<CR>
vnoremap sc :AIC 
nnoremap st :split \| call StartTerm(g:slime_vimterminal_cmd)<CR>
nnoremap svt :vsplit \| call StartTerm(g:slime_vimterminal_cmd)<CR>
nnoremap sr :split \| call StartTerm(g:slime_vimterminal_cmd." %")<CR>
nnoremap sx :vsplit \| call StartTerm('/root/.cargo/bin/is-fast ' . input('Enter text: '))<CR>

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
" Big Jumps
nnoremap gb <c-o>
nnoremap gr <cmd>Telescope lsp_references<cr>
nnoremap <silent> gd :lua require'otter'.ask_definition()<CR>
nnoremap <silent> gn :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> gp :lua vim.diagnostic.goto_prev()<CR>

" Start/End of Line
nnoremap <silent> gsl ^
nnoremap <silent> gel $

" Word Navigation
nnoremap gsw b
nnoremap gew Wbge

" Sentence Navigation
nnoremap gss (w
nnoremap ges )bge

" Paragraph Navigation
nnoremap gsp {w^
nnoremap gep }b$


" Visual  Mappigns
nnoremap vw viw
nnoremap vs vis
nnoremap vp vip
nnoremap v( vi(
nnoremap v{ vi{
nnoremap v[ vi[
nnoremap v' vi'
nnoremap v" vi"

nnoremap <silent> vl v^
nnoremap <silent> ve v$

nnoremap vow vaw
nnoremap vos vas
nnoremap vop vap
nnoremap vo( va(
nnoremap vo{ va{
nnoremap vo[ va[
nnoremap vo' va'
nnoremap vo" va"
vnoremap > >gv
vnoremap < <gv
