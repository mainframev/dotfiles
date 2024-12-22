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
        local none = "NONE"

        -- Telescope (borderless)
        hl.TelescopePreviewBorder = { fg = colors.bg, bg = colors.bg }
        hl.TelescopeResultsBorder = { fg = colors.bg, bg = colors.bg }
        hl.TelescopePromptBorder = { fg = colors.bg, bg = colors.bg }
        hl.TelescopePromptNormal = { fg = colors.cyan, bg = colors.bg_hightlight }
        hl.TelescopeResultsTitle = { fg = colors.green, bg = colors.bg_higlight }
        hl.TelescopePromptPrefix = { fg = colors.pink, bg = none }
        hl.TelescopePromptCount = { fg = colors.fg_gutter }
        hl.TelescopeMatching = { fg = colors.cyan }
        hl.TelescopeSelectionCaret = { fg = colors.magenta2 }
        hl.TelescopeSelection = { fg = colors.fg, bg = colors.bg_visual }
        -- hl.TelescopeResultsDiffDelete = { fg = colors.red }
        -- hl.TelescopeResultsDiffChange = { fg = colors.cyan }
        hl.TelescopeTitle = { fg = colors.green }
        hl.TelescopeNormal = { bg = colors.bg, fg = colors.fg }

        hl.NormalFloat = { bg = colors.bg_highlight }
        hl.NoiceCmdlineIcon = { bg = colors.bg_higlight, fg = colors.pink }
        hl.NoiceCmdlinePopupBorderSearch = { bg = colors.bg, fg = colors.orange }
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
      CmpItemKindFolder = { fg = colors.blue2 },
      CmpItemKindFunction = { fg = colors.blue },
      CmpItemKindInterface = { fg = colors.teal, bg = "NONE" },
      CmpItemKindKeyword = { fg = colors.magneta2 },
      CmpItemKindMethod = { fg = colors.magenta },
      -- CmpItemKindReference = { fg = colors.red },
      -- CmpItemKindSnippet = { fg = colors.dark3 },
      CmpItemKindVariable = { fg = colors.cyan, bg = "NONE" },
      CmpItemKindText = { fg = colors.fg },
      CmpItemMenu = { fg = "#C586C0", bg = "NONE" },
      CmpItemAbbrMatch = { fg = "#569CD6", bg = "NONE" },
      CmpItemAbbrMatchFuzzy = { fg = "#569CD6", bg = "NONE" },
    }

    for group, hl in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, hl)
    end
  end,
}
