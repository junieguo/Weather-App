//
//  HomeView.swift
//  Weather App
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @StateObject private var locationManager = LocationManager()

    @State private var query: String = ""
    @State private var selectedLocation: Location?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private func isValidQuery(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count >= 2
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Weather App")
                    .font(.largeTitle)
                    .bold()

                TextField("Enter city or address", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)

                HStack {
                    Button("Search") {
                        Task { await searchLocation() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidQuery(query))

                    Button("Use Current Location") {
                        locationManager.requestLocation()
                    }
                    .buttonStyle(.bordered)
                }

                if isLoading {
                    ProgressView()
                        .padding()
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }

                List {
                    Section(header: Text("Favorites")) {
                        ForEach(viewModel.favorites) { location in
                            NavigationLink(destination: LocationDetailView(location: location)) {
                                VStack(alignment: .leading) {
                                    Text(location.displayName)
                                    if let city = location.address?.city,
                                       let state = location.address?.state {
                                        Text("\(city), \(state)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
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
            .onChange(of: locationManager.currentQuery) { newQuery in
                query = newQuery
                Task { await searchLocation() }
            }
            .onChange(of: locationManager.errorMessage) { err in
                if let err = err {
                    errorMessage = err
                }
            }
        }
    }

    private func searchLocation() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard isValidQuery(query) else {
                errorMessage = "Please enter at least 2 characters"
                return
            }

            if let location = try await APIService.fetchLocation(query: query) {
                selectedLocation = location
            } else {
                errorMessage = "No matching location found. Try another search."
            }
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
