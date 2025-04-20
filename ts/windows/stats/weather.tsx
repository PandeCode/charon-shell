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
const {
  formatTime,
  formatHour,
  formatDate,
} = require("../../../lua/utils/astal.lua");

const json = require("dkjson");

const WEATHER_URL = `https://api.open-meteo.com/v1/forecast?latitude=9.936855359783848&longitude=-84.18010736600566&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,uv_index_clear_sky_max,sunshine_duration,daylight_duration,rain_sum,showers_sum,snowfall_sum,wind_speed_10m_max,wind_gusts_10m_max,shortwave_radiation_sum&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,visibility,cloud_cover,surface_pressure,apparent_temperature,precipitation_probability,precipitation&current=temperature_2m,apparent_temperature,relative_humidity_2m,is_day,precipitation,showers,rain,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=auto&timeformat=unixtime`;

export default function () {
  const data = useFetchCache<Weather>(WEATHER_URL, json.decode);

  function windDir(deg: number) {
    const dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
    return dirs[Math.round(deg / 45) % 8];
  }

  return (
    <>
      {data._v((v: Weather) => {
        if (!v) return <></>;

        return (
          <div vertical spacing={4} className="bg-base01 text-base05 p-4">
            <grid row-spacing={10} column-spacing={10}>
              <griditem w={12} h={3} x={0} y={0}>
                <div vertical spacing={1} className="bg-base02 p-3 rounded-lg">
                  <div className="text-base0C text-xl">Current Weather</div>
                  <div vertical spacing={1}>
                    <div>Time: {formatTime(v.current.time)}</div>
                    <div>
                      Temp: {v.current.temperature_2m}
                      {v.current_units.temperature_2m}
                    </div>
                    <div>
                      Feels Like: {v.current.apparent_temperature}
                      {v.current_units.apparent_temperature}
                    </div>
                    <div>
                      Humidity: {v.current.relative_humidity_2m}
                      {v.current_units.relative_humidity_2m}
                    </div>
                    <div>
                      Wind: {v.current.wind_speed_10m}
                      {v.current_units.wind_speed_10m}{" "}
                      {windDir(v.current.wind_direction_10m)}
                    </div>
                  </div>
                </div>
              </griditem>

              <griditem w={12} h={3} x={0} y={3}>
                <div vertical spacing={1} className="bg-base02 p-3 rounded-lg">
                  <div className="text-base0C text-xl">Hourly Forecast</div>
                  <grid row-spacing={10} column-spacing={10}>
                    {v.hourly.time.slice(0, 12).map((t, i) => (
                      <griditem w={1} h={1} x={i} y={0}>
                        <div vertical spacing={1} className="p-1">
                          <p className="text-base07">{formatHour(t)}</p>
                          <div vertical className="text-base0A">
                            {v.hourly.temperature_2m[i]}
                            {v.hourly.relative_humidity_2m[i]}
                            {v.hourly.wind_speed_10m[i]}
                            {v.hourly.visibility[i]}
                            {v.hourly.cloud_cover[i]}
                            {v.hourly.surface_pressure[i]}
                            {v.hourly.apparent_temperature[i]}
                            {v.hourly.precipitation_probability[i]}
                            {v.hourly.precipitation[i]}
                          </div>
                        </div>
                      </griditem>
                    ))}
                  </grid>
                </div>
              </griditem>

              <griditem w={12} h={2} x={0} y={6}>
                <div vertical spacing={1} className="bg-base02 p-3 rounded-lg">
                  <div className="text-base0C text-xl">Daily Forecast</div>
                  <grid row-spacing={10} column-spacing={10}>
                    {v.daily.time.slice(0, 7).map((t, i) => (
                      <griditem w={1} h={1} x={i} y={0}>
                        <div vertical spacing={1}>
                          <div className="text-base07">{formatDate(t)}</div>
                          <div className="text-base0A">
                            H {v.daily.temperature_2m_max[i]}° L{" "}
                            {v.daily.temperature_2m_min[i]}°
                          </div>
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
