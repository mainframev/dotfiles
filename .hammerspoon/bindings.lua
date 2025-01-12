local bindings = {}

bindings.cmd_ctrl = { "ctrl", "cmd" }
bindings.ctrl_alt = { "ctrl", "alt" }
bindings.cmd_shift = { "cmd", "shift" }
bindings.cmd_alt = { "cmd", "alt" }
bindings.ctrl = { "ctrl" }

local app_bindings = {
  [bindings.cmd_ctrl] = {
    Kitty = "k",
    Notion = "n",
    Downloads = "d",
    Spotify = "space",
    Firefox = "f",
    ["System Preferences"] = "p",
    ["Microsoft Teams"] = "t",
    ["Microsoft Outlook"] = "o",
    ["Google Chrome"] = "h",
  },
}

local music_bindings = {
  display = { modifier = bindings.ctrl_alt, key = "a" },
  open = { modifier = bindings.ctrl_alt, key = "space" },
  playpause = { modifier = bindings.ctrl_alt, key = "p" },
  previous = { modifier = bindings.ctrl_alt, key = "left" },
  next = { modifier = bindings.ctrl_alt, key = "right" },
  backward = { modifier = bindings.cmd_alt, key = "left" },
  forward = { modifier = bindings.cmd_alt, key = "right" },
  increaseVolume = { modifier = bindings.cmd_ctrl, key = "up" },
  decreaseVolume = { modifier = bindings.cmd_ctrl, key = "down" },
}

bindings.app_bindings = app_bindings
bindings.music_bindings = music_bindings

return bindings
