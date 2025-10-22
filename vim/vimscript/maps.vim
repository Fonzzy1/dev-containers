"File for setting up the maps in Vim:
""
"This is structured around five key verbs:
""(edit): edit some text in place, always a visual map
"(s)pawn/send: spawn a new window or process
""(f)ind: find something, or show something, navigation
"(g)o: jump to something that we know.
""
"
""Also doing some work on remapping the v commands to make them better.
"Here, the better is just fewer keystrokes for my main workflows.
"" base insert
"edit this is leader
""
vnoremap <silent> ec :Commentary<cr>
vnoremap <silent> es :AIE fix spelling and grammar using Australian English, assume markdown formatting is being used. Don't replace -- with dashes<cr>
nnoremap <silent> es <cmd>Telescope spell_suggest<cr>
vnoremap <silent> ew gw
vnoremap ee :AIE 

" Spawn
nnoremap <silent> sB :vnew<CR>:wincmd L<CR>
nnoremap <silent> sb :new<CR>
nnoremap <silent> sc :AIC<CR>
vnoremap sc :AIC 
nnoremap <silent> sr :OverseerRun<CR>
nnoremap <silent> sR :lua load_project_overseer_templates()<CR>
nnoremap <silent> so :OverseerToggle<CR>
nnoremap <silent> sg :LazyGit<CR>
nnoremap <silent> sv :LazyGitFilterCurrentFile<CR>
nnoremap sG :Octo 
nnoremap <silent> sm :lua require('browse').open_manual_bookmarks()<CR>
nnoremap <silent> sM :lua browse_bookmarks()<CR>


""find ()
nnoremap fb <cmd>Telescope bibtex<cr>
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap <silent> fn :RnvimrToggle<CR>
nnoremap <silent> fs <cmd>Telescope lsp_document_symbols<cr>
nnoremap <silent> fd <cmd>Telescope lsp_diagnostics<cr>
nnoremap <silent> fc <cmd>Telescope git_status<cr>
nnoremap  <silent> fh :Gitsigns preview_hunk<CR>
nnoremap  <silent> fa :Gitsigns blame_line<CR>

"go
" Big Jumps
nnoremap gb <c-o>
nnoremap gr <cmd>Telescope lsp_references<cr>
nnoremap <silent> gd :lua vim.lsp.buf.definition()<cr>
nnoremap <silent> gn :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> gp :lua vim.diagnostic.goto_prev()<CR>
nmap <silent> ghn :Gitsigns nav_hunk next<CR>
nmap <silent> ghp :Gitsigns nav_hunk prev<CR>

"actions
nnoremap  <silent> aa :Gitsigns stage_hunk<CR>
nnoremap  <silent> ar :Gitsigns reset_hunk<CR>
vnoremap  <silent> aa :'<,'>Gitsigns stage_hunk<CR>
vnoremap  <silent> ar :'<,'>Gitsigns reset_hunk<CR>
nnoremap  <silent> ac :lua GitCommit()<CR>
nnoremap ab :Gitsigns change_base
nnoremap <silent> ad :lua vim.lsp.buf.hover()<cr>

" miscmap
vnoremap > >gv
vnoremap < <gv
nnoremap + :WindowsMaximize<CR>
nnoremap <silent><Esc> :noh<CR>
"" map esc to enter terminal normal mode
tnoremap <Esc><Esc> <C-\><C-n>
nnoremap <silent> vih :Gitsigns select_hunk<CR>



lua <<EOF
-- Function to run git commit with a custom message
function GitCommit()
  -- Ask for a commit message
  local message = vim.fn.input("Commit message: ")
  if message == "" then
    print("Aborted: no commit message.")
    return
  end

  -- Run git commit in a shell
  local cmd = "git commit -m " .. vim.fn.shellescape(message)
  vim.cmd("!" .. cmd)
end
EOF

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
