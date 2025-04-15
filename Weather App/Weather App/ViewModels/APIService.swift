//
//  APIService.swift
//  Weather App
//

import Foundation

class APIService {
    static let shared = APIService()
    private let cache = NSCache<NSString, NSData>()
    
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
        
        // Add rate limiting delay (Nominatim requires at least 1 second between requests)
        try await Task.sleep(nanoseconds: 1_100_000_000)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug print raw response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Geocoding API Response: \(responseString.prefix(500))...")
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
        let cacheKey = "weather_\(location.latitude)_\(location.longitude)" as NSString
        
        // Check cache first
        if let cachedData = shared.cache.object(forKey: cacheKey) as Data? {
            print("Using cached weather data")
            return try decodeWeatherData(cachedData)
        }
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&current_weather=true&hourly=temperature_2m,precipitation_probability,precipitation&temperature_unit=fahrenheit&forecast_days=1&timezone=auto"
        
        print("Weather API Request: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid Weather API URL")
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 10
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug logging
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 429 {
                throw URLError(.resourceUnavailable)
            }
        }
        
        // Cache the response
        shared.cache.setObject(data as NSData, forKey: cacheKey)
        
        return try decodeWeatherData(data)
    }
    
    private static func decodeWeatherData(_ data: Data) throws -> WeatherInfo {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let weatherInfo = try decoder.decode(WeatherInfo.self, from: data)
            print("Successfully decoded weather data")
            return weatherInfo
        } catch let DecodingError.keyNotFound(key, context) {
            print("Failed to decode due to missing key: \(key.stringValue)")
            print("Debug description: \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(jsonString.prefix(1000))")
            }
            throw WeatherError.decodingFailed
        } catch {
            print("Decoding failed: \(error)")
            throw error
        }
    }
}

enum WeatherError: Error {
    case decodingFailed
    case invalidResponse
    case rateLimited
}
