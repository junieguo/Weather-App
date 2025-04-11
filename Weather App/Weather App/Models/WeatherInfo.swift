//
//  WeatherInfo.swift
//  Weather App
//

import Foundation

struct WeatherInfo: Decodable {
    let hourly_units: HourlyUnits
    let data: WeatherData

    enum CodingKeys: String, CodingKey {
        case hourly_units
        case data = "hourly"
    }
}

struct HourlyUnits: Decodable {
    let temperature: String
    let precipitation_probability: String
    let precipitation: String

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case precipitation_probability
        case precipitation
    }
}

struct WeatherData: Decodable {
    let time: [Date]
    let temperature: [Double]
    let precipitation_probability: [Int]
    let precipitation: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case precipitation_probability
        case precipitation
    }
}
