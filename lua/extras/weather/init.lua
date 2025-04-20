local json = require "dkjson"

local Weather = {}

--- Fetch weather data from Open-Meteo API.
-- @treturn string JSON response string.
function Weather.fetch()
	local url =
		[[https://api.open-meteo.com/v1/forecast?latitude=9.936855359783848&longitude=-84.18010736600566&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,uv_index_clear_sky_max,sunshine_duration,daylight_duration,rain_sum,showers_sum,snowfall_sum,wind_speed_10m_max,wind_gusts_10m_max,shortwave_radiation_sum&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,visibility,cloud_cover,surface_pressure,apparent_temperature,precipitation_probability,precipitation&current=temperature_2m,apparent_temperature,relative_humidity_2m,is_day,precipitation,showers,rain,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=auto&timeformat=unixtime]]
	local handle = io.popen('curl -s "' .. url .. '"')
	local result = handle:read "*a"
	handle:close()
	return result
end

--- Parse the JSON weather data into a Lua table.
-- @tparam string json_str JSON data string.
-- @treturn table Parsed Lua table.
function Weather.parse(json_str)
	local data, pos, err = json.decode(json_str, 1, nil)
	if err then
		error("JSON decode error: " .. err)
	end
	return data
end

return Weather
