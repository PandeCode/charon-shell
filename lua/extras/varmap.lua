local Gtk = require("astal.gtk3").Gtk
local Variable = require("astal.variable")

---@param initial table
---@return varmap
return function(initial)
	local map = initial
	local var = Variable.new({})

	local function notify()
		local arr = {}
		for _, value in pairs(map) do
			table.insert(arr, value)
		end
		var:set(arr)
	end

	local function delete(key)
		if Gtk.Widget:is_type_of(map[key]) then
			map[key]:destroy()
		end

		map[key] = nil
	end

	notify() -- init

	---@class varmap
	---@field set fun(key: any, value: any): nil
	---@field delete fun(key: any): nil
	---@field get fun(): any
	---@field subscribe fun(callback: function): function
	---@overload fun(): Binding
	return setmetatable({
		set = function(key, value)
			delete(key)
			map[key] = value
			notify()
		end,
		delete = function(key)
			delete(key)
			notify()
		end,
		get = function()
			return var:get()
		end,
		subscribe = function(callback)
			return var:subscribe(callback)
		end,
	}, {
		__call = function()
			return var()
		end,
	})
end
