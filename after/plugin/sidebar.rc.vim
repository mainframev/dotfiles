" Plug 'GustavoKatel/sidebar.nvim' {{{
lua << EOF
require("sidebar-nvim").setup({})
-- require("sidebar-nvim").setup({
--     disable_default_keybindings = 0,
--     bindings = nil,
--     open = false,
--     side = "left",
--     initial_width = 35,
--     update_interval = 1000,
--     sections = { "datetime", "git-status", "lsp-diagnostics" },
--     section_separator = "-----",
--     docker = {
--         attach_shell = "/bin/sh", show_all = true, interval = 5000,
--     },
--     datetime = { format = "%a %b %d, %H:%M", clocks = { { name = "local" } } },
--     todos = { ignored_paths = { "~" } }
-- })
EOF
nnoremap <leader>sb <cmd>SidebarNvimToggl<cr>
" }}}


