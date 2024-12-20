local icons = require("mainframev.plugins.configs.icons")

---@type LazySpec
return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "AndreM222/copilot-lualine",
  },
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    vim.o.laststatus = vim.g.lualine_laststatus

    local opts = {
      options = {
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          {
            "diagnostics",
            separator = "|",
            padding = { left = 1, right = 1 },
            symbols = {
              error = icons.error,
              warn = icons.warningCircle,
              info = icons.info,
              hint = icons.event,
            },
          },
        },
        -- lualine_c = {},
        lualine_x = {
          "copilot",
          "encoding",
          "filetype",
          {
            function()
              return require("noice").api.status.command.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
          },
          {
            function()
              return require("noice").api.status.mode.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.mode.has()
            end,
          },
          {
            function()
              return "  " .. require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
          },
          {
            "diff",
            symbols = {
              added = icons.gitAdd,
              modified = icons.gitChange,
              removed = icons.gitRemove,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return icons.clock .. os.date("%R")
          end,
        },
      },
      extensions = { "neo-tree", "lazy", "oil", "trouble", "mason" },
    }

    -- do not add trouble symbols if aerial is enabled
    if vim.g.trouble_lualine then
      local trouble = require("trouble")
      local symbols = trouble.statusline
        and trouble.statusline({
          mode = "symbols",
          groups = {},
          title = false,
          filter = { range = true },
          format = "{kind_icon}{symbol.name:Normal}",
          hl_group = "lualine_c_normal",
        })
      table.insert(opts.sections.lualine_c, {
        symbols and symbols.get,
        cond = symbols and symbols.has,
      })
    end

    return opts
  end,
}
