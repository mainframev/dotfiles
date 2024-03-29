if !exists('g:loaded_telescope') | finish | endif

nnoremap <silent> ;f <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <silent> ;r <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <silent> \\ <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <silent> ;t <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <silent> ;; <cmd>lua require('telescope.builtin').resume()<cr>
nnoremap <silent> ;e <cmd>lua require('telescope.builtin').diagnostics()<cr>


lua << EOF
function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.load_extension('bookmarks')
telescope.load_extension('repo')
telescope.load_extension('media_files')

telescope.setup{
  defaults = {
    layout_config = {
      vertical = { width = 0.5 }
    },
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  },
  pickers = {
    find_files = {
      theme = 'dropdown', 
    }
  },
}
EOF


