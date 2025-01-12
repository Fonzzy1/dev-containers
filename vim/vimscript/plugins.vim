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

" Visual
Plug 'luochen1990/rainbfw'
Plug 'chrisbra/csv.vim' 
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'vim-airline/vim-airline'
Plug 'Yggdroot/indentLine'
Plug 'ryanoasis/vim-nerdfont'
Plug 'TaDaa/vimade'
Plug 'nvimdev/dashboard-nvim'
Plug 'juansalvatore/git-dashboard-nvim'

" Markdown
Plug 'nvim-telescope/telescope-bibtex.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'mattn/calendar-vim'
Plug 'vitalk/vim-simple-todo'
Plug 'dhruvasagar/vim-table-mode'
Plug 'jbyuki/nabla.nvim'
Plug 'bullets-vim/bullets.vim'

" LSP
Plug 'jmbuhr/otter.nvim', { 'tag': 'v1.15.1' }
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'kdheepak/cmp-latex-symbols'
Plug 'hrsh7th/nvim-cmp',
Plug 'neovim/nvim-lspconfig',
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'hrsh7th/cmp-path'


call plug#end()
