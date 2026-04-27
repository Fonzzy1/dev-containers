"" Default Note
function! NoteDefault()
execute 'silent 0r !/scripts/note_default.py ' . shellescape(expand('%:p'))
    normal! gg
endfunction
autocmd BufNewFile *.qmd :call NoteDefault()
autocmd BufRead *.qmd if getfsize(expand('%'))==0|call NoteDefault()|endif

""" Convert to bibtex
lua << EOF
function _G.GetBibTex()
  local word = vim.fn.expand("<cWORD>")
  local bibtex = {}

  if word:match("^https://doi%.org/") then
    local doi = word:gsub("^https://doi%.org/", "")
    bibtex = vim.fn.systemlist({
      "curl", "-sL", "-H", "Accept: application/x-bibtex",
      "https://doi.org/" .. doi
    })

  elseif word:match("^https://arxiv%.org/abs/") or word:match("^%d%d%d%d%.%d%d%d%d%d$") then
    local arxiv_id = word:match("(%d%d%d%d%.%d%d%d%d%d)")
    bibtex = vim.fn.systemlist({
      "curl", "-sL",
      "https://arxiv.org/bibtex/" .. arxiv_id
    })

  else
    vim.api.nvim_err_writeln("Not a recognized DOI or arXiv link/ID: " .. word)
    return
  end

  if vim.v.shell_error ~= 0 or #bibtex == 0 then
    vim.api.nvim_err_writeln("Failed to fetch BibTeX for: " .. word)
    return
  end

  vim.api.nvim_put(bibtex, 'l', true, true)
end
EOF

command! GetBib lua GetBibTex()


function! GetVisualSelection() abort
  let [line_start, col_start] = getpos("'<")[1:2]
  let [line_end, col_end] = getpos("'>")[1:2]

  if line_start == 0 || line_end == 0
    return ''
  endif

  let lines = getline(line_start, line_end)
  if empty(lines)
    return ''
  endif

  let lines[0] = lines[0][col_start - 1:]
  let lines[-1] = lines[-1][:col_end - 1]

  return join(lines, "\n")
endfunction

function! BrainstormAppend(...) abort
  let l:synthesize = get(a:, 1, 0)
  let l:idea = get(a:, 2, '')

  if !l:synthesize
    if empty(l:idea)
      let l:idea = input("Brainstorm idea: ")
    endif

    if empty(l:idea)
      echo "No idea provided"
      return
    endif
  endif

  let l:target_buf = -1
  for buf in getbufinfo({'buflisted':1})
    if buf.name =~# '\.brainstorm$'
      let l:target_buf = buf.bufnr
      break
    endif
  endfor

  if l:target_buf != -1
    let l:file = bufname(l:target_buf)
  else
    let l:file = '/tmp/brainstorm.brainstorm'
    execute 'SmartVsplit ' . l:file
  endif

  let l:model = get(g:, 'instruct_model', 'gpt-5.4-mini')

  if l:synthesize
    echom 'Synthesising ...'
    let l:cmd = [
          \ 'python3', '/scripts/brainstorm_appender.py',
          \ '--file', l:file,
          \ '--model', l:model,
          \ '--synthesize'
          \ ]
  else
    echom 'Appending idea ...'
    let l:cmd = [
          \ 'python3', '/scripts/brainstorm_appender.py',
          \ '--idea', l:idea,
          \ '--file', l:file,
          \ '--model', l:model
          \ ]
  endif

  let l:job = jobstart(l:cmd, {
        \ 'stdout_buffered': v:true,
        \ 'stderr_buffered': v:true,
        \ })
endfunction

function! BrainstormAppendVisual() abort
  let l:idea = GetVisualSelection()
  if empty(l:idea)
    echo "No visual selection"
    return
  endif
  call BrainstormAppend(0, l:idea)
endfunction
