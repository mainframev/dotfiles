local theme = require("themes/eldritch")

local alert = {}

function alert.showOnly(text, duration, size)
  alert.close()
  alert.show(text, duration, size)
end

function alert.close()
  hs.alert.closeAll(0)
end

function alert.show(text, duration, size)
  duration = duration or 0.5
  size = size or 30
  local radius = size - 6

  hs.alert.show(text, {
    textSize = size,
    radius = radius,
    strokeWidth = 0,
    padding = 15,
    strokeColor = {
      alpha = 0,
    },
    fillColor = theme.grey,
    textStyle = {
      paragraphStyle = { alignment = "center" },
      color = theme.green,
    },
  }, hs.screen.primaryScreen(), duration)
end

return alert
