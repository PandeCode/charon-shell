local ____lualib = require("lualib_bundle")
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Elements = ____react.Elements
local Variable = ____react.Variable
local removeCache = ____react.removeCache
local useFetchCache = ____react.useFetchCache
local useReFetchCache = ____react.useReFetchCache
local ____animate = require("ts.components.animate")
local Animate = ____animate.default
local ____require_result_0 = require("lua.utils.init")
local inspect = ____require_result_0.inspect
local ninspect = ____require_result_0.ninspect
local ____require_result_1 = require("lua.utils.astal")
local formatTime = ____require_result_1.formatTime
local formatHour = ____require_result_1.formatHour
local formatDate = ____require_result_1.formatDate
local json = require("dkjson")
local WEATHER_URL = "https://api.open-meteo.com/v1/forecast?latitude=9.936855359783848&longitude=-84.18010736600566&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,uv_index_clear_sky_max,sunshine_duration,daylight_duration,rain_sum,showers_sum,snowfall_sum,wind_speed_10m_max,wind_gusts_10m_max,shortwave_radiation_sum&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,visibility,cloud_cover,surface_pressure,apparent_temperature,precipitation_probability,precipitation&current=temperature_2m,apparent_temperature,relative_humidity_2m,is_day,precipitation,showers,rain,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=auto&timeformat=unixtime"
local function getWeatherIcon(code, isDay)
    if code <= 3 then
        return isDay ~= 0 and "☀️" or "🌙"
    end
    if code <= 48 then
        return "☁️"
    end
    if code <= 67 then
        return "🌧️"
    end
    if code <= 77 then
        return "❄️"
    end
    if code <= 82 then
        return "🌧️"
    end
    if code <= 86 then
        return "🌨️"
    end
    if code <= 99 then
        return "⛈️"
    end
    return "?"
end
local function getWindDirectionText(degree)
    local directions = {
        "N",
        "NNE",
        "NE",
        "ENE",
        "E",
        "ESE",
        "SE",
        "SSE",
        "S",
        "SSW",
        "SW",
        "WSW",
        "W",
        "WNW",
        "NW",
        "NNW"
    }
    local index = math.floor(degree / 22.5 + 0.5) % 16
    return directions[index + 1]
