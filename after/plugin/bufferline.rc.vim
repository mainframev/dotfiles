lua << EOF
require("bufferline").setup{}
EOF
nnoremap <silent> gb :BufferLinePick<CR>
