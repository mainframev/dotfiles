-- Branch that origin/HEAD points to (e.g. "master"), falling back to "main".
local function default_branch()
  local ref = vim.fn.systemlist({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })[1]
  if vim.v.shell_error == 0 and ref and ref ~= "" then
    return (ref:gsub("^origin/", ""))
  end
  return "main"
end

local function open(base)
  local zdiff = require("zdiff")
  -- Also used by the `m` toggle inside the zdiff buffer.
  zdiff.config.default_branch = default_branch()
  zdiff.open(base and zdiff.config.default_branch or nil)
end

---@type LazySpec
return {
  "martindur/zdiff.nvim",
  cmd = "Zdiff",
  keys = {
    { "<leader>gd", function() open(false) end, desc = "Git Diff (uncommitted)" },
    { "<leader>gD", function() open(true) end, desc = "Git Diff (vs default branch)" },
  },
  opts = {},
}
