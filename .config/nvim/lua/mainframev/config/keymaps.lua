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
keymap("n", "<leader>sv", ":vsplit<CR>", {})
keymap("n", "<leader>sh", ":split<CR>", {})

-- Oil --
keymap("n", "-", "<CMD>Oil<CR>", { desc = "Open file explorer" })

-- Move lines up and down in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "[P]Move line down in visual mode" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "[P]Move line up in visual mode" })

-- Open links under cursor in browser with gx
if vim.fn.has("macunix") == 1 then
  keymap("n", "gx", "<cmd>silent execute '!open ' . shellescape('<cWORD>')<CR>", silent)
else
  keymap("n", "gx", "<cmd>silent execute '!xdg-open ' . shellescape('<cWORD>')<CR>", silent)
end

-- Save buffer
keymap("n", "<leader>w", ":w<CR>", silent)
keymap("i", "<leader>w", "<ESC>:w<CR>", silent)

-- Replace word globally for the whole buffer
keymap(
  "n",
  "<leader>su",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "[P]Replace word I'm currently on GLOBALLY" }
)

-- Replaces the current word with the same word in uppercase, globally
keymap(
  "n",
  "<leader>sU",
  [[:%s/\<<C-r><C-w>\>/<C-r>=toupper(expand('<cword>'))<CR>/gI<Left><Left><Left>]],
  { desc = "[P]GLOBALLY replace word I'm on with UPPERCASE" }
)

-- Replaces the current word with the same word in lowercase, globally
keymap(
  "n",
  "<leader>sL",
  [[:%s/\<<C-r><C-w>\>/<C-r>=tolower(expand('<cword>'))<CR>/gI<Left><Left><Left>]],
  { desc = "[P]GLOBALLY replace word I'm on with lowercase" }
)

-- By default, CTRL-U and CTRL-D scroll by half a screen (50% of the window height)
-- Scroll by 35% of the window height and keep the cursor centered
local scroll_percentage = 0.35
-- Scroll by a percentage of the window height and keep the cursor centered
vim.keymap.set("n", "<C-d>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "jzz")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-u>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "kzz")
end, { noremap = true, silent = true })
