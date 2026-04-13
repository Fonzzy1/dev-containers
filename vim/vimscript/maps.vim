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
lua vim.keymap.set({ "n", "x" }, "es", function() require("opencode").prompt("Fix spelling and grammar using Australian English. Assume markdown formatting. Do not replace -- with dashes. @this") end, { desc = "Fix spelling with opencode" })
vnoremap <silent> ew gw
lua vim.keymap.set({ "n", "x" }, "ee", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Send line to opencode with command" })
lua vim.keymap.set("n", "eee", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Quick chat current line" })

" Spawn
nnoremap <silent> sb :vnew<CR>:wincmd L<CR>
nnoremap <silent> sB :new<CR>
nnoremap sC <cmd>lua require('opencode').select()<CR>
vnoremap sC <cmd>lua require('opencode').select()<CR>
nnoremap sc <cmd>lua require('opencode').ask("", { submit = true })<CR>

nnoremap <silent> so :lua require('telescope').extensions.toggletasks.select()<CR>
nnoremap <silent> sr <cmd>Telescope toggletasks spawn<CR>
nnoremap <silent> sg :LazyGit<CR>
nnoremap <silent> sv :LazyGitFilterCurrentFile<CR>
nnoremap sG :Octo 
nnoremap <silent> sm :lua require('browse').open_manual_bookmarks()<CR>
nnoremap <silent> sM :lua browse_bookmarks()<CR>
nnoremap <silent> sf <cmd>lua rss_picker()<CR>

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
nnoremap gr <cmd>Telescope lsp_references<cr>
nnoremap <silent> gd :lua vim.lsp.buf.definition()<cr>
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

" miscmap
nnoremap <silent> q :call SmartQuit()<CR>

function! SmartQuit()
  if !&modifiable || &readonly
    quit
  elseif expand('%') == ''
    let l:fname = input('Save as: ')
    if l:fname != ''
      execute 'saveas ' . l:fname
      wq
    else
      quit
    endif
  else
    wq
  endif
endfunction
vnoremap > >gv
vnoremap < <gv
nnoremap + :WindowsMaximize<CR>
nnoremap <silent><Esc> :noh<CR>

nnoremap <silent> vih :Gitsigns select_hunk<CR>

lua <<EOF
-- Function to run git commit with a custom message
function GitCommit()
  -- Get the pending commit message from lazygit if available
  local lazygit_msg = vim.fn.system("cat .git/LAZYGIT_PENDING_COMMIT 2>/dev/null"):gsub("%s+$", "")
  local default = lazygit_msg ~= "" and lazygit_msg or ""
  
  -- Ask for a commit message with default from lazygit
  local message = vim.fn.input("Commit message: ", default)
  if message == "" then
    print("Aborted: no commit message.")
    return
  end

  -- Run git commit in a shell
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
