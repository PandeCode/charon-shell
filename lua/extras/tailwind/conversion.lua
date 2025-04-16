local CssUnits = {}

-- Base conversion values
local BASE_FONT_SIZE = 16 -- Default browser font size in px
local BASE_VIEWPORT_WIDTH = 1920 -- Default viewport width in px
local BASE_VIEWPORT_HEIGHT = 1080 -- Default viewport height in px
local PX_PER_IN = 96 -- CSS standard: 96px = 1in
local PX_PER_PT = PX_PER_IN / 72 -- 1pt = 1/72in
local PX_PER_PC = PX_PER_PT * 12 -- 1pc = 12pt
local PX_PER_CM = PX_PER_IN / 2.54 -- 2.54cm = 1in
local PX_PER_MM = PX_PER_CM / 10 -- 10mm = 1cm
local PX_PER_Q = PX_PER_MM / 4 -- 1q = 1/4mm

-- Set custom base values
function CssUnits.setBaseValues(fontSizePx, viewportWidthPx, viewportHeightPx)
	BASE_FONT_SIZE = fontSizePx or BASE_FONT_SIZE
	BASE_VIEWPORT_WIDTH = viewportWidthPx or BASE_VIEWPORT_WIDTH
	BASE_VIEWPORT_HEIGHT = viewportHeightPx or BASE_VIEWPORT_HEIGHT
end

-- Convert any unit to pixels
function CssUnits.toPx(value, unit, parentSizePx)
	unit = unit:lower()

	if unit == "px" then
		return value
	elseif unit == "em" then
		return value * (parentSizePx or BASE_FONT_SIZE)
	elseif unit == "rem" then
		return value * BASE_FONT_SIZE
	elseif unit == "vh" then
		return value * BASE_VIEWPORT_HEIGHT / 100
	elseif unit == "vw" then
		return value * BASE_VIEWPORT_WIDTH / 100
	elseif unit == "vmin" then
		return value * math.min(BASE_VIEWPORT_WIDTH, BASE_VIEWPORT_HEIGHT) / 100
	elseif unit == "vmax" then
		return value * math.max(BASE_VIEWPORT_WIDTH, BASE_VIEWPORT_HEIGHT) / 100
	elseif unit == "%" then
		return (parentSizePx or 0) * value / 100
	elseif unit == "pt" then
		return value * PX_PER_PT
	elseif unit == "pc" then
		return value * PX_PER_PC
	elseif unit == "in" then
		return value * PX_PER_IN
	elseif unit == "cm" then
		return value * PX_PER_CM
	elseif unit == "mm" then
		return value * PX_PER_MM
	elseif unit == "q" then
		return value * PX_PER_Q
	else
		error("Unsupported unit: " .. unit)
	end
end

-- Convert pixels to any unit
function CssUnits.fromPx(px, targetUnit, parentSizePx)
	targetUnit = targetUnit:lower()

	if targetUnit == "px" then
		return px
	elseif targetUnit == "em" then
		return px / (parentSizePx or BASE_FONT_SIZE)
	elseif targetUnit == "rem" then
		return px / BASE_FONT_SIZE
	elseif targetUnit == "vh" then
		return px * 100 / BASE_VIEWPORT_HEIGHT
	elseif targetUnit == "vw" then
		return px * 100 / BASE_VIEWPORT_WIDTH
	elseif targetUnit == "vmin" then
		return px * 100 / math.min(BASE_VIEWPORT_WIDTH, BASE_VIEWPORT_HEIGHT)
	elseif targetUnit == "vmax" then
		return px * 100 / math.max(BASE_VIEWPORT_WIDTH, BASE_VIEWPORT_HEIGHT)
	elseif targetUnit == "%" then
		return px * 100 / (parentSizePx or 1)
	elseif targetUnit == "pt" then
		return px / PX_PER_PT
	elseif targetUnit == "pc" then
		return px / PX_PER_PC
	elseif targetUnit == "in" then
		return px / PX_PER_IN
	elseif targetUnit == "cm" then
		return px / PX_PER_CM
	elseif targetUnit == "mm" then
		return px / PX_PER_MM
	elseif targetUnit == "q" then
		return px / PX_PER_Q
	else
		error("Unsupported unit: " .. targetUnit)
	end
end

-- Convert from any unit to any other unit
function CssUnits.convert(value, fromUnit, toUnit, parentSizePx)
	local px = CssUnits.toPx(value, fromUnit, parentSizePx)
	return CssUnits.fromPx(px, toUnit, parentSizePx)
end

-- Parse a CSS dimension string like "10px" or "1.5em"
function CssUnits.parse(dimensionStr)
	local value, unit = dimensionStr:match("([%d%.]+)([%a%%]+)")
	if value and unit then
		return tonumber(value), unit
	end
	return nil, nil
end

-- Convert a CSS dimension string to another unit
function CssUnits.convertString(dimensionStr, toUnit, parentSizePx)
	local value, fromUnit = CssUnits.parse(dimensionStr)
	if value and fromUnit then
		local result = CssUnits.convert(value, fromUnit, toUnit, parentSizePx)
		return result .. toUnit
	end
	return nil
end

return CssUnits
