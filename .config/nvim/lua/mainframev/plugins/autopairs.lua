---@type LazySpec[]
return {
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local autopairs = require("nvim-autopairs")

      autopairs.setup({
        check_ts = true, -- enable treesitter
        fast_wrap = {
          map = "<M-e>", -- map fast wrap to alt+e
          chars = { "{", "[", "(", '"', "'" }, -- wrap these characters
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""), -- pattern to match before the cursor
          offset = 0, -- offset from the cursor
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_commas = true,
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
        }, -- enable fast wrap
        ts_config = {
          lua = { "string" }, -- don't add pairs in lua string treesitter nodes
          javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
          java = false, -- don't check treesitter on java
        },
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp_status_ok = pcall(require, "cmp")

      if not cmp_status_ok then
        return
      end

      local cmp = require("cmp")

      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}
