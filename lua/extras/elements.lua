local Widget = require "astal.gtk3.widget"
local logger = require "lua.logger"
local Gtk = require("astal.gtk3").Gtk

local utils = require "lua.utils"
local assets = require "lua.assets"

--- @module Helper functions for creating GTK3 UI elements
-- @author Updated version with improved consistency and documentation
local M = {}

--- Creates a horizontal box container with provided elements
-- @param children Table of child widgets or a single widget
-- @param class_name CSS class name for styling (defaults to "div")
-- @param extra Table of additional properties to apply to the widget
-- @return Widget.Box instance
function M.mk_div(children, class_name, extra)
	if type(children) == "string" then
		children = { M.p(children) }
	elseif type(children) ~= "table" then
		children = { children }
	end

	local base = {
		class_name = class_name or "div",
	}

	-- Insert children as numbered indices
	for i, child in ipairs(children or {}) do
		base[i] = child
	end

	return utils.merge(base, extra or {})
end

function M.div(...)
	return Widget.Box(M.mk_div(...))
end

function M.grid(...)
	return Gtk.Grid(M.mk_div(...))
end

--- Creates a vertical box container with provided elements
-- @param children Table of child widgets or a single widget
-- @param class_name CSS class name for styling (defaults to "div")
-- @param extra Table of additional properties to apply to the widget
-- @return Widget.Box instance configured vertically
function M.divv(children, class_name, extra)
	extra = extra or {}
	extra.vertical = true
	return M.div(children, class_name, extra)
end

--- Creates a text label widget
-- @param text Text to display (defaults to "p")
-- @param class_name CSS class name for styling (defaults to "")
-- @param extra Table of additional properties to apply to the widget
-- @return Widget.Label instance
function M.p(text, class_name, extra)
	if text == nil then
		text = "nil"
	end
	if type(text) ~= "string" and text.emitter == nil then
		text = utils.inspect(text)
	end
	local base = {
		label = text or "{p}",
		class_name = class_name or "",
	}

	return Widget.Label(utils.merge(base, extra or {}))
end

--- Creates a button widget with an optional callback
-- @param label Button text
-- @param class_name CSS class name for styling (defaults to "")
-- @param callback Function to execute when button is clicked
-- @param extra Table of additional properties to apply to the widget
-- @return Widget.Button instance
function M.btn(label, class_name, callback, extra)
	local base = {
		label = label,
		class_name = class_name or "",
		on_clicked = callback or function()
			logger.debug "Unused Button Callback"
		end,
	}

	return Widget.Button(utils.merge(base, extra or {}))
end

function M.btni(icon_name, class_name, callback, extra)
	local base = {
		class_name = class_name or "",
		on_clicked = callback or function()
			logger.debug "Unused Button Callback"
		end,
		Widget.Icon { icon = icon_name },
	}

	return Widget.Button(utils.merge(base, extra or {}))
end

function M.i(icon_name, class_name, extra)
	return Widget.Icon(utils.merge({ icon = icon_name, class_name = class_name }, extra))
end

--- Creates an image widget from an image URL/path
-- @param image_path Path or URL to the image
-- @param width Width in em units (defaults to 1)
-- @param height Height in em units (defaults to 1)
-- @param class_name CSS class name for styling (defaults to "")
-- @param extra Table of additional properties to apply to the widget
-- @return Widget.Box instance configured as an image
function M.img(image_path, width, height, class_name, extra)
	image_path = image_path or assets.default_image_path
	if type(width) == "number" then
		width = width .. "em"
	elseif type(width) ~= "string" then
		width = "1em"
	end

	if type(height) == "number" then
		height = height .. "em"
	elseif type(height) ~= "string" then
		height = "1em"
	end

	local css = "background-image: url('"
		.. image_path
		.. "');"
		.. [[
        min-width: ]]
		.. width
		.. [[;
        min-height: ]]
		.. height
		.. [[;
        background-position: center;
        background-size: cover;
        background-repeat: no-repeat;
    ]]

	local base = {
		halign = "CENTER",
		valign = "CENTER",
		class_name = class_name or "",
		css = css,
	}

	return Widget.Box(utils.merge(base, extra or {}))
