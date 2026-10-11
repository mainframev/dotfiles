---@type LazySpec
return {
  "stevearc/conform.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        svelte = { "prettierd" },
        rust = { lsp_format = "prefer" },
        sh = { "shfmt" },
        css = { "prettierd" },
        html = { "prettierd" },
        json = { "prettierd" },
        yaml = { "prettierd" },
        haskell = { "fourmolu" },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        graphql = { "prettierd" },
        lua = { "stylua" },
        python = { "isort", "black" },
        gdscript = { "gdformat" },
      },
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 500,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
