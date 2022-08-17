call plug#begin('~/.config/nvim/plugged')

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

if has("nvim")
  Plug 'hoob3rt/lualine.nvim'
  Plug 'kristijanhusak/defx-git'
  Plug 'kristijanhusak/defx-icons'
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/nvim-lsp-installer'
  Plug 'williamboman/mason.nvim'
  Plug 'tami5/lspsaga.nvim'
  Plug 'folke/lsp-colors.nvim'
  Plug 'creativenull/diagnosticls-configs-nvim'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'onsails/lspkind-nvim'
  Plug 'nvim-lua/popup.nvim'
  Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'dhruvmanila/telescope-bookmarks.nvim'
  Plug 'cljoly/telescope-repo.nvim'
  Plug 'nvim-telescope/telescope-media-files.nvim'
  Plug 'windwp/nvim-autopairs'
  Plug 'windwp/nvim-ts-autotag'
  Plug 'kyazdani42/nvim-tree.lua'
  Plug 'editorconfig/editorconfig-vim'
endif

Plug 'github/copilot.vim'
Plug 'jxnblk/vim-mdx-js'
Plug 'pwntester/octo.nvim'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'godlygeek/tabular'
" JSON front matter highlight plugin
Plug 'elzr/vim-json'
Plug 'plasticboy/vim-markdown'

" tpope plugins
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-unimpaired' " helpful shorthand like [b ]b
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-fugitive'

" frontend plugins  
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'prettier/vim-prettier', {
            \ 'do': 'pnpm install --frozen-lockfile --production',
            \ 'for': ['javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'css', 'html', 'json', 'less', 
            \ 'scss', 'sql', 'viml', 'yaml', 'markdown', 'graphql', 'typescriptgraphql']}
Plug 'maxmellon/vim-jsx-pretty' 
Plug 'jose-elias-alvarez/null-ls.nvim'

Plug 'lewis6991/gitsigns.nvim'
Plug 'APZelos/blamer.nvim'
Plug 'karb94/neoscroll.nvim'
Plug 'vimwiki/vimwiki', { 'on': ['VimwikiIndex'] }
Plug 'norcalli/nvim-colorizer.lua', { 'branch': 'color-editor' }
Plug 'machakann/vim-highlightedyank'
Plug 'wesQ3/vim-windowswap' " <leader>ww
Plug 'justinmk/vim-sneak'
Plug 'dstein64/vim-startuptime'
Plug 'akinsho/nvim-bufferline.lua'
Plug 'miyakogi/conoline.vim'
Plug 'yamatsum/nvim-cursorline'
Plug 'glepnir/dashboard-nvim'
Plug 'mattn/emmet-vim'
Plug 'GustavoKatel/sidebar.nvim'

Plug 'folke/zen-mode.nvim'
Plug 'junegunn/limelight.vim'
Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'folke/which-key.nvim'
Plug 'stevearc/dressing.nvim'

Plug 'akinsho/toggleterm.nvim', {'tag' : 'v2.*'}
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

" Themes
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()
