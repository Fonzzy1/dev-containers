call plug#begin()
" AI
Plug 'madox2/vim-ai'

" Nav
Plug 'jpalardy/vim-slime' 
Plug 'preservim/nerdtree' 
Plug 'tpope/vim-fugitive' 
Plug 'airblade/vim-gitgutter' 
Plug 'Xuyuanp/nerdtree-git-plugin' 
Plug 'preservim/tagbar'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'itchyny/vim-qfedit'

" Visual
Plug 'luochen1990/rainbow'
Plug 'chrisbra/csv.vim' 
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'itchyny/lightline.vim' 
Plug 'Yggdroot/indentLine'
Plug 'ryanoasis/vim-nerdfont'

" Markdown
Plug 'quarto-dev/quarto-vim'
Plug 'vim-pandoc/vim-pandoc-syntax' 
Plug 'mattn/calendar-vim'
Plug 'vitalk/vim-simple-todo'
Plug 'dhruvasagar/vim-table-mode'
Plug 'bullets-vim/bullets.vim'

" LSP
Plug 'jmbuhr/otter.nvim', { 'tag': 'v1.15.1' }
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/nvim-cmp',
Plug 'neovim/nvim-lspconfig',
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'hrsh7th/cmp-path'


call plug#end()
