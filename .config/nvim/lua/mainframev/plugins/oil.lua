local is_directory_start = vim.fn.argc(-1) == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1

---@type LazySpec
return {
  "stevearc/oil.nvim",
  cmd = "Oil",
  lazy = not is_directory_start,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      delete_to_trash = true,
      watch_for_changes = true,
      columns = {
        "icon",
        "size",
      },
      buf_options = {
        buflisted = false,
      },
      win_options = {
        signcolumn = "yes",
        list = true,
      },
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          if is_godot_project then
            if vim.endswith(name, ".uid") then
              return true
            end
          end
          return name == ".." or name == ".git"
        end,
      },
    })
  end,
}
