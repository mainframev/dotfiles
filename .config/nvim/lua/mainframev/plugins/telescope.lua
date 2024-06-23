return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "debugloop/telescope-undo.nvim",
    "gbprod/yanky.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod
    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")
    local haproon = require("harpoon")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function()
        trouble.toggle("quickfix")
      end,
    })

    telescope.load_extension("fzf")
    telescope.load_extension("yank_history")

    telescope.setup({
      extensions = {
        fzf = {
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        },
        undo = {
          side_by_side = true,
          layout_strategy = "vertical",
        },
      },
      defaults = {
        path_display = { "absolute" },
        wrap_results = true,
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    --  required harpoon setup
    local harpoon = require("harpoon")
    haproon:setup({})

    local conf = require("telescope.config").values

    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    -- set keymaps
    local keymap = vim.keymap

    keymap.set("n", "<leader>ee", function()
      toggle_telescope(haproon:list())
    end, { desc = "󰏧 Harpoon" })

    keymap.set("n", "<leader>sh", "<cmd>Telescope harpoon marks<cr>", { desc = "Show marks" })
    keymap.set("n", "<leader>hh", function()
      harpoon:list():add()
    end, { desc = "Marks file" })

    keymap.set("n", "<C-j>", function()
      harpoon:list():select(1)
    end)

    keymap.set("n", "<C-k>", function()
      harpoon:list():select(2)
    end)

    keymap.set("n", "<C-l>", function()
      harpoon:list():select(3)
    end)

    keymap.set("n", "<leader>ff", builtin.find_files, {})
    keymap.set("n", "<leader>fl", builtin.live_grep, {})
    keymap.set("n", "<leader>fb", builtin.buffers, {})
    keymap.set("n", "<leader>fg", builtin.git_files, {})
    keymap.set("n", "<leader>fo", builtin.oldfiles, {})
    keymap.set("n", "<leader>fd", builtin.diagnostics, {})
    keymap.set("n", "<leader>fw", builtin.grep_string, {})
    keymap.set("n", "<leader>gc", builtin.git_commits, {})
    keymap.set("n", "<leader>km", builtin.keymaps, {})

    keymap.set("n", "<leader>uu", "<cmd>Telescope undo<cr>", { desc = "󰚰 Undo Tree" })
    keymap.set("n", "<leader>yy", "<cmd>Telescope yank_history<cr>", { desc = "󰮲 Yank history" })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
  end,
}
