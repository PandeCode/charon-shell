import {
  astal,
  Elements,
  Variable,
  removeCache,
  useFetchCache,
  useReFetchCache,
} from "../../../tslib/react";
import Animate from "../../components/animate";
const { inspect, ninspect } = require("lua.utils.init");
const {
  formatTime,
  formatHour,
  formatDate,
} = require("lua.utils.astal");

const json = require("dkjson");

const WEATHER_URL = `https://api.open-meteo.com/v1/forecast?latitude=9.936855359783848&longitude=-84.18010736600566&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,uv_index_clear_sky_max,sunshine_duration,daylight_duration,rain_sum,showers_sum,snowfall_sum,wind_speed_10m_max,wind_gusts_10m_max,shortwave_radiation_sum&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,visibility,cloud_cover,surface_pressure,apparent_temperature,precipitation_probability,precipitation&current=temperature_2m,apparent_temperature,relative_humidity_2m,is_day,precipitation,showers,rain,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=auto&timeformat=unixtime`;

const getWeatherIcon = (code: number, isDay: number) => {
  if (code <= 3) return isDay != 0 ? "☀️" : "🌙";
  if (code <= 48) return "☁️";
  if (code <= 67) return "🌧️";
  if (code <= 77) return "❄️";
  if (code <= 82) return "🌧️";
  if (code <= 86) return "🌨️";
  if (code <= 99) return "⛈️";
  return "?";
};

const getWindDirectionText = (degree: number) => {
  const directions = [
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
    "NNW",
  ];
  const index = Math.round(degree / 22.5) % 16;
  return directions[index];
};

const formatSeconds = (seconds: number) => {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  return `${hours}h ${minutes}m`;
};

