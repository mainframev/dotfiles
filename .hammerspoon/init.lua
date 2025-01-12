require("music")
require("battery")

local alert = require("alert")
local bindings = require("bindings")
local helpers = require("helpers")

-- app bindings
for modifiers, apps in pairs(bindings.app_bindings) do
  for name, key in pairs(apps) do
    hs.hotkey.bind(modifiers, key, function()
      if name == "Downloads" then
        hs.execute("open ~/Downloads/")
      end
      helpers.toggle_application(name)
    end)
  end
end

local function reload_config()
  alert.show("Config reloaded")
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
alert.show("Config loaded")
