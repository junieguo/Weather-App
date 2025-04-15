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
                    if let currentIndex = weatherInfo.currentWeatherIndex() {
                        WeatherCardView(
                            temperature: weatherInfo.hourly.temperature_2m[currentIndex],
                            precipitation: weatherInfo.hourly.precipitation[currentIndex],
                            precipitationProbability: weatherInfo.hourly.precipitation_probability[currentIndex],
                            temperatureUnit: weatherInfo.hourlyUnits.temperature_2m,
                            precipitationUnit: weatherInfo.hourlyUnits.precipitation
                        )
                    } else {
                        Text("Current weather data not available")
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
            errorMessage = "Failed to load weather data: \(error.localizedDescription)"
            print("Weather fetch error: \(error)")
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Weather")
                .font(.headline)
            
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
