//
//  LocationDetailView.swift
//  Weather App
//

import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var weather: WeatherInfo?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text(location.display_name)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)

            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if let weather = weather {
                let index = currentHourIndex(from: weather.data.time)
                if index < weather.data.temperature.count {
                    Text("Temperature: \(weather.data.temperature[index], specifier: "%.1f")°\(weather.hourly_units.temperature)")
                    Text("Precipitation: \(weather.data.precipitation[index], specifier: "%.1f") \(weather.hourly_units.precipitation)")
                    Text("Precip. Probability: \(weather.data.precipitation_probability[index])\(weather.hourly_units.precipitation_probability)")
                }
            }

            Button(viewModel.isFavorited(location) ? "Unfavorite" : "Favorite") {
                if viewModel.isFavorited(location) {
                    viewModel.removeFavorite(location)
                } else {
                    viewModel.addFavorite(location)
                }
            }
            .padding()
            .background(viewModel.isFavorited(location) ? Color.red : Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())

            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await fetchWeather()
            }
        }
    }

    private func fetchWeather() async {
        do {
            self.weather = try await APIService.fetchWeather(for: location)
        } catch {
            self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
        }
        self.isLoading = false
    }

    private func currentHourIndex(from times: [Date]) -> Int {
        let now = Date()
        if let index = times.firstIndex(where: { Calendar.current.component(.hour, from: $0) == Calendar.current.component(.hour, from: now) }) {
            return index
        }
        return 0
    }
}
