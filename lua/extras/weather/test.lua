local lgi = require "lgi"
local Gtk = lgi.Gtk
local Weather = require "./init"

-- Initialize GTK
Gtk.init()

-- Fetch and parse
local raw_json = Weather.fetch()
local weather_data = Weather.parse(raw_json)

-- Create window
local win = Gtk.Window {
	title = "Open-Meteo Forecast",
	default_width = 600,
	default_height = 800,
	on_destroy = Gtk.main_quit,
}

-- Recursive function to format table data
local function format_table(tbl, indent)
	indent = indent or ""
	local lines = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			table.insert(lines, indent .. tostring(k) .. ": {")
			local sub = format_table(v, indent .. "  ")
			for _, line in ipairs(sub) do
				table.insert(lines, line)
			end
			table.insert(lines, indent .. "}")
		else
			table.insert(lines, string.format("%s%s: %s", indent, tostring(k), tostring(v)))
		end
	end
	return lines
end

local all_text = table.concat(format_table(weather_data), "\n")

-- Add scrolled text view
local scrolled = Gtk.ScrolledWindow { expand = true }
local buffer = Gtk.TextBuffer { text = all_text }
local view = Gtk.TextView {
	editable = false,
	wrap_mode = "WORD",
	buffer = buffer,
}

scrolled:add(view)
win:add(scrolled)

win:show_all()
Gtk.main()
