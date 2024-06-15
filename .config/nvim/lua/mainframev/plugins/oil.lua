return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      -- experimental_watch_for_changes = true,
      default_file_explorer = true,
      delete_to_trash = true,
      columns = {
        "icon",
        "size",
      },
      buf_options = {
        buflisted = true,
      },
      win_options = {
        signcolumn = "yes",
        list = true,
      },
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == ".." or name == ".git"
        end,
      },
    })
  end,
}
