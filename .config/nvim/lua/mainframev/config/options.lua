-- vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.autoindent = true
opt.background = "dark"
opt.backspace = "indent,eol,start"
opt.backspace = "indent,eol,start"
opt.breakindent = true
opt.clipboard:append("unnamedplus")
opt.completeopt = "menu,menuone,noselect"
opt.cmdheight = 0
opt.cursorline = true
opt.encoding = "utf-8"
opt.expandtab = true
opt.expandtab = true
opt.fileencoding = "utf-8"
opt.ignorecase = true
opt.ignorecase = true
opt.incsearch = true
opt.mouse = ""
opt.number = true
opt.pumborder = vim.o.winborder
opt.pumheight = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftwidth = 2
opt.showmode = false
opt.signcolumn = "yes"
opt.signcolumn = "yes:2"
opt.smartcase = true
opt.smartindent = true
opt.softtabstop = 2
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.tabstop = 2
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 200
opt.undofile = true
opt.updatetime = 100
opt.updatetime = 300
opt.winborder = "rounded"
opt.wrap = false

vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

vim.filetype.add({
  extension = {
    mdx = "mdx",
  },
})
