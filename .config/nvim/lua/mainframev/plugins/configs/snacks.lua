local icons = require("mainframev.plugins.configs.icons")

local M = {}

local header = [[
 ___      ___       __        __    _____  ___    _______   _______        __       ___      ___   _______
|"  \    /"  |     /""\      |" \  (\"   \|"  \  /"     "| /"      \      /""\     |"  \    /"  | /"     "|
 \   \  //   |    /    \     ||  | |.\\   \    |(: ______)|:        |    /    \     \   \  //   |(: ______)
 /\\  \/.    |   /' /\  \    |:  | |: \.   \\  | \/    |  |_____/   )   /' /\  \    /\\  \/.    | \/    |
|: \.        |  //  __'  \   |.  | |.  \    \. | // ___)   //      /   //  __'  \  |: \.        | // ___)_
|.  \    /:  | /   /  \\  \  /\  |\|    \    \ |(:  (     |:  __   \  /   /  \\  \ |.  \    /:  |(:      "|
|___|\__/|___|(___/    \___)(__\_|_)\___|\____\) \__/     |__|  \___)(___/    \___)|___|\__/|___| \_______)
  ]]

---@class snacks.dashboard.Config
M.dashboard = {
  sections = {
    {
      section = "terminal",
      cmd = "pokemon-colorscripts --name charmander --no-title; ",
      align = "center",
      indent = 10,
    },
    { header = header, padding = 2 },
    { section = "keys", gap = 1, padding = 2 },
    {
      icon = icons.git,
      title = "Git Status",
      section = "terminal",
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
      cmd = "git status --short --branch --renames",
      height = 5,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
    { section = "startup", gap = 1, padding = 2 },
  },
}

---@class snacks.statuscolumn.Config
M.statuscolumn = {
  enabled = true,
  left = { "mark", "sign" },
  right = { "fold", "git" },
  folds = {
    open = true,
    git_hl = true,
  },
  git = {
    patterns = { "GitSign", "MiniDiffSign" },
  },
  refresh = 50,
}

---@class snacks.notifier.Config
M.notifier = {
  enabled = true,
  margin = {
    top = 0,
    right = 1,
    bottom = 0,
  },
  width = { min = 40, max = 0.4 },
  height = { min = 1, max = 0.6 },
  padding = true,
  sort = { "level", "added" },
  level = vim.log.levels.TRACE,
  icons = {
    error = icons.error,
    warn = icons.warningTriangle,
    info = icons.info,
    debug = icons.debug,
  },
  style = "compact",
  top_down = true,
  refresh = 50,
  timeout = 3000,
}

---@class snacks.input.Config
M.input = {
  enabled = true,
  backdrop = true,
  position = "float",
  border = "rounded",
  title_pos = "center",
  height = 1,
  width = 60,
  relative = "editor",
  noautocmd = true,
  row = 2,
  wo = {
    winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
    cursorline = false,
  },
  bo = {
    filetype = "snacks_input",
    buftype = "prompt",
  },
  --- buffer local variables
  b = {
    completion = false, -- disable blink completions in input
  },
  keys = {
    n_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "n" },
    i_esc = { "<esc>", { "cmp_close", "stopinsert" }, mode = "i" },
    i_cr = { "<cr>", { "cmp_accept", "confirm" }, mode = "i" },
    i_tab = { "<tab>", { "cmp_select_next", "cmp" }, mode = "i" },
    q = "cancel",
  },
}

---@class snacks.picker.Config
M.picker = {
  layout = {
    cycle = true,
    --- Use the default layout or vertical if the window is too narrow
    preset = function()
      return vim.o.columns >= 120 and "telescope" or "vertical"
    end,
  },
  matcher = {
    frecency = true,
  },
}

M.keys = {
  -- COMMON
  -- stylua: ignore
  { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  -- stylua: ignore
  { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
  -- stylua: ignore
  { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
  -- stylua: ignore
  { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
    -- stylua: ignore
  { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    -- stylua: ignore
  { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
  -- stylua: ignore
  { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
  -- stylua: ignore
  { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },

  -- FIND
  -- stylua: ignore
  { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    -- stylua: ignore
  { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find buffers" },
  -- stylua: ignore
  { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find git files" },
  -- stylua: ignore
  { "<leader>fo", function() Snacks.picker.recent() end, desc = "Find recent files" },
  -- stylua: ignore
  { "<leader>ft", function () Snacks.picker.todo_comments({ keywords = { "ToDo", "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },

  -- GREP
  -- stylua: ignore
  { "<leader>fl", function() Snacks.picker.grep() end, desc = "Grep" },
  -- stylua: ignore
  { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word" },

  -- DIAGNOSTICS
  -- stylua: ignore
  { "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer diagnostics" },
  -- stylua: ignore
  { "<leader>dg", function() Snacks.picker.diagnostics() end, desc = "Global diagnostics" },

  -- SEARCH
  -- stylua: ignore
  { "<leader>s",  function() Snacks.picker.registers() end, desc = "Registers" },
  -- stylua: ignore
  { "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search history" },
  -- stylua: ignore
  { "<leader>uu", function() Snacks.picker.undo() end, desc = "Search undo history" },
  -- stylua: ignore
  { "<leader>km", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
  -- stylua: ignore
  { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
  -- stylua: ignore
  { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },


  -- GIT
  -- stylua: ignore
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
  -- stylua: ignore
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
  -- stylua: ignore
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
  -- stylua: ignore
    { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },

  -- LSP
  -- stylua: ignore
  { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
  -- stylua: ignore
  { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
  -- stylua: ignore
  { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
  -- stylua: ignore
  { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
  -- stylua: ignore
  { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
  -- stylua: ignore
  { "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
}

return M
