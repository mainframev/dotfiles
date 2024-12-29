---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
      "diff",
      "html",
      "gitcommit",
      "gitignore",
      "css",
      "javascript",
      "jsdoc",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "regex",
      "toml",
      "tsx",
      "typescript",
      "vue",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    },
  },
  ---@param opts TSConfig
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    vim.treesitter.language.register("markdown", "mdx")
  end,
}
