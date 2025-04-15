//
//  WeatherInfo.swift
//  Weather App
//

import Foundation

struct WeatherInfo: Decodable {
    let latitude: Double
    let longitude: Double
    let hourlyUnits: HourlyUnits
    let hourly: HourlyData
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case hourlyUnits = "hourly_units"
        case hourly
    }
    
    func currentWeatherIndex() -> Int? {
        let now = Date()
        let dateFormatter = ISO8601DateFormatter()
        
        for (index, timeString) in hourly.time.enumerated() {
            if let date = dateFormatter.date(from: timeString),
               Calendar.current.isDate(date, equalTo: now, toGranularity: .hour) {
                return index
            }
        }
        return nil
    }
}

struct HourlyUnits: Decodable {
    let temperature_2m: String
    let precipitation_probability: String
    let precipitation: String
}

struct HourlyData: Decodable {
    let time: [String]
    let temperature_2m: [Double]
    let precipitation_probability: [Int]
    let precipitation: [Double]
}
