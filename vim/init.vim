set nocompatible

" Use system clipboard with y and p

" vimscript
source  ~/.config/nvim/vimscript/vim.vim
source  ~/.config/nvim/vimscript/plugins.vim
source  ~/.config/nvim/vimscript/markdown.vim
source  ~/.config/nvim/vimscript/nerdtree.vim
source  ~/.config/nvim/vimscript/R.vim
source  ~/.config/nvim/vimscript/windows.vim
source  ~/.config/nvim/vimscript/display.vim
source  ~/.config/nvim/vimscript/wiki.vim
source  ~/.config/nvim/vimscript/AI_shortcuts.vim


" Lua
lua require("catppuccin_config")
lua require("autocomplete")
lua require("opencode_config")
lua require("visual_config")
lua require("lsp")
lua require("tree_config")
lua require("custom_dashboard")
lua require("telescope_config")
lua require("run_config")

source  ~/.config/nvim/vimscript/maps.vim
lua require("terminal_maps")

