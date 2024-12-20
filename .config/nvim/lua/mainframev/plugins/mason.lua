---@type LazySpec[]
local icons = require("mainframev.plugins.configs.icons")

return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = icons.check,
          package_pending = icons.clock,
          package_uninstalled = icons.close,
        },
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier",
        "prettierd",
        "stylua",
        "isort", -- python formatter
        "black", -- python formatter
        "pylint",
        "eslint_d",
      },
    })
  end,
}
