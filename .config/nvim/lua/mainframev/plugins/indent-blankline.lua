return {
  {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = "TheGLander/indent-rainbowline.nvim",
    opts = function()
      local M = {
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { show_start = false, show_end = false },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      }

      return require("indent-rainbowline").make_opts(M)
    end,
    -- config = function()
    --   return require("indent-rainbowline").make_opts()
    -- end,
    main = "ibl",
  },
}
