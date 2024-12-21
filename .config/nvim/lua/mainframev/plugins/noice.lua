---@type LazySpec
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      progress = { enabled = true },
    },
    messages = {
      enabled = true,
      view = "mini",
      view_error = "notify",
      view_warn = "mini",
      view_history = "messages",
      view_search = "notify",
    },
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
      command_palette = false, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    notify = {
      enabled = true,
      view = "mini",
    },
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "echasnovski/mini.icons",
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}
