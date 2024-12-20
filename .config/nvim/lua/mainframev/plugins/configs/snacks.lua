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

--@class snacks.dashboard.Config
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

return M
