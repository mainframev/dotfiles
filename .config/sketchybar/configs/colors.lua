return {
	black = 0xFF1F2335,
	white = 0xffe0e0e0,
	red = 0xFFFF757F,
	green = 0xFFC3E88D,
	blue = 0xFF3D59A1,
	yellow = 0xfff8c555,
	orange = 0xFFFFC777,
	magenta = 0xFFFF007C,
	grey = 0xff7a7d8c,
	transparent = 0x00000000,
	teal = 0xFF4FD6BE,

	bar = {
		bg = 0xFF24283B,
		border = 0xFF4FD6BE,
	},

	popup = {
		bg = 0xFF24283B,
		border = 0xFFFF007C,
	},

	bg1 = 0xff2e323c,
	bg2 = 0xff353b45,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