end

function M.imgv(image_path, width, height, class_name, extra)
	local base = {
		halign = "CENTER",
		valign = "CENTER",
		class_name = class_name or "",
		css = image_path(function(v)
			return "background-image: url('"
				.. v
				.. "');"
				.. [[
        min-width: ]]
				.. (width or 1)
				.. [[em;
        min-height: ]]
				.. (height or 1)
				.. [[em;
        background-position: center;
        background-size: cover;
        background-repeat: no-repeat;
    ]]
		end),
	}

	return Widget.Box(utils.merge(base, extra or {}))
end

--- Creates a button with an image background
-- @param image_path Path or URL to the image
-- @param width Width in em units (defaults to 1)
-- @param height Height in em units (defaults to 1)
-- @param callback Function to execute when button is clicked
-- @param class_name CSS class name for styling (defaults to "")
-- @param button_extra Table of additional properties for the button widget
-- @param image_extra Table of additional properties for the image widget
-- @return Widget.Button instance with an image background
function M.imgbtn(image_path, width, height, callback, class_name, button_extra, image_extra)
	local css = "background-image: url('"
		.. image_path
		.. "');"
		.. [[
        min-width: ]]
		.. (width or 1)
		.. [[em;
        min-height: ]]
		.. (height or 1)
		.. [[em;
        background-position: center;
        background-size: cover;
        background-repeat: no-repeat;
    ]]

	local image_base = {
		halign = "CENTER",
		valign = "CENTER",
		class_name = class_name or "",
		css = css,
	}

	local image = Widget.Box(utils.merge(image_base, image_extra or {}))

	local button_base = {
		class_name = class_name or "",
		on_clicked = callback or function()
			logger.debug "Unused Button Callback"
		end,
		image, -- Add the image as the first child element
	}

	return Widget.Button(utils.merge(button_base, button_extra or {}))
end

--- Creates a horizontal spacer with configurable width
-- @param width Width in em units (defaults to 1)
-- @param class_name CSS class name for styling (defaults to "spacer")
-- @param extra Table of additional properties
-- @return Widget.Box instance configured as a spacer
function M.spacer(width, class_name, extra)
	local base = {
		class_name = class_name or "spacer",
		css = "min-width: " .. (width or 1) .. "em;",
	}

	return Widget.Box(utils.merge(base, extra or {}))
end

--- Creates a vertical spacer with configurable height
-- @param height Height in em units (defaults to 1)
-- @param class_name CSS class name for styling (defaults to "spacer")
-- @param extra Table of additional properties
-- @return Widget.Box instance configured as a vertical spacer
function M.vspacer(height, class_name, extra)
	local base = {
		class_name = class_name or "spacer",
		css = "min-height: " .. (height or 1) .. "em;",
	}

	return Widget.Box(utils.merge(base, extra or {}))
end

--- Creates an input field (entry) widget
-- @param text Initial text (defaults to "")
-- @param placeholder Placeholder text when empty (defaults to "")
-- @param class_name CSS class name for styling (defaults to "")
-- @param callback Function to execute when text changes
-- @param extra Table of additional properties
-- @return Widget.Entry instance
function M.input(text, placeholder, class_name, callback, extra)
	local base = {
		text = text or "",
		placeholder_text = placeholder or "",
		class_name = class_name or "",
		on_changed = callback,
	}

	return Widget.Entry(utils.merge(base, extra or {}))
end

function M.vscroll(elements, class_name, extra)
	return Widget.Scrollable(utils.merge({
		hscroll = Gtk.PolicyType.NEVER,
		class_name = class_name,
		table.unpack(elements),
	}, extra))
end

return M
