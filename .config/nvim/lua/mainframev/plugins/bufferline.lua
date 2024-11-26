return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons", "moll/vim-bbye" },
  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete Other Buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "<Space>1", "<cmd>BufferLineGoToBuffer 1<CR>" },
    { "<Space>2", "<cmd>BufferLineGoToBuffer 2<CR>" },
    { "<Space>3", "<cmd>BufferLineGoToBuffer 3<CR>" },
    { "<Space>4", "<cmd>BufferLineGoToBuffer 4<CR>" },
    { "<Space>5", "<cmd>BufferLineGoToBuffer 5<CR>" },
    { "<Space>6", "<cmd>BufferLineGoToBuffer 6<CR>" },
    { "<Space>7", "<cmd>BufferLineGoToBuffer 7<CR>" },
    { "<Space>8", "<cmd>BufferLineGoToBuffer 8<CR>" },
    { "<Space>9", "<cmd>BufferLineGoToBuffer 9<CR>" },
  },
  opts = {
    options = {
      mode = "buffers",
      view = "multiwindow",
      diagnostics = "nvim_lsp",
      indicator = {
        -- icon = "▎",
        style = "underline",
      },
      separator_style = "thin",
      show_close_icon = false,
      show_buffer_close_icons = false,
      always_show_bufferline = true,
      sort_by = "directory",
      numbers = function(opts)
        return string.format("%s", opts.raise(opts.ordinal))
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "center",
        },
      },
      diagnostics_indicator = function(_, _, diagnostics_dict)
        local s = " "
        for e, n in pairs(diagnostics_dict) do
          local sym = e == "error" and "  " or (e == "warning" and "  " or " ")
          s = s .. n .. sym
        end
        return s
      end,
      custom_filter = function(buf_number)
        if vim.bo[buf_number].filetype ~= "oil" then
          return true
        end
      end,
    },
    highlights = {
      buffer_selected = {
        bold = true,
        italic = false,
        sp = "#ef8f8f",
      },
    },
  },
}
