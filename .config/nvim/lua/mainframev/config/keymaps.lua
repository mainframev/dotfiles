local keymap = vim.keymap.set
local silent = { silent = true }

vim.g.mapleader = " "

-- Previous
keymap("n", "<leader>pv", vim.cmd.Ex)

-- Quickfix
keymap("n", "<Space>,", ":cp<CR>", silent)

-- Search highlights
keymap("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Splt and wrap
keymap("n", "<leader>n", ":so %<CR>", {})
keymap("n", "<leader>v", ":vsplit<CR>", {})
keymap("n", "<leader>s", ":split<CR>", {})
keymap("n", "<leader>t", ":vsplit<CR>:terminal<CR>", {})
keymap("n", "<leader>w", ":set wrap<CR>", {})

-- Oil --
keymap("n", "-", "<CMD>Oil<CR>", { desc = "Open file explorer" })

-- Open links under cursor in browser with gx
if vim.fn.has("macunix") == 1 then
  keymap("n", "gx", "<cmd>silent execute '!open ' . shellescape('<cWORD>')<CR>", silent)
else
  keymap("n", "gx", "<cmd>silent execute '!xdg-open ' . shellescape('<cWORD>')<CR>", silent)
end

-- Save buffer
keymap("n", "<leader>w", ":w<CR>", silent)
keymap("i", "<leader>w", "<ESC>:w<CR>", silent)
