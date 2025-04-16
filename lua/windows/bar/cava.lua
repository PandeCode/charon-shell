local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local GLib = astal.require("GLib")
local cairo = astal.require("cairo")
local Gdk = require("astal.gtk3").Gdk
local Gtk = require("astal.gtk3").Gtk
local Cava = astal.require("AstalCava")
local bind = astal.bind
local utils = require("lua.utils")
local tailwind = require("lua.extras.tailwind")
local tcss = tailwind.tcss
local toCSS = tailwind.toCSS
local el = require("lua.extras.elements")
local p = el.p
local div = el.div
local math = require("math")

return function(params)
	params = params or {}
	local effect_type = params.effect_type or "bars"
	local bar_color = params.color or { 0.2, 0.6, 0.86, 0.8 }
	local wave_color = params.wave_color or { 0.3, 0.8, 0.4, 0.8 }
	local particle_color = params.particle_color or { 0.9, 0.3, 0.2, 0.7 }
	local mirror = params.mirror or false

	local cava = Cava.get_default()
	cava.bars = params.bars or 32
	cava.framerate = params.framerate or 60

	local particles = {}
	local MAX_PARTICLES = 100

	local rotation = 0

	local draw_functions = {

		bars = function(cr, values, width, height)
			local bar_width = width / #values
			local bar_spacing = bar_width * 0.2
			local actual_bar_width = bar_width - bar_spacing

			cr:set_source_rgba(bar_color[1], bar_color[2], bar_color[3], bar_color[4])

			for i, value in ipairs(values) do
				local x = (i - 1) * bar_width + (bar_spacing / 2)
				local bar_height = value * height
				local y = height - bar_height

				cr:rectangle(x, y, actual_bar_width, bar_height)
				cr:fill()

				if mirror then
					cr:rectangle(x, 0, actual_bar_width, bar_height)
					cr:fill()
				end
			end
		end,

		wave = function(cr, values, width, height)
			cr:set_source_rgba(wave_color[1], wave_color[2], wave_color[3], wave_color[4])

			local point_width = width / (#values - 1)
			local mid_y = height / 2

			cr:move_to(0, mid_y + (values[1] * mid_y))

			for i = 2, #values do
				local x = (i - 1) * point_width
				local y = mid_y + (values[i] * mid_y * (mirror and 1 or 0.8))

				if i > 2 then
					local prev_x = (i - 2) * point_width
					local prev_y = mid_y + (values[i - 1] * mid_y * (mirror and 1 or 0.8))
					local ctrl_x = (i - 1.5) * point_width
					local ctrl_y = mid_y + (values[i - 1] * mid_y * (mirror and 1 or 0.8))

					cr:curve_to(prev_x, prev_y, ctrl_x, ctrl_y, x, y)
				else
					cr:line_to(x, y)
				end
			end

			if mirror then
				cr:line_to(width, mid_y)
				cr:line_to(0, mid_y)
				cr:close_path()
				cr:fill()
			else
				cr:stroke_preserve()

				local pattern = cairo.Pattern.create_linear(0, 0, 0, height)
				pattern:add_color_stop_rgba(0, wave_color[1], wave_color[2], wave_color[3], 0)
				pattern:add_color_stop_rgba(1, wave_color[1], wave_color[2], wave_color[3], wave_color[4] / 2)

				cr:line_to(width, height)
				cr:line_to(0, height)
				cr:close_path()
				cr:set_source(pattern)
				cr:fill()
			end
		end,

		particles = function(cr, values, width, height)
			local avg_value = 0
			for _, v in ipairs(values) do
				avg_value = avg_value + v
			end
			avg_value = avg_value / #values

			if #particles < MAX_PARTICLES then
				local particle_count = math.floor(avg_value * 5) + 1
				for i = 1, particle_count do
					local bar_index = math.random(1, #values)
					local intensity = values[bar_index]

					if intensity > 0.1 then
						local particle = {
							x = (bar_index - 0.5) * (width / #values),
							y = height,
							size = 2 + intensity * 5,
							velocity = {
								x = (math.random() - 0.5) * 2,
								y = -3 - intensity * 7,
							},
							life = 1.0,
							fade_rate = 0.01 + math.random() * 0.02,
						}
						table.insert(particles, particle)
					end
				end
			end

			local particles_to_keep = {}
			for _, particle in ipairs(particles) do
				particle.x = particle.x + particle.velocity.x
				particle.y = particle.y + particle.velocity.y

				particle.velocity.y = particle.velocity.y + 0.1

				particle.life = particle.life - particle.fade_rate

				if particle.life > 0 then
					cr:set_source_rgba(
						particle_color[1],
						particle_color[2],
						particle_color[3],
						particle_color[4] * particle.life
					)
					cr:arc(particle.x, particle.y, particle.size * particle.life, 0, 2 * math.pi)
					cr:fill()

					table.insert(particles_to_keep, particle)
				end
			end
			particles = particles_to_keep

			cr:set_source_rgba(bar_color[1], bar_color[2], bar_color[3], bar_color[4] * 0.3)
			local bar_width = width / #values
			local bar_spacing = bar_width * 0.2
			local actual_bar_width = bar_width - bar_spacing

			for i, value in ipairs(values) do
				local x = (i - 1) * bar_width + (bar_spacing / 2)
				local bar_height = value * height * 0.5
				local y = height - bar_height

				cr:rectangle(x, y, actual_bar_width, bar_height)
				cr:fill()
			end
		end,

		circular = function(cr, values, width, height)
			local center_x = width / 2
			local center_y = height / 2
			local radius = math.min(width, height) * 0.4

			rotation = (rotation + 0.01) % (2 * math.pi)

			for i, value in ipairs(values) do
				local angle = (i / #values) * 2 * math.pi + rotation
				local bar_height = radius * (0.2 + value * 0.8)

				local x1 = center_x + math.cos(angle) * radius
				local y1 = center_y + math.sin(angle) * radius
				local x2 = center_x + math.cos(angle) * (radius + bar_height)
				local y2 = center_y + math.sin(angle) * (radius + bar_height)

				local intensity = value * 0.7 + 0.3
				cr:set_source_rgba(
					bar_color[1] * intensity,
					bar_color[2] * intensity,
					bar_color[3] * intensity,
					bar_color[4]
				)

				cr:set_line_width(radius * 0.05)
				cr:move_to(x1, y1)
				cr:line_to(x2, y2)
				cr:stroke()
			end

			cr:set_source_rgba(bar_color[1], bar_color[2], bar_color[3], bar_color[4] * 0.3)
			cr:set_line_width(1)

			for i, value in ipairs(values) do
				local angle1 = (i / #values) * 2 * math.pi + rotation
				local bar_height1 = radius * (0.2 + value * 0.8)
				local x1 = center_x + math.cos(angle1) * (radius + bar_height1)
				local y1 = center_y + math.sin(angle1) * (radius + bar_height1)

				if i > 1 then
					local prev_angle = ((i - 1) / #values) * 2 * math.pi + rotation
					local prev_bar_height = radius * (0.2 + values[i - 1] * 0.8)
					local x2 = center_x + math.cos(prev_angle) * (radius + prev_bar_height)
					local y2 = center_y + math.sin(prev_angle) * (radius + prev_bar_height)

					cr:move_to(x1, y1)
					cr:line_to(x2, y2)
					cr:stroke()
				end

				if i == #values then
					local first_angle = (1 / #values) * 2 * math.pi + rotation
					local first_bar_height = radius * (0.2 + values[1] * 0.8)
					local x_first = center_x + math.cos(first_angle) * (radius + first_bar_height)
					local y_first = center_y + math.sin(first_angle) * (radius + first_bar_height)

					cr:move_to(x1, y1)
					cr:line_to(x_first, y_first)
					cr:stroke()
				end
			end
		end,
	}

	local area = Widget.DrawingArea({
		expand = true,
		["width-request"] = 150,
		class_name = "transparent",
		on_draw = function(widget, cr)
			local width = widget:get_allocated_width()
			local height = widget:get_allocated_height()

			local values = cava:get_values()

			cr:set_source_rgba(0, 0, 0, 0)
			cr:paint()

			local draw_function = draw_functions[effect_type] or draw_functions["bars"]
			draw_function(cr, values, width, height)

			widget:queue_draw()

			return true
		end,
	})

	GLib.timeout_add(GLib.PRIORITY_DEFAULT, cava.framerate, function()
		area:queue_draw()
		return true
	end)

	return area
end
