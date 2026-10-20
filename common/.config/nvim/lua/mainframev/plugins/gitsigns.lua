---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufRead" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("mainframev.plugins.configs.git.signs")
  end,
  keys = {
    { "<Leader>ghd", desc = "diff hunk" },
    { "<Leader>ghp", desc = "preview" },
    { "<Leader>ghR", desc = "reset buffer" },
    { "<Leader>ghr", desc = "reset hunk" },
    { "<Leader>ghs", desc = "stage hunk" },
    { "<Leader>ghS", desc = "stage buffer" },
    { "<Leader>ght", desc = "toggle deleted" },
    { "<Leader>ghu", desc = "undo stage" },
  },
}
