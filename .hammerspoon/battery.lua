local battery = {
	rem = hs.battery.percentage(),
	source = hs.battery.powerSource(),
	title = "Battery status",
	sound = "Sosumi",
	min = 50,
}

-- notify when battery is less than battery.min
local function notifyWhenBatteryLow()
	local currentPercentage = hs.battery.percentage()
	if currentPercentage <= battery.min and battery.rem ~= currentPercentage and (currentPercentage % 5 == 0) then
		battery.rem = currentPercentage
		hs.notify
			.new({
				title = battery.title,
				informativeText = "Battery left: " .. battery.rem .. "%\nPower Source: " .. battery.source,
				soundName = battery.sound,
			})
			:send()
	end
end

local function watchBattery()
	notifyWhenBatteryLow()
end

hs.battery.watcher.new(watchBattery):start()
