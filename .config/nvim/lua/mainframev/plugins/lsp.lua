---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim", config = true },
    -- maps lspconfig server names (e.g. pylsp) to mason packages for mason-tool-installer
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "b0o/schemastore.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(ev)
        -- show diagnostic on hover
        vim.api.nvim_create_autocmd("CursorHold", {
          buffer = ev.buf,
          callback = function()
            vim.diagnostic.open_float({
              focus = false,
              source = true,
              close_events = {
                "CursorMoved",
                "CursorMovedI",
                "BufHidden",
                "InsertCharPre",
                "WinLeave",
              },
            })
          end,
        })
      end,
    })

    -- blink.cmp only registers these itself once it loads (InsertEnter), after servers may have started
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

    local servers = {
      ts_ls = {},
      ruff = {},
      bashls = {},
      typos_lsp = {
        filetypes = { "markdown", "toml", "yaml", "json" },
        init_options = {
          diagnosticSeverity = "Hint",
        },
      },
      -- https://www.reddit.com/r/neovim/comments/1dfpp3m/for_anyone_whos_trying_to_get_graphql_ls_working/
      -- graphql = {
      --   cmd = { "graphql-lsp", "server", "-m", "stream" },
      --   filetypes = { "graphql", "gql" },
      --   root_dir = require("lspconfig.util").root_pattern(".git", ".graphqlrc", ".graphqlrc.json"),
      -- },
      -- rust_analyzer is handled by rustaceanvim plugin (see rustacean.lua)
      pylsp = {
        settings = {
          pylsp = {
            plugins = {
              pyflakes = { enabled = false },
              pycodestyle = { enabled = false },
              autopep8 = { enabled = false },
              yapf = { enabled = false },
              mccabe = { enabled = false },
              pylsp_mypy = { enabled = false },
              pylsp_black = { enabled = false },
              pylsp_isort = { enabled = false },
            },
          },
        },
      },
      html = { filetypes = { "html", "twig", "hbs" } },
      cssls = {},
      tailwindcss = {
        filetypes = require("mainframev.plugins.configs.lsp.tailwindcss").filetypes,
        init_options = require("mainframev.plugins.configs.lsp.tailwindcss").init_options,
        on_attach = require("mainframev.plugins.configs.lsp.tailwindcss").on_attach,
        settings = require("mainframev.plugins.configs.lsp.tailwindcss").settings,
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, { "tailwind.config.js", "tailwind.config.ts" })
          if root then
            on_dir(root)
          end
        end,
      },
      dockerls = {},
      sqlls = {},
      jsonls = {
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
      },
      yamlls = {},
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = {
              globals = { "vim" },
              disable = { "missing-fields" },
            },
            format = {
              enable = false,
            },
          },
        },
      },
    }

    -- Ensure the servers and tools above are installed
    local ensure_installed = vim.tbl_keys(servers or {})

    vim.list_extend(ensure_installed, {
      "stylua",
      "prettierd",
      "markdownlint-cli2",
      "marksman",
      "markdown-toc",
      "eslint_d",
      "jq",
      "shellcheck",
      "black",
      "ruff",
      "hadolint",
    })

    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    for server, cfg in pairs(servers) do
      vim.lsp.config(server, cfg)
    end

    vim.lsp.enable(vim.list_extend({ "gdscript" }, vim.tbl_keys(servers)))
  end,
}
