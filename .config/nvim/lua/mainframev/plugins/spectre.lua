---@type LazySpec
return {
  "nvim-pack/nvim-spectre",
  lazy = true,
  config = function()
    require("mainframev.plugins.configs.spectre")
  end,
}
