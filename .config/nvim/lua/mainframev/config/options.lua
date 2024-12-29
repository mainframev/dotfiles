-- vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.backspace = "indent,eol,start"

opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.smartindent = true
opt.undofile = true
opt.updatetime = 100
opt.ignorecase = true
opt.completeopt = "menu,menuone,noselect"
opt.tabstop = 2
opt.softtabstop = 2
opt.scrolloff = 8
opt.pumheight = 10
opt.expandtab = true
opt.timeoutlen = 200
opt.signcolumn = "yes:2"

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")

opt.swapfile = false

vim.filetype.add({
  extension = {
    mdx = "mdx",
  },
})
