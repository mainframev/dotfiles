return {
  "pmizio/typescript-tools.nvim",
  ft = { "js", "ts", "jsx", "tsx", "javascript", "typescript", "javascriptreact", "typescriptreact" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("typescript-tools").setup({
      on_attach = require("mainframev.plugins.configs.lsp.attach").global_on_attach,
      settings = {
        separate_diagnostic_server = true,
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    })
  end,
}