export default function () {
  let data = useFetchCache<Weather>(WEATHER_URL, json.decode);

  return (
    <>
      {data._v((v?: Weather) => {
        if (v == null)
          return (
            <div expand halign="CENTER" valign="CENTER" className="text-base05">
              Loading
            </div>
          );
        return (
          <scrollable hscroll="NEVER" expand>
            <div vertical spacing={16} className="p-4 bg-base00">
              {/* Header with Location Info */}
              <div spacing={8} className="p-4 bg-base01 rounded-lg">
                <div vertical>
                  <div vertical className="text-base05 text-2xl font-bold">
                    Weather Dashboard
                  </div>
                  <div valign="FILL" className="text-base04" vertical>
                    <>{`${v.timezone} (${v.timezone_abbreviation})`}</>
                    <>{`Lat: ${v.latitude.toFixed(4)}° Long: ${v.longitude.toFixed(4)}°`}</>
                    <>{`Elevation: ${v.elevation}m`}</>
                    <div className="text-base04">
                      Updated: {formatTime(v.current.time)}
                    </div>
                  </div>
                  <button
                    onClick={() => {
                      data._v.set(data._v, null);
                      removeCache(WEATHER_URL);
                      useReFetchCache<Weather>(data, WEATHER_URL, json.decode);
                    }}
                    className="p-2 bg-base03 text-base05 rounded mt-2"
                  >
                    Refresh Data
                  </button>
                </div>
                <div spacing={16}>
                  <div
                    expand
                    vertical
                    spacing={8}
                    className="p-4 bg-base02 rounded-lg"
                  >
                    <div spacing={12}>
                      <div className="text-5xl font-bold text-base0B">
                        {getWeatherIcon(
                          v.current.weather_code,
                          v.current.is_day,
                        )}
                      </div>
                      <div vertical>
                        <div className="text-5xl font-bold text-base05">
                          {v.current.temperature_2m}°C
                        </div>
                        <div className="text-base04">
                          Feels like: {v.current.apparent_temperature}°C
                        </div>
                      </div>

                      <div>
                        <div
                          vertical
                          spacing={4}
                          className="p-4 bg-base02 rounded-lg"
                        >
                          <div spacing={16}>
                            <div className="text-base05">
                              💧 {v.current.relative_humidity_2m}
                              {v.current_units.relative_humidity_2m}
                            </div>
                            <div className="text-base05">
                              ☁️ {v.current.cloud_cover}
                              {v.current_units.cloud_cover}
                            </div>
                          </div>
                          <div spacing={16}>
                            <div className="text-base05">
                              💨 {v.current.wind_speed_10m} km/h
                            </div>
                            <div className="text-base05">
                              🧭
                              {getWindDirectionText(
                                v.current.wind_direction_10m,
                              )}
                            </div>
                          </div>
                          <div spacing={16}>
                            <div className="text-base05">
                              💨 Gusts: {v.current.wind_gusts_10m} km/h
                            </div>
                            <div className="text-base05">
                              ☂️ {v.current.precipitation}{" "}
                              {v.current_units.precipitation}
                            </div>
                          </div>
                        </div>
                      </div>
                      <div spacing={16} className="p-4 bg-base02 rounded-lg">
                        <div vertical spacing={2}>
                          <div className="text-base04">MSL Pressure</div>
                          <div className="text-base05 font-bold">
                            {v.current.pressure_msl} hPa
                          </div>
                        </div>
                        <div vertical spacing={2}>
                          <div className="text-base04">Surface Pressure</div>
                          <div className="text-base05 font-bold">
                            {v.current.surface_pressure} hPa
                          </div>
                        </div>
                        <div vertical spacing={2}>
                          <div className="text-base04">Showers</div>
                          <div className="text-base05 font-bold">
                            {v.current.showers} mm
                          </div>
                        </div>
                        <div vertical spacing={2}>
                          <div className="text-base04">Rain</div>
                          <div className="text-base05 font-bold">
                            {v.current.rain} mm
                          </div>
                        </div>
                        <div vertical spacing={2}>
                          <div className="text-base04">Snowfall</div>
                          <div className="text-base05 font-bold">
                            {v.current.snowfall} cm
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Hourly Forecast (next 24 hours) */}
              <div vertical spacing={8} className="p-6 bg-base01 rounded-lg">
                <div className="text-base05 text-xl font-bold mb-4">
                  Next 24 Hours
                </div>
                <scrollable expand vscroll="NEVER">
                  <div spacing={8} expand className="p-2">
                    {v.hourly.time.slice(0, 24).map((timestamp, idx) => {
                      const ref = Variable(null);
                      return (
                        <Animate delay={1000}>
                          <div
                            vertical
                            expand
                            spacing={4}
                            className="p-4 bg-base02 rounded-lg min-w-[140px]"
                          >
                            <div className="text-base04 text-center font-bold">
                              {formatTime(timestamp)}
                            </div>
                            <div className="text-3xl text-center text-base05">
                              {v.hourly.temperature_2m[idx]}°
                            </div>
                            <button
                              onClick={() => {
                                const el = ref.get(ref);
                                if (el != null) {
                                  el.reveal_child = !el.reveal_child;
                                }
                              }}
                            >
                              More
                            </button>
                            <revealer ref={ref}>
                              <div
                                className="text-base04 text-sm"
                                expand
                                vertical
                                spacing={2}
                              >
                                {`💧 Humidity: ${v.hourly.relative_humidity_2m[idx]} ${v.hourly_units.relative_humidity_2m}`}
                                {`☔ Chance: ${v.hourly.precipitation_probability[idx]} ${v.hourly_units.precipitation_probability}`}
                                {`🌧️ Amount: ${v.hourly.precipitation[idx]} ${v.hourly_units.precipitation}`}
                                {`💨 Wind: ${v.hourly.wind_speed_10m[idx]} ${v.hourly_units.wind_speed_10m}`}
                                {`👁️ Visibility: ${Math.round(v.hourly.visibility[idx] / 1000)} ${v.hourly_units.visibility}`}
                                {`☁️ Cloud: ${v.hourly.cloud_cover[idx]} ${v.hourly_units.cloud_cover}`}
                              </div>
                            </revealer>
                          </div>
                        </Animate>
                      );
                    })}
                  </div>
                </scrollable>
              </div>

              {/* 7-Day Forecast with Enhanced Metrics */}
              <div
                vertical
                expand
                spacing={8}
                className="p-6 bg-base01 rounded-lg"
              >
                <div className="text-base05 text-xl font-bold mb-4">
                  7-Day Forecast
                </div>
                <div spacing={16} expand>
                  <scrollable expand vscroll="NEVER">
                    <>
                      {v.daily.time.map((timestamp, idx) => {
                        const ref = Variable(null);

                        ref.subscribe(ref, (el: any) => el.hide(el));

                        return (
                          <div
                            vertical
                            className="p-6 px-6 mx-6 bg-base02 rounded-lg"
                          >
                            <p expand className="text-base05 text-lg font-bold">
                              {formatDate(timestamp)}
                            </p>

                            <div expand spacing={16}>
                              <div vertical spacing={4} className="w-1/5">
                                <p className="text-base04">Temperature</p>
                                <p className="text-base0D text-xl">
                                  {v.daily.temperature_2m_max[idx]}°
                                </p>
                                <p className="text-base08 text-xl">
                                  {v.daily.temperature_2m_min[idx]}°
                                </p>

                                <div className="text-base04">Sun Times</div>
                                <div className="text-base05">
                                  ☀️ {formatTime(v.daily.sunrise[idx])}
                                </div>
                                <div className="text-base05">
                                  🌙 {formatTime(v.daily.sunset[idx])}
                                </div>
                                <button
                                  onClick={() => {
                                    const el = ref.get(ref);
                                    if (el != null) {
                                      if (!el.reveal_child) el.show(el);

                                      el.reveal_child = !el.reveal_child;

                                      if (el.reveal_child) el.show(el);
                                      else
                                        astal.timeout(500, () => el.hide(el));
                                    }
                                  }}
                                >
                                  More
                                </button>
                              </div>

                              <revealer
                                ref={ref}
                                visible={false}
                                transition_duration={500}
                                transition_type={"SLIDE_RIGHT"}
                              >
                                <div vertical spacing={4} className="w-1/5">
                                  <div className="text-base04">UV & Light</div>
                                  <div className="text-base05">
                                    UV: {v.daily.uv_index_max[idx]}
                                  </div>
                                  <div className="text-base05">
                                    Clear Sky UV:{" "}
                                    {v.daily.uv_index_clear_sky_max[idx]}
                                  </div>
                                  <div className="text-base05">
                                    Sunshine:
                                    {formatSeconds(
                                      v.daily.sunshine_duration[idx],
                                    )}
                                  </div>
                                  <div className="text-base05">
                                    Daylight:
                                    {formatSeconds(
                                      v.daily.daylight_duration[idx],
                                    )}
                                  </div>
                                </div>

                                <div vertical spacing={4} className="w-1/5">
                                  <div className="text-base04">
                                    Precipitation
                                  </div>
                                  <div className="text-base05">
                                    Rain: {v.daily.rain_sum[idx]} mm Showers:{" "}
                                    {v.daily.showers_sum[idx]} mm Snow:{" "}
                                    {v.daily.snowfall_sum[idx]} cm
                                  </div>
                                  <div className="text-base04">
                                    Wind & Radiation
                                  </div>
                                  <div className="text-base05">
                                    Wind: {v.daily.wind_speed_10m_max[idx]} km/h
                                    Gusts: {v.daily.wind_gusts_10m_max[idx]}{" "}
                                    km/h
                                  </div>
                                  <div className="text-base05">
                                    Radiation:{" "}
                                    {v.daily.shortwave_radiation_sum[idx]}
                                    MJ/m²
                                  </div>
                                </div>
                              </revealer>
                            </div>
                          </div>
                        );
                      })}
                    </>
                  </scrollable>
                </div>
              </div>
            </div>
          </scrollable>
        );
      })}
    </>
  );
}
