---@type LazySpec
return {
  "leath-dub/snipe.nvim",
  keys = {
    {
      "sp",
      function()
        require("snipe").open_buffer_menu()
      end,
      desc = "Open snipe buffer menu",
    },
  },
  opts = {
    ui = {
      position = "bottomleft",
    },
  },
}
