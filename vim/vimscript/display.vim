" Lualine config - similar to old airline config
lua << EOF
require('lualine').setup {
  options = {
    theme = "auto",
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { 'filename' },
    lualine_x = {
      { 'filetype', icon_enabled = true },
      function()
        local word_count = vim.fn.wordcount()
        if word_count.visual_words then
          return word_count.visual_words .. 'W'
        end
        return (word_count.words or 0) .. 'W'
      end
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = { 'branch' },
    lualine_c = {},
    lualine_x = { 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}
EOF



"lightline
if !has('gui_running')
    set t_Co=256
endif
set laststatus=2

""Relative Numbers
"augroup numbertoggle
"  autocmd!
"  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu | endif
"  autocmd BufLeave,FocusLost,InsertEnter,WinLeave * if &nu | set nornu | endif
"augroup END

" Color stuff
set t_Co=256
set termguicolors
silent! colorscheme catppuccin-macchiato

let g:rainbow_active = 1
" Color for the terminal
let g:terminal_ansi_colors = [
    \ "#5c5f77",
    \ "#d20f39",
    \ "#40a02b",
    \ "#df8e1d",
    \ "#1e66f5",
    \ "#ea76cb",
    \ "#179299",
    \ "#acb0be",
    \ "#6c6f85",
    \ "#d20f39",
    \ "#40a02b",
    \ "#df8e1d",
    \ "#1e66f5",
    \ "#ea76cb",
    \ "#179299",
    \ "#4c4f69"
\]
augroup CursorLine
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
