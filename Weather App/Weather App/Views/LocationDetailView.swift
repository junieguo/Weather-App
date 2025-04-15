//
//  LocationDetailView.swift
//  Weather App
//

import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var weatherInfo: WeatherInfo?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Location header
                VStack(alignment: .leading) {
                    Text(location.displayName)
                        .font(.title)
                        .bold()
                    
                    if let address = location.address {
                        HStack {
                            if let city = address.city {
                                Text(city)
                            }
                            if let state = address.state {
                                Text(state)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                // Favorite button
                Button {
                    if viewModel.isFavorited(location) {
                        viewModel.removeFavorite(location)
                    } else {
                        viewModel.addFavorite(location)
                    }
                } label: {
                    Label(
                        viewModel.isFavorited(location) ? "Remove Favorite" : "Add Favorite",
                        systemImage: viewModel.isFavorited(location) ? "heart.fill" : "heart"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(viewModel.isFavorited(location) ? .red : .blue)
                
                // Weather data
                if let weatherInfo = weatherInfo {
                    if let currentWeather = weatherInfo.currentWeather {
                        WeatherCardView(
                            temperature: currentWeather.temperature,
                            precipitation: weatherInfo.hourly?.precipitation?.first ?? 0,
                            precipitationProbability: weatherInfo.hourly?.precipitationProbability?.first ?? 0,
                            temperatureUnit: weatherInfo.currentWeatherUnits?.temperature ?? "°F",
                            precipitationUnit: weatherInfo.hourlyUnits?.precipitation ?? "mm",
                            weatherCode: currentWeather.weathercode,
                            isDay: currentWeather.isDay == 1
                        )
                    } else {
                        Text("Current weather data unavailable")
                            .foregroundColor(.secondary)
                    }
                } else if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Location Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadWeather()
        }
    }
    
    private func loadWeather() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("Fetching weather for location: \(location.displayName) (\(location.lat), \(location.lon))")
            weatherInfo = try await APIService.fetchWeather(for: location)
            print("Successfully fetched weather data")
        } catch {
            errorMessage = "Failed to load weather data"
            print("Weather fetch error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

struct WeatherCardView: View {
    let temperature: Double
    let precipitation: Double
    let precipitationProbability: Int
    let temperatureUnit: String
    let precipitationUnit: String
    let weatherCode: Int
    let isDay: Bool
    
    var weatherIcon: String {
        switch weatherCode {
        case 0: return isDay ? "sun.max.fill" : "moon.fill"
        case 1, 2, 3: return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51...67: return "cloud.rain.fill"
        case 71...77: return "cloud.snow.fill"
        case 80...86: return "cloud.heavyrain.fill"
        case 95...99: return "cloud.bolt.rain.fill"
        default: return "questionmark.circle"
        }
    }
    
    var weatherDescription: String {
        switch weatherCode {
        case 0: return isDay ? "Clear sky" : "Clear night"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Foggy"
        case 51...55: return "Drizzle"
        case 56...57: return "Freezing drizzle"
        case 61...65: return "Rain"
        case 66...67: return "Freezing rain"
        case 71...75: return "Snow fall"
        case 77: return "Snow grains"
        case 80...82: return "Rain showers"
        case 85...86: return "Snow showers"
        case 95...99: return "Thunderstorm"
        default: return "Unknown weather"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: weatherIcon)
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("Current Weather")
                        .font(.headline)
                    Text(weatherDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Temperature")
                        .font(.subheadline)
                    Text("\(temperature, specifier: "%.1f")\(temperatureUnit)")
                        .font(.title)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Precipitation")
                        .font(.subheadline)
                    Text("\(precipitation, specifier: "%.1f")\(precipitationUnit)")
                        .font(.title)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Probability")
                        .font(.subheadline)
                    Text("\(precipitationProbability)%")
                        .font(.title)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
