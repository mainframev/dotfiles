return {
  "nvimdev/dashboard-nvim",
  lazy = false,
  opts = function()
    -- Font Name: ANSI Shadow
    -- https://patorjk.com/software/taag
    local logo = [[
 ___      ___       __        __    _____  ___    _______   _______        __       ___      ___   _______  
|"  \    /"  |     /""\      |" \  (\"   \|"  \  /"     "| /"      \      /""\     |"  \    /"  | /"     "| 
 \   \  //   |    /    \     ||  | |.\\   \    |(: ______)|:        |    /    \     \   \  //   |(: ______) 
 /\\  \/.    |   /' /\  \    |:  | |: \.   \\  | \/    |  |_____/   )   /' /\  \    /\\  \/.    | \/    |   
|: \.        |  //  __'  \   |.  | |.  \    \. | // ___)   //      /   //  __'  \  |: \.        | // ___)_  
|.  \    /:  | /   /  \\  \  /\  |\|    \    \ |(:  (     |:  __   \  /   /  \\  \ |.  \    /:  |(:      "| 
|___|\__/|___|(___/    \___)(__\_|_)\___|\____\) \__/     |__|  \___)(___/    \___)|___|\__/|___| \_______) 
  ]]

    logo = string.rep("\n", 8) .. logo

    local opts = {
      theme = "doom",
      hide = {
        statusline = false,
      },
      config = {
        header = vim.split(logo, "\n"),
        center = {
          {
            icon = "  ",
            icon_hl = "Title",
            desc = "New File",
            desc_hl = "String",
            key = "<Leader> n",
            keymap = "SPC n",
            key_hl = "Number",
            action = function()
              vim.api.nvim_input("<cmd>enew<cr>")
            end,
          },
          {
            icon = "  ",
            icon_hl = "Title",
            desc = "Restore sessions",
            desc_hl = "String",
            key = "<Leader> ss",
            keymap = "SPC s s",
            key_hl = "Number",
            action = "SessionSearch",
          },
          {
            icon = "󰈢  ",
            icon_hl = "Title",
            desc = "Recently opened files",
            desc_hl = "String",
            key = "<Leader> fo",
            keymap = "SPC f o",
            key_hl = "Number",
            action = "Telescope oldfiles",
          },
          {
            icon = "󰈬  ",
            icon_hl = "Title",
            desc = "Project grep",
            desc_hl = "String",
            key = "<Leader> fl",
            keymap = "SPC f l",
            key_hl = "Number",
            action = "Telescope live_grep",
          },
          {
            icon = "  ",
            icon_hl = "Title",
            desc = "Git Braches",
            desc_hl = "String",
            key = "<Leader> gb",
            keymap = "SPC g b",
            key_hl = "Number",
            action = ":Telescope git_branches",
          },
          {
            icon = "  ",
            icon_hl = "Title",
            desc = "Open Nvim config",
            desc_hl = "String",
            key = "<Leader> ev",
            keymap = "SPC e v",
            key_hl = "Number",
            action = "tabnew $MYVIMRC | tcd %:p:h",
          },
          {
            icon = " ",
            action = function()
              vim.api.nvim_input("<cmd>qa<cr>")
            end,
            desc = " Quit",
            key = "<Esc>",
          },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        end,
      },
    }

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end

    -- open dashboard after closing lazy
    if vim.o.filetype == "lazy" then
      vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(vim.api.nvim_get_current_win()),
        once = true,
        callback = function()
          vim.schedule(function()
            vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
          end)
        end,
      })
    end

    return opts
  end,
}
