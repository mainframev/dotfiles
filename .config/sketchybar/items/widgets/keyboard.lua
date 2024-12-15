local constants = require("configs.constants")

sbar.add("event", constants.events.KEYBOARD_CHANGE, "AppleSelectedInputSourcesChangedNotification")

local keyboard = sbar.add("item", "widgets.keyboard", {
	position = "right",
})

local function get_keyboard_layout()
	sbar.exec(
		"defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID",
		function(result)
			local icon = "??"

			if result == "com.apple.keylayout.US\n" then
				-- icon = "🇺🇸"
				icon = "EN"
			elseif result == "com.apple.keylayout.RussianWin\n" then
				-- icon = "🇷🇺"
				icon = "RU"
			elseif result == "com.apple.keylayout.Czech\n" then
				-- icon = "🇨🇿"
				icon = "CZ"
			end
			keyboard:set({
				icon = { string = icon },
			})
		end
	)
end

get_keyboard_layout()

keyboard:subscribe(constants.events.KEYBOARD_CHANGE, function()
	sbar.delay(1, function()
		get_keyboard_layout()
	end)
end)
