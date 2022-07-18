" Tabs
nmap te :tabedit 
nmap <S-Tab> :tabprev<Return>
nmap <Tab> :tabnext<Return>

" Save 
nnoremap <c-s> :w<cr>

" Select all
nmap <C-a> gg<S-v>G

" Find file
nnoremap <C-p> :FZF<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \}

" Markdown preview
nnoremap <M-m> :MarkdownPreview<CR>

