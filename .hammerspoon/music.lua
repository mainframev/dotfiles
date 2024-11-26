local global_bindings = require("bindings")

local music_bindings = global_bindings.music_bindings

local music = {}

local app = require("hs.application")
local spotify = require("spotify")

local function provider()
	if app.get("Spotify") ~= nil then
		return spotify
	end
	return nil
end

local function call(method, option)
	local provider_inner = provider()
	if provider_inner ~= nil then
		provider_inner[method](option)
	end
end

local bindings = {
	"next",
	"previous",
	"forward",
	"backward",
	"increaseVolume",
	"decreaseVolume",
	"maxVolume",
	"minVolume",
	"display",
	"open",
	"toggle",
	"save",
	"remove",
}
for i = 1, #bindings do
	music[bindings[i]] = function(option)
		call(bindings[i], option)
	end
end

function music.playpause()
	local provider_inner = provider()
	if provider_inner == nil then
		provider_inner = spotify
	end
	provider_inner.playpause()
end

-- Music
hs.hotkey.bind(music_bindings.display.modifier, music_bindings.display.key, function()
	music.display()
end)

hs.hotkey.bind(music_bindings.open.modifier, music_bindings.open.key, function()
	music.open()
end)

hs.hotkey.bind(music_bindings.playpause.modifier, music_bindings.playpause.key, function()
	music.playpause()
end)

hs.hotkey.bind(music_bindings.previous.modifier, music_bindings.previous.key, function()
	music.previous()
end)

hs.hotkey.bind(music_bindings.next.modifier, music_bindings.next.key, function()
	music.next()
end)

hs.hotkey.bind(
	music_bindings.forward.modifier,
	music_bindings.forward.key,
	function()
		music.forward()
	end,
	nil,
	function()
		music.forward(1)
	end
)

hs.hotkey.bind(
	music_bindings.backward.modifier,
	music_bindings.backward.key,
	function()
		music.backward()
	end,
	nil,
	function()
		music.backward(1)
	end
)

hs.hotkey.bind(
	music_bindings.increaseVolume.modifier,
	music_bindings.increaseVolume.key,
	function()
		music.increaseVolume()
	end,
	nil,
	function()
		music.increaseVolume()
	end
)

hs.hotkey.bind(
	music_bindings.decreaseVolume.modifier,
	music_bindings.decreaseVolume.key,
	function()
		music.decreaseVolume()
	end,
	nil,
	function()
		music.decreaseVolume()
	end
)
