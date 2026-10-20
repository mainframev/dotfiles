---@type LazySpec
return {
  {
    -- main branch: no `highlight`/`indent` opts; parsers are installed explicitly
    -- and highlighting is started per buffer. Does not support lazy-loading.
    "nvim-treesitter/nvim-treesitter",
    version = false,
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").install({
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
      })

      local max_filesize = 100 * 1024 -- 100 KB
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("mainframev_treesitter", { clear = true }),
        callback = function(args)
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
          if ok and stats and stats.size > max_filesize then
            return
          end
          -- fails when no parser exists for the filetype; keep regex highlighting then
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
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
