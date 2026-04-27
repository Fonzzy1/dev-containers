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
vnoremap ee :AIE 
nnoremap <silent> eb <cmd>GetBib<cr>


" Spawn
nnoremap <silent> sb :vnew<CR>:wincmd L<CR>
nnoremap <silent> sB :new<CR>
nnoremap <silent> sV :SmartVsplit 
nnoremap <silent> sc :AIC<cr>i
vnoremap sc :AIC 
nnoremap sC <Cmd>AIRoles<cr>

nnoremap <silent> so :lua require('telescope').extensions.toggletasks.select()<CR>
nnoremap <silent> sr <cmd>Telescope toggletasks spawn<CR>
nnoremap <silent> sg :LazyGit<CR>
nnoremap <silent> sv :LazyGitFilterCurrentFile<CR>
nnoremap sG :Octo 
nnoremap <silent> sm :lua require('browse').open_manual_bookmarks()<CR>
nnoremap <silent> sM :lua browse_bookmarks()<CR>
nnoremap <silent> sf <cmd>lua rss_picker()<CR>
nnoremap <silent> si :call BrainstormAppend(0)<CR>
xnoremap <silent> si :<C-u>call BrainstormAppendVisual()<CR>
nnoremap <silent> sI :call BrainstormAppend(1)<CR>

""find ()
nnoremap fb <cmd>Telescope bibtex<cr>
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap fs <cmd>Telescope lsp_document_symbols<cr>
nnoremap <silent> fn :RnvimrToggle<CR>
nnoremap <silent> fe <cmd>Telescope diagnostics bufnr=0 <cr>
nnoremap <silent> fd :lua vim.lsp.buf.hover()<cr>
nnoremap <silent> fc <cmd>Telescope git_status<cr>
nnoremap  <silent> fh :Gitsigns preview_hunk<CR>
nnoremap  <silent> fa :Gitsigns blame_line<CR>

"go
" Big Jumps
nnoremap gb <c-o>
nnoremap <silent> gr <cmd>lua require('telescope.builtin').lsp_references({ reuse_win = 1, jump_type = "never" })<CR>
nnoremap <silent> gd <cmd>lua require('telescope.builtin').lsp_definitions({ reuse_win = 1, jump_type = "never" })<CR>
nnoremap <silent> gn <cmd>lua vim.diagnostic.jump({ count = 1 })<cr>
nnoremap <silent> gp <cmd>lua vim.diagnostic.jump({ count = -1 })<cr>
nmap <silent> ghn :Gitsigns nav_hunk next<CR>
nmap <silent> ghp :Gitsigns nav_hunk prev<CR>

"actions
nnoremap  <silent> aa :Gitsigns stage_hunk<CR>
nnoremap  <silent> ar :Gitsigns reset_hunk<CR>
vnoremap  <silent> aa :'<,'>Gitsigns stage_hunk<CR>
vnoremap  <silent> ar :'<,'>Gitsigns reset_hunk<CR>
nnoremap  <silent> ac :lua GitCommit()<CR>
nnoremap ab :Gitsigns change_base

nnoremap <silent> vih :Gitsigns select_hunk<CR>

lua <<EOF
-- Function to run git commit with a generated message
function GitCommit()

  -- Call Python script to generate commit message
  local generated = vim.fn.system({
    "python3",
    "/scripts/git_commit_message.py",
    vim.g.instruct_model
  })

  -- Clean up output (remove trailing newline/spaces)
  generated = vim.trim(generated)

  -- Ask for confirmation / edit, prefilled with generated message
  local message = vim.fn.input("Commit message: ", generated)

  if message == "" then
    print("Aborted: no commit message.")
    return
  end

  -- Run git commit
  local cmd = "git commit -m " .. vim.fn.shellescape(message)
  vim.cmd("!" .. cmd)
end
EOF


nnoremap = :WindowsEqualize<CR>
autocmd VimResized * WindowsEqualize
" autocmd WinNew,BufNew * WindowsEqualize

nnoremap <silent><C-h> :wincmd h<CR>
nnoremap <silent><C-j> :wincmd j<CR>
nnoremap <silent><C-k> :wincmd k<CR>
nnoremap <silent><C-l> :wincmd l<CR>
tnoremap <c-h> <Cmd>wincmd h<CR>
tnoremap <c-j> <Cmd>wincmd j<CR>
tnoremap <c-k> <Cmd>wincmd k<CR>
tnoremap <c-l> <Cmd>wincmd l<CR>
