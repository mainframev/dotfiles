---@type LazySpec
return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    local palette = require("rose-pine.palette")

    require("rose-pine").setup({
      variant = "moon", -- auto, main, moon, or dawn
      dark_variant = "moon", -- main, moon, or dawn
      dim_inactive_windows = true,
      extend_background_behind_borders = true,

      enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true, -- Handle deprecated options automatically
      },

      styles = {
        bold = true,
        italic = true,
        transparency = false,
      },

      groups = {
        border = "muted",
        link = "iris",
        panel = "surface",

        error = "love",
        hint = "iris",
        info = "foam",
        note = "pine",
        todo = "rose",
        warn = "gold",

        git_add = "foam",
        git_change = "rose",
        git_delete = "love",
        git_dirty = "rose",
        git_ignore = "muted",
        git_merge = "iris",
        git_rename = "pine",
        git_stage = "iris",
        git_text = "rose",
        git_untracked = "subtle",

        h1 = "iris",
        h2 = "foam",
        h3 = "rose",
        h4 = "gold",
        h5 = "pine",
        h6 = "foam",
      },

      palette = {
        -- Override the builtin palette per variant
        moon = {
          -- base = "#18191a",
          -- base = "#212337",
          -- overlay = "#363738",
        },
      },

      highlight_groups = {
        CursorLineNr = { fg = palette.love },
        Comment = { fg = palette.muted, italic = true, bold = true },
        ["@variable"] = { fg = palette.text, italic = false },
        ["@variable.builtin"] = { fg = palette.love, italic = false },
        ["@variable.parameter"] = { fg = palette.iris, italic = false },
        ["@variable.parameter.builtin"] = { fg = palette.iris, italic = false },
        ["@constant"] = { fg = palette.gold, bold = true },
        ["@constant.builtin"] = { fg = palette.gold, bold = true },
        ["@constant.macro"] = { fg = palette.gold },
        ["@property"] = { italic = false },
        StatusLine = { fg = "love", bg = "love", blend = 10 },
        StatusLineNC = { fg = "subtle", bg = "surface" },
      },
    })

    vim.cmd("colorscheme rose-pine-moon")

    -- Others
    vim.api.nvim_set_hl(0, "Boolean", { fg = palette.love })
    vim.api.nvim_set_hl(0, "LspInlayHint", { link = "LspCodeLens" })

    -- SnackPicker
    local highlights = {
      SnacksPickerPreviewBorder = { fg = palette.overlay, bg = palette.overlay },
      SnacksPickerBorder = { fg = palette.overlay, bg = palette.overlay },
      SnacksPickerBoxBorder = { fg = palette.overlay, bg = palette.overlay },
      SnacksPickerInputBorder = { fg = palette.overlay, bg = palette.overlay },
      SnacksPickerListBorder = { fg = palette.overlay, bg = palette.overlay },
      SnacksPickerPreview = { bg = palette.overlay },
      SnacksPickerResults = { bg = palette.overlay },
      SnacksPickerPreviewTitle = { fg = palette.gold, bg = palette.overlay },
      SnacksPickerTitle = { fg = palette.gold, bg = palette.overlay },
      SnacksPickerIcon = { fg = palette.love },
      SnacksPicker = { bg = palette.overlay },
    }

    for group, hl in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, hl)
    end
  end,
}
