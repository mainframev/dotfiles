---@type LazySpec
return {
  "akinsho/git-conflict.nvim",
  -- Load on demand only: the plugin's recursive .git watcher spawns a `git diff`
  -- per index write, which piles up to GBs of RAM in large repos (1JS)
  cmd = { "GitConflictRefresh", "GitConflictListQf" },
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

    -- Drop the autocmd that starts the .git watcher; scan once on load instead
    for _, au in ipairs(vim.api.nvim_get_autocmds({ group = "GitConflictCommands", event = "BufRead" })) do
      vim.api.nvim_del_autocmd(au.id)
    end
    vim.schedule(function()
      vim.cmd("GitConflictRefresh")
    end)

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
