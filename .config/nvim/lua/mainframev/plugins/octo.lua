---@type LazySpec
return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  ft = "octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("octo").setup({ picker = "snacks" })
  end,
}
