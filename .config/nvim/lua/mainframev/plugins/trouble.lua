return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
    keys = {
      { "<leader>ut", "<cmd>TroubleToggle workspace_diagnostics<CR>", desc = "Toggle trouble" },
      { "<leader>fd", "<cmd>TroubleToggle document_diagnostics<CR>", desc = "Toggle trouble for document" },
    },
  },
}
