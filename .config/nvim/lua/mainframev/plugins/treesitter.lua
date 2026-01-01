---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    branch = "main",
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      auto_install = true,
      -- disable for files larger than 100 KB
      disable = function(_, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
      ensure_installed = {
        "diff",
        "gdscript",
        "godot_resource",
        "gdshader",
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
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = function()
      local tsc = require("treesitter-context")
      Snacks.toggle({
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>up")
      return { mode = "cursor", max_lines = 3 }
    end,
  },
}
