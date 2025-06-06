local icons = require("configs.icons")
local colors = require("configs.colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "network_update"
-- for the network interface "en0", which is fired every 2.0 seconds.
sbar.exec(
	"killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0"
)

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	label = {
		drawing = false,
	},
})

sbar.add("item", { position = "right", width = settings.group_paddings })

wifi:subscribe({ "wifi_change", "system_woke" }, function()
	sbar.exec("ipconfig getifaddr en0", function(ip)
		local connected = not (ip == "")
		wifi:set({
			icon = {
				string = connected and icons.wifi.connected or icons.wifi.disconnected,
				color = connected and colors.green or colors.red,
			},
		})
	end)
end)

local function toggle_details()
	sbar.exec("open -a 'System Preferences' /System/Library/PreferencePanes/Network.prefPane")
end

wifi:subscribe("mouse.clicked", toggle_details)
