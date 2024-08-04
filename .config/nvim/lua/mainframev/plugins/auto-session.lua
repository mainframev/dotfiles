return {
  "rmagatti/auto-session",
  lazy = false,
  dependencies = {
    "nvim-telescope/telescope.nvim", -- Only needed if you want to use sesssion lens
  },
  keys = {
    { "<leader>ss", "<cmd>SessionSearch<CR>", desc = "Session search" },
    { "<leader>sw", "<cmd>SessionSave<CR>", desc = "Save session" },
    { "<leader>sa", "<cmd>SessionToggleAutoSave<CR>", desc = "Auto save session" },
  },
  config = function()
    require("auto-session").setup({
      auto_session_enable_last_session = vim.loop.cwd() == vim.loop.os_homedir(),
      auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      session_lens = {
        buftypes_to_ignore = {},
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
      },
    })
  end,
}
