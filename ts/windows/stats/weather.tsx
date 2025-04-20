import {
  astal,
  Gtk,
  Elements,
  useState,
  useEffect,
  useFile,
  useCmd,
  Variable,
  useFetchCache,
} from "../../../tslib/react";
const { inspect, ninspect } = require("../../../lua/utils/init.lua");

const json = require("dkjson");

const WEATHER_URL = `https://api.open-meteo.com/v1/forecast?latitude=9.936855359783848&longitude=-84.18010736600566&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,uv_index_clear_sky_max,sunshine_duration,daylight_duration,rain_sum,showers_sum,snowfall_sum,wind_speed_10m_max,wind_gusts_10m_max,shortwave_radiation_sum&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,visibility,cloud_cover,surface_pressure,apparent_temperature,precipitation_probability,precipitation&current=temperature_2m,apparent_temperature,relative_humidity_2m,is_day,precipitation,showers,rain,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=auto&timeformat=unixtime`;

export default function () {
  const data = useFetchCache<Weather>(WEATHER_URL, json.decode);

  // Helpers
  function formatTime(ts: number) {
    return "impl";
    // return new Date(ts * 1000).toLocaleTimeString();
  }
  function formatHour(ts: number) {
    // return `${new Date(ts * 1000).getHours()}:00`;
    return "impl";
  }
  function formatDate(ts: number) {
    // return new Date(ts * 1000).toLocaleDateString();
    return "impl";
  }
  function windDir(deg: number) {
    const dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
    return dirs[Math.round(deg / 45) % 8];
  }

  return (
    <>
      {data._v((v: Weather) => {
        if (!v) return <></>;

        return (
          <div
            vertical={true}
            spacing={4}
            className="bg-base01 text-base05 p-4"
          >
            <grid row-spacing={10} column-spacing={10}>
              <griditem w={12} h={3} x={0} y={0}>
                <div
                  vertical={true}
                  spacing={1}
                  className="bg-base02 p-3 rounded-lg"
                >
                  <p className="text-base0C text-xl">Current Weather</p>
                  <div vertical={true} spacing={1}>
                    <p>Time: {formatTime(v.current.time)}</p>
                    <p>
                      Temp: {v.current.temperature_2m}
                      {v.current_units.temperature_2m}
                    </p>
                    <p>
                      Feels Like: {v.current.apparent_temperature}
                      {v.current_units.apparent_temperature}
                    </p>
                    <p>
                      Humidity: {v.current.relative_humidity_2m}
                      {v.current_units.relative_humidity_2m}
                    </p>
                    <p>
                      Wind: {v.current.wind_speed_10m}
                      {v.current_units.wind_speed_10m}{" "}
                      {windDir(v.current.wind_direction_10m)}
                    </p>
                  </div>
                </div>
              </griditem>

              <griditem w={12} h={3} x={0} y={3}>
                <div
                  vertical={true}
                  spacing={1}
                  className="bg-base02 p-3 rounded-lg"
                >
                  <p className="text-base0C text-xl">Hourly Forecast</p>
                  <grid>
                    {v.hourly.time.slice(0, 12).map((t, i) => (
                      <griditem w={1} h={1} x={i} y={0}>
                        <div vertical={true} spacing={1} className="p-1">
                          <p className="text-base07">{formatHour(t)}</p>
                          <p className="text-base0A">
                            {v.hourly.temperature_2m[i]}°
                          </p>
                        </div>
                      </griditem>
                    ))}
                  </grid>
                </div>
              </griditem>

              <griditem w={12} h={2} x={0} y={6}>
                <div
                  vertical={true}
                  spacing={1}
                  className="bg-base02 p-3 rounded-lg"
                >
                  <p className="text-base0C text-xl">Daily Forecast</p>
                  <grid>
                    {v.daily.time.slice(0, 7).map((t, i) => (
                      <griditem w={1} h={1} x={i} y={0}>
                        <div vertical={true} spacing={1}>
                          <p className="text-base07">{formatDate(t)}</p>
                          <p className="text-base0A">
                            H {v.daily.temperature_2m_max[i]}° L{" "}
                            {v.daily.temperature_2m_min[i]}°
                          </p>
                        </div>
                      </griditem>
                    ))}
                  </grid>
                </div>
              </griditem>
            </grid>
          </div>
        );
      })}
    </>
  );
}
