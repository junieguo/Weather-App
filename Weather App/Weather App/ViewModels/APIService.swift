//
//  APIService.swift
//  Weather App
//

import Foundation

class APIService {
    static func fetchLocation(query: String) async throws -> Location? {
        guard !query.isEmpty else {
            print("Error: Empty query")
            throw URLError(.badURL)
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://nominatim.openstreetmap.org/search?q=\(encodedQuery)&format=json&addressdetails=1"
        
        print("Geocoding API Request: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("WeatherApp/1.0 (contact@example.com)", forHTTPHeaderField: "User-Agent")
        
        // Add rate limiting delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug print raw response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Geocoding API Response: \(responseString.prefix(1000))...")
        }
        
        // Check response status code
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if !(200...299).contains(httpResponse.statusCode) {
                throw URLError(.badServerResponse)
            }
        }
        
        do {
            let decoder = JSONDecoder()
            let results = try decoder.decode([Location].self, from: data)
            print("Found \(results.count) locations")
            return results.first
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }

    static func fetchWeather(for location: Location) async throws -> WeatherInfo {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&hourly=temperature_2m,precipitation_probability,precipitation&temperature_unit=fahrenheit&forecast_days=1"
        
        print("Weather API Request: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid Weather API URL")
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Debug print raw response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Weather API Response: \(responseString.prefix(500))...")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(WeatherInfo.self, from: data)
    }
}
