"" Let the rmd handler function! on files ending with .md
au BufRead,BufNewFile *.md  set filetype=quarto
au BufRead,BufNewFile *.rmd  set filetype=quarto
au BufRead,BufNewFile *.qmd  set filetype=quarto
filetype plugin on

highlight link MarkviewPalette7Fg Keyword

highlight link @markup.quote.markdown Comment
highlight link @punctuation.special.markdown Comment
highlight link MarkviewLink MarkviewPalette7Fg


function! QuartoExtras()
    lua require'otter'.activate()
    syntax match Cite /\k\@<!@\k\+\>/
    highlight link Cite MarkviewPalette7Fg
endfunction

augroup QuartoExtrasGroup
    autocmd!
    autocmd BufReadPost *.qmd,*.quarto if &filetype == 'quarto' | call QuartoExtras() | endif
    autocmd BufWritePost *.qmd call QuartoExtras()
augroup END


""" Bullet Setup
let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text',
    \ 'gitcommit',
    \ 'quarto',
    \ 'rmd'
    \]

let g:bullets_outline_levels = ['ROM', 'ABC', 'num', 'abc', 'rom', 'std-',]



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
