---@type LazySpec
return {
  "zbirenbaum/copilot-cmp",
  after = "copilot.lua",
  event = { "InsertEnter", "LspAttach" },
  config = function()
    require("copilot_cmp").setup()
  end,
}
