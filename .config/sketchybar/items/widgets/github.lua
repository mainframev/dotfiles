local cjson = require("cjson")

local GITHUB_PAGE = 'open -n -a "Google Chrome" "https://github.com/notifications?query=reason%3Aparticipating"'

local notification_defaults = {
	drawing = true,
	update_freq = 60,
	updates = true,
}

local github = sbar.add("item", "widgets.github", notification_defaults)

function query_notifications()
	local command = [[  gh api -X GET notifications --cache=20s -f participating=true ]]
	local handle = io.popen(command)
	local res = handle:read("*a")
	handle:close()

	local parsed_res, err = cjson.decode(res)

	if err then
		print("Error parsing JSON:", err)
		return
	end

	return parsed_res
end

github:subscribe({ "forced", "routine", "system_woke" }, function()
	local notifications = query_notifications()
	github:set({ drawing = true, label = #notifications })
end)

function toggle_notifications(env)
	sbar.exec(GITHUB_PAGE)
	return
end

github:subscribe("mouse.clicked", toggle_notifications)
