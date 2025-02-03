---@type LazySpec
return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  event = { "BufReadPre " .. vim.fn.expand("~") .. "/" .. "mainframev" .. "/**.md" },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/mainframev",
      },
    },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)
  end,
}
