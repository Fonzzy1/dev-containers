" Lualine config - similar to old airline config
lua << EOF
require('lualine').setup {
  options = {
    disabled_filetypes = {
        statusline = { "no-neck-pain" }},
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
silent! colorscheme catppuccin-mocha

let g:rainbow_active = 1
" Color for the terminal
let g:terminal_ansi_colors = [
    \ "#45475A",
    \ "#F38BA8",
    \ "#A6E3A1",
    \ "#F9E2AF",
    \ "#89B4FA",
    \ "#F5C2E7",
    \ "#94E2D5",
    \ "#BAC2DE",
    \ "#585B70",
    \ "#F38BA8",
    \ "#A6E3A1",
    \ "#F9E2AF",
    \ "#89B4FA",
    \ "#F5C2E7",
    \ "#94E2D5",
    \ "#A6ADC8"
 \]

augroup CursorLine
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
