//
//  LocationDetailView.swift
//  Weather App
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    let location: Location
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var weatherInfo: WeatherInfo?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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

                if let weatherInfo = weatherInfo {
                    WeatherCardView(
                        temperature: weatherInfo.current.temperature2m,
                        precipitation: weatherInfo.hourly?.precipitation?.first ?? 0,
                        precipitationProbability: weatherInfo.hourly?.precipitationProbability?.first ?? 0,
                        temperatureUnit: weatherInfo.currentUnits.temperature2m,
                        precipitationUnit: weatherInfo.hourlyUnits?.precipitation ?? "mm",
                        weatherCode: weatherInfo.current.weathercode,
                        isDay: weatherInfo.current.isDay == 1
                    )
                } else if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                }

                MapView(latitude: location.latitude, longitude: location.longitude)

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
        case 51...67: return "cloud.drizzle.fill"
        case 71...77: return "cloud.snow.fill"
        case 80...86: return "cloud.heavyrain.fill"
        case 95...99: return "cloud.bolt.rain.fill"
        default: return "questionmark.circle"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: weatherIcon)
                    .font(.largeTitle)
                Text("Current Weather")
                    .font(.headline)
            }

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

