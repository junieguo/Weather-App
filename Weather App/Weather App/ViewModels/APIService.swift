//
//  APIService.swift
//  Weather App
//

import Foundation

class APIService {
    static func fetchLocation(query: String) async throws -> Location? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://nominatim.openstreetmap.org/search?q=\(encodedQuery)&addressdetails=1&format=json"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let results = try decoder.decode([Location].self, from: data)

        return results.first
    }

    static func fetchWeather(for location: Location) async throws -> WeatherInfo {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(location.lat)&longitude=\(location.lon)&hourly=temperature_2m,precipitation_probability,precipitation&temperature_unit=fahrenheit&forecast_days=1"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(WeatherInfo.self, from: data)
    }
}
