---@type LazySpec
return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  build = "make tiktoken",
  event = "VeryLazy",
  opts = {
    show_help = "no",
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
    {
      "<leader>ccT",
      "<cmd>CopilotChatVsplitToggle<cr>",
      desc = "CopilotChat - Toggle Vsplit",
    },
    {
      "<leader>ccv",
      ":CopilotChatVisual",
      mode = "x",
      desc = "CopilotChat - Open in vertical split",
    },
    {
      "<leader>ccc",
      ":CopilotChatInPlace<cr>",
      mode = { "n", "x" },
      desc = "CopilotChat - Run in-place code",
    },
    {
      "<leader>ccf",
      "<cmd>CopilotChatFixDiagnostic<cr>",
      desc = "CopilotChat - Fix diagnostic",
    },
  },
}
