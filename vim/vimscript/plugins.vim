call plug#begin()
" AI
Plug 'nickjvandyke/opencode.nvim'

" Nav
Plug 'stevearc/aerial.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'kevinhwang91/rnvimr'
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main' }

" Visual
Plug 'folke/snacks.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'hat0uma/csvview.nvim' 
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvimdev/dashboard-nvim'
Plug 'anuvyklack/windows.nvim'
Plug 'anuvyklack/middleclass'
Plug 'MunifTanjim/nui.nvim'
Plug 'folke/noice.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'stevearc/dressing.nvim'

" Git
Plug 'kdheepak/lazygit.nvim'
Plug 'juansalvatore/git-dashboard-nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'pwntester/octo.nvim'
Plug 'whb/vim-gitbranch'


" Markdown
Plug 'OXY2DEV/markview.nvim'
Plug 'bullets-vim/bullets.vim'

" LSP
Plug 'jmbuhr/otter.nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'kdheepak/cmp-latex-symbols'
Plug 'hrsh7th/nvim-cmp',
Plug 'neovim/nvim-lspconfig',
Plug 'hrsh7th/cmp-path'
Plug 'williamboman/mason.nvim'
Plug 'nvimtools/none-ls.nvim'

" Motions
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'tpope/vim-commentary'

" Telescope 
Plug 'nvim-telescope/telescope-bibtex.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'lalitmee/browse.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
Plug 'axkirillov/easypick.nvim'

"Code Running
Plug 'Vigemus/iron.nvim' 
Plug 'akinsho/toggleterm.nvim'
Plug 'jedrzejboczar/toggletasks.nvim', { 'do': ':LuaSupportSync' }

call plug#end()

