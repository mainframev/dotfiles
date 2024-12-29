---@type LazySpec
return {
  "VonHeikemen/lsp-zero.nvim",
  event = { "BufReadPre", "BufNewFile" },
  lazy = false,
  dependencies = {
    "neovim/nvim-lspconfig",
    "barreiroleo/ltex-extra.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "b0o/schemastore.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    vim.o.updatetime = 300 -- set faster update time

    local lsp_zero = require("lsp-zero")

    lsp_zero.extend_lspconfig()

    lsp_zero.on_attach(function(_, bufnr)
      local keymap = vim.keymap
      local opts = { buffer = bufnr, silent = true }

      opts.desc = "Show LSP references"
      keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
      opts.desc = "Go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

      opts.desc = "Show LSP definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

      opts.desc = "Show LSP implementations"
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

      opts.desc = "See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

      opts.desc = "Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

      opts.desc = "Show line diagnostics"
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "K", vim.lsp.buf.hover, opts)

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end)

    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")
    local blink = require("blink.cmp")

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = blink.get_lsp_capabilities()

    mason_lspconfig.setup({
      automatic_installation = true,
      -- list of servers for mason to install
      ensure_installed = {
        "ts_ls",
        "ltex",
        "rust_analyzer",
        "bashls",
        "jsonls",
        "typos_lsp",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
      },
    })

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,

      ["ltex"] = function()
        require("lspconfig").ltex.setup({
          settings = {
            ltex = {
              language = "en-GB",
              additionalRules = {
                languageModel = "~/LanguageTool/",
              },
              disabledRules = {
                ["en-GB"] = { "                enablePickyRules = true,
""EN_QUOTES", "COMMA_PARENTHESIS_WHITESPACE" },
              },
              enabled = {
                "html",
                "latex",
                "markdown",
                "gitcommit",
                "text",
                "mdx",
              },
            },
          },
          filetypes = {
            "html",
            "gitcommit",
            "text",
            "latex",
            "markdown",
            "mdx",
          },
          capabilities = capabilities,
          on_attach = function()
            require("ltex_extra").setup({
              load_langs = { "en-GB" },
              init_check = true,
              path = vim.fn.stdpath("config") .. "/spell", -- path to store dictionaries.
              log_level = "none",
            })
          end,
        })
      end,

      ["svelte"] = function()
        -- configure svelte server
        lspconfig["svelte"].setup({
          capabilities = capabilities,
          on_attach = function(client)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                -- Here use ctx.match instead of ctx.file
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
              end,
            })
          end,
        })
      end,
      ["eslint"] = function()
        lspconfig.eslint.setup({
          -- capabilities = capabilities,
          on_attach = function(_, bufnr)
            vim.api.nvim_create_autocmd("BufWritePost", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
        })
      end,
      ["graphql"] = function()
        -- configure graphql language server
        lspconfig["graphql"].setup({
          capabilities = capabilities,
          filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
        })
      end,
      ["emmet_ls"] = function()
        -- configure emmet language server
        lspconfig["emmet_ls"].setup({
          capabilities = capabilities,
          filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
        })
      end,
      -- configure typos_lsp language server
      ["typos_lsp"] = function()
        lspconfig.typos_lsp.setup({
          capabilities = capabilities,
          filetypes = { "markdown", "toml", "yaml", "json" },
          init_options = {
            diagnosticSeverity = "Hint",
          },
        })
      end,
      -- configure json language server
      ["jsonls"] = function()
        lspconfig.jsonls.setup({
          capabilities = capabilities,
          settings = {
            json = {
              schemas = require("schemastore").json.schemas({
                ignore = {
                  ".eslintrc",
                  "package.json",
                },
              }),
              validate = { enable = true },
            },
          },
        })
      end,
      ["tailwindcss"] = function()
        lspconfig.tailwindcss.setup({
          capabilities = require("mainframev.plugins.configs.lsp.tailwindcss").capabilities,
          filetypes = require("mainframev.plugins.configs.lsp.tailwindcss").filetypes,
          init_options = require("mainframev.plugins.configs.lsp.tailwindcss").init_options,
          on_attach = require("mainframev.plugins.configs.lsp.tailwindcss").on_attach,
          settings = require("mainframev.plugins.configs.lsp.tailwindcss").settings,
          root_dir = lspconfig.util.root_pattern("tailwind.config.js", "tailwind.config.ts"),
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
      ["ts_ls"] = function()
        lspconfig["ts_ls"].setup({
          filetypes = {
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript.tsx",
            "vue",
          },
          capabilities = capabilities,
        })
      end,
    })
  end,
}
