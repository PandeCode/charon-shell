local ____lualib = require("lualib_bundle")
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____react = require("tslib.react")
local Elements = ____react.Elements
local useFetchCache = ____react.useFetchCache
local ____require_result_0 = require("lua.utils.init")
local inspect = ____require_result_0.inspect
local ninspect = ____require_result_0.ninspect
local json = require("dkjson")
local WEATHER_URL = "https://api.open-meteo.com/v1/forecast?latitude=9.936855359783848&longitude=-84.18010736600566&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,uv_index_clear_sky_max,sunshine_duration,daylight_duration,rain_sum,showers_sum,snowfall_sum,wind_speed_10m_max,wind_gusts_10m_max,shortwave_radiation_sum&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,visibility,cloud_cover,surface_pressure,apparent_temperature,precipitation_probability,precipitation&current=temperature_2m,apparent_temperature,relative_humidity_2m,is_day,precipitation,showers,rain,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=auto&timeformat=unixtime"
function ____exports.default()
    local data = useFetchCache(WEATHER_URL, json.decode)
    local function formatTime(ts)
        return "impl"
    end
    local function formatHour(ts)
        return "impl"
    end
    local function formatDate(ts)
        return "impl"
    end
    local function windDir(deg)
        local dirs = {
            "N",
            "NE",
            "E",
            "SE",
            "S",
            "SW",
            "W",
            "NW"
        }
        return dirs[math.floor(deg / 45 + 0.5) % 8 + 1]
    end
    return Elements.Create(
        Elements.Fragment,
        nil,
        data._v(function(v)
            if not v then
                return Elements.Create(Elements.Fragment, nil)
            end
            return Elements.Create(
                "div",
                {vertical = true, spacing = 4, className = "bg-base01 text-base05 p-4"},
                Elements.Create(
                    "grid",
                    {["row-spacing"] = 10, ["column-spacing"] = 10},
                    Elements.Create(
                        "griditem",
                        {w = 12, h = 3, x = 0, y = 0},
                        Elements.Create(
                            "div",
                            {vertical = true, spacing = 1, className = "bg-base02 p-3 rounded-lg"},
                            Elements.Create("p", {className = "text-base0C text-xl"}, "Current Weather"),
                            Elements.Create(
                                "div",
                                {vertical = true, spacing = 1},
                                Elements.Create(
                                    "p",
                                    nil,
                                    "Time: ",
                                    formatTime(v.current.time)
                                ),
                                Elements.Create(
                                    "p",
                                    nil,
                                    "Temp: ",
                                    v.current.temperature_2m,
                                    v.current_units.temperature_2m
                                ),
                                Elements.Create(
                                    "p",
                                    nil,
                                    "Feels Like: ",
                                    v.current.apparent_temperature,
                                    v.current_units.apparent_temperature
                                ),
                                Elements.Create(
                                    "p",
                                    nil,
                                    "Humidity: ",
                                    v.current.relative_humidity_2m,
                                    v.current_units.relative_humidity_2m
                                ),
                                Elements.Create(
                                    "p",
                                    nil,
                                    "Wind: ",
                                    v.current.wind_speed_10m,
                                    v.current_units.wind_speed_10m,
                                    " ",
                                    windDir(v.current.wind_direction_10m)
                                )
                            )
                        )
                    ),
                    Elements.Create(
                        "griditem",
                        {w = 12, h = 3, x = 0, y = 3},
                        Elements.Create(
                            "div",
                            {vertical = true, spacing = 1, className = "bg-base02 p-3 rounded-lg"},
                            Elements.Create("p", {className = "text-base0C text-xl"}, "Hourly Forecast"),
                            Elements.Create(
                                "grid",
                                nil,
                                __TS__ArrayMap(
                                    __TS__ArraySlice(v.hourly.time, 0, 12),
                                    function(____, t, i) return Elements.Create(
                                        "griditem",
                                        {w = 1, h = 1, x = i, y = 0},
                                        Elements.Create(
                                            "div",
                                            {vertical = true, spacing = 1, className = "p-1"},
                                            Elements.Create(
                                                "p",
                                                {className = "text-base07"},
                                                formatHour(t)
                                            ),
                                            Elements.Create("p", {className = "text-base0A"}, v.hourly.temperature_2m[i + 1], "°")
                                        )
                                    ) end
                                )
                            )
                        )
                    ),
                    Elements.Create(
                        "griditem",
                        {w = 12, h = 2, x = 0, y = 6},
                        Elements.Create(
                            "div",
                            {vertical = true, spacing = 1, className = "bg-base02 p-3 rounded-lg"},
                            Elements.Create("p", {className = "text-base0C text-xl"}, "Daily Forecast"),
                            Elements.Create(
                                "grid",
                                nil,
                                __TS__ArrayMap(
                                    __TS__ArraySlice(v.daily.time, 0, 7),
                                    function(____, t, i) return Elements.Create(
                                        "griditem",
                                        {w = 1, h = 1, x = i, y = 0},
                                        Elements.Create(
                                            "div",
                                            {vertical = true, spacing = 1},
                                            Elements.Create(
                                                "p",
                                                {className = "text-base07"},
                                                formatDate(t)
                                            ),
                                            Elements.Create(
                                                "p",
                                                {className = "text-base0A"},
                                                "H ",
                                                v.daily.temperature_2m_max[i + 1],
                                                "° L",
                                                " ",
                                                v.daily.temperature_2m_min[i + 1],
                                                "°"
                                            )
                                        )
                                    ) end
                                )
                            )
                        )
                    )
                )
            )
        end)
    )
end
return ____exports
