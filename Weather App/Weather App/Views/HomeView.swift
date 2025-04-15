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
            VStack(spacing: 16) {
                Text("Weather App")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                ZStack {
                    TextField("Enter city or address", text: $query)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)

                    HStack {
                        Spacer()
                        if !query.isEmpty {
                            Button(action: {
                                query = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 40)
                            }
                        }
                    }
                }
                
                HStack {
                    Button("Search") {
                        Task { await searchLocation() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidQuery(query))

                    Button("Use Current Location") {
                        locationManager.requestLocation { locationQuery in
                            if let locationQuery = locationQuery, !locationQuery.contains("denied") {
                                query = locationQuery
                                Task { await searchLocation() }
                            } else {
                                errorMessage = locationQuery
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

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
                errorMessage = "No matching location found."
            }
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

