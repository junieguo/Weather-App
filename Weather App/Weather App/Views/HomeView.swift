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

                Button("Search") {
                    Task {
                        await searchLocation()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValidQuery(query))

                if isLoading {
                    ProgressView()
                        .padding()
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
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
        
        print("Starting search for: '\(query)'")
        
        do {
            guard isValidQuery(query) else {
                errorMessage = "Please enter at least 2 characters"
                return
            }
            
            if let location = try await APIService.fetchLocation(query: query) {
                print("Successfully found location: \(location.displayName)")
                selectedLocation = location
            } else {
                errorMessage = "No matching location found. Please try a different search term."
                print("No locations found for query: '\(query)'")
            }
        } catch URLError.badURL {
            errorMessage = "Invalid search query"
            print("Bad URL error")
        } catch URLError.badServerResponse {
            errorMessage = "Server error. Please try again later."
            print("Server response error")
        } catch {
            errorMessage = "Failed to fetch location. Please check your connection."
            print("Search error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
