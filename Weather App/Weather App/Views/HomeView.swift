//
//  HomeView.swift
//  Weather App
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var query: String = ""
    @State private var selectedLocation: Location?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Weather App")
                    .font(.largeTitle)
                    .bold()

                TextField("Enter city or address", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button("Search") {
                    Task {
                        await searchLocation()
                    }
                }
                .disabled(query.isEmpty)

                if isLoading {
                    ProgressView()
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                List {
                    Section(header: Text("Favorites")) {
                        ForEach(viewModel.favorites) { location in
                            NavigationLink(destination: LocationDetailView(location: location)) {
                                Text(location.display_name)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)

                Spacer()
            }
            .padding()
            .navigationDestination(item: $selectedLocation) { location in
                LocationDetailView(location: location)
            }
        }
    }

    private func searchLocation() async {
        isLoading = true
        errorMessage = nil
        do {
            if let location = try await APIService.fetchLocation(query: query) {
                selectedLocation = location
            } else {
                errorMessage = "No matching location found."
            }
        } catch {
            errorMessage = "Failed to fetch location: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
