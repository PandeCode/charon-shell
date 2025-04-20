local astal = require "astal"
local Astal = astal.require "Astal"
local Gtk = require("astal.gtk3").Gtk
local GLib = astal.require "GLib"
local Widget = require "astal.gtk3.widget"
local utils = require "lua.utils"

local M = {}
local timing = 100

function M.mkPopupToggleAnim(WindowChild, props, props_r)
	local window = nil
	local r_main = nil
	local timeout = 10000
	local window_visible = astal.Variable(false)

	local function toggle()
		if window_visible:get() and window and r_main then
			r_main.reveal_child = false
			GLib.timeout_add(GLib.PRIORITY_DEFAULT, timing, function()
				window:hide()
				window_visible:set(false)
				return false
			end)
			GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, function()
				if window_visible:get() then
					return false
				end
				if timeout > 0 then
					timeout = timeout - 1000
					return true
				end
				r_main:destroy()
				window:destroy()
				window = nil
				r_main = nil
				collectgarbage "collect"
				return false
			end)
		else
			if not window then
				r_main = Widget.Revealer(utils.merge({
					child = WindowChild(),
					reveal_child = false,
					transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
					transition_duration = 500,
				}, props_r))
				window = Widget.Window(utils.merge(props, {
					r_main,
					class_name = "transparent",
				}))
			end
			window:show_all()
			window_visible:set(true)
			timeout = 10000
			GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, function()
				r_main.reveal_child = true
				return false
			end)
		end
	end

	return toggle
end

function M.mkPopupToggle(Window)
	local window = nil
	local window_visible = astal.Variable(false)

	local function toggle()
		if window_visible:get() and window then
			window:hide()
			window_visible:set(false)
		else
			if not window then
				window = Window()
			end
			window:show_all()
			window_visible:set(true)
		end
	end

	return toggle
end

function M.loadGlade(path)
	local builder = Gtk.Builder()
	builder:add_from_file(path)
	local objects = builder:get_objects()
	local main_box = nil
	for _, obj in ipairs(objects) do
		if Gtk.Box:is_type_of(obj) then
			main_box = obj
			break
		end
	end
	if not main_box then
		error "No GtkBox found in the Glade file!"
	end
	return main_box
end

function M.ensure_icon(...)
	local args = { ... }
	local default = "dialog-information-symbolic"

	for _, icon_name in ipairs(args) do
		if Astal.Icon.lookup_icon(icon_name) then
			return icon_name
		end
	end

	-- If no icons were found, return the last argument or the default
	return args[#args] or default
end

function M.formatTime(ts)
	local date = GLib.DateTime.new_from_unix_local(ts)
	return date:format "%X" -- Locale-specific time
end
function M.formatHour(ts)
	local date = GLib.DateTime.new_from_unix_local(ts)
	return string.format("%02d:00", date:get_hour())
end

function M.formatDate(ts)
	local date = GLib.DateTime.new_from_unix_local(ts)
	return date:format "%x" -- Locale-specific date
end

return M
