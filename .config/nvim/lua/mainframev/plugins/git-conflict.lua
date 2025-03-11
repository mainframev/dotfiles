---@type LazySpec
return {
  "akinsho/git-conflict.nvim",
  lazy = false,
  version = "2.1.0",
  config = function()
    local present, conflict = pcall(require, "git-conflict")
    if not present then
      return
    end

    conflict.setup({
      default_mappings = true,
      default_commands = true,
      disable_diagnostics = true,
      list_style = "copen",
      -- They must have background color, otherwise the default color will be used
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "GitConflictDetected",
      callback = function()
        vim.notify("Conflict detected in " .. vim.fn.expand("<afile>"))
      end,
    })
  end,
  keys = {
    { "<Leader>gcb", "<cmd>GitConflictChooseBoth<CR>", desc = "choose both" },
    { "<Leader>gcn", "<cmd>GitConflictNextConflict<CR>", desc = "move to next conflict" },
    { "<Leader>gcc", "<cmd>GitConflictChooseOurs<CR>", desc = "choose current" },
    { "<Leader>gcp", "<cmd>GitConflictPrevConflict<CR>", desc = "move to prev conflict" },
    { "<Leader>gci", "<cmd>GitConflictChooseTheirs<CR>", desc = "choose incoming" },
  },
}
