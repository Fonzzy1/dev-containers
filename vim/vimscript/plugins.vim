call plug#begin()
" AI
Plug 'madox2/vim-ai'

" Nav
Plug 'jpalardy/vim-slime' 
Plug 'preservim/nerdtree' 
Plug 'tpope/vim-fugitive' 
Plug 'airblade/vim-gitgutter' 
Plug 'Xuyuanp/nerdtree-git-plugin' 
Plug 'stevearc/aerial.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'echasnovski/mini.nvim'
Plug 'tpope/vim-commentary'

" Visual
Plug 'nvim-tree/nvim-web-devicons'
Plug 'hat0uma/csvview.nvim' 
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'vim-airline/vim-airline'
Plug 'nvimdev/dashboard-nvim'
Plug 'juansalvatore/git-dashboard-nvim'
Plug 'xiyaowong/virtcolumn.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'

" Markdown
Plug 'OXY2DEV/markview.nvim'
Plug 'nvim-telescope/telescope-bibtex.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'bullets-vim/bullets.vim'


" LSP
Plug 'jmbuhr/otter.nvim', { 'tag': 'v1.15.1' }
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'kdheepak/cmp-latex-symbols'
Plug 'hrsh7th/nvim-cmp',
Plug 'neovim/nvim-lspconfig',
Plug 'hrsh7th/cmp-path'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

call plug#end()


