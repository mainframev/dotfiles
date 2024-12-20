---@type LazySpec
return {
  "eldritch-theme/eldritch.nvim",
  config = function()
    local colors = require("eldritch.colors").setup() -- pass in any of the config options as explained above
    require("eldritch").setup({
      transparent = false,
      terminal_colors = true,
      hide_inactive_statusline = true,
      styles = {
        comments = {
          italic = true,
          bold = true,
        },
        functions = {
          bold = true,
        },
        variables = {
          bold = true,
        },
        keywords = {
          bold = true,
        },
        floats = "normal",
        sidebars = "normal",
      },
      dim_inactive = true,
      lualine_bold = true,
      on_highlights = function(hl, _)
        local prompt = colors.green
        local none = "NONE"

        hl.TelescopeTitle = {
          fg = prompt,
        }

        hl.TelescopeNormal = {
          bg = colors.bg_dark,
          fg = colors.fg,
        }

        hl.TelescopeBorder = {
          bg = colors.bg_dark,
          fg = colors.green,
        }

        hl.TelescopePreviewTitle = {
          fg = prompt,
        }

        hl.TelescopePromptBorder = {
          bg = none,
          fg = colors.teal,
        }

        hl.TelecopeResultsTitle = {
          fg = prompt,
          bg = none,
        }

        hl.TelescopeResultsNormal = {
          bg = none,
          fg = colors.fg,
        }
        --
        hl.TelescopeMatching = {
          fg = colors.teal,
        }

        hl.TelescopePreviewTitle = {
          fg = prompt,
        }
        --
        hl.TelescopeResultsTitle = {
          fg = prompt,
        }

        hl.TelescopePromptNormal = {
          bg = none,
          fg = colors.teal,
        }

        hl.TelescopePromptTitle = {
          fg = prompt,
        }
      end,
    })
    vim.cmd("colorscheme eldritch")

    vim.api.nvim_set_hl(0, "BufferCurrentSign", { fg = colors.cyan })
    vim.api.nvim_set_hl(0, "BufferInactiveSign", { bg = colors.bg_dark, fg = colors.dark3 })
    vim.api.nvim_set_hl(0, "BufferInactiveMod", { bg = "NONE", fg = colors.yellow })
    vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { bg = colors.bg_dark, fg = colors.cyan })

    vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { link = "Comment" })
    vim.api.nvim_set_hl(0, "rainbowcol1", { fg = colors.blue, ctermfg = 9 })
    vim.api.nvim_set_hl(0, "TSRainbowRed", { fg = colors.blue, ctermfg = 9 })
    vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = colors.blue, ctermfg = 9 })
    vim.api.nvim_set_hl(0, "Boolean", { fg = colors.pink })
    vim.api.nvim_set_hl(0, "LspInlayHint", { link = "LspCodeLens" })

    local highlights = {
      CmpItemAbbr = { fg = colors.dark3, bg = "NONE" },
      CmpItemKindClass = { fg = colors.orange },
      CmpItemKindConstructor = { fg = colors.purple },
      -- CmpItemKindFolder = { fg = colors.blue2 },
      -- CmpItemKindFunction = { fg = colors.blue },
      CmpItemKindInterface = { fg = colors.teal, bg = "NONE" },
      CmpItemKindKeyword = { fg = colors.magneta2 },
      CmpItemKindMethod = { fg = colors.red },
      CmpItemKindReference = { fg = colors.red },
      CmpItemKindSnippet = { fg = colors.dark3 },
      CmpItemKindVariable = { fg = colors.cyan, bg = "NONE" },
      CmpItemKindText = { fg = "LightGrey" },
      CmpItemMenu = { fg = "#C586C0", bg = "NONE" },
      CmpItemAbbrMatch = { fg = "#569CD6", bg = "NONE" },
      CmpItemAbbrMatchFuzzy = { fg = "#569CD6", bg = "NONE" },
    }

    vim.api.nvim_set_hl(0, "CmpBorderedWindow_FloatBorder", { fg = colors.blue0 })

    for group, hl in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, hl)
    end
  end,
}
