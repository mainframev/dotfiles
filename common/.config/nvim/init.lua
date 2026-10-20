require("mainframev")

-- defer godot project detection until after startup
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local cwd = vim.fn.getcwd()
    local paths_to_check = { "/", "/../" }
    local is_godot_project = false
    local godot_project_path = ""

    for _, value in pairs(paths_to_check) do
      if vim.uv.fs_stat(cwd .. value .. "project.godot") then
        is_godot_project = true
        godot_project_path = cwd .. value
        break
      end
    end

    if is_godot_project and not vim.uv.fs_stat(godot_project_path .. "/server.pipe") then
      vim.fn.serverstart(godot_project_path .. "/server.pipe")
    end
  end,
})