end
local function formatSeconds(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    return ((tostring(hours) .. "h ") .. tostring(minutes)) .. "m"
end
function ____exports.default()
    local data = useFetchCache(WEATHER_URL, json.decode)
    return Elements.Create(
        Elements.Fragment,
        nil,
        data._v(function(v)
            if v == nil then
                return Elements.Create("div", {expand = true, halign = "CENTER", valign = "CENTER", className = "text-base05"}, "Loading")
            end
            return Elements.Create(
                "scrollable",
                {hscroll = "NEVER", expand = true},
                Elements.Create(
                    "div",
                    {vertical = true, spacing = 16, className = "p-4 bg-base00"},
                    Elements.Create(
                        "div",
                        {spacing = 8, className = "p-4 bg-base01 rounded-lg"},
                        Elements.Create(
                            "div",
                            {vertical = true},
                            Elements.Create("div", {vertical = true, className = "text-base05 text-2xl font-bold"}, "Weather Dashboard"),
                            Elements.Create(
                                "div",
                                {valign = "FILL", className = "text-base04", vertical = true},
                                Elements.Create(Elements.Fragment, nil, ((v.timezone .. " (") .. v.timezone_abbreviation) .. ")"),
                                Elements.Create(
                                    Elements.Fragment,
                                    nil,
                                    ((("Lat: " .. __TS__NumberToFixed(v.latitude, 4)) .. "° Long: ") .. __TS__NumberToFixed(v.longitude, 4)) .. "°"
                                ),
                                Elements.Create(
                                    Elements.Fragment,
                                    nil,
                                    ("Elevation: " .. tostring(v.elevation)) .. "m"
                                ),
                                Elements.Create(
                                    "div",
                                    {className = "text-base04"},
                                    "Updated: ",
                                    formatTime(v.current.time)
                                )
                            ),
                            Elements.Create(
                                "button",
                                {
                                    onClick = function()
                                        data._v.set(data._v, nil)
                                        removeCache(WEATHER_URL)
                                        useReFetchCache(data, WEATHER_URL, json.decode)
                                    end,
                                    className = "p-2 bg-base03 text-base05 rounded mt-2"
                                },
                                "Refresh Data"
                            )
                        ),
                        Elements.Create(
                            "div",
                            {spacing = 16},
                            Elements.Create(
                                "div",
                                {expand = true, vertical = true, spacing = 8, className = "p-4 bg-base02 rounded-lg"},
                                Elements.Create(
                                    "div",
                                    {spacing = 12},
                                    Elements.Create(
                                        "div",
                                        {className = "text-5xl font-bold text-base0B"},
                                        getWeatherIcon(v.current.weather_code, v.current.is_day)
                                    ),
                                    Elements.Create(
                                        "div",
                                        {vertical = true},
                                        Elements.Create("div", {className = "text-5xl font-bold text-base05"}, v.current.temperature_2m, "°C"),
                                        Elements.Create(
                                            "div",
                                            {className = "text-base04"},
                                            "Feels like: ",
                                            v.current.apparent_temperature,
                                            "°C"
                                        )
                                    ),
                                    Elements.Create(
                                        "div",
                                        nil,
                                        Elements.Create(
                                            "div",
                                            {vertical = true, spacing = 4, className = "p-4 bg-base02 rounded-lg"},
                                            Elements.Create(
                                                "div",
                                                {spacing = 16},
                                                Elements.Create(
                                                    "div",
                                                    {className = "text-base05"},
                                                    "💧 ",
                                                    v.current.relative_humidity_2m,
                                                    v.current_units.relative_humidity_2m
                                                ),
                                                Elements.Create(
                                                    "div",
                                                    {className = "text-base05"},
                                                    "☁️ ",
                                                    v.current.cloud_cover,
                                                    v.current_units.cloud_cover
                                                )
                                            ),
                                            Elements.Create(
                                                "div",
                                                {spacing = 16},
                                                Elements.Create(
                                                    "div",
                                                    {className = "text-base05"},
                                                    "💨 ",
                                                    v.current.wind_speed_10m,
                                                    " km/h"
                                                ),
                                                Elements.Create(
                                                    "div",
                                                    {className = "text-base05"},
                                                    "🧭",
                                                    getWindDirectionText(v.current.wind_direction_10m)
                                                )
                                            ),
                                            Elements.Create(
                                                "div",
                                                {spacing = 16},
                                                Elements.Create(
                                                    "div",
                                                    {className = "text-base05"},
                                                    "💨 Gusts: ",
                                                    v.current.wind_gusts_10m,
                                                    " km/h"
                                                ),
                                                Elements.Create(
                                                    "div",
                                                    {className = "text-base05"},
                                                    "☂️ ",
                                                    v.current.precipitation,
                                                    " ",
                                                    v.current_units.precipitation
                                                )
                                            )
                                        )
                                    ),
                                    Elements.Create(
                                        "div",
                                        {spacing = 16, className = "p-4 bg-base02 rounded-lg"},
                                        Elements.Create(
                                            "div",
                                            {vertical = true, spacing = 2},
                                            Elements.Create("div", {className = "text-base04"}, "MSL Pressure"),
                                            Elements.Create("div", {className = "text-base05 font-bold"}, v.current.pressure_msl, " hPa")
                                        ),
                                        Elements.Create(
                                            "div",
                                            {vertical = true, spacing = 2},
                                            Elements.Create("div", {className = "text-base04"}, "Surface Pressure"),
                                            Elements.Create("div", {className = "text-base05 font-bold"}, v.current.surface_pressure, " hPa")
                                        ),
                                        Elements.Create(
                                            "div",
                                            {vertical = true, spacing = 2},
                                            Elements.Create("div", {className = "text-base04"}, "Showers"),
                                            Elements.Create("div", {className = "text-base05 font-bold"}, v.current.showers, " mm")
                                        ),
                                        Elements.Create(
                                            "div",
                                            {vertical = true, spacing = 2},
                                            Elements.Create("div", {className = "text-base04"}, "Rain"),
                                            Elements.Create("div", {className = "text-base05 font-bold"}, v.current.rain, " mm")
                                        ),
                                        Elements.Create(
                                            "div",
                                            {vertical = true, spacing = 2},
                                            Elements.Create("div", {className = "text-base04"}, "Snowfall"),
                                            Elements.Create("div", {className = "text-base05 font-bold"}, v.current.snowfall, " cm")
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    Elements.Create(
                        "div",
                        {vertical = true, spacing = 8, className = "p-6 bg-base01 rounded-lg"},
                        Elements.Create("div", {className = "text-base05 text-xl font-bold mb-4"}, "Next 24 Hours"),
                        Elements.Create(
                            "scrollable",
                            {expand = true, vscroll = "NEVER"},
                            Elements.Create(
                                "div",
                                {spacing = 8, expand = true, className = "p-2"},
                                __TS__ArrayMap(
                                    __TS__ArraySlice(v.hourly.time, 0, 24),
                                    function(____, timestamp, idx)
                                        local ref = Variable(nil)
                                        return Elements.Create(
                                            Animate,
                                            {delay = 1000},
                                            Elements.Create(
                                                "div",
                                                {vertical = true, expand = true, spacing = 4, className = "p-4 bg-base02 rounded-lg min-w-[140px]"},
                                                Elements.Create(
                                                    "div",
                                                    {className = "text-base04 text-center font-bold"},
                                                    formatTime(timestamp)
                                                ),
                                                Elements.Create("div", {className = "text-3xl text-center text-base05"}, v.hourly.temperature_2m[idx + 1], "°"),
                                                Elements.Create(
                                                    "button",
                                                    {onClick = function()
                                                        local el = ref.get(ref)
                                                        if el ~= nil then
                                                            el.reveal_child = not el.reveal_child
                                                        end
                                                    end},
                                                    "More"
                                                ),
                                                Elements.Create(
                                                    "revealer",
                                                    {ref = ref},
                                                    Elements.Create(
                                                        "div",
                                                        {className = "text-base04 text-sm", expand = true, vertical = true, spacing = 2},
                                                        (("💧 Humidity: " .. tostring(v.hourly.relative_humidity_2m[idx + 1])) .. " ") .. v.hourly_units.relative_humidity_2m,
                                                        (("☔ Chance: " .. tostring(v.hourly.precipitation_probability[idx + 1])) .. " ") .. v.hourly_units.precipitation_probability,
                                                        (("🌧️ Amount: " .. tostring(v.hourly.precipitation[idx + 1])) .. " ") .. v.hourly_units.precipitation,
                                                        (("💨 Wind: " .. tostring(v.hourly.wind_speed_10m[idx + 1])) .. " ") .. v.hourly_units.wind_speed_10m,
                                                        (("👁️ Visibility: " .. tostring(math.floor(v.hourly.visibility[idx + 1] / 1000 + 0.5))) .. " ") .. v.hourly_units.visibility,
                                                        (("☁️ Cloud: " .. tostring(v.hourly.cloud_cover[idx + 1])) .. " ") .. v.hourly_units.cloud_cover
                                                    )
                                                )
                                            )
                                        )
                                    end
                                )
                            )
                        )
                    ),
                    Elements.Create(
                        "div",
                        {vertical = true, expand = true, spacing = 8, className = "p-6 bg-base01 rounded-lg"},
                        Elements.Create("div", {className = "text-base05 text-xl font-bold mb-4"}, "7-Day Forecast"),
                        Elements.Create(
                            "div",
                            {spacing = 16, expand = true},
                            Elements.Create(
                                "scrollable",
                                {expand = true, vscroll = "NEVER"},
                                Elements.Create(
                                    Elements.Fragment,
                                    nil,
                                    __TS__ArrayMap(
                                        v.daily.time,
                                        function(____, timestamp, idx)
                                            local ref = Variable(nil)
                                            ref.subscribe(
                                                ref,
                                                function(el) return el.hide(el) end
                                            )
                                            return Elements.Create(
                                                "div",
                                                {vertical = true, className = "p-6 px-6 mx-6 bg-base02 rounded-lg"},
                                                Elements.Create(
                                                    "p",
                                                    {expand = true, className = "text-base05 text-lg font-bold"},
                                                    formatDate(timestamp)
                                                ),
                                                Elements.Create(
                                                    "div",
                                                    {expand = true, spacing = 16},
                                                    Elements.Create(
                                                        "div",
                                                        {vertical = true, spacing = 4, className = "w-1/5"},
                                                        Elements.Create("p", {className = "text-base04"}, "Temperature"),
                                                        Elements.Create("p", {className = "text-base0D text-xl"}, v.daily.temperature_2m_max[idx + 1], "°"),
                                                        Elements.Create("p", {className = "text-base08 text-xl"}, v.daily.temperature_2m_min[idx + 1], "°"),
                                                        Elements.Create("div", {className = "text-base04"}, "Sun Times"),
                                                        Elements.Create(
                                                            "div",
                                                            {className = "text-base05"},
                                                            "☀️ ",
                                                            formatTime(v.daily.sunrise[idx + 1])
                                                        ),
                                                        Elements.Create(
                                                            "div",
                                                            {className = "text-base05"},
                                                            "🌙 ",
                                                            formatTime(v.daily.sunset[idx + 1])
                                                        ),
                                                        Elements.Create(
                                                            "button",
                                                            {onClick = function()
                                                                local el = ref.get(ref)
                                                                if el ~= nil then
                                                                    if not el.reveal_child then
                                                                        el.show(el)
                                                                    end
                                                                    el.reveal_child = not el.reveal_child
                                                                    if el.reveal_child then
                                                                        el.show(el)
                                                                    else
                                                                        astal.timeout(
                                                                            500,
                                                                            function() return el.hide(el) end
                                                                        )
                                                                    end
                                                                end
                                                            end},
                                                            "More"
                                                        )
                                                    ),
                                                    Elements.Create(
                                                        "revealer",
                                                        {ref = ref, visible = false, transition_duration = 500, transition_type = "SLIDE_RIGHT"},
                                                        Elements.Create(
                                                            "div",
                                                            {vertical = true, spacing = 4, className = "w-1/5"},
                                                            Elements.Create("div", {className = "text-base04"}, "UV & Light"),
                                                            Elements.Create("div", {className = "text-base05"}, "UV: ", v.daily.uv_index_max[idx + 1]),
                                                            Elements.Create(
                                                                "div",
                                                                {className = "text-base05"},
                                                                "Clear Sky UV:",
                                                                " ",
                                                                v.daily.uv_index_clear_sky_max[idx + 1]
                                                            ),
                                                            Elements.Create(
                                                                "div",
                                                                {className = "text-base05"},
                                                                "Sunshine:",
                                                                formatSeconds(v.daily.sunshine_duration[idx + 1])
                                                            ),
                                                            Elements.Create(
                                                                "div",
                                                                {className = "text-base05"},
                                                                "Daylight:",
                                                                formatSeconds(v.daily.daylight_duration[idx + 1])
                                                            )
                                                        ),
                                                        Elements.Create(
                                                            "div",
                                                            {vertical = true, spacing = 4, className = "w-1/5"},
                                                            Elements.Create("div", {className = "text-base04"}, "Precipitation"),
                                                            Elements.Create(
                                                                "div",
                                                                {className = "text-base05"},
                                                                "Rain: ",
                                                                v.daily.rain_sum[idx + 1],
                                                                " mm Showers:",
                                                                " ",
                                                                v.daily.showers_sum[idx + 1],
                                                                " mm Snow:",
                                                                " ",
                                                                v.daily.snowfall_sum[idx + 1],
                                                                " cm"
                                                            ),
                                                            Elements.Create("div", {className = "text-base04"}, "Wind & Radiation"),
                                                            Elements.Create(
                                                                "div",
                                                                {className = "text-base05"},
                                                                "Wind: ",
                                                                v.daily.wind_speed_10m_max[idx + 1],
                                                                " km/h Gusts: ",
                                                                v.daily.wind_gusts_10m_max[idx + 1],
                                                                " ",
                                                                "km/h"
                                                            ),
                                                            Elements.Create(
                                                                "div",
                                                                {className = "text-base05"},
                                                                "Radiation:",
                                                                " ",
                                                                v.daily.shortwave_radiation_sum[idx + 1],
                                                                "MJ/m²"
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        end
                                    )
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
