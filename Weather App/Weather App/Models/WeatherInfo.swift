//
//  WeatherInfo.swift
//  Weather App
//

import Foundation

struct WeatherInfo: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double?
    let utcOffsetSeconds: Int?
    let timezone: String?
    let timezoneAbbreviation: String?
    let elevation: Double?
    let current: CurrentWeather
    let currentUnits: CurrentWeatherUnits
    let hourly: HourlyData?
    let hourlyUnits: HourlyUnits?

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case current
        case currentUnits = "current_units"
        case hourly
        case hourlyUnits = "hourly_units"
    }
}

struct CurrentWeather: Decodable {
    let temperature2m: Double
    let windspeed: Double
    let winddirection: Double
    let weathercode: Int
    let time: String
    let interval: Int
    let isDay: Int

    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case windspeed
        case winddirection
        case weathercode
        case time
        case interval
        case isDay = "is_day"
    }
}

struct CurrentWeatherUnits: Decodable {
    let temperature2m: String
    let windspeed: String
    let winddirection: String
    let weathercode: String
    let time: String
    let isDay: String

    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case windspeed
        case winddirection
        case weathercode
        case time
        case isDay = "is_day"
    }
}


struct HourlyUnits: Decodable {
    let time: String
    let temperature2m: String
    let precipitationProbability: String
    let precipitation: String

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case precipitation
    }
}

struct HourlyData: Decodable {
    let time: [String]
    let temperature2m: [Double]?
    let precipitationProbability: [Int]?
    let precipitation: [Double]?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case precipitation
    }
}
