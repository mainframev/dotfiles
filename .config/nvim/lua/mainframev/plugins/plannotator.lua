---@type LazySpec
return {
  "radsadowski/plannotator.nvim",
  -- setup() starts the session watcher that notifies about new plan/review sessions
  event = "VeryLazy",
  cmd = "Plannotator",
  keys = {
    { "<leader>pp", "<cmd>Plannotator<cr>", desc = "Plannotator Session" },
  },
  config = function()
    require("plannotator").setup()
  end,
}
