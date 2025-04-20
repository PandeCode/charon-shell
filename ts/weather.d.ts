declare interface Weather {
  readonly latitude: number;
  readonly longitude: number;
  readonly generationtime_ms: number;
  readonly utc_offset_seconds: number;
  readonly timezone: string;
  readonly timezone_abbreviation: string;
  readonly elevation: number;
  readonly current_units: CurrentUnits;
  readonly current: {
    time: number;
    interval: number;
    temperature_2m: number;
    apparent_temperature: number;
    relative_humidity_2m: number;
    is_day: number;
    precipitation: number;
    showers: number;
    rain: number;
    snowfall: number;
    weather_code: number;
    cloud_cover: number;
    pressure_msl: number;
    surface_pressure: number;
    wind_speed_10m: number;
    wind_direction_10m: number;
    wind_gusts_10m: number;
  };
  readonly hourly_units: HourlyUnits;
  readonly hourly: Hourly;
  readonly daily_units: DailyUnits;
  readonly daily: {
    time: number[];
    temperature_2m_max: number[];
    temperature_2m_min: number[];
    sunrise: number[];
    sunset: number[];
    uv_index_max: number[];
    uv_index_clear_sky_max: number[];
    sunshine_duration: number[];
    daylight_duration: number[];
    rain_sum: number[];
    showers_sum: number[];
    snowfall_sum: number[];
    wind_speed_10m_max: number[];
    wind_gusts_10m_max: number[];
    shortwave_radiation_sum: number[];
  };
}

declare interface CurrentUnits {
  readonly time: string;
  readonly interval: string;
  readonly temperature_2m: string;
  readonly apparent_temperature: string;
  readonly relative_humidity_2m: string;
  readonly is_day: string;
  readonly precipitation: string;
  readonly showers: string;
  readonly rain: string;
  readonly snowfall: string;
  readonly weather_code: string;
  readonly cloud_cover: string;
  readonly pressure_msl: string;
  readonly surface_pressure: string;
  readonly wind_speed_10m: string;
  readonly wind_direction_10m: string;
  readonly wind_gusts_10m: string;
}

declare interface DailyUnits {
  readonly time: string;
  readonly temperature_2m_max: string;
  readonly temperature_2m_min: string;
  readonly sunrise: string;
  readonly sunset: string;
  readonly uv_index_max: string;
  readonly uv_index_clear_sky_max: string;
  readonly sunshine_duration: string;
  readonly daylight_duration: string;
  readonly rain_sum: string;
  readonly showers_sum: string;
  readonly snowfall_sum: string;
  readonly wind_speed_10m_max: string;
  readonly wind_gusts_10m_max: string;
  readonly shortwave_radiation_sum: string;
}

declare interface Hourly {
  readonly time: number[];
  readonly temperature_2m: number[];
  readonly relative_humidity_2m: number[];
  readonly wind_speed_10m: number[];
  readonly visibility: number[];
  readonly cloud_cover: number[];
  readonly surface_pressure: number[];
  readonly apparent_temperature: number[];
  readonly precipitation_probability: number[];
  readonly precipitation: number[];
}

declare interface HourlyUnits {
  readonly time: string;
  readonly temperature_2m: string;
  readonly relative_humidity_2m: string;
  readonly wind_speed_10m: string;
  readonly visibility: string;
  readonly cloud_cover: string;
  readonly surface_pressure: string;
  readonly apparent_temperature: string;
  readonly precipitation_probability: string;
  readonly precipitation: string;
}
