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

