local astal = require "astal"
local Widget = require "astal.gtk3.widget"
local Gtk = require("astal.gtk3").Gtk
local Astal = astal.require "Astal"
local utils = require "lua.utils"
local tailwind = require "lua.extras.tailwind"

local mappings = {
	cls = "class_name",
	className = "class_name",
	onClick = "on_clicked",
	onDestroy = "on_destroy",
	width = "width-request",
	height = "height-request",
}

local function attach_children(grid, children)
	for _, c in ipairs(children) do
		if c.widget ~= nil then
			grid:attach(c.widget, c.x, c.y, c.w, c.h)
		elseif type(c) == "table" then
			attach_children(grid, c) -- recursive call
		end
	end
end
local function labelc(v)
	if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
		return Widget.Label { label = tostring(v) }
	end
	return v
end

local function Create(name, props, ...)
	local returnValue = nil
	local ref = nil

	if type(name) == "function" or type(name) == "table" then
		if props and props.ref then
			ref = props.ref
			props.ref = nil
			returnValue = name(props, ...)
			ref:set(returnValue)
			return returnValue
		end
		return name(props, ...)
	end

	local children = { ... }
	if props then
		props.key = nil
		if type(props.css) == "table" then
			props.css = tailwind.toCSS(props.css)
		end

		for k, v in pairs(mappings) do
			if props[k] then
				props[v] = props[k]
				props[k] = nil
			end
		end

		if props.class_name then
			if type(props.class_name) == "table" then
				props.class_name = table.concat(props.class_name, " ")
			end
		end
		props.visible = true
		if props.ref then
			ref = props.ref
			props.ref = nil
		end
	else
		props = { visible = true }
	end

	if name == "div" or name == "box" or name == "eventbox" then
		for k, v in pairs(children or {}) do
			children[k] = labelc(v)
		end
		returnValue = name ~= "eventbox" and Widget.Box(utils.merge(children, props))
			or Astal.EventBox(utils.merge(children, props))
	elseif name == "grid" then
		local grid = Gtk.Grid(utils.merge({}, props))
		attach_children(grid, children)
		returnValue = grid
	elseif name == "griditem" then
		if props == nil then
			props = { x = 0, y = 0, w = 1, h = 1 }
		end
		local x, y, w, h = props.x or 0, props.y or 0, props.w or 1, props.h or 1
		props.x, props.y, props.w, props.h = nil, nil, nil, nil
		if #children == 1 then
			children[1] = labelc(children[1])
			returnValue = { widget = children[1], x = x, y = y, w = w, h = h }
		end
		returnValue = { widget = Create("div", props, ...), x = x, y = y, w = w, h = h }
	elseif name == "p" or name == "label" or name == "span" then
		local labelText = (type(children[1]) == "string" or (children[1] ~= nil and children[1].emitter ~= nil))
				and { label = children[1] }
			or {}
		returnValue = Widget.Label(utils.merge(labelText, props))
	elseif name == "button" then
		local labelText = type(children[1]) == "string" and { label = children[1] } or {}
		returnValue = Widget.Button(utils.merge(labelText, props))
	elseif name == "centerbox" then
		returnValue = Astal.CenterBox(utils.merge(children, props))
	elseif name == "circularprogress" then
		returnValue = Astal.CircularProgress(utils.merge(props))
	elseif name == "drawingarea" then
		returnValue = Gtk.DrawingArea(utils.merge(props))
	elseif name == "entry" then
		returnValue = Gtk.Entry(utils.merge(props))
	elseif name == "icon" then
		returnValue = Astal.Icon(utils.merge(props))
	elseif name == "levelbar" then
		returnValue = Astal.LevelBar(utils.merge(props))
	elseif name == "overlay" then
		returnValue = Widget.Overlay(utils.merge(children, props))
	elseif name == "revealer" then
		if #children == 0 then
			returnValue = Gtk.Revealer(utils.merge({ child = Create("p", nil, "<Empty Revealer>") }, props))
		else
			returnValue = Gtk.Revealer(utils.merge({ child = Create("div", nil, ...) }, props))
		end
	elseif name == "scrollable" then
		returnValue = Astal.Scrollable(utils.merge(children, props))
	elseif name == "slider" then
		returnValue = Astal.Slider(utils.merge(props))
	elseif name == "stack" then
		returnValue = Astal.Stack(utils.merge(children, props))
	elseif name == "switch" then
		returnValue = Gtk.Switch(utils.merge(props))
	elseif name == "hr" or name == "Separator" then
		returnValue = Gtk.Separator(utils.merge(props))
	else
		error("Unknown component: " .. tostring(name))
	end

	if props and ref then
		ref:set(returnValue)
	end
	return returnValue
end

return {
	Table = function(tbl)
		local children = {}
		for k, v in pairs(tbl) do
			table.insert(children, Widget.Label { label = tostring(k) .. ": " .. tostring(v) })
		end
		return Widget.Box(children)
	end,
	Create = Create,
	Fragment = "div",
}
