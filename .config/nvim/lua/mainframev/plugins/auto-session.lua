---@type LazySpec[]
return {
  {
    "rmagatti/auto-session",
    omg = false,
    lazy = false,
    keys = {
      { "<leader>ss", "<cmd>SessionSearch<CR>", desc = "Session search" },
      { "<leader>sw", "<cmd>SessionSave<CR>", desc = "Save session" },
      { "<leader>sa", "<cmd>SessionToggleAutoSave<CR>", desc = "Auto save session" },
    },
    config = function()
      require("auto-session").setup({
        auto_session_enable_last_session = vim.uv.cwd() == vim.uv.os_homedir(),
        auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
        bypass_save_filetypes = { "oil" },
        session_lens = {
          picker = "snacks",
          buftypes_to_ignore = {},
          load_on_setup = false,
          theme_conf = { border = true },
          previewer = false,
        },
      })
    end,
  },
}
