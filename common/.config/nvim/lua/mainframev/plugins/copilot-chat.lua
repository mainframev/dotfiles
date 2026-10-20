---@type LazySpec
return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "github/copilot.vim" },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  build = "make tiktoken",
  event = "VeryLazy",
  opts = {
    show_help = false,
    prompts = {
      Explain = "Explain how it works.",
      Review = "Review the following code and provide concise suggestions.",
      Tests = "Briefly explain how the selected code works, then generate unit tests.",
      Refactor = "Refactor the code to improve clarity and readability.",
    },
  },
  keys = {
    { "<leader>ccb", "<cmd>CopilotChatOpen<cr>", desc = "CopilotChat - Buffer" },
    { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
    { "<leader>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
    { "<leader>ccT", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
    { "<leader>ccv", ":CopilotChat<cr>", mode = "x", desc = "CopilotChat - Chat about selection" },
    { "<leader>ccf", "<cmd>CopilotChatFix<cr>", mode = { "n", "x" }, desc = "CopilotChat - Fix" },
  },
}
