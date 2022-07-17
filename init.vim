" Options 
autocmd!
scriptencoding utf-8

set clipboard=unnamedplus " Enables the clipboard between Vim/Neovim and other applications.
set completeopt=noinsert,menuone,noselect " Modifies the auto-complete menu to behave more like an IDE.
set cursorline " Highlights the current line in the editor
set hidden " Hide unused buffers
set inccommand=split " Show replacements in a split screen
set mouse=a " Allow to use the mouse in the editor
set number " Shows the line numbers
set splitbelow splitright " Change the split screen behavior
set wildignore+=*/node_modules/**
set title " Show file title
set wildmenu " Show a more advance menu
set cc=120 " Show at 120 column a border for good code style
filetype plugin indent on   " Allow auto-indenting depending on file type
syntax on
set ttyfast " Speed up scrolling in Vim
set fileformat=unix " Use Unix line endings
set expandtab " Enable tabulation
set tabstop=2 " Set the tabstop to 4 spaces
set encoding=utf8 " Set the encoding to UTF-8
set shiftwidth=2 " Set the tab width to 4 spaces
set termguicolors " Use terminal colors
set scrolloff=2 " Disable the scrollbar 
set smartcase " smart case for search
set showcmd " Show the command in the status bar
set ignorecase " ignore case in search
set noerrorbells " Disable error bell
set nowrap " Disable wrapping
set shell=zsh " Set the shell to zsh
set expandtab " Enable tabulation
set hlsearch " Highlight search
set lazyredraw " Redraw the screen only when needed
set si " Smart ident
set ai " Auto ident 

autocmd InsertLeave * set nopaste " Turn off past mode when leaving insert mode 
set formatoptions+=r

" File types "{{{
" ---------------------------------------------------------------------
" JavaScript
au BufNewFile,BufRead *.es6 setf javascript
" TypeScript
au BufNewFile,BufRead *.tsx setf typescriptreact
" Markdown
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.mdx set filetype=markdown
" Flow
au BufNewFile,BufRead *.flow set filetype=javascript

set suffixesadd=.js,.es,.jsx,.json,.css,.less,.sass,.styl,.php,.py,.md

autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
"}}}

" Extras "{{{
" ---------------------------------------------------------------------
set exrc

"}}}

" vim: set foldmethod=marker foldlevel=0:


inoremap jk <esc> 

" incremental substitution (neovim)
if has('nvim')
  set inccommand=split
endif


" Imports "{{{
" ---------------------------------------------------------------------
runtime ./plug.vim
runtime ./maps.vim

if has("unix")
  let s:uname = system("uname -s")
  " Do Mac stuff
  if s:uname == "Darwin\n"
    runtime ./macos.vim
  endif
endif

"}}}
"

" theming
" Enable theming support
if (has("termguicolors"))
 set termguicolors
endif

colorscheme dracula " Dracula theme
let g:dracula_colorterm = 0
let g:dracula_italic = 1

" Markdown
let g:mkdp_theme = 'light'
let g:mkdp_auto_start = 1

" Git
let g:blamer_enabled = 1 
let g:blamer_delay = 500
let g:blamer_date_format = '%d/%m/%y'

