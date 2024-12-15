local settings = require("settings")
local colors = require("configs.colors")

-- Equivalent to the --default domain
sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Black"],
			size = 14.0,
		},
		color = colors.green,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Black"],
			size = 14.0,
		},
		color = colors.teal,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	background = {
		height = 40,
		corner_radius = 9,
		border_width = 0,
		border_color = colors.bg2,
		image = {
			corner_radius = 9,
			border_color = colors.grey,
			border_width = 1,
		},
	},
	popup = {
		background = {
			border_width = 2,
			corner_radius = 9,
			border_color = colors.popup.border,
			color = colors.popup.bg,
			shadow = { drawing = true },
		},
		blur_radius = 50,
	},
	padding_left = 5,
	padding_right = 5,
	scroll_texts = true,
})
