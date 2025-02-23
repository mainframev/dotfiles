---@type LazySpec
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      json = { "jsonlint" },
      markdown = { "markdownlint-cli2", "prettier", "eslint_d" },
      yaml = { "yamllint" },
      svelte = { "eslint_d" },
      python = { "pylint" },
      lua = { "selene" },
      bash = { "shellcheck" },
      zsh = { "shellcheck" },
    }

    local eslint = lint.linters.eslint_d
    local markdownlint = lint.linters["markdownlint-cli2"]

    markdownlint.args = {
      args = { "--config", os.getenv("HOME") .. "/mainframev/markdownlint.yaml", "--" },
    }

    eslint.args = {
      -- "--no-warn-ignored",
      "--format",
      "json",
      "--stdin",
      "--stdin-filename",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      -- callback = function()
      --   lint.try_lint()
      -- end,
      callback = function()
        local client = vim.lsp.get_clients({ bufnr = 0 })[1] or {}
        lint.try_lint(nil, { cwd = client.root_dir or vim.fn.fnamemodify(vim.fn.finddir(".git", ".;"), ":h") })
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
